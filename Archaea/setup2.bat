@echo off
setlocal enabledelayedexpansion

:: Prompt for hostname
set /p NEW_HOSTNAME=Enter desired hostname: 

:: Get current hostname
for /f %%A in ('hostname') do set CURRENT_HOSTNAME=%%A

echo Current hostname: %CURRENT_HOSTNAME%
echo Desired hostname: %NEW_HOSTNAME%

if /I "%CURRENT_HOSTNAME%"=="%NEW_HOSTNAME%" (
    echo Hostname is already set to %NEW_HOSTNAME%.
) else (
    echo Changing hostname to %NEW_HOSTNAME%...
    WMIC computersystem where name="%COMPUTERNAME%" call rename name="%NEW_HOSTNAME%"
    echo You must restart for hostname changes to take effect.
)

:: Set DNS to 192.168.1.240 on all adapters
echo Configuring DNS to 192.168.1.240 on all Ethernet and Wi-Fi adapters...
for /f "tokens=*" %%A in ('netsh interface show interface ^| findstr "Connected"') do (
    for /f "tokens=1,* delims=:" %%B in ("%%A") do (
        set INTERFACE_NAME=%%B
        call :Trim !INTERFACE_NAME!
        echo Setting DNS for !INTERFACE_NAME!...
        netsh interface ipv4 set dns name="!INTERFACE_NAME!" static 192.168.1.240 primary
    )
)

:: Check winget availability
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo winget not found! Please install App Installer manually from Microsoft Store.
    pause
    exit /b 1
)

:: Begin installing apps via winget
echo Installing required applications using winget...
winget source update

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
call :InstallApp "VeyonSolutions.Veyon" "Veyon"

:: Run SuperCode installer from Downloads
echo Installing SuperCode...

set DOWNLOADS_PATH=%USERPROFILE%\Downloads
set SUPER_SOURCE=E:\supercode.exe
set SUPER_DEST=%DOWNLOADS_PATH%\supercode.exe

if exist "%SUPER_SOURCE%" (
    echo Copying supercode.exe to %DOWNLOADS_PATH%...
    copy /Y "%SUPER_SOURCE%" "%SUPER_DEST%"
    
    if exist "%SUPER_DEST%" (
        echo Running SuperCode installer from Downloads...
        start /wait "" "%SUPER_DEST%"
        echo SuperCode installed successfully.
    ) else (
        echo ERROR: Failed to copy SuperCode installer to Downloads.
    )
) else (
    echo ERROR: supercode.exe not found at E:\supercode.exe.
)

echo All done! You may want to restart the computer now.
pause
exit /b

:: Trim leading/trailing whitespace
:Trim
set "str=%~1"
:TrimLoop
if "%str:~0,1%"==" " set "str=%str:~1%" & goto TrimLoop
if not "%str:~-1%"==" " goto :EOF
set "str=%str:~0,-1%"
goto TrimLoop

:: Winget app installer function
:InstallApp
set PACKAGE_ID=%~1
set FRIENDLY_NAME=%~2
echo.
echo Installing %FRIENDLY_NAME%...
winget install --exact --id %PACKAGE_ID% --accept-package-agreements --accept-source-agreements
goto :eof
