@echo off
rem canvas-scanner suite setup for Windows. Double-click this file.
rem It installs Hermes Agent (if needed), then runs scripts/setup.sh to
rem configure OpenRouter, the free Nemotron 550B model, and the suite skills.

setlocal
title Canvas Scanner Suite setup
cd /d "%~dp0"

where hermes >nul 2>nul
if %errorlevel%==0 goto have_hermes
if exist "%LOCALAPPDATA%\hermes\bin\hermes.exe" goto have_hermes
if exist "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe" goto have_hermes

echo.
echo Hermes Agent was not found. Installing it now (one-time download).
echo This opens a PowerShell window. If an interactive setup wizard appears
echo at the very end, press Ctrl+C to skip it: this setup configures
echo everything automatically in the next step.
echo.
pause
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)"
if not exist "%LOCALAPPDATA%\hermes\bin\hermes.exe" (
    echo.
    echo The Hermes install did not finish. Check the PowerShell window for
    echo errors, then re-run this file. (Missing git is auto-installed by
    echo Hermes, but a manual Git for Windows from git-scm.com also fixes it.)
    pause
    exit /b 1
)

:have_hermes
rem locate a bash.exe: Hermes bundles PortableGit, otherwise use system Git
set "BASH_PATH="
if exist "%LOCALAPPDATA%\hermes\git\usr\bin\bash.exe" set "BASH_PATH=%LOCALAPPDATA%\hermes\git\usr\bin\bash.exe"
if not defined BASH_PATH if exist "%LOCALAPPDATA%\hermes\git\bin\bash.exe" set "BASH_PATH=%LOCALAPPDATA%\hermes\git\bin\bash.exe"
if not defined BASH_PATH if exist "C:\Program Files\Git\bin\bash.exe" set "BASH_PATH=C:\Program Files\Git\bin\bash.exe"
if not defined BASH_PATH if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_PATH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_PATH (
    echo.
    echo Could not find bash (Git). Installing Git for Windows from
    echo git-scm.com fixes this, then re-run this file.
    pause
    exit /b 1
)

echo.
echo Running the setup script. You will be asked for your OpenRouter API key
echo (free account at openrouter.ai, then Keys). Paste it and press Enter.
echo.
"%BASH_PATH%" scripts/setup.sh --no-install
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" (
    echo Setup finished with errors (see above).
    pause
    exit /b %RC%
)
echo Setup complete. Open a NEW terminal and run:  hermes desktop
echo.
pause
exit /b 0
