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
        Version:        0.1.2
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
        [ValidateSet('Forest')]
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
        [Switch] $Signature = $false
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

        if ($Signature -and (([string]::IsNullOrEmpty($AuthorName)) -or ([string]::IsNullOrEmpty($CompanyName)))) {
            throw "New-ADDiagram : AuthorName and CompanyName must be defined if the Signature option is specified"
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

        $URLIcon = $false

        if ($EnableEdgeDebug) {
            $EdgeDebug = @{style='filled'; color='red'}
            $URLIcon = $true
        } else {$EdgeDebug = @{style='invis'; color='red'}}

        if ($EnableSubGraphDebug) {
            $SubGraphDebug = @{style='dashed'; color='red'}
            $NodeDebug = @{color='black'; style='red'}
            $URLIcon = $true
        } else {
            $SubGraphDebug = @{style='invis'; color='gray'}
            $NodeDebug = @{color='transparent'; style='transparent'}
        }

        $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $IconPath = Join-Path $RootPath 'icons'
        $Dir = switch ($Direction) {
            'top-to-bottom' {'TB'}
            'left-to-right' {'LR'}
        }

        # Validate Custom logo
        $CustomLogo = Test-Logo -LogoPath $Logo
        # Validate Custom Signature Logo
        $CustomSignatureLogo = Test-Logo -LogoPath $SignatureLogo -Signature

        $MainGraphAttributes = @{
            pad = 1.0
            rankdir   = $Dir
            overlap   = 'true'
            splines   = $EdgeType
            penwidth  = 1.5
            fontname  = "Segoe UI"
            fontcolor = '#71797E'
            fontsize  = 32
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
                $script:TempCIMSession = New-CIMSession $System -Credential $Credential -Authentication $PSDefaultAuthentication -ErrorAction Stop
                $script:ADSystem = Invoke-Command -Session $TempPssSession { Get-ADForest -ErrorAction Stop }
            } Catch {throw "Unable to get Domain Controller Server"}

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
                    fontname = "Segoe UI"
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

                SubGraph MainGraph -Attributes @{Label=(Get-HTMLLabel -Label $MainGraphLabel -Type $CustomLogo -URLIcon $URLIcon); fontsize=22; penwidth=0} {
                    $script:ForestRoot = $ADSystem.Name.ToString().ToUpper()
                    SubGraph ForestMain -Attributes @{Label=" "; style="invis"; bgcolor="gray"; penwidth=1; color="blue"} {

                        if ($DiagramVerbosity -eq 2) {
                            $ADVersion = Invoke-Command -Session $TempPssSession {Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select-Object -ExpandProperty objectVersion}
                            If ($ADVersion -eq '88') {$server = 'Windows Server 2019'}
                            ElseIf ($ADVersion -eq '87') {$server = 'Windows Server 2016'}
                            ElseIf ($ADVersion -eq '69') {$server = 'Windows Server 2012 R2'}
                            ElseIf ($ADVersion -eq '56') {$server = 'Windows Server 2012'}
                            ElseIf ($ADVersion -eq '47') {$server = 'Windows Server 2008 R2'}
                            ElseIf ($ADVersion -eq '44') {$server = 'Windows Server 2008'}
                            ElseIf ($ADVersion -eq '31') {$server = 'Windows Server 2003 R2'}
                            ElseIf ($ADVersion -eq '30') {$server = 'Windows Server 2003'}

                            # Main Forest Root Node
                            $Rows = @(
                                "<B>Func Level</B> : $($ADSystem.ForestMode)"
                                "<B>Schema Ver</B> : $server"
                            )

                            Convert-TableToHTML -Label "Forest Root Information" -Name ForestRootInformation -Row $Rows -HeaderColor "#6d8faf" -HeaderFontColor "white" -BorderColor "black" -FontSize 14
                            node $ForestRoot @{Label=Get-NodeIcon -Name $ForestRoot -Type "ForestRoot" -Align "Center"; shape='plain'; fillColor='transparent'; fontsize=14}

                            # Edges between nodes to ensure that Forest name is in the center of the cluster
                            edge ForestRootInformation,$ForestRoot @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank $ForestRoot,ForestRootInformation
                        } else {
                            # Dummy Nodes used for subgraph centering
                            node Left @{Label='Left'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                            node Leftt @{Label='Leftt'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}
                            node Right @{Label='Right'; fontcolor=$NodeDebug.color; fillColor=$NodeDebug.style; shape='plain'}

                            node $ForestRoot @{Label=Get-NodeIcon -Name $ForestRoot -Type "ForestRoot" -Align "Center"; shape='plain'; fillColor='transparent'; fontsize=14}

                            # Edges between nodes to ensure that Forest name is in the center of the cluster
                            edge Left,Leftt,$ForestRoot,Right @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank Left,Leftt,$ForestRoot,Right
                        }
                    }

                    # Call Forest Diagram
                    if ($DiagramType -eq 'Forest') {
                        $ForestInfo = Get-DiagForest
                        if ($ForestInfo) {
                            $ForestInfo
                        } else {Write-Warning "No Forest Infrastructure available to diagram"}
                    }
                }
                if ($Signature) {
                    SubGraph Legend @{Label=" "; style='dashed,rounded'; color=$SubGraphDebug.color; fontsize=1} {
                        if ($CustomSignatureLogo) {
                            node LegendTable -Attributes @{Label=(Get-HTMLTable -Rows "Author: $($AuthorName)","Company: $($CompanyName)" -TableBorder 0 -CellBorder 0 -align 'left' -Logo $CustomSignatureLogo); shape='plain'; fillColor='white'}
                        } else {
                            node LegendTable -Attributes @{Label=(Get-HTMLTable -Rows "Author: $($AuthorName)","Company: $($CompanyName)" -TableBorder 0 -CellBorder 0 -align 'left' -Logo "AD_LOGO_Footer"); shape='plain'; fillColor='white'}
                        }
                    }
                    inline {rank="sink"; "Legend"; "LegendTable";}
                    edge -from MainSubGraph:s -to LegendTable @{minlen=5; constrains='false'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                }
            }
        }
    } end {
        # Remove used PSSession
        Write-Verbose "Clearing PowerShell Session $($TempPssSession.Id)"
        Remove-PSSession -Session $TempPssSession

        # Remove used CIMSession
        Write-Verbose "Clearing CIM Session $($TempCIMSession.Id)"
        Remove-CIMSession -CimSession $TempCIMSession

        #Export Diagram
        Out-ADDiagram -GraphObj $Graph -ErrorDebug $EnableErrorDebug -Rotate $Rotate
    }
}