function New-ADDiagram {
    <#
.SYNOPSIS
    Diagram the configuration of Microsoft AD infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
.DESCRIPTION
    Diagram the configuration of Microsoft AD  infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
.PARAMETER DiagramType
    Specifies the type of microsoft ad diagram that will be generated.
.PARAMETER Target
    Specifies the IP/FQDN of the system to connect.
    Multiple targets may be specified, separated by a comma.
.PARAMETER Credential
    Specifies the stored credential of the target system.
.PARAMETER Username
    Specifies the username for the target system.
.PARAMETER Password
    Specifies the password for the target system.
.PARAMETER Format
    Specifies the output format of the diagram.
    The supported output formats are PDF, PNG, DOT & SVG.
    Multiple output formats may be specified, separated by a comma.
.PARAMETER Direction
    Set the direction in which resource are plotted on the visualization
    By default, direction will be set to top-to-bottom.
.PARAMETER NodeSeparation
    Controls Node separation ratio in visualization
    By default, NodeSeparation will be set to .60.
.PARAMETER SectionSeparation
    Controls Section (Subgraph) separation ratio in visualization
    By default, NodeSeparation will be set to .75.
.PARAMETER EdgeType
    Controls how edges lines appear in visualization
    By default, EdgeType will be set to spline.
.PARAMETER OutputFolderPath
    Specifies the folder path to save the diagram.
.PARAMETER Filename
    Specifies a filename for the diagram.
.PARAMETER Rotate
Specifies a int to rotate the output image diagram.
.PARAMETER EnableEdgeDebug
    Control to enable edge debugging ( Dummy Edge and Node lines ).
.PARAMETER EnableSubGraphDebug
    Control to enable subgraph debugging ( Subgraph Lines ).
.PARAMETER EnableErrorDebug
    Control to enable error debugging.
.NOTES
    Version:        0.1.0
    Author(s):      Jonathan Colon
    Twitter:        @jcolonfzenpr
    Github:         rebelinux
    Credits:        Kevin Marquette (@KevinMarquette) -  PSGraph module
    Credits:        Prateek Singh (@PrateekKumarSingh) - AzViz module
.LINK
    https://github.com/rebelinux/Diagrammer.Microsoft.AD
    https://github.com/KevinMarquette/PSGraph
    https://github.com/PrateekKumarSingh/AzViz
#>

[Diagnostics.CodeAnalysis.SuppressMessage(
    'PSUseShouldProcessForStateChangingFunctions',
    ''
)]

[CmdletBinding(
    PositionalBinding = $false,
    DefaultParameterSetName = 'Credential'
)]

param (

    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'Please provide the IP/FQDN of the system'
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('Server', 'IP')]
    [String[]] $Target,

    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = 'Please provide credentials to connect to the system',
        ParameterSetName = 'Credential'
    )]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $Credential,

    [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = 'Please provide the username to connect to the target system',
        ParameterSetName = 'UsernameAndPassword'
    )]
    [ValidateNotNullOrEmpty()]
    [String] $Username,

    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = 'Please provide the password to connect to the target system',
        ParameterSetName = 'UsernameAndPassword'
    )]
    [ValidateNotNullOrEmpty()]
    [String] $Password,

    [Parameter(
        Position = 4,
        Mandatory = $false,
        HelpMessage = 'Please provide the diagram output format'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('pdf', 'svg', 'png', 'dot', 'base64', 'jpg')]
    [Array] $Format = 'pdf',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Direction in which resource are plotted on the visualization'
    )]
    [ValidateSet('left-to-right', 'top-to-bottom')]
    [string] $Direction = 'top-to-bottom',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Please provide the path to the diagram output file'
    )]
    [ValidateScript( { Test-Path -Path $_ -IsValid })]
    [string] $OutputFolderPath = (Join-Path ([System.IO.Path]::GetTempPath()) "$Filename.$Format"),

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Specify the Diagram filename'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if ($Format.count -lt 2) {
            $true
        } else {
            throw "Format value must be unique if Filename is especified."
        }
    })]
    [String] $Filename,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls how edges lines appear in visualization'
    )]
    [ValidateSet('polyline', 'curved', 'ortho', 'line', 'spline')]
    [string] $EdgeType = 'spline',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls Node separation ratio in visualization'
    )]
    [ValidateSet(0, 1, 2, 3)]
    [string] $NodeSeparation = .60,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls Section (Subgraph) separation ratio in visualization'
    )]
    [ValidateSet(0, 1, 2, 3)]
    [string] $SectionSeparation = .75,

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Controls type of Active Directory generated diagram'
    )]
    [ValidateSet('Forest')]
    [string] $DiagramType,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls type of Active Directory generated diagram'
    )]
    [ValidateSet(90, 180)]
    [string] $Rotate,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable edge debugging ( Dummy Edge and Node lines)'
    )]
    [Switch] $EnableEdgeDebug = $false,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable subgraph debugging ( Subgraph Lines )'
    )]
    [Switch] $EnableSubGraphDebug = $false,
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable error debugging'
    )]
    [Switch] $EnableErrorDebug = $false,
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable error debugging'
    )]
    [ValidateSet("Negotiate", "Kerberos")]
    [String] $PSDefaultAuthentication = "Negotiate"
)


begin {

    # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
    #@tpcarman
    if (($Username -and $Password)) {
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
    }

    if (($Format -ne "base64") -and  !(Test-Path $OutputFolderPath)) {
        Write-Error "OutputFolderPath '$OutputFolderPath' is not a valid folder path."
        break
    }

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

        throw "The requested operation requires elevation: Run PowerShell console as administrator"
    }


    #Validate Required Modules and Features
    $OSType = (Get-ComputerInfo).OsProductType
    if ($OSType -eq 'WorkStation') {
        Get-RequiredFeature -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0' -OSType $OSType
    }
    if ($OSType -eq 'Server' -or $OSType -eq 'DomainController') {
        Get-RequiredFeature -Name RSAT-AD-PowerShell -OSType $OSType
    }

    $MainGraphLabel = Switch ($DiagramType) {
        'Forest' {'Active Directory Forest Architecture'}
    }

    if ($EnableEdgeDebug) {
        $EdgeDebug = @{style='filled'; color='red'}
    } else {$EdgeDebug = @{style='invis'; color='red'}}

    if ($EnableSubGraphDebug) {
        $SubGraphDebug = @{style='dashed'; color='red'}
    } else {$SubGraphDebug = @{style='invis'; color='gray'}}

    $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $IconPath = Join-Path $RootPath 'icons'
    $Dir = switch ($Direction) {
        'top-to-bottom' {'TB'}
        'left-to-right' {'LR'}
    }

    $MainGraphAttributes = @{
        # pad = 1.0
        rankdir   = $Dir
        overlap   = 'false'
        splines   = $EdgeType
        penwidth  = 1.5
        fontname  = "Segoe Ui"
        fontcolor = '#71797E'
        fontsize  = 32
        style = "dashed"
        labelloc = 't'
        imagepath = $IconPath
        nodesep = $NodeSeparation
        ranksep = $SectionSeparation
        # ratio = "compress"
        # size = "7.5,10"
    }
}

process {

    foreach ($System in $Target) {

        # Get-VbrServerConnection

        try {

            $script:TempPssSession = New-PSSession $System -Credential $Credential -Authentication $PSDefaultAuthentication -ErrorAction Stop
            $script:TempCIMSession = New-CIMSession $System -Credential $Credential -Authentication $PSDefaultAuthentication -ErrorAction Stop
            $script:ADSystem = Invoke-Command -Session $TempPssSession { Get-ADForest -ErrorAction Stop}

        } Catch {throw "Unable to get Domain Controller Server"}

        # Get-ADForestInfo

        $Graph = Graph -Name MicrosoftAD -Attributes $MainGraphAttributes {
            # Node default theme
            node @{
                shape = 'ellipse'
                labelloc = 't'
                style = 'filled'
                fillColor = '#99ceff'
                fontsize = 14;
                imagescale = $true;
                color = "#003099";
                penwidth = 3
                fontname = "Courier New"
            }
            # Edge default theme
            edge @{
                style = 'dashed'
                dir = 'both'
                arrowtail = 'dot'
                color = '#71797E'
                penwidth = 1.5
                arrowsize = 1
            }

            SubGraph MainGraph -Attributes @{Label=(Get-HTMLLabel -Label $MainGraphLabel -Type "Microsoft_LOGO" ); fontsize=22; penwidth=0} {
                SubGraph ForestMain -Attributes @{Label='Root Domain'; style="rounded"; bgcolor="#ceedc4"; fontsize=18; penwidth=2} {
                    $script:ForestRoot = $ADSystem.Name.ToString().ToUpper()
                    node  $ForestRoot @{Label=$ForestRoot}
                }

                if ($DiagramType -eq 'Forest') {
                    $ForestInfo = Get-DiagForest
                    if ($ForestInfo) {
                        $ForestInfo
                    } else {Write-Warning "No Forest Infrastructure available to diagram"}
                }
            }
        }

        if ($EnableErrorDebug) {
            $Graph
        } else {
            # If Filename parameter is not specified, set filename to the Output.$OutputFormat
            foreach ($OutputFormat in $Format) {
                if ($Filename) {
                    Try {
                        if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                                }

                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat 'png'
                            if ($Document) {
                                if ($Rotate) {
                                    Add-Type -AssemblyName System.Windows.Forms
                                    $RotatedIMG = new-object System.Drawing.Bitmap $Document.FullName
                                    $RotatedIMG.RotateFlip("Rotate90FlipNone")
                                    $RotatedIMG.Save($Document.FullName,"png")
                                    if ($RotatedIMG) {
                                        $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                        if ($Base64) {
                                            Remove-Item -Path $Document.FullName
                                            $Base64
                                        } else {Remove-Item -Path $Document.FullName}
                                    }
                                } else {
                                    $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                    if ($Base64) {
                                        Remove-Item -Path $Document.FullName
                                        $Base64
                                    } else {Remove-Item -Path $Document.FullName}

                                }
                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
                elseif (!$Filename) {
                    if ($OutputFormat -ne "base64") {
                        $File = "Output.$OutputFormat"
                    } else {$File = "Output.png"}
                    Try {
                        if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                                }
                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat 'png'
                            if ($Document) {
                                if ($Rotate) {
                                    Add-Type -AssemblyName System.Windows.Forms
                                    $RotatedIMG = new-object System.Drawing.Bitmap $Document.FullName
                                    $RotatedIMG.RotateFlip("Rotate90FlipNone")
                                    $RotatedIMG.Save($Document.FullName,"png")
                                    if ($RotatedIMG) {
                                        $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                        if ($Base64) {
                                            Remove-Item -Path $Document.FullName
                                            $Base64
                                        } else {Remove-Item -Path $Document.FullName}
                                    }
                                } else {
                                    $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                    if ($Base64) {
                                        Remove-Item -Path $Document.FullName
                                        $Base64
                                    } else {Remove-Item -Path $Document.FullName}

                                }

                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
            }
        }
    }

}
end {}
}