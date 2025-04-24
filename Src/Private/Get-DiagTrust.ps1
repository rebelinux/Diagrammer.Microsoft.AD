function Get-DiagTrust {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Trusts.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.14
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
        Write-Verbose $translate.genDiagTrust
    }

    process {
        Write-Verbose -Message ($translate.connectingTrusts -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $TrustsInfo = Get-ADTrustsInfo

                if ($TrustsInfo) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50 -Fontsize 22 -fontName 'Segoe UI' -fontColor $Fontcolor) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if (($TrustsInfo.Name | Measure-Object).count -gt 3) {

                                $ChildDomainsNodes = $TrustsInfo.Label

                                Node -Name "TrustDestinations" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildDomainsNodes -Align 'Center' -IconDebug $IconDebug -Label $translate.TrustRelationships -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -fontSize 22 -fontName 'Segoe UI' -TableBorderColor $Edgecolor -fontColor $Fontcolor); shape = 'plain'; fillColor = 'transparent'; fontsize = 18; fontname = "Segoe Ui" }

                                $ForestRootDomain = Remove-SpecialChar -String "$($TrustsInfo.Source[0])ForestRoot" -SpecialChars '\-. '
                                Node -Name $ForestRootDomain -Attributes @{Label = $TrustsInfo.SourceLabel[0]; shape = "plain"; fillColor = 'transparent' }
                                Edge -From $ForestRootDomain -To TrustDestinations @{minlen = 2 }
                            } else {
                                foreach ($TrustsObj in $TrustsInfo) {
                                    $SourceDomain = Remove-SpecialChar -String "$($TrustsObj.Source)Trusts" -SpecialChars '\-. '
                                    Node -Name $TrustsObj.Name -Attributes @{Label = $TrustsObj.Label; shape = "plain"; fillColor = 'transparent' }
                                    Node -Name $SourceDomain -Attributes @{Label = $TrustsObj.SourceLabel; shape = "plain"; fillColor = 'transparent' }
                                    if ($TrustsObj.Direction -eq 'Bidirectional') {
                                        Edge -From $SourceDomain -To $TrustsObj.Name @{minlen = 2; arrowtail = 'normal'; arrowhead = 'normal' }
                                    } elseif ($TrustsObj.Direction -eq 'Outbound') {
                                        Edge -From $SourceDomain -To $TrustsObj.Name @{minlen = 2; arrowtail = 'dot'; arrowhead = 'normal' }
                                    } elseif ($TrustsObj.Direction -eq 'Inbound') {
                                        Edge -From $SourceDomain -To $TrustsObj.Name @{minlen = 2; arrowtail = 'normal'; arrowhead = 'dot' }
                                    } else {
                                        Edge -From $SourceDomain -To $TrustsObj.Name @{minlen = 2 }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Node -Name NoTrusts @{Label = $translate.NoTrusts; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}