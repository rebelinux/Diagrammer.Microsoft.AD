function Get-ADSitesInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory sites information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.6
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
        Write-Verbose -Message ($translate.connectingSites -f $($ForestRoot))
        try {
            $Sites = Invoke-Command -Session $TempPssSession { Get-ADReplicationSite -Filter * -Properties * }

            $SitesInfo = @()
            if ($Sites) {
                foreach ($Site in $Sites) {

                    $SubnetArray = @()
                    $Subnets = $Site.Subnets
                    foreach ($Object in $Subnets) {
                        $SubnetName = Invoke-Command -Session $TempPssSession { Get-ADReplicationSubnet $using:Object }
                        $SubnetArray += $SubnetName.Name
                    }

                    $TempSitesInfo = [PSCustomObject]@{
                        Name = $Site.Name
                        # Label = Get-NodeIcon -Name "$($Sobr.Name)" -Type "VBR_SOBR" -Align "Center" -Rows $SobrRows
                        Label = $Site.Name
                        Subnets = & {
                            $SubnetArray = @()
                            $Subnets = $Site.Subnets
                            foreach ($Object in $Subnets) {
                                $SubnetName = Invoke-Command -Session $TempPssSession { Get-ADReplicationSubnet $using:Object }
                                $SubnetArray += $SubnetName.Name
                            }

                            return $SubnetArray
                        }
                        DomainControllers = & {
                            $ServerArray = @()
                            $Servers = try { Get-ADObjectSearch -DN "CN=Servers,$($Site.DistinguishedName)" -Filter { objectClass -eq "Server" } -Properties "DNSHostName" -SelectPrty 'DNSHostName', 'Name' -Session $TempPssSession } catch { Out-Null }
                            foreach ($Object in $Servers) {
                                $ServerArray += $Object.Name
                            }

                            return $ServerArray
                        }
                        SitesObj = $Site
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