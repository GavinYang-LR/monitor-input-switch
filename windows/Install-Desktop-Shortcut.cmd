@echo off
setlocal
cd /d "%~dp0"
echo Installing the desktop shortcut...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Desktop-Shortcut.ps1"
set "INSTALL_RESULT=%ERRORLEVEL%"
echo.
if not "%INSTALL_RESULT%"=="0" (
  echo Installation failed with error code %INSTALL_RESULT%.
  echo Please send a photo of the error shown above.
) else (
  echo Installation completed.
)
echo.
pause
exit /b %INSTALL_RESULT%
