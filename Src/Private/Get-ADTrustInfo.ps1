function Get-ADTrustsInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory trust information.
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
        Write-Verbose -Message ($translate.buildingTrusts -f $($ForestRoot))
        try {

            $TrustDomain = Invoke-Command -Session $TempPssSession { ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships() }
            $TrustForest = Invoke-Command -Session $TempPssSession { [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GetAllTrustRelationships() }


            $Trusts = @()
            $Trusts += $TrustDomain
            $Trusts += $TrustForest

            $TrustsInfo = @()
            if ($Trusts) {
                foreach ($Trust in $Trusts) {
                    $AditionalInfo = @{
                        'Type' = $Trust.TrustType
                        'Direction' = $Trust.TrustDirection
                    }
                    $TempTrustsInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($Trust.TargetName)Trusts" -SpecialChars '\-. '
                        Label = Get-DiaNodeIcon -Name $Trust.TargetName -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalInfo
                        Source = $Trust.SourceName
                        SourceLabel = Get-DiaNodeIcon -Name $Trust.SourceName -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug
                        Target = $Trust.TargetName
                        Type = $Trust.TrustType
                        Direction = $Trust.TrustDirection
                    }
                    $TrustsInfo += $TempTrustsInfo
                }
            }
            return $TrustsInfo
        } catch {
            $_
        }
    }
    end {}
}