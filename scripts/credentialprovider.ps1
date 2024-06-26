# A PowerShell script that adds the latest version of the Azure Artifacts credential provider
# plugin for Dotnet and/or NuGet to ~/.nuget/plugins directory

param(
    [switch]$Force
)

write-host "Sniffing dotnet app runtimes..."
write-host "`$Force = $Force"

$dotnetruntimes = dotnet --list-runtimes
$dotnetruntimes.Count
$dotnetappruntimes = $dotnetruntimes -match  "Microsoft.NetCore.App"
$HighestversionRuntime= $dotnetappruntimes[-1] # you can index arrays backwards with negative numbers !
write-host "Highest dotnet app runtime is $HighestversionRuntime"
$parsedDetails = $HighestversionRuntime -split " "
[version]$ParsedVersion = $parsedDetails[1] #1 is the version part.

if ($ParsedVersion -lt [version]'8.0.0')
{
    throw "dotnet 8.0 runtime is not installed. please download from https://dotnet.microsoft.com/download"
}

& "$PSScriptRoot\InstallCredentialProvider.ps1" "Azure DevOps" "https://pkgs.dev.azure.com/sdl/_apis/public/nuget/client/CredentialProviderBundle.zip" "CredentialProviderBundle.zip" "CredentialProvider.VSS.exe" -Force:$Force.IsPresent

& "$PSScriptRoot\InstallCredentialProvider.ps1" "Paket" "https://github.com/RWS/Paket.CredentialProvider.Gen2Support/releases/download/v.8.0.0/Paket.CredentialProvider.Gen2Support.zip" "Paket.CredentialProvider.Gen2Support.zip" "*" -Force:$Force.IsPresent
