function Get-ADForestInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory forest information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.2
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
                    $AditionalForestInfo = @{
                        'Functional Level' = $ForestObj.ForestMode
                        # 'Direction' = $Trust.TrustDirection
                    }
                    $TempForestInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($ChildDomain)ChildDomain" -SpecialChars '\-. '
                        Label = Get-DiaNodeIcon -Name $ChildDomain -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalInfo
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