
$RegPath = "HKCU:\Software\Microsoft\VSCommon\14.0\ClientServices\TokenStorage\VisualStudio\VssApp\"
Get-ChildItem $RegPath | ForEach-Object {
    $childPath =$_.Name.Replace('HKEY_CURRENT_USER', 'HKCU:')
    Remove-Item -Path $childPath -Recurse          
}
