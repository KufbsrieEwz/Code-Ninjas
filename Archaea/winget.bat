@echo off
REM 1. Download latest winget installer
powershell -Command ^
  "$url = (Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_ -match '.msixbundle$' }; ^
   Invoke-WebRequest -Uri $url -OutFile '%TEMP%\winget.msixbundle' -UseBasicParsing;"

REM 2. Install winget
powershell -Command ^
  "Add-AppxPackage -Path '%TEMP%\winget.msixbundle'"

REM 3. Cleanup
del "%TEMP%\winget.msixbundle"

echo Winget installation complete.
pause 
