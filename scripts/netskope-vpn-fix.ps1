
#We need to allow the azure cli through the netskope vpn.
#see https://docs.netskope.com/en/netskope-help/data-security/netskope-secure-web-gateway/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception/
#
#this script will create a folder and store a combined certificate for that.

$TargetPath= "$env:LocalAppData\Netskope\STAgent\data"
$CombinedCertificateLocation = "$TargetPath\nscacert_combined.pem"


If(!(test-path -PathType container $TargetPath))
{
    New-Item -ItemType Directory -Force -Path "$TargetPath"
}


((((Get-ChildItem Cert:\CurrentUser\Root) + (Get-ChildItem  Cert:\LocalMachine\Root) + (Get-ChildItem  Cert:\CurrentUser\CA) + (Get-ChildItem  Cert:\LocalMachine\Root)) | Where-Object { $_.RawData -ne $null } `
| Sort-Object -Property Thumbprint -Unique `
| ForEach-Object { "-----BEGIN CERTIFICATE-----", [System.Convert]::ToBase64String($_.RawData, "InsertLineBreaks"), "-----END CERTIFICATE-----", "" }) `
-replace "`r","") -join "`n" `
| Out-File -Encoding ascii "$CombinedCertificateLocation" -NoNewline


#set environment variable
[System.Environment]::SetEnvironmentVariable("REQUESTS_CA_BUNDLE","$CombinedCertificateLocation", "User")

