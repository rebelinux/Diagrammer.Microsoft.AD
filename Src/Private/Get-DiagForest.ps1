function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.8
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

                $ForestGroups = Get-ADForestInfo

                if ($ForestGroups) {
                    SubGraph ForestSubGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestRoot -IconType "ForestRoot" -URLIcon $URLIcon -SubgraphLabel -IconWidth 50 -IconHeight 50) ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style ; color = $SubGraphDebug.color } {
                        SubGraph MainSubGraph -Attributes @{Label = $translate.DiagramLabel ; fontsize = 24; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                            foreach ($ForestGroupOBJ in $ForestGroups) {
                                if ($ForestGroupOBJ.Name -match $ForestRoot -and $ForestGroupOBJ.Childs.Group) {
                                    $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph ContiguousChilds -Attributes @{Label = $translate.contiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                        SubGraph $SubGraphName -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel -URLIcon $URLIcon); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; fontcolor = "black" } {
                                            Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-DiaHTMLTable -ImagesObj $Images -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -ColumnSize 3 -Align 'Center' -FontSize 14 -URLIcon $URLIcon); shape = "plain"; fillColor = 'transparent' }
                                        }
                                    }
                                } elseif ($ForestGroupOBJ.Name -notmatch $ForestRoot -and $ForestGroupOBJ.Childs) {
                                    $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                    SubGraph NonContiguousChilds -Attributes @{Label = $translate.noncontiguous; fontsize = 20; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                                        if (($ForestGroupOBJ.Childs.Group | Measure-Object).Count -ge 1) {
                                            SubGraph $SubGraphName -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel -URLIcon $URLIcon); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name "$($SubGraphName)DomainTable" -Attributes @{Label = (Get-DiaHTMLTable -ImagesObj $Images -Rows $ForestGroupOBJ.Childs.Group -MultiColunms -ColumnSize 3 -Align 'Center' -FontSize 14 -URLIcon $URLIcon); shape = "plain"; fillColor = 'transparent' }
                                            }
                                        } else {
                                            $SubGraphName = Remove-SpecialChar -String $ForestGroupOBJ.Name -SpecialChars '\-. '
                                            SubGraph $SubGraphName -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $ForestGroupOBJ.Name -IconType "AD_Domain" -SubgraphLabel -URLIcon $URLIcon); fontsize = 20; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                Node -Name $ForestGroupOBJ.Name @{ Label = (Get-DiaHTMLTable -ImagesObj $Images -Rows $ForestGroupOBJ.Name -MultiColunms -ColumnSize 3 -Align 'Center' -FontSize 14 -URLIcon $URLIcon); shape = 'plain'; fillColor = 'transparent' }
                                            }
                                        }
                                    }
                                } else {
                                    Node -Name NoChildDomain @{Label = $translate.NoChildDomain; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                                }
                            }

                        }
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}