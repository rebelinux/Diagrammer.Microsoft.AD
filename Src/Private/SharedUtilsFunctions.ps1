
function Remove-SpecialChar {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to remove unsupported graphviz dot characters.
    .DESCRIPTION
    .NOTES
        Version:        0.1.2
        Author:         Prateek Singh
    .EXAMPLE
        Remove-SpecialChar -String "Non Supported chars ()[]{}&."
    .LINK
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [string]$String,
        [string]$SpecialChars = "()[]{}&."
    )

    if ($PSCmdlet.ShouldProcess($String, ("Remove {0} chars" -f $SpecialChars, $String))) {
        $String -replace $($SpecialChars.ToCharArray().ForEach( { [regex]::Escape($_) }) -join "|"), ""
    }
}


function Get-IconType {
    <#
    .SYNOPSIS
        Used by Diagrammer.Microsoft.AD to translate repository type to icon type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String
    )

    $IconType = Switch ($String) {
        'LinuxLocal' { 'VBR_Linux_Repository' }
        'WinLocal' { 'VBR_Windows_Repository' }
        'Cloud' { 'VBR_Cloud_Repository' }
        'AzureBlob' { 'VBR_Cloud_Repository' }
        'AmazonS3' { 'VBR_Cloud_Repository' }
        'AmazonS3Compatible' { 'VBR_Cloud_Repository' }
        'AmazonS3Glacier' { 'VBR_Cloud_Repository' }
        'AzureArchive' { 'VBR_Cloud_Repository' }
        'DDBoost' { 'VBR_Deduplicating_Storage' }
        'HPStoreOnceIntegration' { 'VBR_Deduplicating_Storage' }
        'SanSnapshotOnly' { 'VBR_Storage_NetApp' }
        'Proxy' { 'VBR_Repository' }
        'ESXi' { 'VBR_ESXi_Server' }
        'HyperVHost' { 'Hyper-V_host' }
        default { 'VBR_No_Icon' }
    }

    return $IconType
}

function Get-RoleType {
    <#
    .SYNOPSIS
        Used by Diagrammer.Microsoft.AD to translate role type to function type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String
    )

    $RoleType = Switch ($String) {
        'LinuxLocal' { 'Linux Local' }
        'WinLocal' { 'Windows Local' }
        'DDBoost' { 'Dedup Appliances' }
        'HPStoreOnceIntegration' { 'Dedup Appliances' }
        'Cloud' { 'Cloud' }
        'SanSnapshotOnly' { 'SAN' }
        "vmware" { 'VMware Backup Proxy' }
        "hyperv" { 'HyperV Backup Proxy' }
        default { 'Backup Repository' }
    }

    return $RoleType
}

function Get-NodeIP {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate node name to an network ip address type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$Hostname
    )

    try {
        try {
            if ("InterNetwork" -in [System.Net.Dns]::GetHostAddresses($Hostname).AddressFamily) {
                $IPADDR = ([System.Net.Dns]::GetHostAddresses($Hostname) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }).IPAddressToString
            } elseif ("InterNetworkV6" -in [System.Net.Dns]::GetHostAddresses($Hostname).AddressFamily) {
                $IPADDR = ([System.Net.Dns]::GetHostAddresses($Hostname) | Where-Object { $_.AddressFamily -eq 'InterNetworkV6' }).IPAddressToString
            } else {
                $IPADDR = 127.0.0.1
            }
        } catch { $null }
        $NodeIP = Switch ([string]::IsNullOrEmpty($IPADDR)) {
            $true { 'Unknown' }
            $false { $IPADDR }
            default { $Hostname }
        }
    } catch {
        $_
    }

    return $NodeIP
}

function ConvertTo-TextYN {
    <#
    .SYNOPSIS
    Used by As Built Report to convert true or false automatically to Yes or No.
    .DESCRIPTION
    .NOTES
        Version:        0.3.0
        Author:         LEE DAILEY
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    [OutputType([String])]

    Param
    (
        [Parameter (
            Position = 0,
            Mandatory)]
        [AllowEmptyString()]
        [string]
        $TEXT
    )

    switch ($TEXT) {
        "" { "-" }
        $Null { "-" }
        "True" { "Yes"; break }
        "False" { "No"; break }
        default { $TEXT }
    }
} # end

function Write-ColorOutput {
    <#
    .SYNOPSIS
        Used by Diagrammer.Microsoft.AD to output colored text.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Prateek Singh
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([String])]

    Param
    (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Color,

        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $String
    )
    # save the current color
    $ForegroundColor = $Host.UI.RawUI.ForegroundColor

    # set the new color
    $Host.UI.RawUI.ForegroundColor = $Color

    # output
    if ($String) {
        Write-Output $String
    }

    # restore the original color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
}

function Split-array {

    param(
        $inArray,
        [int]$parts,
        [int]$size)

    if ($parts) {
        $PartSize = [Math]::Ceiling($inArray.count / $parts)
    }
    if ($size) {
        $PartSize = $size
        $parts = [Math]::Ceiling($inArray.count / $size)
    }

    $outArray = @()
    for ($i = 1; $i -le $parts; $i++) {
        $start = (($i - 1) * $PartSize)
        $end = (($i) * $PartSize) - 1
        if ($end -ge $inArray.count) {
            $end = $inArray.count
        }
        $outArray += , @($inArray[$start..$end])
    }
    return , $outArray

}

function Test-Image {
    <#
.SYNOPSIS
    Used by Diagrammer.AD to validate supported logo image extension.
.DESCRIPTION
.NOTES
    Version:        0.1.0
    Author:         Doctor Scripto
.EXAMPLE
    Test-Image -Path "C:\Users\jocolon\logo.png"
.LINK
    https://devblogs.microsoft.com/scripting/psimaging-part-1-test-image/
#>

    [CmdletBinding()]
    param(

        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        $Path
    )

    PROCESS {
        $knownImageExtensions = @( ".jpeg", ".jpg", ".png" )
        $extension = [System.IO.Path]::GetExtension($Path)
        return $knownImageExtensions -contains $extension.ToLower()
    }
}

function Test-Logo {
    <#
    .SYNOPSIS
        Used by Diagrammer.AD to validate logo path.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Joanthan Colon
    .EXAMPLE
        Test-Image -LogoPath "C:\Users\jocolon\logo.png"
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param(

        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        $LogoPath,
        [Switch] $Signature
    )

    PROCESS {
        if ([string]::IsNullOrEmpty($LogoPath)) {
            if ($Signature) {
                return "AD_LOGO_Footer"
            } else {
                return "Microsoft_Logo"
            }
        } else {
            if (Test-Image -Path $LogoPath) {
                # Add logo path to the Image variable
                Copy-Item -Path $LogoPath -Destination $IconPath
                $outputLogoFile = Split-Path $LogoPath -Leaf
                if ($outputLogoFile) {
                    $Images.Add("Custom", $outputLogoFile)
                    return "Custom"
                }
            } else {
                throw "New-ADDiagram : Logo isn't a supported image file. Please use the following format [.jpeg, .jpg, .png]"
            }
        }
    }
}

function Convert-IpAddressToMaskLength {
    <#
    .SYNOPSIS
    Used by As Built Report to convert subnet mask to dotted notation.
    .DESCRIPTION

    .NOTES
        Version:        0.4.0
        Author:         Ronald Rink

    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter (
            Position = 0,
            Mandatory)]
        [string]
        $SubnetMask
    )

    [IPAddress] $MASK = $SubnetMask
    $octets = $MASK.IPAddressToString.Split('.')
    $result = $Null
    foreach ($octet in $octets) {
        while (0 -ne $octet) {
            $octet = ($octet -shl 1) -band [byte]::MaxValue
            $result++;
        }
    }
    return $result;
}

function ConvertTo-ADObjectName {
    <#
    .SYNOPSIS
    Used by As Built Report to translate Active Directory DN to Name.
    .DESCRIPTION

    .NOTES
        Version:        0.4.0
        Author:         Jonathan Colon

    .EXAMPLE

    .LINK

    #>
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DN,
        $Session,
        $DC
    )
    $ADObject = @()
    foreach ($Object in $DN) {
        $ADObject += Invoke-Command -Session $Session { Get-ADObject $using:Object -Server $using:DC | Select-Object -ExpandProperty Name }
    }
    return $ADObject;
}# end

function Get-ADObjectSearch {
    <#
    .SYNOPSIS
    Used by As Built Report to lookup Object subtree in Active Directory.
    .DESCRIPTION

    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon

    .EXAMPLE

    .LINK

    #>
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DN,
        $Session,
        $Filter,
        $Properties = "*",
        $SelectPrty

    )
    $ADObject = @()
    foreach ($Object in $DN) {
        $ADObject += Invoke-Command -Session $Session { Get-ADObject -SearchBase $using:DN -SearchScope OneLevel -Filter $using:Filter -Properties $using:Properties -EA 0 | Select-Object $using:SelectPrty }
    }
    return $ADObject;
}# end

function ConvertTo-ADCanonicalName {
    <#
    .SYNOPSIS
    Used by As Built Report to translate Active Directory DN to CanonicalName.
    .DESCRIPTION

    .NOTES
        Version:        0.4.0
        Author:         Jonathan Colon

    .EXAMPLE

    .LINK

    #>
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $DN,
        $Domain,
        $DC
    )
    $ADObject = @()
    $DC = Invoke-Command -Session $TempPssSession -ScriptBlock { Get-ADDomainController -Discover -Domain $using:Domain | Select-Object -ExpandProperty HostName }
    foreach ($Object in $DN) {
        $ADObject += Invoke-Command -Session $TempPssSession { Get-ADObject $using:Object -Properties * -Server $using:DC | Select-Object -ExpandProperty CanonicalName }
    }
    return $ADObject;
}# end