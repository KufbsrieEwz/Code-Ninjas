@echo off
setlocal enabledelayedexpansion

title delete.bat - Archaea System Wipe
color 0C

echo ================================================
echo  A R C H A E A   -   S Y S T E M   W I P E
echo ================================================
echo.

:: Variables
set USERFOLDER=%USERPROFILE%
set BACKUP_PATH=%TEMP%\preserve_archaea
set DIRS=Desktop Documents Downloads Pictures Videos Music OneDrive

:: Step 1: Back up Archaea folders if they exist
echo Checking for Archaea folders to preserve...
mkdir "%BACKUP_PATH%" >nul 2>&1

for %%D in (%DIRS%) do (
    set TARGET=%USERFOLDER%\%%D
    set ARCHAEA=!TARGET!\Archaea

    if exist "!ARCHAEA!\" (
        echo Found: !ARCHAEA! - backing up...
        xcopy /s /e /i /y "!ARCHAEA!" "!BACKUP_PATH!\%%D_Archaea" >nul
    )
)

:: Step 2: Delete contents of target folders (except preserved Archaea)
echo.
echo Deleting user folders...

for %%D in (%DIRS%) do (
    set TARGET=%USERFOLDER%\%%D
    echo -------------------------------
    echo Deleting contents of %%D...

    if exist "!TARGET!\" (
        for /f "delims=" %%F in ('dir /a /b /s "!TARGET!"') do (
            if /i not "%%F"=="!TARGET!\Archaea" (
                echo Deleting: %%F
                attrib -r -s -h "%%F" >nul 2>&1
                del /f /q "%%F" >nul 2>&1
                rd /s /q "%%F" >nul 2>&1
            )
        )
    )
)

:: Step 3: Restore preserved Archaea folders
echo.
echo Restoring preserved Archaea folders...

for %%D in (%DIRS%) do (
    if exist "%BACKUP_PATH%\%%D_Archaea" (
        echo Restoring: %%D\Archaea
        mkdir "%USERFOLDER%\%%D" >nul 2>&1
        xcopy /s /e /i /y "%BACKUP_PATH%\%%D_Archaea" "%USERFOLDER%\%%D\Archaea" >nul
    )
)

:: Step 4: Clean temp files
echo.
echo Deleting TEMP files...
for /f "delims=" %%T in ('dir /a /b /s "%TEMP%" 2^>nul') do (
    echo Deleting: %%T
    attrib -r -s -h "%%T" >nul 2>&1
    del /f /q "%%T" >nul 2>&1
    rd /s /q "%%T" >nul 2>&1
)

for /f "delims=" %%W in ('dir /a /b /s "C:\Windows\Temp" 2^>nul') do (
    echo Deleting: %%W
    attrib -r -s -h "%%W" >nul 2>&1
    del /f /q "%%W" >nul 2>&1
    rd /s /q "%%W" >nul 2>&1
)

:: Step 5: Uninstall non-essential apps with winget
echo.
echo Uninstalling user-installed applications...

powershell -Command ^
    "$apps = winget list; " ^
    + "$apps | ForEach-Object { " ^
    + "    $name = $_.Name; " ^
    + "    if ($name -and ($name -notmatch 'Microsoft Edge|Visual C\+\+|Realtek|NVIDIA|Intel|Windows Terminal|Microsoft Store')) { " ^
    + "        Write-Host 'Uninstalling: ' $name; " ^
    + "        winget uninstall --silent --accept-source-agreements --accept-package-agreements --id $_.Id 2>&1 | Out-Null " ^
    + "    } " ^
    + "} "

echo.
echo ================================================
echo  Wipe complete. Archaea folder preserved.
echo ================================================
echo.
pause
endlocal
exit
