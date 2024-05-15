function Get-ADSitesInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory sites information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.2.1
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
            $SitesLinks = Invoke-Command -Session $TempPssSession { [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites | Select-Object Name,Subnets,Servers,Domains,@{l = 'Links'; e = { $x = $_.name; $_.sitelinks.Sites | Where-Object name -ne $x } } }

            $SitesInfo = @()
            if ($SitesLinks) {
                foreach ($SitesLink in $SitesLinks) {
                    $TempSitesInfo = [PSCustomObject]@{
                        Name = $SitesLink.Name
                        Label = $SitesLink.Name
                        Sites = $SitesLink.Links
                        AditionalInfo = @{
                            # 'Subnets' = $SitesLink.Subnets
                            # 'Servers' = $SitesLink.Servers
                            'Domain' = $SitesLink.Domains
                        }
                    }
                    $SitesInfo += $TempSitesInfo
                }
            }

            return $SitesInfo
        } catch {
            $_
        }
    }
    end {}
}