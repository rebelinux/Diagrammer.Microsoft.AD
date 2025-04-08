function Get-ADTrustsInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory trust information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.10
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

            $Trusts = @()
            $Trusts += Invoke-Command -Session $TempPssSession { ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships() }
            $Trusts += Invoke-Command -Session $TempPssSession { [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GetAllTrustRelationships() }

            $TrustsInfo = @()
            if ($Trusts) {
                foreach ($Trust in $Trusts) {
                    $AditionalInfo = [PSCustomObject][ordered]@{
                        $translate.TrustDirection = $Trust.TrustDirection
                        $translate.TrustType = $Trust.TrustType
                    }
                    $TempTrustsInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($Trust.TargetName)Trusts" -SpecialChars '\-. '
                        Label = Get-DiaNodeIcon -Name $Trust.TargetName -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -RowsOrdered $AditionalInfo
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
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}