@echo off
setlocal enabledelayedexpansion
title Archaea Setup
color 0A

echo ================================================
echo      A R C H A E A   -   S E T U P   S T A R T
echo ================================================
echo.

:: Set DNS to 192.168.1.240 on all connected adapters
echo Configuring DNS to 192.168.1.240 on all connected adapters...

for /f "tokens=1,* delims=:" %%A in ('netsh interface show interface ^| findstr /I "Connected"') do (
    set "LINE=%%A"
    for /f "tokens=*" %%I in ("!LINE!") do (
        call :Trim "%%I"
        set INTERFACE_NAME=!str!
        echo Setting DNS for adapter: "!INTERFACE_NAME!"...
        netsh interface ipv4 set dns name="!INTERFACE_NAME!" static 192.168.1.240 primary >nul 2>&1
    )
)

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
call :InstallApp "Brave.Brave" "Brave Browser"
call :InstallApp "MITMediaLab.Scratch.3" "Scratch 3"
call :InstallApp "Mojang.MinecraftLauncher" "Minecraft"
call :InstallApp "9NBLGGH4R2R6" "Minecraft Education"
call :InstallApp "Roblox.Roblox" "Roblox Player"
call :InstallApp "MaximumADHD.RobloxStudioModManager" "Roblox Studio"
call :InstallApp "MCreator.MCreator" "MCreator"
call :InstallApp "GitHub.GitHubDesktop" "GitHub Desktop"
call :InstallApp "MartiCliment.UniGetUI" "UniGetUI"

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
pause
exit /b

:: Trim leading/trailing spaces from a string
:Trim
set "str=%~1"
:TrimLoop
if "%str:~0,1%"==" " set "str=%str:~1%" & goto TrimLoop
if not "%str:~-1%"==" " goto :EOF
set "str=%str:~0,-1%"
goto TrimLoop

:: Function to install apps via winget
:InstallApp
set "PACKAGE_ID=%~1"
set "FRIENDLY_NAME=%~2"
echo.
echo Installing %FRIENDLY_NAME%...
winget install --exact --id %PACKAGE_ID% --accept-package-agreements --accept-source-agreements
goto :eof
