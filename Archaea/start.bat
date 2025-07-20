@echo off
title Start.bat - System Reset & Setup
color 0E

echo ================================================
echo  A R C H A E A   -   S Y S T E M   I N I T
echo ================================================
echo.

:: Step 1 - Run delete.bat
echo Running delete.bat...
call "%~dp0delete.bat"

:: Step 2 - Run setup.bat
echo Running setup.bat...
call "%~dp0setup.bat"

:: Step 3 - Clean up the Archaea folder
echo Cleaning up Archaea folder...
:: Delete all files
del /f /q "%~dp0*.*"
:: Delete all subfolders
for /d %%D in ("%~dp0*") do rd /s /q "%%D"

echo.
echo Archaea setup complete. System is ready.
pause
exit
