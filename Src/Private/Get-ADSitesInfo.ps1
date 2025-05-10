function Get-ADSitesInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory sites information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.15
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
        Write-Verbose -Message ($translate.buildingSites -f $($ForestRoot))
        try {
            $Sites = Invoke-Command -Session $TempPssSession { [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites | Select-Object Name, @{l = 'SitesLink'; e = { $_.sitelinks } } }

            $SitesInfo = @()
            if ($Sites) {
                foreach ($SitesLink in $Sites) {
                    $TempSitesInfo = [PSCustomObject]@{
                        'Name' = $SitesLink.Name
                        'SiteLink' = & {
                            foreach ($Link in $SitesLink.SitesLink.Name) {
                                $SitesLinkInfo = Invoke-Command -Session $TempPssSession { Get-ADReplicationSiteLink -Identity $using:Link }
                                @{
                                    'Name' = $Link
                                    'Sites' = $SitesLinkInfo.SitesIncluded | ForEach-Object { ConvertTo-ADObjectName -Session $TempPssSession -DN $_ -DC $System }
                                    'AditionalInfo' = [ordered]@{
                                        $translate.siteLinkName = $Link
                                        $translate.siteLinkCost = $SitesLinkInfo.Cost
                                        $translate.siteLinkFrequency = "$($SitesLinkInfo.ReplicationFrequencyInMinutes) $($translate.siteLinkFrequencyMinutes)"
                                    }
                                }
                            }
                        }
                    }
                    $SitesInfo += $TempSitesInfo
                }
            }

            return $SitesInfo
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}