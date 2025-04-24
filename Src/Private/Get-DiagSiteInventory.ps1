function Get-DiagSiteInventory {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Sites Inventory.
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
        Write-Verbose ($translate.gereratingDiag -f "Sites Inventory")
    }

    process {
        Write-Verbose -Message ($translate.connectingSites -f $($ForestRoot))
        try {
            if ($ForestRoot) {

                $SitesGroups = Get-ADSitesInventoryInfo

                if ($SitesGroups) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -IconDebug $IconDebug -SubgraphLabel -IconWidth 50 -IconHeight 50 -Fontsize 22 -fontName 'Segoe UI' -fontColor $Fontcolor) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = ' ' ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                            if (($SitesGroups | Measure-Object).Count -ge 1) {
                                $ChildSiteSubgraphArray = @()
                                foreach ($SiteGroupOBJ in $SitesGroups) {
                                    $SubGraphName = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '

                                    if ($SiteGroupOBJ.DomainControllers.DCsArray) {
                                        $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '

                                        $ChildDCsNodes = Get-DiaHTMLTable -ImagesObj $Images -Rows $SiteGroupOBJ.DomainControllers.DCsArray -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -TableStyle "dashed,rounded" -NoFontBold -FontSize 18

                                        $ChildDCsNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildDCsNodes -Align 'Center' -IconDebug $IconDebug -Label $translate.DomainControllers -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -IconType "AD_DC" -fontSize 18

                                    } else {
                                        $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '

                                        $ChildDCsNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $translate.NoSiteDC -Align 'Center' -IconDebug $IconDebug -Label $translate.DomainControllers -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -IconType "AD_DC" -fontSize 22
                                    }

                                    if ($SiteGroupOBJ.Subnets.SubnetArray) {
                                        $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '

                                        $ChildSubnetsNodes = Get-DiaHTMLTable -ImagesObj $Images -Rows $SiteGroupOBJ.Subnets.SubnetArray -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -TableStyle "dashed,rounded" -NoFontBold -FontSize 18

                                        $ChildSubnetsNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildSubnetsNodes -Align 'Center' -IconDebug $IconDebug -Label $translate.Subnets -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -IconType "AD_Site_Subnet" -fontSize 22
                                    } else {
                                        $SubGraphNameSN = Remove-SpecialChar -String $SiteGroupOBJ.Name -SpecialChars '\-. '

                                        $ChildSubnetsNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $translate.NoSiteSubnet -Align 'Center' -IconDebug $IconDebug -Label $translate.Subnets -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -IconType "AD_Site_Subnet" -fontSize 22
                                    }

                                    $ChildSiteSubgraph = @()

                                    $ChildSiteSubgraph += $ChildDCsNodesSubgraph, $ChildSubnetsNodesSubgraph

                                    $ChildSiteSubgraphArray += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildSiteSubgraph -Align 'Center' -IconType "AD_Site" -IconDebug $IconDebug -Label $SiteGroupOBJ.Name -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -fontSize 22
                                }

                                Node -Name "SitesTopology" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ChildSiteSubgraphArray -Align 'Center' -IconDebug $IconDebug -Label $translate.Sites -LabelPos "top" -TableStyle "dashed,rounded" -TableBorder "1" -columnSize 3 -TableBorderColor "gray" -fontColor $Fontcolor -fontSize 22); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                            } else {
                                Node -Name NoSites -Attributes @{Label = $translate.NoSites; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                            }
                        }
                    }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}