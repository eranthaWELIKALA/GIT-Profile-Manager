@echo off
setlocal EnableDelayedExpansion

:: Check for flags
if "%1"=="" (
    echo No command provided. Use create or add.
    echo Help:: "git-profile-manager add" or "git-profile-manager create"
    echo.
    pause
    exit /b 1
)

if "%1"=="create" (
    call :create_profile
    exit /b 0
)

if "%1"=="add" (
    call :add_profile
    exit /b 0
)

echo Invalid command provided. Use create or add.
echo Help:: "git-profile-manager add" or "git-profile-manager create"
echo.
pause
exit /b 1

:create_profile
echo Creating a new Git profile...
:: Include your git-profile-create script logic here
call git-profile-create.bat
exit /b 0

:add_profile
echo Adding an existing Git profile...
:: Include your git-profile-add script logic here
call git-profile-add.bat
exit /b 0

:EOF
