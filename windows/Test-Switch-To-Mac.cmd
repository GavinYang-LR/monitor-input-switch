@echo off
setlocal
cd /d "%~dp0"
echo Testing DDC input switching using the configuration in this package...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Switch-To-Mac.ps1" -VerboseMode
set "TEST_RESULT=%ERRORLEVEL%"
echo.
if not "%TEST_RESULT%"=="0" (
  echo Test failed. Please send the contents of last-run.log.
) else (
  echo The DDC command was accepted by Windows.
)
echo.
pause
exit /b %TEST_RESULT%
