@echo off
setlocal
cd /d "%~dp0"
echo Testing AOC CU34G2X DDC input switching...
echo Target: HDMI2 (VCP 0x60 = 0x12)
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
