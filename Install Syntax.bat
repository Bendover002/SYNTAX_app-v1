@echo off
setlocal
set "HELPER_DIR=%~dp0"
set "ROOT=%HELPER_DIR%"
if not exist "%ROOT%scripts\install-syntax.mjs" if exist "%HELPER_DIR%..\scripts\install-syntax.mjs" set "ROOT=%HELPER_DIR%..\"

where node.exe >nul 2>nul
if errorlevel 1 (
  call :openExistingInstaller
  if not errorlevel 1 exit /b 0
  echo node.exe was not found. Install Node.js or run npm run package:win from a developer terminal.
  pause
  exit /b 1
)

if not exist "%ROOT%scripts\install-syntax.mjs" (
  call :openExistingInstaller
  if not errorlevel 1 exit /b 0
  echo Syntax installer helper could not find scripts\install-syntax.mjs.
  pause
  exit /b 1
)

pushd "%ROOT%"
node.exe "%ROOT%scripts\install-syntax.mjs"
set "INSTALL_EXIT=%ERRORLEVEL%"
popd

if not "%INSTALL_EXIT%"=="0" pause
exit /b %INSTALL_EXIT%

:openExistingInstaller
set "INSTALLER="
for /f "delims=" %%F in ('dir /b /o-d "%HELPER_DIR%Syntax-Setup-*.exe" 2^>nul') do (
  set "INSTALLER=%HELPER_DIR%%%F"
  goto :startExistingInstaller
)
for /f "delims=" %%F in ('dir /b /o-d "%ROOT%Installers\Syntax-Setup-*.exe" 2^>nul') do (
  set "INSTALLER=%ROOT%Installers\%%F"
  goto :startExistingInstaller
)
for /f "delims=" %%F in ('dir /b /o-d "%ROOT%build\Syntax-Setup-*.exe" 2^>nul') do (
  set "INSTALLER=%ROOT%build\%%F"
  goto :startExistingInstaller
)

exit /b 1

:startExistingInstaller
echo Starting %INSTALLER%
start "" "%INSTALLER%"
exit /b 0
