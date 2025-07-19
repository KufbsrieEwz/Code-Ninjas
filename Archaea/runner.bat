@echo off
setlocal

:: Define paths
set DOWNLOADS=%USERPROFILE%\Downloads
set SETUP_NAME=setup.bat
set SUPER_EXE=supercode.exe

echo Copying %SETUP_NAME% and %SUPER_EXE% to %DOWNLOADS%...

:: Copy both files
copy /Y "%~dp0%SETUP_NAME%" "%DOWNLOADS%\%SETUP_NAME%"
copy /Y "%~dp0%SUPER_EXE%" "%DOWNLOADS%\%SUPER_EXE%"

:: Check if both files were copied
if exist "%DOWNLOADS%\%SETUP_NAME%" if exist "%DOWNLOADS%\%SUPER_EXE%" (
    echo Files copied successfully.

    :: Run setup.bat as admin from Downloads
    echo Running setup.bat as administrator...
    powershell -Command "Start-Process '%DOWNLOADS%\%SETUP_NAME%' -Verb RunAs"
) else (
    echo ERROR: One or both files failed to copy.
)

:: Exit script
exit /b
