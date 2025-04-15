function Get-ADForestInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory forest information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.11
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

            # $ChildDomains = @("pharmax.local", "acad.pharmax.local", "hr.pharmax.local", "fin.pharmax.local", "it.pharmax.local", "admin.pharmax.local")
            # $ChildDomains = @("pharmax.local")

            $ForestInfo = @()
            if ($ChildDomains) {
                foreach ($ChildDomain in $ChildDomains | sort-object) {
                    $ChildDomainsInfo = try {
                        Invoke-Command -Session $TempPssSession { Get-ADDomain -Identity $using:ChildDomain }
                    } catch {
                        Out-Null
                    }

                    $FuncionalLevel = @{
                        Windows2012R2Domain = '2012 R2 (Domain)'
                        Windows2012R2Forest = '2012 R2 (Forest)'
                        Windows2016Domain = '2016 (Domain)'
                        Windows2016Forest = '2016 (Forest)'
                        Windows2025Domain = '2025 (Domain)'
                        Windows2025Forest = '2025 (Forest)'
                    }

                    $AditionalForestInfo = [PSCustomObject] [ordered] @{
                        $translate.fDomainNaming = $ForestObj.DomainNamingMaster.ToString().ToUpper().Split(".")[0]
                        $translate.fSchema = $ForestObj.SchemaMaster.ToString().ToUpper().Split(".")[0]
                        $translate.fFuncLevel = $FuncionalLevel[$ForestObj.ForestMode]
                    }

                    $AditionalDomainInfo = [PSCustomObject] [ordered] @{
                        $translate.fInfrastructure = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.InfrastructureMaster)) {
                            $true { 'Unknown' }
                            $false { $ChildDomainsInfo.InfrastructureMaster.ToString().ToUpper().Split(".")[0] }
                            default { '--' }
                        }
                        $translate.fPDC = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.PDCEmulator)) {
                            $true { 'Unknown' }
                            $false { $ChildDomainsInfo.PDCEmulator.ToString().ToUpper().Split(".")[0] }
                            default { '--' }
                        }
                        $translate.fRID = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.RIDMaster)) {
                            $true { 'Unknown' }
                            $false { $ChildDomainsInfo.RIDMaster.ToString().ToUpper().Split(".")[0] }
                            default { '--' }
                        }
                        $translate.fFuncLevel = Switch ([string]::IsNullOrEmpty($ChildDomainsInfo.DomainMode)) {
                            $true { 'Unknown' }
                            $false { $FuncionalLevel[$ChildDomainsInfo.DomainMode] }
                            default { '--' }
                        }
                    }

                    if ($ChildDomain -eq $ForestObj.Name) {
                        $IsForest = $true

                    } else {
                        $IsForest = $false
                    }

                    $TempForestInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($ChildDomain)ChildDomain" -SpecialChars '\-. '
                        ChildDomainLabel = $ChildDomain
                        Label = Get-DiaNodeIcon -Name $ChildDomain -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -AditionalInfo $AditionalDomainInfo -FontSize 18
                        RootDomain = $ForestObj.RootDomain
                        RootDomainLabel = Get-DiaNodeIcon -Name $ForestObj.RootDomain -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -AditionalInfo $AditionalForestInfo -FontSize 18
                        ChildDomain = $ChildDomain
                        AditionalInfo = $AditionalDomainInfo
                        IsForest = $IsForest
                    }
                    $ForestInfo += $TempForestInfo
                }
            }
            return $ForestInfo
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}