@echo off
setlocal EnableDelayedExpansion

:: Check if Git is installed
call where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Please install Git from https://gitforwindows.org/.
    pause
    exit /b 1
)

echo Git is installed.

:: Check if SSH is available
call where ssh >nul 2>nul
if %errorlevel% neq 0 (
    echo SSH is not available. Please ensure that SSH is installed and available in your PATH.
    pause
    exit /b 1
)

echo SSH is available.

:: Check if ssh-keygen is available
call where ssh-keygen >nul 2>nul
if %errorlevel% neq 0 (
    echo ssh-keygen is not available. Please ensure that OpenSSH is installed and available in your PATH.
    pause
    exit /b 1
)

echo ssh-keygen is available.

:: Check if the current directory is a Git repository
if not exist ".git" (
    echo This directory is not a Git repository. Please navigate to a Git repository directory.
    pause
    exit /b 1
)

echo Current directory is a Git repository.

:: Accept command-line arguments
set gitUserName=%1
set email=%2
set name=%3

echo Git User Name: %gitUserName%
echo Email: %email%
echo Identifiable Name: %name%

:: Validate IDENTIFIABLE_NAME
set validName=true
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" %%a in ("%name%") do set validName=false

if "%name%"=="" (
    echo Identifiable name cannot be empty.
    exit /b 1
)

if "!validName!"=="false" (
    echo Identifiable name cannot contain spaces or symbols.
    exit /b 1
)

:: Check if the SSH key file already exists
set "sshKeyFile=C:\Users\%USERNAME%\.ssh\id_rsa_%name%"
if exist "%sshKeyFile%" (
    echo There is already a Git profile with the given identifiable name.
    exit /b 1
)

:: Generate the SSH key
ssh-keygen -t rsa -C "%email%" -f "%sshKeyFile%"

:: Inform the user of the successful key generation
if %errorlevel% neq 0 (
    echo Failed to generate SSH key.
    exit /b 1
)

echo SSH key successfully generated at %sshKeyFile%.

:: Configure Git to use the new SSH key
git config core.sshCommand "ssh -i ~/.ssh/id_rsa_%name%"

echo Git SSH configuration updated to use the new key.

:: Configure Git user name and email
git config user.name "%gitUserName%"
git config user.email "%email%"

echo Git user name and email configured:
echo user.name: %gitUserName%
echo user.email: %email%

:: Final message
echo Setting up Git profile is done.
exit /b 0
