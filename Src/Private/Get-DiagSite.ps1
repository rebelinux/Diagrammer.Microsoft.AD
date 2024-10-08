function Get-DiagSite {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.4
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
        Write-Verbose "Generating Site Diagram"
    }

    process {
        Write-Verbose -Message ($translate.connectingSites -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $SitesInfo = Get-ADSitesInfo

                if ($SitesInfo) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if ($SitesInfo.Site) {
                                foreach ($SitesObj in $SitesInfo) {
                                    $Site = Remove-SpecialChar -String "$($SitesObj.Name)" -SpecialChars '\-. '
                                    Node -Name $Site -Attributes @{Label = $SitesObj.Name; penwidth = 1; width = 2; height = .5}
                                    foreach ($Link in $SitesObj.SiteLink) {
                                        $AditionalInfoObj = [ordered]@{
                                            1 = "Frequency = $($Link.AditionalInfo.Frequency) Cost = $($Link.AditionalInfo.Cost)"
                                        }
                                        $SiteLink = Remove-SpecialChar -String $Link.Name -SpecialChars '\-. '
                                        Node -Name $SiteLink -Attributes @{Label = (Get-DiaNodeIcon -Name "SiteLink: $($Link.Name)" -IconType "NoIcon" -Align "Center" -IconDebug $IconDebug -Rows $AditionalInfoObj -FontSize 10 -NoFontBold); shape = "plain"; fillColor = 'transparent'}
                                        Edge -From $Site -To $SiteLink @{minlen = 2; arrowtail = 'none'; arrowhead = 'none'}
                                        foreach ($SiteLinkSite in $Link.Sites) {
                                            $SiteIncluded = Remove-SpecialChar -String $SiteLinkSite -SpecialChars '\-. '
                                            Node -Name $SiteIncluded -Attributes @{Label = $SiteLinkSite; penwidth = 1; width = 2; height = .5}
                                            Edge -From $SiteLink -To $SiteIncluded @{minlen = 2; arrowtail = 'none'; arrowhead = 'normal'}

                                        }
                                    }
                                }
                            } else {
                                $Site = Remove-SpecialChar -String "$($SitesInfo.Name)" -SpecialChars '\-. '
                                Node -Name $Site -Attributes @{Label = $SitesInfo.Name; penwidth = 1; width = 2; height = .5 }
                            }
                        }
                    }
                } else {
                    Node -Name NoSites -Attributes @{Label = $translate.NoSites; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}
