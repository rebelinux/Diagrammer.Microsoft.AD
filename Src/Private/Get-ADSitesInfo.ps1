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
            $Sites = Invoke-Command -Session $TempPssSession { Get-ADReplicationSite -Filter * -Properties * }

            $SitesInfo = @()
            if ($Sites) {
                foreach ($Site in $Sites) {
                    # For future uses
                    # $DCRows = @{
                    #     Memory = "4GB"
                    #     CPU = "2"
                    # }

                    $TempSitesInfo = [PSCustomObject]@{
                        Name = $Site.Name
                        Label = $Site.Name
                        Subnets = & {
                            $SubnetTable = @()
                            $SubnetArray = @()
                            $Subnets = $Site.Subnets
                            foreach ($Object in $Subnets) {
                                $SubnetName = Invoke-Command -Session $TempPssSession { Get-ADReplicationSubnet $using:Object }
                                $SubnetArray += $SubnetName.Name
                            }

                            # Used for Debug
                            # $SubnetArray = @("192.168.5.0/24","192.168.4.0/24","192.168.3.0/24","192.168.7.0/24","192.168.9.0/24","192.168.10.0/24","192.168.1.0/24","192.168.19.0/24")

                            $SubnetTable += [PSCustomObject]@{
                                Name = Remove-SpecialChar -String "$($Site.Name)SubNets" -SpecialChars '\-. '
                                Label = (Get-DiaHtmlTable -ImagesObj $Images -Rows $SubnetArray -MultiColunms -Columnsize 3 -Align 'Center' -IconDebug $IconDebug)
                                SubnetArray = $SubnetArray
                            }

                            return $SubnetTable
                        }
                        DomainControllers = & {
                            $DCsTable = @()
                            $DCsArray = @()
                            $DCs = try { Get-ADObjectSearch -DN "CN=Servers,$($Site.DistinguishedName)" -Filter { objectClass -eq "Server" } -Properties "DNSHostName" -SelectPrty 'DNSHostName', 'Name' -Session $TempPssSession } catch { Out-Null }
                            foreach ($Object in $DCs) {
                                $DCsArray += $Object.Name
                            }

                            # Used for Debug
                            # $DCsArray = @("Server-dc-01v","Server-dc-02v","Server-dc-03v","Server-dc-04v","Server-dc-05v","Server-dc-06v","Server-dc-07v","Server-dc-08v","Server-dc-09v","DC-Server-01v","DC-Server-02v","DC-Server-03v","DC-Server-04v")

                            $DCsTable += [PSCustomObject]@{
                                Name = Remove-SpecialChar -String "$($Site.Name)DCs" -SpecialChars '\-. '
                                Label = (Get-DiaHtmlTable -Rows $DCsArray -MultiColunms -Columnsize 3 -Align 'Center' -ImagesObj $Images -IconDebug $IconDebug)
                                DCsArray = $DCsArray
                            }

                            return $DCsTable
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