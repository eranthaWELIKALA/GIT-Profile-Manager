@echo off
setlocal EnableDelayedExpansion

if "%0"=="%~dpnx0" (
    echo This script cannot be run directly. Please run "git-profile-manager add" or "git-profile-manager create" instead.
    echo.
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

:: Check if SSH is available
where ssh >nul 2>nul
if %errorlevel% neq 0 (
    echo SSH is not available. Please ensure that SSH is installed and available in your PATH.
    echo.
    pause
    exit /b 1
)

echo SSH is available.

:: Check if ssh-keygen is available
where ssh-keygen >nul 2>nul
if %errorlevel% neq 0 (
    echo ssh-keygen is not available. Please ensure that OpenSSH is installed and available in your PATH.
    echo.
    pause
    exit /b 1
)

echo ssh-keygen is available.

:: Check if the current directory is a Git repository
if not exist ".git" (
    echo This directory is not a Git repository. Please navigate to a Git repository directory.
    echo.
    pause
    exit /b 1
)

echo Current directory is a Git repository.

:: Prompt for Git user name
set /p gitUserName=Please enter your Git user name: 
echo You entered: %gitUserName%

:: Prompt for email address
set /p email=Please enter your email address: 
echo You entered: %email%

:: Prompt for identifiable name and validate
:prompt_identifiable_name
set /p name=Please enter your identifiable name for Git profile (no spaces or symbols): 
:: Validate IDENTIFIABLE_NAME
set validName=true
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" %%a in ("!name!") do set validName=false

if "!name!"=="" (
    echo Identifiable name cannot be empty. Please try again.
    goto prompt_identifiable_name
)

if not %validName%==true (
    echo Identifiable name cannot contain spaces or symbols. Please try again.
    goto prompt_identifiable_name
)

echo You entered: %name%

:: Check if the SSH key file already exists
set "sshKeyFile=C:\Users\%USERNAME%\.ssh\id_rsa_%name%"
echo "%sshKeyFile%"
if exist "%sshKeyFile%" (
    echo There is already a Git profile with the given identifiable name.
    set /p removeExisting=Do you want to remove the existing key files? [y or n]:
    if /i "%removeExisting%"=="y" (
        echo Removing existing key files...
        del "%sshKeyFile%"
        del "%sshKeyFile%.pub"
        if %errorlevel% neq 0 (
            echo Failed to remove existing key files.
            echo.
            pause
            exit /b 1
        )
        echo Existing key files removed successfully.
    )
) else (
    echo File does not exist
)

echo No existing SSH key file found or existing files removed.

:: Generate the SSH key
ssh-keygen -t rsa -C "%email%" -f "%sshKeyFile%"

:: Inform the user of the successful key generation
if %errorlevel% neq 0 (
    echo Failed to generate SSH key.
    echo.
    pause
    exit /b 1
)

echo SSH key successfully generated at %sshKeyFile%.

set index=1
:: List all Git profiles in .ssh folder
echo Listing all Git profiles in .ssh folder:
echo ==================================================
for %%f in ("C:\Users\%USERNAME%\.ssh\id_rsa_*") do (
    if "%%~xf"=="" (
        set "profileName=%%~nf"
        set "profileName=!profileName:id_rsa_=!"
        echo [!index!] !profileName!
        set /a index+=1
    )
)
echo ==================================================

:: Display the public key
set sshPublicKeyFile=%sshKeyFile%.pub
echo.
echo.
echo.
echo ==================================================
echo ==================================================
echo SSH public key:
echo ==================================================
echo ==================================================
type "%sshPublicKeyFile%"
echo ==================================================
echo ==================================================
echo.
echo.
echo.

:: Configure Git to use the new SSH key
git config core.sshCommand "ssh -i \"C:/Users/%USERNAME%/.ssh/id_rsa_%name%\""

echo Git SSH configuration updated to use the new key.

:: Configure Git user name and email
git config user.name "%gitUserName%"
git config user.email "%email%"
echo.

echo Git user name and email configured:
echo user.name: %gitUserName%
echo user.email: %email%

:: Final message
echo.
echo Setting up Git profile is done.
echo.
pause
exit /b 0
