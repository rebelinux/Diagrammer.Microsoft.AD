function Get-ADForestInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory forest information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.3
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param()

    begin {
    }

    process {
        Write-Verbose -Message ($translate.connectingForest -f $($ForestRoot))
        try {
            $ForestObj = $ADSystem
            $ChildDomains = $ADSystem.Domains

            $ForestInfo = @()
            if ($ChildDomains) {
                foreach ($ChildDomain in $ChildDomains) {
                    $ChildDomainsInfo = try {
                        Invoke-Command -Session $TempPssSession { Get-ADDomain -Identity $using:ChildDomain }
                    } catch {
                        Out-Null
                    }

                    $AditionalForestInfo = [ordered] @{
                        'Domain Naming' = $ForestObj.DomainNamingMaster.ToString().ToUpper().Split(".")[0]
                        'Schema' = $ForestObj.SchemaMaster.ToString().ToUpper().Split(".")[0]
                        'Mode' = $ForestObj.ForestMode
                    }
                    $AditionalDomainInfo = [ordered] @{
                        'Infrastructure' = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.InfrastructureMaster)) {
                            $true {'Unknown'}
                            $false {$ChildDomainsInfo.InfrastructureMaster.ToString().ToUpper().Split(".")[0]}
                            default {'Unknown'}
                        }
                        'PDC Emulator' = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.PDCEmulator)) {
                            $true {'Unknown'}
                            $false {$ChildDomainsInfo.PDCEmulator.ToString().ToUpper().Split(".")[0]}
                            default {'Unknown'}
                        }
                        'RID' = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.RIDMaster)) {
                            $true {'Unknown'}
                            $false {$ChildDomainsInfo.RIDMaster.ToString().ToUpper().Split(".")[0]}
                            default {'Unknown'}
                        }
                        'Mode' = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.DomainMode)) {
                            $true {'Unknown'}
                            $false {$ChildDomainsInfo.DomainMode}
                            default {'Unknown'}
                        }
                    }

                    $TempForestInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($ChildDomain)ChildDomain" -SpecialChars '\-. '
                        Label = Get-DiaNodeIcon -Name $ChildDomain -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalDomainInfo
                        RootDomain = $ForestObj.RootDomain
                        RootDomainLabel = Get-DiaNodeIcon -Name $ForestObj.RootDomain -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalForestInfo
                        ChildDomain = $ChildDomain
                    }
                    $ForestInfo += $TempForestInfo
                }
            }
            return $ForestInfo
        } catch {
            $_
        }
    }
    end {}
}