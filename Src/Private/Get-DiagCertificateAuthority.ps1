function Get-DiagCertificateAuthority {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Certificate Authority.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.10
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
        Write-Verbose -Message ($translate.gereratingDiag -f "Certificate Authority")
    }

    process {
        Write-Verbose -Message ($translate.connectingDomain -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $CAInfo = Get-ADCAInfo

                if ($CAInfo) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50 -Fontsize 22 -fontName 'Segoe UI' -fontColor '#565656') ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if ($CAInfo | Where-Object { $_.IsRoot }) {

                                if (($CAInfo | Where-Object { $_.IsRoot }).AditionalInfo.Type -eq 'Standalone CA') {
                                    $CALabel = $translate.caStdRootCA
                                } else {
                                    $CALabel = $translate.caEntRootCA
                                }

                                $CARootNodes = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($CAInfo | Where-Object { $_.IsRoot }).CAName -Align "Center" -iconType "AD_Certificate" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($CAInfo | Where-Object { $_.IsRoot }).AditionalInfo -fontSize 18

                                Node -Name "RootCA" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CARootNodes -Align 'Center' -IconDebug $IconDebug -Label $CALabel -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -IconType "AD_PKI_Logo" -fontSize 22); shape = 'plain'; fillColor = '#F5FBFF'; fontsize = 18; fontname = "Segoe Ui" }
                            }

                            if ($CAInfo | Where-Object { $_.IsRoot -eq $false }) {

                                $CASubordinateNodes = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($CAInfo | Where-Object { $_.IsRoot -eq $false }).CAName -Align "Center" -iconType "AD_Certificate" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($CAInfo | Where-Object { $_.IsRoot -eq $false }).AditionalInfo -fontSize 18

                                Node -Name "SubordinateCA" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CASubordinateNodes -Align 'Center' -IconDebug $IconDebug -Label $translate.caEntSubCA -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -IconType "AD_PKI_Logo" -fontSize 22); shape = 'plain'; fillColor = 'transparent'; fontsize = 18; fontname = "Segoe Ui" }

                            }

                            if ($CARootNodes -and $CASubordinateNodes) {
                                Edge -From RootCA -To SubordinateCA @{minlen = 2 }
                            }
                        }
                    }
                } else {
                    Node -Name NoDomain @{Label = $translate.NoCA; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "5"; height = "3"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}