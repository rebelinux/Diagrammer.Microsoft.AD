<p align="center">
    <a href="https://github.com/rebelinux/Diagrammer.Microsoft.AD" alt="Diagrammer.Microsoft.AD"></a>
            <img src='https://raw.githubusercontent.com/rebelinux/Diagrammer.Microsoft.AD/dev/icons/DMAD_Logo.png' width="8%" height="8%" /></a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/Diagrammer.Microsoft.AD/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/Diagrammer.Microsoft.AD.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/Diagrammer.Microsoft.AD/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/Diagrammer.Microsoft.AD.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/Diagrammer.Microsoft.AD/" alt="PS Platform">
        <img src="https://img.shields.io/powershellgallery/p/Diagrammer.Microsoft.AD.svg" /></a>
</p>
<p align="center">
    <a href="https://github.com/rebelinux/Diagrammer.Microsoft.AD/graphs/commit-activity" alt="GitHub Last Commit">
        <img src="https://img.shields.io/github/last-commit/rebelinux/Diagrammer.Microsoft.AD.svg" /></a>
    <a href="https://raw.githubusercontent.com/rebelinux/Diagrammer.Microsoft.AD/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/rebelinux/Diagrammer.Microsoft.AD.svg" /></a>
    <a href="https://github.com/rebelinux/Diagrammer.Microsoft.AD/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/rebelinux/Diagrammer.Microsoft.AD.svg"/></a>
</p>
<p align="center">
    <a href="https://twitter.com/jcolonfzenpr" alt="Twitter">
            <img src="https://img.shields.io/twitter/follow/jcolonfzenpr.svg?style=social"/></a>
</p>
<p align="center">
    <a href='https://ko-fi.com/F1F8DEV80' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'            border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Diagrammer Microsoft Active Directory

<!-- ********** REMOVE THIS MESSAGE WHEN THE MODULE IS FUNCTIONAL ********** -->
## :exclamation: THIS POWERSHELL MODULE IS CURRENTLY IN DEVELOPMENT AND MIGHT NOT YET BE FUNCTIONAL ❗

Diagrammer.Microsoft.AD is a PowerShell module to automatically generate Actie Directory topology diagrams by just typing a PowerShell cmdlet and passing the name of the Forest/Domain.

## This project is extensively based on the [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) module.

> Special thanks & shoutout to [`Kevin Marquette`](https://twitter.com/KevinMarquette) and his [`PSGraph`](https://github.com/KevinMarquette/PSGraph) module and to [`Prateek Singh`](https://twitter.com/singhprateik) and his [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) project without it work the Diagrammer.Microsoft.AD won't be possible!



## :books: Sample Diagram

### Forest Diagram

![!\[Forest Diagram\](Forest_Diagram.webp)](Samples/Forest_Diagram.webp)

# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a Diagrammer.Microsoft.AD diagram.

## :floppy_disk: Supported Versions
<!-- ********** Update supported Microsoft AD versions ********** -->
The Diagrammer.Microsoft.AD supports the following Active Directory version;

- 2016, 2019 & 2022

### :closed_lock_with_key: Required Privileges

Diagrammer.Microsoft.AD can be generated with Active Directory Enterprise Forest level privileges. Since this report relies extensively on the WinRM component, you should make sure that it is enabled and configured. [Reference](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

### PowerShell

This project is compatible with the following PowerShell versions;

<!-- ********** Update supported PowerShell versions ********** -->
| Windows PowerShell 5.1 | PowerShell 7 |
| :--------------------: | :----------: |
|   :white_check_mark:   |     :x:      |

## :wrench: System Requirements

PowerShell 5.1, and the following PowerShell modules are required for generating a Diagrammer.Microsoft.AD diagram.

- [ActiveDirectory Module](https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2019-ps)
- [PSGraph Module](https://github.com/KevinMarquette/PSGraph)
- [Diagrammer.Core Module](https://github.com/rebelinux/Diagrammer.Core)


## What is GraphViz?

[Graphviz](http://graphviz.org/) is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. It has important applications in networking, bioinformatics,  software engineering, database and web design, machine learning, and in visual interfaces for other technical domains. 

No need to install GraphViz on your system because from now on it's libraries are included in the local module path.

## :package: Module Installation

### PowerShell v5.x running on a Domain Controller server

```powershell

Install-WindowsFeature -Name RSAT-AD-PowerShell

# Install Diagrammer.Microsoft.AD from the Powershell Gallery
install-module -Name Diagrammer.Microsoft.AD

```

### PowerShell v5.x running on Windows 10 client computer
<!-- ********** Add installation for any additional PowerShell module(s) ********** -->
```powershell

install-module -Name Diagrammer.Microsoft.AD
Add-WindowsCapability -online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'

```

### GitHub

If you are unable to use the PowerShell Gallery, you can still install the module manually. Ensure you repeat the following steps for the [system requirements](https://github.com/rebelinux/Diagrammer.Microsoft.AD#wrench-system-requirements) also.

1. Download the code package / [latest release](https://github.com/rebelinux/Diagrammer.Microsoft.AD/releases/latest) zip from GitHub
2. Extract the zip file
3. Copy the folder `Diagrammer.Microsoft.AD` to a path that is set in `$env:PSModulePath`.
4. Open a PowerShell terminal window and unblock the downloaded files with

    ```powershell
    $path = (Get-Module -Name Diagrammer.Microsoft.AD -ListAvailable).ModuleBase; Unblock-File -Path $path\*.psd1; Unblock-File -Path $path\Src\Public\*.ps1; Unblock-File -Path $path\Src\Private\*.ps1
    ```

5. Close and reopen the PowerShell terminal window.

_Note: You are not limited to installing the module to those example paths, you can add a new entry to the environment variable PSModulePath if you want to use another path._


## :pencil2: Commands

### **New-ADDiagram**

The `New-ADDiagram` cmdlet is used to generate a Active Directory diagram. The type of diagram to generate is specified by using the `DiagramType` parameter. The DiagramType parameter relies on additional diagram modules being created alongside the defaults module. The `Target` parameter specifies one or more Forest/Domain servers on which to connect and run the diagram. User credentials to the system are specifed using the `Credential`, or the `Username` and `Password` parameters. One or more document formats, such as `PNG`, `PDF`, `SVG`, `BASE64` or `DOT` can be specified using the `Format` parameter. Additional parameters are outlined below.

```powershell
.PARAMETER DiagramType
    Specifies the type of active directory diagram that will be generated.
    The supported output diagrams are:
                'Forest'
                'Sites'
                'Trusts'
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
.PARAMETER WatermarkText
    Allow to add a watermark to the output image (Not supported in svg format).
.PARAMETER WatermarkColor
    Allow to specified the color used for the watermark text. Default: Blue.
```

For a full list of common parameters and examples you can view the `New-ADDiagram` cmdlet help with the following command;

```powershell
Get-Help New-ADDiagram -Full
```

## :computer: Examples

There are a few examples listed below on running the Diagrammer.Microsoft.AD script against a Domain Controller Server. Refer to the `README.md` file in the main Diagrammer.Microsoft.AD project repository for more examples.

```powershell
# Generate a Diagrammer.Microsoft.AD diagram for Domain Controller 'dc-01.pharmax.local' using specified credentials. Export report to PDF & PNG formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-ADDiagram -DiagramType Forest -Target dc-01.pharmax.local -Username 'Domain\ad_admin' -Password 'P@ssw0rd' -Format pdf,png -OutputFolderPath 'C:\Users\Jon\Documents'

# Generate a Diagrammer.Microsoft.AD diagram for Domain Controller dc-01.pharmax.local using stored credentials. Export report to DOT & SVG formats. Save reports to 'C:\Users\Jon\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-ADDiagram -DiagramType Forest -Target dc-01.pharmax.local -Credential $Creds -Format dot,pdf -OutputFolderPath 'C:\Users\Jon\Documents'

```

## :x: Known Issues

- Due to a limitation of the WinRM component, a domain-joined machine is needed, also it is required to use the FQDN of the DC instead of it's IP address.
[Reference](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_troubleshooting?view=powershell-7.1#how-to-use-an-ip-address-in-a-remote-command)
