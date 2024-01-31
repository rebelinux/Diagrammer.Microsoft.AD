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
                            Node STLeft @{Label = 'STLeft'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node STLeftt @{Label = 'STLeftt'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node STRight @{Label = 'STRight'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Edge STLeft, STLeftt, SitesTEXT, STRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank STLeft, STLeftt, SitesTEXT, STRight
                        }

                        if ($SitesGroups.Length -gt 1) {
                            SubGraph SitesTopology -Attributes @{Label = ' '; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                Node DummySitesText @{Label = 'DummySitesText'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                if ($SitesGroups.Length -ge 1 -and $SitesGroups.Length -le 5) {
                                    foreach ($SiteGroupOBJ in $SitesGroups) {
                                        $SubGraphName = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                        Node "Dummy$($SubGraphName)" @{Label = "Dummy$($SubGraphName)"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                        SubGraph $SubGraphName -Attributes @{Label = $SiteGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            $SubGraphNameDC = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameDC)DC" -Attributes @{Label = "Domain Controllers"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                $SiteGroupOBJ.DomainControllers | ForEach-Object { Node $_ @{Label = $_; fontname = "Segoe Ui" } }
                                                Edge -From "Dummy$SubGraphName" -To $SiteGroupOBJ.DomainControllers @{minlen = 0.05; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }

                                            $SubGraphNameDC = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph "$($SubGraphNameDC)DC" -Attributes @{Label = "Domain Controllers"; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                $SiteGroupOBJ.DomainControllers | ForEach-Object { Node $_ @{Label = $_; fontname = "Segoe Ui" } }
                                                Edge -From "Dummy$SubGraphName" -To $SiteGroupOBJ.DomainControllers @{minlen = 0.05; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            }
                                        }
                                        Edge -From DummySitesText -To "Dummy$($SubGraphName)" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }
                                } else {
                                    # $SubGraphName = Remove-SpecialChar -String $SitesGroups.Name -SpecialChars '\-. '
                                    # $Group = Split-array -inArray $SitesGroups.Name -size 3
                                    # $Number = 0
                                    # while ($Number -ne $Group.Length) {
                                    #     SubGraph $SubGraphName -Attributes @{Label=$SiteGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                    #         $Group[$Number] | ForEach-Object {
                                    #             node $_ @{Label=$_}
                                    #         }
                                    #     }
                                    #     $Number++
                                    # }
                                    # edge -From DummySitesText -To $Group[0] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    # $Start = 0
                                    # $LocalRepoNum = 1
                                    # while ($LocalRepoNum -ne $Group.Length) {
                                    #     edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    #     $Start++
                                    #     $LocalRepoNum++
                                    # }
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