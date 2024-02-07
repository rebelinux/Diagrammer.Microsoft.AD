function Get-DiagForest {
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
        Write-Verbose -Message ($translate.connectingDomain -f $($ForestRoot))
        try {
            if ($ForestRoot) {
                # Get Forest Root Node Object
                Get-DiagForestRoot

                if ($Dir -eq 'LR') {
                    $DiagramLabel = $translate.DiagramLabel
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = $translate.DiagramDummyLabel
                }
                $ForestGroups = Get-ADForestInfo
`


                if ($ForestGroups) {
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel ; fontsize = 22; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        # Dummy Node used for subgraph centering
                        Node CHILDDOMAINSTEXT @{Label = $DiagramDummyLabel; fontcolor = '#71797E'; fontsize = 22; shape = 'plain'; fillColor = 'transparent' }
                        if ($Dir -eq 'TB') {
                            Node CDLeft @{Label = 'CDLeft'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node CDLeftt @{Label = 'CDLeftt'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node CDRight @{Label = 'CDRight'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Edge CDLeft, CDLeftt, CHILDDOMAINSTEXT, CDRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank CDLeft, CDLeftt, CHILDDOMAINSTEXT, CDRight
                        }

                        foreach ($ForestGroupOBJ in $ForestGroups) {
                            if ($ForestGroupOBJ.Name -match $ForestRoot -and $ForestGroupOBJ.Childs.Group) {
                                SubGraph ContiguousChilds -Attributes @{Label = $translate.contiguous; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                    Node DummyContiguousChilds @{Label = 'DummyContiguousChilds'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1 -and $ForestGroupOBJ.Childs.Group.Length -le 3) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = $ForestGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            $ForestGroupOBJ.Childs.Group | ForEach-Object { Node $_ @{Label = Get-NodeIcon -Name $_ -IconType "Domain" -Align "Center"; shape = 'plain'; fillColor = 'transparent' } }
                                        }
                                        Edge -From DummyContiguousChilds -To $ForestGroupOBJ.Childs.Group @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    } else {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        $Group = Split-Array -inArray $ForestGroupOBJ.Childs.Group -size 3
                                        $Number = 0
                                        while ($Number -ne $Group.Length) {
                                            SubGraph $SubGraphName -Attributes @{Label = $ForestGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                $Group[$Number] | ForEach-Object {
                                                    Node $_ @{Label = Get-NodeIcon -Name $_ -IconType "Domain" -Align "Center"; shape = 'plain'; fillColor = 'transparent' }
                                                }
                                            }
                                            $Number++
                                        }
                                        Edge -From DummyContiguousChilds -To $Group[0] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start = 0
                                        $LocalRepoNum = 1
                                        while ($LocalRepoNum -ne $Group.Length) {
                                            Edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            $Start++
                                            $LocalRepoNum++
                                        }
                                    }
                                }
                                Edge -From CHILDDOMAINSTEXT -To DummyContiguousChilds @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                            } elseif ($ForestGroupOBJ.Name -notmatch $ForestRoot -and $ForestGroupOBJ.Childs) {
                                SubGraph NonContiguousChilds -Attributes @{Label = $translate.noncontiguous; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                    Node DummyNonContiguousChilds @{Label = 'DummyNonContiguousChilds'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                    $DomainDummyNode = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1 -and $ForestGroupOBJ.Childs.Group.Length -le 3) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = $ForestGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            Node "Dummy$DomainDummyNode" @{Label = "Dummy$DomainDummyNode"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                            $ForestGroupOBJ.Childs.Group | ForEach-Object { Node $_ @{Label = Get-NodeIcon -Name $_ -IconType "Domain" -Align "Center"; shape = 'plain'; fillColor = 'transparent' } }
                                            Edge -From "Dummy$DomainDummyNode" -To $ForestGroupOBJ.Childs.Group @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        }
                                        Edge -From DummyNonContiguousChilds -To "Dummy$DomainDummyNode" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    } elseif ($ForestGroupOBJ.Childs.Group.Length -ge 4) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        $Group = Split-Array -inArray $ForestGroupOBJ.Childs.Group -size 3
                                        $Number = 0
                                        while ($Number -ne $Group.Length) {
                                            SubGraph $SubGraphName -Attributes @{Label = $ForestGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node "Dummy$DomainDummyNode" @{Label = "Dummy$DomainDummyNode"; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                                                $Group[$Number] | ForEach-Object {
                                                    Node $_ @{ Label = Get-NodeIcon -Name $_ -IconType "Domain" -Align "Center"; shape = 'plain'; fillColor = 'transparent' }
                                                }
                                            }
                                            $Number++
                                        }
                                        Edge -From "Dummy$DomainDummyNode" -To $Group[0] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start = 0
                                        $LocalRepoNum = 1
                                        while ($LocalRepoNum -ne $Group.Length) {
                                            Edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                            $Start++
                                            $LocalRepoNum++
                                        }
                                        Edge -From DummyNonContiguousChilds -To "Dummy$DomainDummyNode" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    } else {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = $ForestGroupOBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            Node -Name $ForestGroupOBJ.Name @{ Label = Get-NodeIcon -Name $ForestGroupOBJ.Name -IconType "Domain" -Align "Center"; shape = 'plain'; fillColor = 'transparent' }
                                        }
                                        Edge -From DummyNonContiguousChilds -To $ForestGroupOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }
                                }
                                Edge -From CHILDDOMAINSTEXT -To DummyNonContiguousChilds @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                            } else {
                                Node -Name NoChildDomain @{LAbel = $translate.NoChildDomain; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                                Edge -From CHILDDOMAINSTEXT -To NoChildDomain @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                            }
                        }

                    }
                    Edge -From $ForestRoot -To CHILDDOMAINSTEXT @{minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}