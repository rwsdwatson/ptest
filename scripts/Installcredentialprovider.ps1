# A PowerShell script that adds the latest version of the Azure Artifacts credential provider
# plugin for Dotnet and/or NuGet to ~/.nuget/plugins directory

param(
    [string]$ProviderPath = "Azure DevOps",
    [string]$packageSourceUrl = "https://pkgs.dev.azure.com/sdl/_apis/public/nuget/client/CredentialProviderBundle.zip",
    [string]$packagename ="CredentialProviderBundle.zip",
    [string]$copyWildcard ="*.exe",
    [switch]$Force
)

write-host "Attempting to install $ProviderPath credential provider."

write-host "`$ProviderPath = $ProviderPath"
write-host "`$packageSourceUrl = $packageSourceUrl"
write-host "`$packagename = $packagename"
write-host "`$Force = $Force"

$script:ErrorActionPreference='Stop'

# Without this, System.Net.WebClient.DownloadFile will fail on a client with TLS 1.0/1.1 disabled
if ([Net.ServicePointManager]::SecurityProtocol.ToString().Split(',').Trim() -notcontains 'Tls12') {
    [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
}

$pluginLocation = "$env:LOCALAPPDATA\NuGet\CredentialProviders"
$tempZipLocation = "$env:TEMP\CredProviderZip"



$azureDevOpsPathExists = Test-Path -Path "$pluginLocation\$ProviderPath"

if (!$Force) {
    if ($azureDevOpsPathExists -eq $True ) {
        Write-Host "The $ProviderPath Credential Provider is already in $pluginLocation"
        return
    }
}
else
{
    if ($azureDevOpsPathExists -eq $True ) {
        Remove-Item "$pluginLocation\$ProviderPath" -Force -Recurse
        }
    $RegPath = "HKCU:\Software\Microsoft\VSCommon\14.0\ClientServices\TokenStorage\VisualStudio\VssApp\"
    Get-ChildItem $RegPath | ForEach-Object {
      $childPath =$_.Name.Replace('HKEY_CURRENT_USER', 'HKCU:')
      Remove-Item -Path $childPath -Recurse          
    }
}


# Create temporary location for the zip file handling
Write-Host "Creating temp directory for the Credential Provider zip: $tempZipLocation"
if (Test-Path -Path $tempZipLocation) {
    Remove-Item $tempZipLocation -Force -Recurse
}
New-Item -ItemType Directory -Force -Path $tempZipLocation

Write-Host "Created: $tempZipLocation"
# Download credential provider zip to the temp location
$pluginZip = "$tempZipLocation\$packagename"
Write-Host "Downloading $packageSourceUrl to $pluginZip"
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($packageSourceUrl, $pluginZip)
} catch {
    Write-Error "Unable to download $packageSourceUrl to the location $pluginZip"
}

# Extract zip to temp directory
Write-Host "Extracting zip to the Credential Provider temp directory"
Add-Type -AssemblyName System.IO.Compression.FileSystem 
[System.IO.Compression.ZipFile]::ExtractToDirectory($pluginZip, $tempZipLocation)

# Create credentials provider folder 
Write-Host "Creating temp directory for the Credential Provider zip: $pluginLocation\$ProviderPath"

New-Item -ItemType Directory -Force -Path "$pluginLocation\$ProviderPath"
# Forcibly copy netcore (and netfx) directories to plugins directory
Write-Host "Copying Credential Provider to $pluginLocation\$ProviderPath"
Write-Host $tempZipLocation

Copy-Item "$tempZipLocation\$copyWildcard" -Destination "$pluginLocation\$ProviderPath" -recurse -Exclude "*.zip"


# Remove $tempZipLocation directory
Write-Host "Removing the Credential Provider temp directory $tempZipLocation"
Remove-Item $tempZipLocation -Force -Recurse

Write-Host "$ProviderPath Credential Provider installed successfully"