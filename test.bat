@echo installing credential providers
@Powershell.exe -executionpolicy remotesigned -File  .\scripts\credentialprovider.ps1 -force
::@Powershell.exe -executionpolicy remotesigned -File  .\scripts\reset-credential-key.ps1 
@IF ERRORLEVEL 1 GOTO errorHandling
.paket\paket.exe restore -f
:errorHandling
@exit /b