function Get-DiagForest {
    <#
    .SYNOPSIS
        Function to diagram Microsoft Active Directory Forest.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.0
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
                $ChildDomains = ($ADSystem.Domains | Where-Object {$_ -ne $ForestRoot })
                # $ChildDomains = @("a.pharmax.local","b.pharmax.local","c.pharmax.local","ad.pharmax.local","e.pharmax.local","f.pharmax.local","g.pharmax.local", "uia.local", "b12.local", "acad.uia.local", "admin.b12.local", "hr.b12.local")
                if ($ChildDomains) {
                    # Dummy Node used for Main Labeling
                    node CHILDDOMAINSTEXT @{Label='Child Domains'; fontcolor='#71797E'; fontsize=22; shape='plain'; fillColor='transparent'}
                    # node DummyChildDOMAINS @{Label='DummyChildDOMAINS'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                    SubGraph MainSubGraph -Attributes @{Label=''; penwidth=1.5; labelloc='t'; style="dashed,rounded"; color="gray"} {
                        if ($ChildDomains.ToUpper() -notmatch $ForestRoot) {
                            SubGraph ContiguousChilds -Attributes @{Label='Contiguous'; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed"; color="gray"} {
                                # Dummy Node used for subgraph centering
                                node DummyContiguous @{Label='DummyContiguous'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                if (($ChildDomains.ToUpper() -match $ForestRoot).Length -ge 1 -and ($ChildDomains.ToUpper() -match $ForestRoot).Length -le 3) {
                                    node ($ChildDomains.ToUpper() -match $ForestRoot) @{width=5}
                                    $ChildDomains.ToUpper() -match $ForestRoot | ForEach-Object { edge -from DummyContiguous -to $_ @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color} }
                                } else {
                                    $Group = Split-array -inArray ($ChildDomains.ToUpper() -match $ForestRoot | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "Contiguous$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                node $_ @{Label=$_}
                                            }
                                        }
                                        $Number++
                                    }
                                    edge -From DummyContiguous -To $Group[0] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalRepoNum = 1
                                    while ($LocalRepoNum -ne $Group.Length) {
                                        edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalRepoNum++
                                    }
                                }
                            }
                            SubGraph NonContiguousChilds -Attributes @{Label='Non-Contiguous'; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed"; color="gray"} {
                                # Dummy Node used for subgraph centering
                                node DummyNonContiguous @{Label='DummyNonContiguous'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                                if (($ChildDomains.ToUpper() -notmatch $ForestRoot).Length -ge 1 -and ($ChildDomains.ToUpper() -notmatch $ForestRoot).Length -le 3) {
                                    node ($ChildDomains.ToUpper() -notmatch $ForestRoot) @{width=5}
                                    $ChildDomains.ToUpper() -notmatch $ForestRoot | ForEach-Object { edge -from DummyNonContiguous -to $_ @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color} }
                                } else {
                                    $Group = Split-array -inArray ($ChildDomains.ToUpper() -notmatch $ForestRoot | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "NonContiguous$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                node $_ @{Label=$_}
                                            }
                                        }
                                        $Number++
                                    }
                                    edge -From DummyNonContiguous -To $Group[0] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalRepoNum = 1
                                    while ($LocalRepoNum -ne $Group.Length) {
                                        edge -From $Group[$Start] -To $Group[$LocalRepoNum] @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalRepoNum++
                                    }
                                }
                            }
                            edge -from CHILDDOMAINSTEXT:s -to DummyContiguous:n, DummyNonContiguous:n @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        } else {

                            node $ChildDomains.ToUpper()
                            $ChildDomains.ToUpper() | ForEach-Object { edge -from CHILDDOMAINSTEXT -to $_ @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color} }

                        }
                    }
                    # edge -from CHILDDOMAINSTEXT:s -to CHILDDOMAINSTEXT:n @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                    edge -from $ForestRoot -to CHILDDOMAINSTEXT @{minlen=2}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}