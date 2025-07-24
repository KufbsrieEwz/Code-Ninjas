@echo off
title Start.bat - System Reset & Setup
color 0E

echo =====================================================
echo       A R C H A E A   -   S Y S T E M   I N I T
echo =====================================================
echo.

:: Check for administrator permissions

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

:: Step 0 - Check for winget
echo.
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

:: Step 1 - Run delete.bat
echo Running delete.bat...
call "%~dp0delete.bat"

:: Step 2 - Run setup.bat
echo Running setup.bat...
call "%~dp0setup.bat"

:: Step 3 - Create a self-deleting cleanup script
echo Creating deferred cleanup script...

set CLEANUP_SCRIPT=%TEMP%\_cleanup_Archaea.bat

(
echo @echo off
echo timeout /t 10 /nobreak >nul
echo tasklist ^| findstr /I "supercode.exe" >nul
echo if %%errorlevel%% equ 0 (
echo     echo SuperCode still running. Cleanup postponed.
echo     exit /b
echo )
echo rd /s /q "%~dp0"
echo del "%%~f0"
echo exit
) > "%CLEANUP_SCRIPT%"

:: Step 4 - Run cleanup script in background
start "" "%CLEANUP_SCRIPT%"

echo.
echo Archaea setup complete. System is ready.
pause
exit
