@echo off
setlocal enabledelayedexpansion
title Archaea Setup
color 0A

echo ================================================
echo     A R C H A E A   -   S E T U P   S T A R T
echo ================================================
echo.

:: Prompt for interface name
set "INTERFACE_NAME=WiFi"
echo.
echo Configuring DNS to 192.168.1.240 on adapter: "!INTERFACE_NAME!"...

:: Set static DNS
netsh interface ipv4 set dns name="!INTERFACE_NAME!" static 192.168.1.240 primary
netsh interface ipv4 add dns name="!INTERFACE_NAME!" 192.168.1.240 index=2

:: Check for winget
echo.
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: winget not found! Install App Installer manually from the Microsoft Store.
    pause
    exit /b 1
)

:: Install software using winget
echo Updating winget sources...
winget source update

echo.
echo Installing required applications...

call :InstallApp "Unity.UnityHub" "Unity Hub"

:: Wait briefly before checking install path
echo Waiting for Unity Hub to be installed...
timeout /t 10 >nul

:: Install Unity Editor via Unity Hub CLI
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

:: Install SuperCode from Archaea folder
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

echo.
echo ================================================
echo          S E T U P   C O M P L E T E
echo ================================================
exit /b

:: Function to install apps via winget
:InstallApp
set "PACKAGE_ID=%~1"
set "FRIENDLY_NAME=%~2"
echo.
echo Installing %FRIENDLY_NAME%...
winget install --exact --id %PACKAGE_ID% --accept-package-agreements --accept-source-agreements
goto :eof
