@echo off
title Archaea - Full User Cleanup
color 0C

echo =====================================================
echo   A R C H A E A   -   S Y S T E M   D E L E T I O N
echo =====================================================
echo.

set "USERDIR=%USERPROFILE%"
set "KEEPFOLDER=%USERDIR%\Downloads\Archaea"

echo Beginning deletion of user data...
echo Preserving: %KEEPFOLDER%
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
        :: Special handling for Downloads — skip Archaea folder
        for %%F in ("%CURRENT%\*") do (
            if /I not "%%~fF"=="%KEEPFOLDER%" (
                if exist "%%F" (
                    echo Deleting file: %%F
                    del /f /q "%%F" >nul 2>&1
                )
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
        :: For all other folders — delete contents
        if exist "%CURRENT%" (
            echo Deleting contents of %CURRENT%...
            del /f /s /q "%CURRENT%\*" >nul 2>&1
            for /d %%X in ("%CURRENT%\*") do (
                echo Deleting folder: %%X
                rd /s /q "%%X"
            )
        )
    )
)

echo.
echo ==========================================
echo      D E L E T I O N   C O M P L E T E
echo ==========================================
pause
exit /b
