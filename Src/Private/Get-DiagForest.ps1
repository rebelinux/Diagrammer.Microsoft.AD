function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.7
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
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        # Dummy Node used for subgraph centering
                        Node CHILDDOMAINSTEXT @{Label = $DiagramDummyLabel; fontcolor = '#71797E'; fontsize = 24; shape = 'plain'; fillColor = 'transparent' }
                        if ($Dir -eq 'TB') {
                            Node CDLeft @{Label = 'CDLeft'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node CDLeftt @{Label = 'CDLeftt'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Node CDRight @{Label = 'CDRight'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                            Edge CDLeft, CDLeftt, CHILDDOMAINSTEXT, CDRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank CDLeft, CDLeftt, CHILDDOMAINSTEXT, CDRight
                        }

                        foreach ($ForestGroupOBJ in $ForestGroups) {
                            if ($ForestGroupOBJ.Name -match $ForestRoot -and $ForestGroupOBJ.Childs.Group) {
                                SubGraph ContiguousChilds -Attributes @{Label = $translate.contiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                    $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; fontcolor = "black" } {
                                        Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = "plain"; fillColor = 'transparent' }
                                    }
                                    Edge -From CHILDDOMAINSTEXT -To "$($SubGraphName)DomainTable" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                }
                            } elseif ($ForestGroupOBJ.Name -notmatch $ForestRoot -and $ForestGroupOBJ.Childs) {
                                SubGraph NonContiguousChilds -Attributes @{Label = $translate.noncontiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                    if ($ForestGroupOBJ.Childs.Group.Length -ge 1) {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = "plain"; fillColor = 'transparent' }
                                        }
                                        Edge -From CHILDDOMAINSTEXT -To "$($SubGraphName)DomainTable" @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    } else {
                                        $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                        SubGraph $SubGraphName -Attributes @{Label = (Get-HTMLLabel -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                            Node -Name $ForestGroupOBJ.Name @{ Label = (Get-HtmlTable -Rows $ForestGroupOBJ.Name -MultiColunms -Columnsize 3 -Align 'Center' -fontSize 14); shape = 'plain'; fillColor = 'transparent' }
                                        }
                                        Edge -From CHILDDOMAINSTEXT -To $ForestGroupOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }
                                }
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