function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.17
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    param
    (

    )

    begin {
        Write-Verbose ($translate.gereratingDiagram -f "Forest")
    }

    process {
        Write-Verbose -Message ($translate.connectingDomain -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $ForestInfo = Get-ADForestInfo

                if ($ForestInfo) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Add-DiaHtmlLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50 -Fontsize 22 -fontName 'Segoe UI' -fontColor $Fontcolor -FontBold) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if ($ForestInfo.ChildDomain ) {

                                $ForestRootDomain = Remove-SpecialChar -String "$($ForestInfo[0].RootDomain)ChildDomain" -SpecialChars '\-. '
                                Node -Name $ForestRootDomain -Attributes @{Label = ($ForestInfo[0]).RootDomainLabel; shape = "plain"; fillColor = 'transparent' }

                                foreach ($ForestObj in $ForestInfo) {
                                    $ParentDomain = Remove-SpecialChar -String "$($ForestObj.ParentDomain)" -SpecialChars '\-. '
                                    Node -Name $ForestObj.Name -Attributes @{Label = $ForestObj.Label; shape = "plain"; fillColor = 'transparent' }
                                    Edge -From $ParentDomain -To $ForestObj.Name @{minlen = 2 }
                                }

                            } else {

                                Node -Name $ForestInfo.Name -Attributes @{Label = $ForestInfo.Label; shape = "plain"; fillColor = 'transparent' }

                                Node -Name NoDomain @{Label = $translate.fNoChildDomains; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }

                                Edge -From $ForestInfo.Name  -To NoDomain @{minlen = 2 }

                            }
                        }
                    }
                } else {
                    Node -Name NoDomain @{Label = $translate.fNoChildDomains; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "15"; height = "13"; fillColor = 'transparent'; penwidth = 1.5; style = 'dashed'; color = 'gray' }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}