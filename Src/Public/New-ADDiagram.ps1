function New-ADDiagram {
    <#
    .SYNOPSIS
        Diagram the configuration of Microsoft AD infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .DESCRIPTION
        Diagram the configuration of Microsoft AD  infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .PARAMETER DiagramType
        Specifies the type of active directory diagram that will be generated.
        The supported output diagrams are:
                    'Forest'
                    'Sites'
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
        The supported directions are:
            'top-to-bottom', 'left-to-right'
        By default, direction will be set to top-to-bottom.
    .PARAMETER NodeSeparation
        Controls Node separation ratio in visualization
        By default, NodeSeparation will be set to .60.
    .PARAMETER SectionSeparation
        Controls Section (Subgraph) separation ratio in visualization
        By default, NodeSeparation will be set to .75.
    .PARAMETER EdgeType
        Controls how edges lines appear in visualization
        The supported edge type are:
            'polyline', 'curved', 'ortho', 'line', 'spline'
        By default, EdgeType will be set to spline.
        References: https://graphviz.org/docs/attrs/splines/
    .PARAMETER OutputFolderPath
        Specifies the folder path to save the diagram.
    .PARAMETER Filename
        Specifies a filename for the diagram.
    .PARAMETER EnableEdgeDebug
        Control to enable edge debugging ( Dummy Edge and Node lines ).
    .PARAMETER EnableSubGraphDebug
        Control to enable subgraph debugging ( Subgraph Lines ).
    .PARAMETER EnableErrorDebug
        Control to enable error debugging.
    .PARAMETER AuthorName
        Allow to set footer signature Author Name.
    .PARAMETER CompanyName
        Allow to set footer signature Company Name.
    .PARAMETER Logo
        Allow to change the Microsoft logo to a custom one.
        Image should be 400px x 100px or less in size.
    .PARAMETER SignatureLogo
        Allow to change the Microsoft signature logo to a custom one.
        Image should be 120px x 130px or less in size.
    .PARAMETER Signature
        Allow the creation of footer signature.
        AuthorName and CompanyName must be set to use this property.
    .NOTES
        Version:        0.1.6
        Author(s):      Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Kevin Marquette (@KevinMarquette) -  PSGraph module
        Credits:        Prateek Singh (@PrateekKumarSingh) - AzViz module
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
        https://github.com/KevinMarquette/PSGraph
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
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "Path $_ not found!"
                }
            })]
        [string] $OutputFolderPath = [System.IO.Path]::GetTempPath(),

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom logo used for Signature'
        )]
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "File $_ not found!"
                }
            })]
        [string] $SignatureLogo,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom logo'
        )]
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "File $_ not found!"
                }
            })]
        [string] $Logo,

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
        [ValidateSet('Forest', 'Domain', 'Sites', 'SiteTopology', 'DomainController')]
        [string] $DiagramType,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to rotate the diagram output image. valid rotation degree (90, 180)'
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
        [String] $PSDefaultAuthentication = "Negotiate",

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Controls verbose of Active Directory generated diagram'
        )]
        [ValidateSet(1, 2)]
        [int] $DiagramVerbosity = 1,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to set footer signature Author Name'
        )]
        [string] $AuthorName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to set footer signature Company Name'
        )]
        [string] $CompanyName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow the creation of footer signature'
        )]
        [Switch] $Signature = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow the creation of footer signature'
        )]
        [ValidateSet('en-US', 'es-ES')]
        [string] $UICulture
    )


    begin {

        # Setup all paths required for script to run
        $script:RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $IconPath = Join-Path $RootPath 'icons'
        $script:GraphvizPath = Join-Path $RootPath 'Graphviz\bin\dot.exe'

        if ($PSBoundParameters.ContainsKey('UICulture')) {

            # Override the default (en-US) if it exists in lang directory
            Import-LocalizedData -BaseDirectory ($RootPath + '\Language') -BindingVariable translate -UICulture $UICulture -ErrorAction SilentlyContinue

        } else {

            # Default language en-US
            Import-LocalizedData -BaseDirectory ($RootPath + "\Language") -BindingVariable translate -ErrorAction SilentlyContinue
        }

        # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
        #@tpcarman
        if (($Username -and $Password)) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        }

        if (($Format -ne "base64") -and !(Test-Path $OutputFolderPath)) {
            Write-Error ($translate.outputfolderpatherror -f $OutputFolderPath)
            break
        }

        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

            throw $translate.runasadmin
        }

        if ($Signature -and (([string]::IsNullOrEmpty($AuthorName)) -or ([string]::IsNullOrEmpty($CompanyName)))) {
            throw $translate.signaturerequirements
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
            'Forest' { $translate.forestgraphlabel }
            'Domain' { $translate.domaingraphlabel }
            'Sites' { $translate.sitesgraphlabel }
            'SitesTopology' { $translate.sitesgraphlabel }
        }

        $script:URLIcon = $false

        if ($EnableEdgeDebug) {
            $EdgeDebug = @{style = 'filled'; color = 'red' }
            $script:URLIcon = $true
        } else { $EdgeDebug = @{style = 'invis'; color = 'red' } }

        if ($EnableSubGraphDebug) {
            $SubGraphDebug = @{style = 'dashed'; color = 'red' }
            $script:NodeDebug = @{color = 'black'; style = 'red' }
            $script:URLIcon = $true
        } else {
            $SubGraphDebug = @{style = 'invis'; color = 'gray' }
            $script:NodeDebug = @{color = 'transparent'; style = 'transparent' }
        }

        $Dir = switch ($Direction) {
            'top-to-bottom' { 'TB' }
            'left-to-right' { 'LR' }
        }

        # Validate Custom logo
        $CustomLogo = Test-Logo -LogoPath $Logo
        # Validate Custom Signature Logo
        $CustomSignatureLogo = Test-Logo -LogoPath $SignatureLogo -Signature

        $MainGraphAttributes = @{
            pad = 1.0
            rankdir = $Dir
            overlap = 'true'
            splines = $EdgeType
            penwidth = 1.5
            fontname = "Segoe UI"
            fontcolor = '#71797E'
            fontsize = 32
            style = "dashed"
            labelloc = 't'
            imagepath = $IconPath
            nodesep = $NodeSeparation
            ranksep = $SectionSeparation
        }
    }

    process {
        foreach ($System in $Target) {

            try {
                # Connection setup
                $script:TempPssSession = New-PSSession $System -Credential $Credential -Authentication $PSDefaultAuthentication -ErrorAction Stop
                $script:TempCIMSession = New-CimSession $System -Credential $Credential -Authentication $PSDefaultAuthentication -ErrorAction Stop
                $script:ADSystem = Invoke-Command -Session $TempPssSession { Get-ADForest -ErrorAction Stop }
            } Catch { throw ($translate.unableToConnect -f $System) }

            $Graph = Graph -Name MicrosoftAD -Attributes $MainGraphAttributes {
                # Node default theme
                Node @{
                    shape = 'ellipse'
                    labelloc = 't'
                    style = 'filled'
                    fillColor = '#99ceff'
                    fontsize = 14;
                    imagescale = $true;
                    color = "#003099";
                    penwidth = 3
                    fontname = "Segoe UI"
                }
                # Edge default theme
                Edge @{
                    style = 'dashed'
                    dir = 'both'
                    arrowtail = 'dot'
                    color = '#71797E'
                    penwidth = 1.5
                    arrowsize = 1
                }

                SubGraph MainGraph -Attributes @{Label = (Get-HTMLLabel -Label $MainGraphLabel -IconType $CustomLogo -URLIcon $URLIcon); fontsize = 22; penwidth = 0 } {
                    $script:ForestRoot = $ADSystem.Name.ToString().ToUpper()

                    # Call Forest Diagram
                    if ($DiagramType -eq 'Forest') {
                        $ForestInfo = Get-DiagForest
                        if ($ForestInfo) {
                            $ForestInfo
                        } else { Write-Warning $translate.emptyForest }
                    } elseif ($DiagramType -eq 'Sites') {
                        $SitesInfo = Get-DiagSite
                        if ($SitesInfo) {
                            $SitesInfo
                        } else { Write-Warning $translate.emptySites }
                    }
                }
                if ($Signature) {
                    SubGraph Legend @{Label = " "; style = 'dashed,rounded'; color = $SubGraphDebug.color; fontsize = 1 } {
                        if ($CustomSignatureLogo) {
                            Node LegendTable -Attributes @{Label = (Get-HtmlTable -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 0 -CellBorder 0 -align 'left' -Logo $CustomSignatureLogo); shape = 'plain'; fillColor = 'white' }
                        } else {
                            Node LegendTable -Attributes @{Label = (Get-HtmlTable -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 0 -CellBorder 0 -align 'left' -Logo "AD_LOGO_Footer"); shape = 'plain'; fillColor = 'white' }
                        }
                    }
                    Inline { rank="sink"; "Legend"; "LegendTable"; }
                    Edge -From MainSubGraph:s -To LegendTable @{minlen = 5; constrains = 'false'; style = $EdgeDebug.style; color = $EdgeDebug.color }
                }
            }
        }
    } end {
        # Remove used PSSession
        Write-Verbose ($translate.psSession -f $($TempPssSession.Id))
        Remove-PSSession -Session $TempPssSession

        # Remove used CIMSession
        Write-Verbose ($translate.cimSession -f $($TempCIMSession.Id))
        Remove-CimSession -CimSession $TempCIMSession

        #Export Diagram
        Out-ADDiagram -GraphObj $Graph -ErrorDebug $EnableErrorDebug -Rotate $Rotate
    }
}