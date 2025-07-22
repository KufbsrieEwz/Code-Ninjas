@echo off
title Start.bat - System Reset & Setup
color 0E

echo =====================================================
echo      A R C H A E A   -   S Y S T E M   I N I T
echo =====================================================
echo.

:: Step 1 - Run delete.bat
echo Running delete.bat...
call "%~dp0delete.bat"

:: Step 2 - Run setup.bat
echo Running setup.bat...
call "%~dp0setup.bat"

:: Step 3 - Prepare to clean up the Archaea folder
echo Preparing Archaea folder cleanup...

:: Change directory to avoid being inside Archaea
cd /d "%USERPROFILE%\Downloads"

:: Create temporary cleanup script
set CLEANUP_SCRIPT=%TEMP%\cleanup.bat
echo @echo off > "%CLEANUP_SCRIPT%"
echo timeout /t 3 /nobreak > "%CLEANUP_SCRIPT%"
echo rd /s /q "%~dp0" >> "%CLEANUP_SCRIPT%"
echo del "%%~f0" >> "%CLEANUP_SCRIPT%"

:: Run the cleanup script
start "" "%CLEANUP_SCRIPT%"

echo.
echo Archaea setup complete. System is ready.
pause
exit
