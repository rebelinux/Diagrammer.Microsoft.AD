function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.2
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
        Write-Verbose "Generating Forest Diagram"
    }

    process {
        Write-Verbose -Message ($translate.connectingDomain -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $ForestInfo = Get-ADForestInfo

                if ($ForestInfo | Where-Object { $_.ChildDomain -ne $_.RootDomain }) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if (($ForestInfo.ChildDomain | Measure-Object).count -gt 5) {
                                SubGraph ChildDomains -Attributes @{Label = 'Child Domains'; fontsize = 18; penwidth = 1.5; labelloc = 't'; labeljust = 'l'; style = 'dashed,rounded' } {
                                    # Node used for subgraph centering
                                    Node ChildDomainsDummy @{Label = 'ChildDomainsDummy'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                    $Group = Split-array -inArray ($ForestInfo | Sort-Object -Property Name) -size 5
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ChildDomainGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                                Node $_.Name @{Label = $REPOHASHTABLE.Label; shape = "plain"; fillColor = 'transparent' }
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From ChildDomainsDummy -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $ChildDomainNum = 1
                                    while ($ChildDomainNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$ChildDomainNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $ChildDomainNum++
                                    }
                                }
                                $ForestRootDomain = Remove-SpecialChar -String "$($ForestInfo[0].RootDomain)ForestRoot" -SpecialChars '\-. '
                                Node -Name $ForestRootDomain -Attributes @{Label = $ForestInfo[0].RootDomainLabel; shape = "plain"; fillColor = 'transparent' }
                                Edge -From $ForestRootDomain -To ChildDomainsDummy @{minlen = 2 }
                            } else {
                                foreach ($ForestObj in ($ForestInfo | Where-Object { $_.ChildDomain -ne $_.RootDomain })) {
                                    $ForestRootDomain = Remove-SpecialChar -String "$($ForestObj.RootDomain)ForestRoot" -SpecialChars '\-. '
                                    Node -Name $ForestObj.Name -Attributes @{Label = $ForestObj.Label; shape = "plain"; fillColor = 'transparent' }
                                    Node -Name $ForestRootDomain -Attributes @{Label = $ForestObj.RootDomainLabel; shape = "plain"; fillColor = 'transparent' }
                                    Edge -From $ForestRootDomain -To $ForestObj.Name @{minlen = 2 }
                                }
                            }
                        }
                    }
                } else {
                    $ForestRootDomain = Remove-SpecialChar -String "$($ForestInfo.RootDomain)ForestRoot" -SpecialChars '\-. '
                    Node -Name $ForestRootDomain -Attributes @{Label = $ForestInfo.RootDomainLabel; shape = "plain"; fillColor = 'transparent' }
                    Node -Name NoChildDomain @{Label = $translate.NoChildDomain; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }
                    Edge -From $ForestRootDomain -To NoChildDomain @{minlen = 2 }

                }
            }
        } catch {
            $_
        }
    }
    end {}
}