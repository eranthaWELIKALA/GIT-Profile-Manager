@echo off
setlocal EnableDelayedExpansion

if "%0"=="%~dpnx0" (
    echo This script cannot be run directly. Please run "git-profile-manager add" or "git-profile-manager create" instead.
    pause
    exit /b 1
)

:: Check if Git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Please install Git from https://gitforwindows.org/.
    echo.
    pause
    exit /b 1
)

echo Git is installed.

:: Check if the current directory is a Git repository
if not exist ".git" (
    echo This directory is not a Git repository. Please navigate to a Git repository directory.
    echo.
    pause
    exit /b 1
)

echo Current directory is a Git repository.

set "profiles="
:: List all Git profiles in .ssh folder
echo Existing Git Profiles:
set index=1
echo ==================================================
for %%f in ("C:\Users\%USERNAME%\.ssh\id_rsa_*") do (
    if "%%~xf"=="" (
        set "profileName=%%~nf"
        set "profileName=!profileName:id_rsa_=!"
        echo [!index!] !profileName!
        set profiles=!profiles! !profileName!
        set /a index+=1
    )
)
echo ==================================================

:: Convert profiles to an array
setlocal enabledelayedexpansion
set i=0
for %%p in (!profiles!) do (
    set /a i+=1
    set "profile[!i!]=%%p"
)

:: Ask user to select a Git profile
:select_profile
set /p profile_number="Please select a Git Profile by entering the corresponding number (1 to %i%): "

if not defined profile[%profile_number%] (
    echo Invalid selection. Please try again.
    goto select_profile
)

set selected_profile=!profile[%profile_number%]!
echo You selected: !selected_profile!

:: Configure Git to use the new SSH key
git config core.sshCommand "ssh -i C:/Users/%USERNAME%/.ssh/id_rsa_!selected_profile!"

echo Updated Git configurations to use the selected Git Profile.

:: Final message
echo.
echo Setting up Git profile is done.
echo.
pause
exit /b 0
