@echo off
title Archaea - Safe System Cleanup
color 0C

echo =====================================================
echo        A R C H A E A   -   S Y S T E M   W I P E
echo =====================================================
echo.

set "USERDIR=%USERPROFILE%"
set "KEEPFOLDER=%USERDIR%\Downloads\Archaea"

:: Set critical executables to protect
set "SAFE1=explorer.exe"
set "SAFE2=cmd.exe"
set "SAFE3=SystemSettings.exe"

echo Deleting user data, preserving:
echo - Archaea folder
echo - explorer.exe, cmd.exe, SystemSettings.exe
echo.

:: Loop through top-level user folders
for %%D in (
    Desktop
    Documents
    Pictures
    Videos
    Music
    Downloads
    3DObjects
    Favorites
    Links
    SavedGames
    Searches
    Contacts
) do (
    set "CURRENT=%USERDIR%\%%D"

    echo.
    echo === Processing %%D ===

    if /I "%%D"=="Downloads" (
        :: Special handling for Downloads — skip Archaea
        for %%F in ("%CURRENT%\*") do (
            set "F=%%~nxF"
            call :ShouldDeleteFile "%%F"
            if "!DELETE!"=="1" (
                echo Deleting file: %%F
                del /f /q "%%F" >nul 2>&1
            ) else (
                echo Skipping critical file: %%F
            )
        )

        for /d %%X in ("%CURRENT%\*") do (
            if /I not "%%~fX"=="%KEEPFOLDER%" (
                echo Deleting folder: %%X
                rd /s /q "%%X"
            ) else (
                echo Skipping folder: %%X
            )
        )
    ) else (
        if exist "%CURRENT%" (
            echo Deleting contents of %CURRENT%...
            for %%F in ("%CURRENT%\*") do (
                set "F=%%~nxF"
                call :ShouldDeleteFile "%%F"
                if "!DELETE!"=="1" (
                    echo Deleting file: %%F
                    del /f /q "%%F" >nul 2>&1
                ) else (
                    echo Skipping critical file: %%F
                )
            )

            for /d %%X in ("%CURRENT%\*") do (
                echo Deleting folder: %%X
                rd /s /q "%%X"
            )
        )
    )
)

echo.
echo =============================================
echo     D E L E T I O N   C O M P L E T E
echo =============================================
pause
exit /b

:: --- Function to determine if file is safe to delete ---
:ShouldDeleteFile
set "DELETE=1"
set "NAME=%~nx1"
if /I "%NAME%"=="%SAFE1%" set "DELETE=0"
if /I "%NAME%"=="%SAFE2%" set "DELETE=0"
if /I "%NAME%"=="%SAFE3%" set "DELETE=0"
exit /b
