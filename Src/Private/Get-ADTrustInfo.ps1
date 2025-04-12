function Get-ADTrustsInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory trust information.
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
        Write-Verbose -Message ($translate.buildingTrusts -f $($ForestRoot))
        try {
            $TrustDirectionID = @{
                1 = 'InBound'
                2 = 'OutBound'
                3 = 'BiDirectional'
            }

            $TrustTypeID = @{
                'Downlevel' = 'Downlevel (NT domain)'
                'Uplevel' = 'Uplevel (Active Directory)'
                'MIT' = 'MIT (Kerberos Realm Trust)'
                'DCE' = 'DCE'
            }

            $TrustAttributesID = @{
                0 = 'External (0)'
                1 = 'Non-Transitive (1)'
                2 = 'Uplevel Only (2)'
                4 = 'External (4)'
                8 = 'Forest (8)'
                10 = 'Cross Organization (10)'
                16 = 'Cross-Organizational (16)'
                20 = 'Forest (20)'
                40 = 'External (40)'
                32 = 'ParentChild (32)'
                64 = 'Inter-Forest (64)'
                80 = 'Uses RC4 Encryption (80)'
                200 = 'Cross Organization (200)'
                400 = 'PIM Trust (400)'
                800 = 'Cross Organization (800)'
            }

            $Trusts = Invoke-Command -Session $TempPssSession { Get-ADTrust -Filter * -Properties CanonicalName, Target, TrustDirection, TrustAttributes, TrustType, SelectiveAuthentication } -ErrorAction Stop

            $TrustsInfo = @()
            if ($Trusts) {
                foreach ($Trust in $Trusts) {
                    $AditionalInfo = [PSCustomObject] [ordered]@{
                        $translate.TrustDirection = $TrustDirectionID[[int]$Trust.TrustDirection]
                        $translate.TrustType = $TrustTypeID[[string]$Trust.TrustType]
                        $translate.TrustAttributes = $TrustAttributesID[[int]$Trust.TrustAttributes]
                        $translate.AuthenticationLevel = Switch ($Trust.SelectiveAuthentication) {
                            $true { 'Selective' }
                            $false { 'DomainWide' }
                            default { '--' }
                        }
                    }
                    $TempTrustsInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($Trust.Target)Trusts" -SpecialChars '\-. '
                        Label = Get-DiaNodeIcon -Name $Trust.Target -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -RowsOrdered $AditionalInfo
                        Source = $Trust.CanonicalName.split('/')[0]
                        SourceLabel = Get-DiaNodeIcon -Name $Trust.CanonicalName.split('/')[0] -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug
                        Direction = $TrustDirectionID[[int]$Trust.TrustDirection]
                    }
                    $TrustsInfo += $TempTrustsInfo
                }
            }
            return $TrustsInfo
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}