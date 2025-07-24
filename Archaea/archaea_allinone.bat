@echo off
setlocal enabledelayedexpansion
title Archaea - All-in-One System Reset & Setup
color 0B

:: Check for administrator privileges first
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo =====================================================
    echo   ERROR: Administrator privileges required!
    echo   Please right-click and select "Run as administrator"
    echo =====================================================
    echo.
    pause
    exit /b 1
)

echo =====================================================
echo      A R C H A E A   -   U N I F I E D   S T A R T
echo =====================================================
echo.

:: === STEP 0: Ensure script runs from Downloads\Archaea ===
set "TARGET=%USERPROFILE%\Downloads\Archaea"
if /I not "%~dp0"=="%TARGET%\" (
    echo Script is not running from %TARGET%
    echo Moving to correct location...
    
    if not exist "%TARGET%\" (
        echo Creating Archaea folder in Downloads...
        mkdir "%TARGET%"
    )
    
    echo Copying script and resources...
    xcopy "%~dp0*" "%TARGET%\" /s /e /i /y >nul
    
    echo Launching script from correct location...
    start "" "%TARGET%\archaea_allinone.bat"
    echo Original script location can be safely closed.
    exit /b
)

:: === STEP 1: Install winget if missing ===
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo Winget not found. Attempting to install...
    powershell -Command "\
      $url = (Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_ -match '.msixbundle$' }; \
       Invoke-WebRequest -Uri $url -OutFile '%TEMP%\\winget.msixbundle' -UseBasicParsing;"
    powershell -Command "Add-AppxPackage -Path '%TEMP%\\winget.msixbundle'"
    del "%TEMP%\winget.msixbundle"
    echo Winget installation complete. Please re-run this script.
    pause
    exit /b 1
)

:: === STEP 2: System Wipe (Delete non-critical files) ===
set "EXCLUDED_FOLDER_1=Archaea"
set "DOWNLOADS=%USERPROFILE%\Downloads"
echo Cleaning Downloads folder (excluding "Archaea")...
for %%F in ("%DOWNLOADS%\*") do (
    if /I not "%%~nxF"=="%EXCLUDED_FOLDER_1%" (
        if exist "%%F" (
            echo Deleting file: %%F
            del /f /q "%%F" >nul 2>&1
        )
    ) else (
        echo Skipping folder: %%F
    )
)
for /d %%D in ("%DOWNLOADS%\*") do (
    if /I not "%%~nxD"=="%EXCLUDED_FOLDER_1%" (
        echo Deleting folder: %%D
        rd /s /q "%%D"
    ) else (
        echo Skipping folder: %%D
    )
)
for %%D in (Desktop Documents Pictures Videos Music) do (
    set "DIR=%USERPROFILE%\%%D"
    echo Cleaning %%D...
    if exist "!DIR!" (
        rd /s /q "!DIR!"
        md "!DIR!"
        echo Reset: !DIR!
    )
)
echo.

:: === STEP 3: Install/Update Software and Set DNS ===
echo Updating winget sources...
winget source update
echo.
echo Installing required applications...
call :InstallApp "Unity.UnityHub" "Unity Hub"
echo Waiting for Unity Hub to be installed...
timeout /t 10 >nul
set "UNITY_HUB_EXE=C:\Program Files\Unity Hub\Unity Hub.exe"
if exist "!UNITY_HUB_EXE!" (
    echo Installing Unity Editor 2022.3.20f1 via Unity Hub...
    start /wait "" "!UNITY_HUB_EXE!" -- --headless install --version 2022.3.20f1 --changeset 84ab732f9cbd --module win-mono
) else (
    echo ERROR: Unity Hub not found at expected location: !UNITY_HUB_EXE!
)
call :InstallApp "BlenderFoundation.Blender" "Blender"
call :InstallApp "Brave.Brave" "Brave Browser"
call :InstallApp "MITMediaLab.Scratch.3" "Scratch 3"
call :InstallApp "Mojang.MinecraftLauncher" "Minecraft"
call :InstallApp "9NBLGGH4R2R6" "Minecraft Education"
call :InstallApp "Roblox.Roblox" "Roblox Player"
call :InstallApp "MaximumADHD.RobloxStudioModManager" "Roblox Studio"
call :InstallApp "MCreator.MCreator" "MCreator"
call :InstallApp "GitHub.GitHubDesktop" "GitHub Desktop"
call :InstallApp "MartiCliment.UniGetUI" "UniGetUI"
call :InstallApp "Microsoft.VisualStudio.2022.Community" "Visual Studio 2022 Community"
echo.
echo Installing SuperCode from local copy...
set "SUPERPATH=%USERPROFILE%\Downloads\Archaea\supercode.exe"
if exist "!SUPERPATH!" (
    echo Running !SUPERPATH!...
    start /wait "" "!SUPERPATH!"
    echo SuperCode installed successfully.
) else (
    echo ERROR: supercode.exe not found at !SUPERPATH!
)
set "INTERFACE_NAME=WiFi"
echo.
echo Configuring DNS to 192.168.1.240 on adapter: "!INTERFACE_NAME!"...
netsh interface ipv4 set dns name="!INTERFACE_NAME!" static 192.168.1.240 primary
netsh interface ipv4 add dns name="!INTERFACE_NAME!" 192.168.1.240 index=2

echo.

:: === STEP 4: Deferred Cleanup ===
echo Creating deferred cleanup script...
set CLEANUP_SCRIPT=%TEMP%\_cleanup_Archaea.bat
(
echo @echo off
echo timeout /t 10 /nobreak ^>nul
echo tasklist ^| findstr /I "supercode.exe" ^>nul
echo if %%errorlevel%% equ 0 (
echo     echo SuperCode still running. Cleanup postponed.
echo     exit /b
echo )
echo rd /s /q "%~dp0"
echo del "%%~f0"
echo exit
) > "%CLEANUP_SCRIPT%"
start "" "%CLEANUP_SCRIPT%"

echo.
echo ================================================
echo          S E T U P   C O M P L E T E
echo ================================================
pause
exit /b

:InstallApp
set "PACKAGE_ID=%~1"
set "FRIENDLY_NAME=%~2"
echo.
echo Installing %FRIENDLY_NAME%...
winget install --exact --id %PACKAGE_ID% --accept-package-agreements --accept-source-agreements
goto :eof
