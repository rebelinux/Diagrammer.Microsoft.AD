function Get-RequiredFeature {
    <#
    .SYNOPSIS
        Function to check if the required version of windows feature is installed
    .DESCRIPTION
        Function to check if the required version of windows feature is installed
    .NOTES
        Version:        0.1.6
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .PARAMETER Name
        The name of the required windows feature
    .PARAMETER Version
        The version of the required windows feature
    #>

    Param
    (
        [CmdletBinding()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $OSType
    )

    begin {
    }

    process {
        # Check if the required version of Module is installed
        if ($OSType -eq 'WorkStation') {
            $RequiredFeature = Get-WindowsCapability -online -Name $Name -InformationAction SilentlyContinue
            if ($RequiredFeature.State -ne 'Installed')  {
                throw ($translate.osType -f $($Name))
            }
        }
        elseif ($OSType -eq 'Server' -or $OSType -eq 'DomainController') {
            $RequiredFeature = Get-WindowsFeature -Name $Name
            if ($RequiredFeature.InstallState -ne 'Installed')  {
                throw ($translate.osType -f $($Name))
            }
        }
        else {
            throw ($translate.osTypelast -f $($Name))
        }
    }
    end {}
}