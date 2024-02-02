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
                    $DiagramLabel = $translate.SiteDiagramLabel
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = $translate.SitesDiagramDummyLabel
                }
                $SitesGroups = Get-ADSitesInfo
`


                if ($SitesGroups) {
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel ; fontsize = 22; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        # Dummy Node used for subgraph centering
                        Node SitesTEXT @{Label = $DiagramDummyLabel; fontcolor = '#71797E'; fontsize = 22; shape = 'plain'; fillColor = 'transparent' }
                        if ($Dir -eq 'TB') {
                            Node STLeft @{Label = 'STLeft'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node STLeftt @{Label = 'STLeftt'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node STRight @{Label = 'STRight'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Edge STLeft, STLeftt, SitesTEXT, STRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank STLeft, STLeftt, SitesTEXT, STRight
                        }

                        if ($SitesGroups.Length -gt 1) {
                            SubGraph SitesTopology -Attributes @{Label = ' '; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                Node DummySitesText @{Label = 'DummySitesText'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                foreach ($SiteGroupOBJ in $SitesGroups) {
                                    $SubGraphName = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                    Node "Dummy$($SubGraphName)" @{Label = "Dummy$($SubGraphName)"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                    SubGraph $SubGraphName -Attributes @{Label = $SiteGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                        if ($SiteGroupOBJ.DomainControllers.count -ge 1) {
                                            $SubGraphNameDC = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            Node "Dummy$($SubGraphName)DC" @{Label = "Dummy$($SubGraphName)DC"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                            SubGraph "$($SubGraphNameDC)DC" -Attributes @{Label = "Domain Controllers"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                $SiteGroupOBJ.DomainControllers | ForEach-Object { Node $_ @{Label = Get-NodeIcon -Name $_ -Type "DomainController" -Align "Center"; shape = 'plain'; fillColor = 'transparent'; } }
                                                Edge -From "Dummy$($SubGraphName)DC" -To $SiteGroupOBJ.DomainControllers @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }
                                            Edge -From "Dummy$($SubGraphName)" -To "Dummy$($SubGraphName)DC" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        } else {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            Node "Dummy$($SubGraphName)DC" @{Label = "Dummy$($SubGraphName)DC"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                            SubGraph "$($SubGraphNameSN)DC" -Attributes @{Label = "Domain Controllers"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name "Dummy$($SubGraphName)NoSiteDC" @{LAbel = $translate.NoSiteDC; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                                Edge -From "Dummy$($SubGraphName)DC" -To "Dummy$($SubGraphName)NoSiteDC" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }
                                            Edge -From "Dummy$($SubGraphName)" -To "Dummy$($SubGraphName)DC" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        }

                                        if ($SiteGroupOBJ.Subnets.count -ge 1 -and $SiteGroupOBJ.Subnets.count -le 2) {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            Node "Dummy$($SubGraphName)SN" @{Label = "Dummy$($SubGraphName)SN"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                            SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = "Subnets"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                $SiteGroupOBJ.Subnets | ForEach-Object { Node $_ @{Label = $_; shape = "plain"; fillColor = 'transparent' } }
                                                Edge -From "Dummy$($SubGraphName)SN" -To $SiteGroupOBJ.Subnets @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }

                                            Edge -From "Dummy$($SubGraphName)" -To "Dummy$($SubGraphName)SN" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                                        } elseif ($SiteGroupOBJ.Subnets.count -gt 2) {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            $Group = Split-Array -inArray $SiteGroupOBJ.Subnets -size 2
                                            $Number = 0
                                            while ($Number -ne $Group.Length) {
                                                SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = "Subnets"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                    Node "Dummy$($SubGraphName)SN" @{Label = "Dummy$($SubGraphName)SN"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                                    $Group[$Number] | ForEach-Object {
                                                        Node $_ @{Label = $_; shape = "plain"; fillColor = 'transparent' }
                                                    }
                                                }
                                                $Number++
                                            }
                                            Edge -From "Dummy$($SubGraphName)SN" -To $Group[0] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            $Start = 0
                                            $LocalRepoNum = 1
                                            while ($LocalRepoNum -ne $Group.Length) {
                                                Edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                                $Start++
                                                $LocalRepoNum++
                                            }
                                            Edge -From "Dummy$($SubGraphName)" -To "Dummy$($SubGraphName)SN" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        } else {
                                            $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            Node "Dummy$($SubGraphName)SN" @{Label = "Dummy$($SubGraphName)SN"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                            SubGraph "$($SubGraphNameSN)SN" -Attributes @{Label = "Subnets"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name "Dummy$($SubGraphName)NoSiteSN" @{LAbel = $translate.NoSiteSubnet; shape = "rectangle"; labelloc = 'c'; fillColor = 'transparent'; penwidth = 0 }
                                                Edge -From "Dummy$($SubGraphName)SN" -To "Dummy$($SubGraphName)NoSiteSN" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }
                                            Edge -From "Dummy$($SubGraphName)" -To "Dummy$($SubGraphName)SN" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        }
                                    }
                                    Edge -From DummySitesText -To "Dummy$($SubGraphName)" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                }
                            }
                            Edge -From SitesTEXT -To DummySitesText @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        } else {
                            Node -Name NoSites @{LAbel = $translate.NoSites; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
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