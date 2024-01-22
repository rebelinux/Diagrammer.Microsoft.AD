function Get-ADForestInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory forest information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.2
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param
    (

    )
    process {
        Write-Verbose -Message "Collecting Microsoft AD Forest information from $($ForestRoot)."
        try {
            $ChildDomains = $ADSystem.Domains
            # $ChildDomains = @("a.uia.local","b.uia.local","c.uia.local")
            # $ChildDomains = @("acad.a.pharmax.local","b.pharmax.local","c.pharmax.local","ad.pharmax.local","e.pharmax.local","f.pharmax.local","g.pharmax.local", "uia.local", "b12.local", "acad.uia.local", "admin.b12.local", "fin.b12.local", "it.b12.local", "hr.b12.local", "fin.uia.local", "hr.uia.local", "gov.uia.local", "hr.b13.local", "fin.uib.local", "hr.uib.local", "gov.uib.local")


            $ForestGroups =  @()
            $ForestRootDomain = $ChildDomains | ForEach-Object {$_.Split(".")[-2,-1] -join "."} | Select-Object -Unique
            foreach ($Domain in $ForestRootDomain) {
                $DomainGroup = @()
                foreach ($CHDomain in $ChildDomains) {
                    if ($CHDomain -match $Domain -and $CHDomain -ne $Domain) {
                        $DomainGroup += $CHDomain
                    }
                }
                $inObj = [ordered] @{
                    'Name' = $Domain
                    'Group' = $DomainGroup
                }
                $ForestGroups += [pscustomobject]$inobj
            }
            $ForestDomainInfo = @()
            if ($ForestGroups) {
                foreach ($ForestGroup in $ForestGroups) {
                    # $ForestRootRows = @{
                    #     'Placement Policy' = $Sobr.PolicyType
                    #     'Encryption Enabled' = ConvertTo-TextYN $Sobr.EncryptionEnabled
                    # }

                    $TempDomainInfo = [PSCustomObject]@{
                        Name = $ForestGroup.Name
                        # Label = Get-NodeIcon -Name "$($Sobr.Name)" -Type "VBR_SOBR" -Align "Center" -Rows $SobrRows
                        Label = $ForestGroup.Name
                        Childs =  $ForestGroup
                    }
                    $ForestDomainInfo  += $TempDomainInfo
                }
            }

            return $ForestDomainInfo
        }
        catch {
            $_
        }
    }
    end {}
}