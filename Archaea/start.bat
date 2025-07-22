@echo off
title Start.bat - System Reset & Setup
color 0E

echo =====================================================
echo       A R C H A E A   -   S Y S T E M   I N I T
echo =====================================================
echo.

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
) > "%CLEANUP_SCRIPT%"

:: Step 4 - Run cleanup script in background
start "" "%CLEANUP_SCRIPT%"

echo.
echo Archaea setup complete. System is ready.
pause
exit
