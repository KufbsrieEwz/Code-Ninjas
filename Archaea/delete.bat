@echo off
setlocal enabledelayedexpansion
title Archaea - System Wipe
color 0C

echo =====================================================
echo        A R C H A E A   -   S Y S T E M   W I P E
echo =====================================================
echo.

:: === SETUP EXCLUSIONS ===
set "EXCLUDED_FOLDER_1=Archaea"
set "SAFE_APP_1=explorer.exe"
set "SAFE_APP_2=cmd.exe"
set "SAFE_APP_3=SystemSettings.exe"

:: === WIPE USER PROFILE FOLDERS (EXCEPT Archaea in Downloads) ===
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

echo.

:: === WIPE OTHER USER FOLDERS ===
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

:: === CLEAN PROGRAM FILES (EXCLUDING SYSTEM CRITICAL ONES) ===
set "PF1=C:\Program Files"
set "PF2=C:\Program Files (x86)"

echo Cleaning %PF1%...
call :CleanProgramFiles "%PF1%"
echo.
echo Cleaning %PF2%...
call :CleanProgramFiles "%PF2%"

echo.

:: === DONE ===
echo.
echo =============================================
echo     D E L E T I O N   C O M P L E T E
echo =============================================
pause
exit /b

:: === Function to clean non-critical folders in Program Files ===
:CleanProgramFiles
set "BASE=%~1"

for /d %%D in ("%BASE%\*") do (
    set "FOLDER=%%~nxD"
    set "DELETE=1"
    if /I "!FOLDER!"=="WindowsApps" set "DELETE=0"
    if /I "!FOLDER!"=="Windows Defender" set "DELETE=0"
    if /I "!FOLDER!"=="Common Files" set "DELETE=0"
    if /I "!FOLDER!"=="Windows NT" set "DELETE=0"
    if /I "!FOLDER!"=="Internet Explorer" set "DELETE=0"

    if "!DELETE!"=="1" (
        echo Deleting: %%D
        rd /s /q "%%D"
    ) else (
        echo Skipping critical folder: %%D
    )
)
goto :eof
