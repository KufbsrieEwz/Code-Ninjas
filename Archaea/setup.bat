@echo off
setlocal enabledelayedexpansion
title Archaea Setup
color 0A

echo ================================================
echo     A R C H A E A   -   S E T U P   S T A R T
echo ================================================
echo.

:: Check for winget
echo Checking for winget...
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: winget not found! Install App Installer manually from the Microsoft Store.
    pause
    exit /b 1
)

:: Update winget sources
echo Updating winget sources...
winget source update

echo.
echo Installing required applications...

:: Install Unity Hub
call :InstallApp "Unity.UnityHub" "Unity Hub"

:: Wait for Unity Hub installation
echo Waiting for Unity Hub to finish installing...
timeout /t 10 >nul

:: Install Unity Editors via Unity Hub CLI
set "UNITY_HUB_EXE=C:\Program Files\Unity Hub\Unity Hub.exe"
if exist "!UNITY_HUB_EXE!" (
    echo Installing Unity Editor 2022.3.20f1...
    start /wait "" "!UNITY_HUB_EXE!" -- --headless install --version 2022.3.20f1 --changeset 84ab732f9cbd --module win-mono

    echo Installing Unity Editor 6.2.0b10...
    start /wait "" "!UNITY_HUB_EXE!" -- --headless install --version 6.2.0b10 --changeset eb0fd4b17661 --module win-mono
) else (
    echo ERROR: Unity Hub not found at expected location: !UNITY_HUB_EXE!
)

:: Install other applications
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

:: Install SuperCode from local folder
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

:: Set DNS for common Wi-Fi names
echo.
echo Configuring DNS for Wi-Fi interfaces...
for %%I in ("Wi-Fi" "WiFi") do (
    netsh interface show interface name=%%~I >nul 2>&1
    if !errorlevel! EQU 0 (
        echo Setting DNS for interface: %%~I
        netsh interface ipv4 set dns name="%%~I" static 192.168.1.240 primary
        netsh interface ipv4 add dns name="%%~I" 192.168.1.240 index=2
    )
)

echo.
echo ================================================
echo          S E T U P   C O M P L E T E
echo ================================================
pause
exit /b

:: Function to install apps via winget
:InstallApp
set "PACKAGE_ID=%~1"
set "FRIENDLY_NAME=%~2"
echo.
echo Installing %FRIENDLY_NAME%...
winget install --exact --id %PACKAGE_ID% --accept-package-agreements --accept-source-agreements
goto :eof
