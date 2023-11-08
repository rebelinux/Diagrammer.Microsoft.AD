function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.1
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
        Write-Verbose -Message "Collecting Forest information from $($ForestRoot)."
        try {
            if ($ForestRoot) {
                # $ChildDomains = ($ADSystem.Domains | Where-Object {$_ -ne $ForestRoot })
                $ChildDomains = @("a.pharmax.local","b.pharmax.local","c.pharmax.local","ad.pharmax.local","e.pharmax.local","f.pharmax.local","g.pharmax.local","uia.local")
                if ($ChildDomains.ToUpper() -notmatch $ForestRoot) {
                    SubGraph ContiguousChilds -Attributes @{Label='Contiguous'; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed,rounded"} {
                        node ($ChildDomains.ToUpper() -match $ForestRoot) @{width=5}

                        rank ($ChildDomains.ToUpper() -match $ForestRoot)

                        $ChildDomains.ToUpper() -match $ForestRoot  | ForEach-Object { edge -from $ForestRoot -to $_ @{arrowtail="dot"; arrowhead="normal"; minlen=3;} }
                    }
                    SubGraph NonContiguousChilds -Attributes @{Label='Non-Contiguous'; fontsize=18; penwidth=1; labelloc='b'} {
                        node ($ChildDomains.ToUpper() -notmatch $ForestRoot) @{width=5}

                        rank ($ChildDomains.ToUpper() -notmatch $ForestRoot)

                        $ChildDomains.ToUpper() -notmatch $ForestRoot  | ForEach-Object { edge -from $ForestRoot -to $_ @{arrowtail="dot"; arrowhead="normal"; minlen=3;} }
                    }

                } else {

                    node $ChildDomains.ToUpper()

                    $ChildDomains.ToUpper()  | ForEach-Object { edge -from $ForestRoot -to $_ @{arrowtail="dot"; arrowhead="normal"; minlen=3;} }

                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}