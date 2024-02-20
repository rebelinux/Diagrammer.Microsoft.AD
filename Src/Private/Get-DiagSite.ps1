function Get-DiagSite {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.8
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
        Write-Verbose "Generating Site Diagram"
    }

    process {
        Write-Verbose -Message ($translate.connectingSites -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $SitesGroups = Get-ADSitesInfo

                if ($SitesGroups) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -URLIcon $URLIcon -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            SubGraph SitesTopology -Attributes @{Label = 'Sites'; fontsize = 22; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                if (($SitesGroups | Measure-Object).Count -ge 1) {
                                    foreach ($SiteGroupOBJ in $SitesGroups) {
                                        $SubGraphName = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label $SiteGroupOBJ.Name -IconType "AD_Site" -SubgraphLabel -URLIcon $URLIcon); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            if ($SiteGroupOBJ.DomainControllers.DCsArray) {
                                                $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                                SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label "Domain Controllers" -IconType "AD_DC" -SubgraphLabel -URLIcon $URLIcon); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                    Node -Name $SiteGroupOBJ.DomainControllers.Name -Attributes @{Label = $SiteGroupOBJ.DomainControllers.Label; shape = "plain"; fillColor = 'transparent' }
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
                                                SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label "Domain Controllers" -IconType "AD_DC" -SubgraphLabel -URLIcon $URLIcon); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,
                                                rounded'
                                                } {
                                                    Node -Name "Dummy$($SubGraphName)NoSiteDC" -Attributes @{Label = $translate.NoSiteDC; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                                }
                                            }

                                            if ($SiteGroupOBJ.Subnets.SubnetArray) {
                                                $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                                SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label "Subnets" -IconType "AD_Site_Subnet" -SubgraphLabel -URLIcon $URLIcon); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                    Node -Name $SiteGroupOBJ.Subnets.Name -Attributes @{Label = $SiteGroupOBJ.Subnets.Label; shape = "plain"; fillColor = 'transparent' }
                                                }
                                            } else {
                                                $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                                SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = (Get-HTMLLabel -ImagesObj $Images -Label "Subnets" -IconType "AD_Site_Subnet" -SubgraphLabel -URLIcon $URLIcon); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                    Node -Name "Dummy$($SubGraphName)NoSiteSN" -Attributes @{Label = $translate.NoSiteSubnet; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Node -Name NoSites -Attributes @{LAbel = $translate.NoSites; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}