<p align="center">
    <a href="https://github.com/rebelinux/Diagrammer.Microsoft.AD" alt="Diagrammer.Microsoft.AD"></a>
            <img src='https://raw.githubusercontent.com/rebelinux/Diagrammer.Microsoft.AD/dev/icons/verified_recoverability.png' width="8%" height="8%" /></a>
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

# Active Directory Diagrammer

<!-- ********** REMOVE THIS MESSAGE WHEN THE MODULE IS FUNCTIONAL ********** -->
## :exclamation: THIS POWERSHELL MODULE IS CURRENTLY IN DEVELOPMENT AND MIGHT NOT YET BE FUNCTIONAL ❗

Diagrammer.Microsoft.AD: A #powershell module to automatically generate Microsoft Active Directory resource topology diagrams by just typing a PowerShell cmdlet and passing the name of the Domain Controller.

## This project is extensively based on the [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) module.

> Special thanks & shoutout to [`Kevin Marquette`](https://twitter.com/KevinMarquette) and his [`PSGraph`](https://github.com/KevinMarquette/PSGraph) module and to [`Prateek Singh`](https://twitter.com/singhprateik) and his [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) project without it work the Diagrammer.Microsoft.AD won't be possible!



## :books: Sample Diagram



# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a Diagrammer.Microsoft.AD diagram.

## :floppy_disk: Supported Versions
<!-- ********** Update supported Microsoft versions ********** -->
The Diagrammer.Microsoft.AD supports the following Active Directory version;

- 2012, 2016, 2019 & 2022

### :closed_lock_with_key: Required Privileges

A Microsoft AD As Built Report can be generated with Active Directory Enterprise Forest level privileges. Since this report relies extensively on the WinRM component, you should make sure that it is enabled and configured. [Reference](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

### PowerShell

This project is compatible with the following PowerShell versions;

<!-- ********** Update supported PowerShell versions ********** -->
| Windows PowerShell 5.1 |     PowerShell 7    |
|:----------------------:|:--------------------:|
|   :white_check_mark:   | :x: |

## :wrench: System Requirements

PowerShell 5.1, and the following PowerShell modules are required for generating a Microsoft AD diagram.

- [AsBuiltReport.Microsoft.AD Module](https://www.powershellgallery.com/packages/AsBuiltReport.Microsoft.AD/)
- [ActiveDirectory Module](https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2019-ps)
- [ADCSAdministration Module](https://learn.microsoft.com/en-us/powershell/module/adcsadministration/?view=windowsserver2019-ps)
- [PSPKI Module](https://www.powershellgallery.com/packages/PSPKI/3.7.2)
- [DnsServer Module](https://docs.microsoft.com/en-us/powershell/module/dnsserver/?view=windowsserver2019-ps)

## What is GraphViz?

[Graphviz](http://graphviz.org/) is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. It has important applications in networking, bioinformatics,  software engineering, database and web design, machine learning, and in visual interfaces for other technical domains. 


We need to install GraphViz on our system before we can proceed with using the 'Diagrammer.Microsoft.AD' PowerShell module.
### Installing GraphViz
Make sure you are running Powershell 5.0 (WMF 5.0). I don't know that it is a hard requirement at the moment but I plan on using 5.0 features.

```powershell
# Install GraphViz from the Chocolatey repo
Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
Find-Package graphviz | Install-Package -ForceBootstrap
```

## :package: Module Installation

### PowerShell

```powershell
# Install PSGraph from the Powershell Gallery
Install-Module -Name PSGraph

# Install Diagrammer.Microsoft.AD from the Powershell Gallery
install-module -Name Diagrammer.Microsoft.AD

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

The `New-ADDiagram` cmdlet is used to generate a Microsoft Active Directory diagram. The type of diagram to generate is specified by using the `DiagramType` parameter. The DiagramType parameter relies on additional diagram modules being created alongside the defaults module. The `Target` parameter specifies the Domain Controller server on which to connect and run the diagram. User credentials to the system are specifed using the `Credential`, or the `Username` and `Password` parameters. One or more document formats, such as `PNG`, `PDF`, `SVG`, `BASE64` or `DOT` can be specified using the `Format` parameter. Additional parameters are outlined below.

```powershell
.PARAMETER DiagramType
    Specifies the type of microsoft ad diagram that will be generated.
.PARAMETER Target
    Specifies the IP/FQDN of the system to connect.
    Multiple targets may be specified, separated by a comma.
.PARAMETER Port
    Specifies a optional port to connect to Microsoft AD Service.
    By default, port will be set to 9392
.PARAMETER Credential
    Specifies the stored credential of the target system.
.PARAMETER Username
    Specifies the username for the target system.
.PARAMETER Password
    Specifies the password for the target system.
.PARAMETER Format
    Specifies the output format of the diagram.
    The supported output formats are BASE64, PDF, PNG, DOT & SVG.
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
.PARAMETER EnableEdgeDebug
    Control to enable edge debugging ( Dummy Edge and Node lines).
.PARAMETER EnableSubGraphDebug
    Control to enable subgraph debugging ( Subgraph Lines ).
.PARAMETER EnableErrorDebug
    Control to enable error debugging.
```

For a full list of common parameters and examples you can view the `New-ADDiagram` cmdlet help with the following command;

```powershell
Get-Help New-ADDiagram -Full
```

## :computer: Examples

There are a few examples listed below on running the Diagrammer.Microsoft.AD script against a Domain Controller Server. Refer to the `README.md` file in the main Diagrammer.Microsoft.AD project repository for more examples.

```powershell
# Generate a Diagrammer.Microsoft.AD diagram for Forest 'server-dc-01v.pharmax.local' using specified credentials. Export report to PDF & PNG formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-ADDiagram -DiagramType Forest -Target server-dc-01v.pharmax.local -Username 'Domain\domain_admin' -Password 'P@ssw0rd' -Format pdf,png -OutputFolderPath 'C:\Users\Jon\Documents'

# Generate a Diagrammer.Microsoft.AD diagram for Forest server-dc-01v.pharmax.local using stored credentials. Export report to DOT & SVG formats. Save reports to 'C:\Users\Jon\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-ADDiagram -DiagramType Forest -Target server-dc-01v.pharmax.local -Credential $Creds -Format DOT,SVG -OutputFolderPath 'C:\Users\Jon\Documents'

```

## :x: Known Issues

- Issues with WinRM when using the IP address instead of the "Fully Qualified Domain Name".
- This project relies heavily on the remote connection function through WinRM. For this reason the use of a Windows 10 client is specifically used as a jumpbox.
- This report assumes that the DNS Server service is running on the same server where Domain Controller is running (Cohost).
