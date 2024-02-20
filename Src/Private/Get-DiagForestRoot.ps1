function Get-DiagForestRoot {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest Root.
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
    }

    process {
        Write-Verbose -Message ($translate.connectingForest -f $($ForestRoot))
        try {
            if ($ForestRoot) {
                SubGraph ForestMain -Attributes @{Label = " "; style = "invis"; bgcolor = "gray"; penwidth = 1; color = "blue" } {

                    if ($DiagramVerbosity -eq 2) {
                        $ADVersion = Invoke-Command -Session $TempPssSession { Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select-Object -ExpandProperty objectVersion }
                        If ($ADVersion -eq '88') { $server = 'Windows Server 2019+' }
                        ElseIf ($ADVersion -eq '87') { $server = 'Windows Server 2016' }
                        ElseIf ($ADVersion -eq '69') { $server = 'Windows Server 2012 R2' }
                        ElseIf ($ADVersion -eq '56') { $server = 'Windows Server 2012' }
                        ElseIf ($ADVersion -eq '47') { $server = 'Windows Server 2008 R2' }
                        ElseIf ($ADVersion -eq '44') { $server = 'Windows Server 2008' }
                        ElseIf ($ADVersion -eq '31') { $server = 'Windows Server 2003 R2' }
                        ElseIf ($ADVersion -eq '30') { $server = 'Windows Server 2003' }

                        # Main Forest Root Node
                        $Rows = @(
                            $($translate.funcLevel -f $ADSystem.ForestMode)
                            $($translate.schemaVersion -f $server)
                        )

                        Convert-TableToHTML -Label $translate.forestRootInfo -Name ForestRootInformation -Row $Rows -HeaderColor "#6d8faf" -HeaderFontColor "white" -BorderColor "black" -FontSize 14

                        $ADForestFSMO = $ADSystem | Select-Object DomainNamingMaster, SchemaMaster
                        $ADDomainFSMO = Invoke-Command -Session $TempPssSession { Get-ADDomain $using:ForestRoot | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator }

                        $FSMOObj = @(
                            $translate.infrastructure -f $($ADDomainFSMO.InfrastructureMaster)
                            $translate.rID -f $($ADDomainFSMO.RIDMaster)
                            $translate.pdcEmulator -f $($ADDomainFSMO.PDCEmulator)
                            $translate.domainNaming -f $($ADForestFSMO.DomainNamingMaster)
                            $translate.schema -f $($ADForestFSMO.SchemaMaster)
                        )

                        Convert-TableToHTML -Label $translate.fsmoRoles -Name FSMORoles -Row $FSMOObj -HeaderColor "#6d8faf" -HeaderFontColor "white" -BorderColor "black" -FontSize 14

                        Node $ForestRoot @{Label = Get-NodeIcon -ImagesObj $Images -Name $ForestRoot -IconType "ForestRoot" -Align "Center" -URLIcon $URLIcon; shape = 'plain'; fillColor = 'transparent'; fontsize = 14 }

                        # Edges between nodes to ensure that Forest name is in the center of the cluster
                        Edge ForestRootInformation, $ForestRoot, FSMORoles @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank $ForestRoot, ForestRootInformation, FSMORoles
                    } else {
                        # Dummy Nodes used for subgraph centering
                        Node Left @{Label = 'Left'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                        Node Leftt @{Label = 'Leftt'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }
                        Node Right @{Label = 'Right'; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = 'plain' }

                        Node $ForestRoot @{Label = Get-NodeIcon -ImagesObj $Images -Name $ForestRoot -IconType "ForestRoot" -Align "Center" -URLIcon $URLIcon; shape = 'plain'; fillColor = 'transparent'; fontsize = 14 }

                        # Edges between nodes to ensure that Forest name is in the center of the cluster
                        Edge Left, Leftt, $ForestRoot, Right @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank Left, Leftt, $ForestRoot, Right
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}