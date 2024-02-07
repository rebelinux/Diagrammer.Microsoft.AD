function Get-DiagSite {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.6
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param
    (

    )

    begin {
    }

    process {
        Write-Verbose -Message ($translate.connectingSites -f $($ForestRoot))
        try {
            if ($ForestRoot) {
                # Get Forest Root Node Object
                Get-DiagForestRoot

                if ($Dir -eq 'LR') {
                    $DiagramLabel = $translate.SitesDiagramLabel
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = $translate.SitesDiagramDummyLabel
                }
                $SitesGroups = Get-ADSitesInfo

                if ($SitesGroups) {
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        # Dummy Node used for subgraph centering
                        Node -Name SitesTEXT -Attributes @{Label = $DiagramDummyLabel; fontcolor = '#71797E'; fontsize = 22; shape = 'plain'; fillColor = 'transparent' }
                        if ($Dir -eq 'TB') {
                            Node -Name STLeft -Attributes @{Label = 'STLeft'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node -Name STLeftt -Attributes @{Label = 'STLeftt'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node -Name STRight -Attributes @{Label = 'STRight'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Edge -Name STLeft, STLeftt, SitesTEXT, STRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank STLeft, STLeftt, SitesTEXT, STRight
                        }

                        if ($SitesGroups.Length -gt 1) {
                            SubGraph SitesTopology -Attributes @{Label = ' '; fontsize = 22; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                foreach ($SiteGroupOBJ in $SitesGroups) {
                                    $SubGraphName = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $SiteGroupOBJ.Name -IconType "AD_Site" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                        if ($SiteGroupOBJ.DomainControllers.DCsArray) {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = (Get-HTMLLabel -Label "Domain Controllers" -IconType "AD_DC" -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name $SiteGroupOBJ.DomainControllers.Name -Attributes @{Label = $SiteGroupOBJ.DomainControllers.Label; shape = "plain"; fillColor = 'transparent'}
                                            }

                                            # MultiIcon
                                            # $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            # SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = "Domain Controllers"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            #     $Group = @()
                                            #     $SiteGroupOBJ.DomainControllers.Label | ForEach-Object {
                                            #         Node -Name "$($SiteGroupOBJ.DomainControllers.Name)$($_.Group)" @{Label = $_.Label; shape = "plain"; fillColor = 'transparent' }
                                            #         $Group += "$($SiteGroupOBJ.DomainControllers.Name)$($_.Group)"
                                            #     }
                                            #     Edge $Group @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            # }
                                        } else {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = (Get-HTMLLabel -Label "Domain Controllers" -IconType "AD_DC" -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,
                                            rounded' } {
                                                Node -Name "Dummy$($SubGraphName)NoSiteDC" -Attributes @{Label = $translate.NoSiteDC; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                            }
                                        }

                                        if ($SiteGroupOBJ.Subnets.SubnetArray) {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = (Get-HTMLLabel -Label "Subnets" -IconType "AD_Site_Subnet" -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name $SiteGroupOBJ.Subnets.Name -Attributes @{Label = $SiteGroupOBJ.Subnets.Label; shape = "plain"; fillColor = 'transparent' }
                                            }
                                        } else {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = (Get-HTMLLabel -Label "Subnets" -IconType "AD_Site_Subnet" -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name "Dummy$($SubGraphName)NoSiteSN" -Attributes @{Label = $translate.NoSiteSubnet; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                            }
                                        }
                                    }
                                    Edge -From SitesTEXT -To $($SubGraphName) @{minlen = 2; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                }
                            }
                        } else {
                            Node -Name NoSites -Attributes @{LAbel = $translate.NoSites; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                            Edge -From SitesTEXT -To NoSites @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }

                    }
                    Edge -From $ForestRoot -To SitesTEXT @{minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}