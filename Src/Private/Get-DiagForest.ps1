function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.1
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
                    SubGraph MainSubGraph -Attributes @{Label=$DiagramLabel ; fontsize=22; penwidth=1.5; labelloc='t'; style='dashed,rounded'; color=$SubGraphDebug.color} {
                        # Dummy Node used for subgraph centering
                        node CHILDDOMAINSTEXT @{Label=$DiagramDummyLabel; fontcolor='#71797E'; fontsize=22; shape='plain'; fillColor='transparent'}
                        if ($Dir -eq 'TB') {
                            node CDLeft @{Label='CDLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node CDLeftt @{Label='CDLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node CDRight @{Label='CDRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            edge CDLeft,CDLeftt,CHILDDOMAINSTEXT,CDRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank CDLeft,CDLeftt,CHILDDOMAINSTEXT,CDRight
                        }

                        foreach ($ForestGroupOBJ in $ForestGroups) {
                            if ($ForestGroupOBJ.Name -match $ForestRoot -and $ForestGroupOBJ.Childs.Group) {
                                SubGraph ContiguousChilds -Attributes @{Label=$translate.contiguous; fontsize=18; penwidth=1.5; labelloc='b'; style='dashed,rounded'} {
                                    node DummyContiguousChilds @{Label='DummyContiguousChilds'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1 -and $ForestGroupOBJ.Childs.Group.Length -le 3) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label=$ForestGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                            $ForestGroupOBJ.Childs.Group | ForEach-Object {node $_ @{Label=$_; fontname="Segoe Ui"}}
                                        }
                                        edge -from DummyContiguousChilds -to $ForestGroupOBJ.Childs.Group @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    } else {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        $Group = Split-array -inArray $ForestGroupOBJ.Childs.Group -size 3
                                        $Number = 0
                                        while ($Number -ne $Group.Length) {
                                            SubGraph $SubGraphName -Attributes @{Label=$ForestGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                                $Group[$Number] | ForEach-Object {
                                                    node $_ @{Label=$_}
                                                }
                                            }
                                            $Number++
                                        }
                                        edge -From DummyContiguousChilds -To $Group[0] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start = 0
                                        $LocalRepoNum = 1
                                        while ($LocalRepoNum -ne $Group.Length) {
                                            edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            $Start++
                                            $LocalRepoNum++
                                        }
                                    }
                                }
                                edge -from CHILDDOMAINSTEXT -to DummyContiguousChilds @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                            }
                            elseif ($ForestGroupOBJ.Name -notmatch $ForestRoot -and $ForestGroupOBJ.Childs) {
                                SubGraph NonContiguousChilds -Attributes @{Label=$translate.noncontiguous; fontsize=18; penwidth=1.5; labelloc='b'; style='dashed,rounded'} {
                                    node DummyNonContiguousChilds @{Label='DummyNonContiguousChilds'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                    $DomainDummyNode = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1 -and $ForestGroupOBJ.Childs.Group.Length -le 3) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label=$ForestGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                            node "Dummy$DomainDummyNode" @{Label="Dummy$DomainDummyNode"; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                            $ForestGroupOBJ.Childs.Group | ForEach-Object {node $_ @{Label=$_; fontname="Segoe Ui"}}
                                            edge -from "Dummy$DomainDummyNode" -to $ForestGroupOBJ.Childs.Group @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        }
                                        edge -from DummyNonContiguousChilds -to "Dummy$DomainDummyNode" @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    } elseif ($ForestGroupOBJ.Childs.Group.Length -ge 4) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        $Group = Split-array -inArray $ForestGroupOBJ.Childs.Group -size 3
                                        $Number = 0
                                        while ($Number -ne $Group.Length) {
                                            SubGraph $SubGraphName -Attributes @{Label=$ForestGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                                node "Dummy$DomainDummyNode" @{Label="Dummy$DomainDummyNode"; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                                $Group[$Number] | ForEach-Object {
                                                    node $_ @{Label=$_}
                                                }
                                            }
                                            $Number++
                                        }
                                        edge -From "Dummy$DomainDummyNode" -To $Group[0] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start = 0
                                        $LocalRepoNum = 1
                                        while ($LocalRepoNum -ne $Group.Length) {
                                            edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            $Start++
                                            $LocalRepoNum++
                                        }
                                        edge -from DummyNonContiguousChilds -to "Dummy$DomainDummyNode" @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    } else {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label=$ForestGroupOBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                            node $ForestGroupOBJ.Name
                                        }
                                        edge -from DummyNonContiguousChilds -to $ForestGroupOBJ.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                }
                                edge -from CHILDDOMAINSTEXT -to DummyNonContiguousChilds @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                            } else {
                                Node -Name NoChildDomain @{LAbel= $translate.NoChildDomain; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0}
                                edge -from CHILDDOMAINSTEXT -to NoChildDomain @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                            }
                        }

                    }
                    edge -from $ForestRoot -to CHILDDOMAINSTEXT @{minlen=3}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}