@echo off
title Awake.bat - Copy Archaea Files and Start
color 0B

echo ===============================================
echo  A R C H A E A   -   B O O T   I N I T I A T E D
echo ===============================================
echo.

:: Set USB drive (where this script is running from)
set USB=%~d0

:: Set destination folder in Downloads
set TARGET=%USERPROFILE%\Downloads\Archaea

:: Create Archaea folder if not exists
if not exist "%TARGET%\" (
    echo Creating Archaea folder in Downloads...
    mkdir "%TARGET%"
)

echo Copying all files from USB to Archaea...
xcopy "%USB%\*" "%TARGET%\" /s /e /i /y >nul

echo.
echo Launching start.bat from Archaea...
start "" "%TARGET%\start.bat"

echo.
echo Done. You may now unplug the USB.
exit
