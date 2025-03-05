function Get-DiagTrust {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Trusts.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.9
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
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50 -Fontsize 22 -fontName 'Segoe UI' -fontColor '#565656') ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            foreach ($TrustsObj in $TrustsInfo) {
                                $SourceDomain = Remove-SpecialChar -String "$($TrustsObj.SourceName)Trusts" -SpecialChars '\-. '
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
                } else {
                    Node -Name NoTrusts -Attributes @{Label = $translate.NoTrusts; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}