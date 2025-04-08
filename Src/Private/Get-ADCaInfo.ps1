function Get-ADCAInfo {
    <#
    .SYNOPSIS
        Function to extract microsoft active directory certificate authority information.
    .DESCRIPTION
        Build a diagram of the configuration of Microsoft Active Directory to a supported formats using Psgraph.
    .NOTES
        Version:        0.2.10
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Diagrammer.Microsoft.AD
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param()

    begin {
        Write-Verbose -Message ($translate.connectingForest -f $($ForestRoot))
    }

    process {
        try {
            $ForestObj = $ADSystem

            $ConfigNCDN = $ForestObj.PartitionsContainer.Split(',') | Select-Object -Skip 1
            $rootCAs = Get-ADObjectSearch -DN "CN=Certification Authorities,CN=Public Key Services,CN=Services,$($ConfigNCDN -join ',')" -Filter { objectClass -eq "certificationAuthority" } -Properties "*" -SelectPrty 'DistinguishedName', 'Name', 'cACertificate' -Session $TempPssSession

            $subordinateCAs = Get-ADObjectSearch -DN "CN=Enrollment Services,CN=Public Key Services,CN=Services,$($ConfigNCDN -join ',')" -Filter { objectClass -eq "pKIEnrollmentService" } -Properties "*" -SelectPrty 'dNSHostName', 'Name', 'cACertificate' -Session $TempPssSession

            $CAInfo = @()
            if ($rootCAs) {
                foreach ($rootCA in $rootCAs) {

                    $AditionalInfo = [ordered] @{
                        $translate.caNotBefore = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($rootCA.cACertificate[0]).NotBefore.ToShortDateString()
                        $translate.caNotAfter = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($rootCA.cACertificate[0]).NotAfter.ToShortDateString()
                        $translate.caType = $translate.caEnterpriseCA
                    }

                    $TempCAInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String "$($rootCA.Name)RootCA" -SpecialChars '\-. '
                        CAName = $rootCA.Name
                        Label = Get-DiaNodeIcon -Name $rootCA.Name -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalInfo
                        AditionalInfo = $AditionalInfo
                        IsRoot = $true
                    }
                    $CAInfo += $TempCAInfo
                }
            } else {
                if ($subordinateCAs) {
                    foreach ($subordinateCA in $subordinateCAs) {

                        $AditionalInfo = [ordered] @{
                            $translate.caNotBefore = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).NotBefore.ToShortDateString()
                            $translate.caNotAfter = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).NotAfter.ToShortDateString()
                            $translate.caType = $translate.caStandaloneCA
                        }

                        $RootCAName = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).Issuer.Split(',').Split('=')[1]

                        $TempCAInfo = [PSCustomObject]@{
                            Name = Remove-SpecialChar -String $RootCAName -SpecialChars '\-. '
                            CAName = $RootCAName
                            Label = Get-DiaNodeIcon -Name $RootCAName -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalInfo
                            AditionalInfo = $AditionalInfo
                            IsRoot = $true
                        }
                        $CAInfo += $TempCAInfo
                    }
                }
            }
            if ($subordinateCAs) {
                foreach ($subordinateCA in $subordinateCAs) {

                    $AditionalInfo = [ordered] @{
                        $translate.caDnsName = $subordinateCA.dNSHostName
                        $translate.caRootCaIssuer = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).Issuer.Split(',').Split('=')[1]
                        $translate.caNotBefore = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).NotBefore.ToShortDateString()
                        $translate.caNotAfter = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($subordinateCA.cACertificate[0]).NotAfter.ToShortDateString()
                        $translate.caType = $translate.caSubordinateCA
                    }

                    $TempCAInfo = [PSCustomObject]@{
                        Name = Remove-SpecialChar -String $subordinateCA.Name -SpecialChars '\-. '
                        CAName = $subordinateCA.Name
                        Label = Get-DiaNodeIcon -Name $subordinateCA.dNSHostName -IconType "AD_Domain" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -Rows $AditionalInfo
                        AditionalInfo = $AditionalInfo
                        IsRoot = $false
                    }
                    $CAInfo += $TempCAInfo
                }

            }

            return $CAInfo

        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}$CAInfo