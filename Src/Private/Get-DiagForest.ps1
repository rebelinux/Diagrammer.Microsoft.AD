function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.8
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

                if ($ForestInfo) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if (($ForestInfo.ChildDomain | Measure-Object).count -gt 5) {

                                $ChildDomainsNodes = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ForestInfo | ForEach-Object { $_.ChildDomainLabel }) -Align "Center" -iconType "AD_Domain" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ForestInfo.AditionalInfo )

                                Node -Name "ChildDomains" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildDomainsNodes -Align 'Center' -IconDebug $IconDebug -Label 'Child Domains' -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 18; fontname = "Segoe Ui" }

                                $ForestRootDomain = Remove-SpecialChar -String "$($ForestInfo[0].RootDomain)ForestRoot" -SpecialChars '\-. '
                                Node -Name $ForestRootDomain -Attributes @{Label = ($ForestInfo | Where-Object {$_.IsForest -eq $True}).RootDomainLabel; shape = "plain"; fillColor = 'transparent' }
                                Edge -From $ForestRootDomain -To ChildDomains @{minlen = 2 }
                            } else {
                                $ForestRootDomain = Remove-SpecialChar -String "$($ForestObj.RootDomain)ForestRoot" -SpecialChars '\-. '
                                Node -Name $ForestRootDomain -Attributes @{Label = ($ForestInfo | Where-Object {$_.IsForest -eq $True}).RootDomainLabel; shape = "plain"; fillColor = 'transparent' }
                                foreach ($ForestObj in $ForestInfo) {
                                    Node -Name $ForestObj.Name -Attributes @{Label = $ForestObj.Label; shape = "plain"; fillColor = 'transparent' }
                                    Edge -From $ForestRootDomain -To $ForestObj.Name @{minlen = 2 }
                                }
                            }
                        }
                    }
                } else {
                    Node -Name NoDomain @{Label = "No Forest Data"; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}