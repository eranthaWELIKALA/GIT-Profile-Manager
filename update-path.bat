@echo off
setlocal

:: Define the path to be added
set "newPath=%~1"

:: Normalize the new path for safer handling
set "newPath=%newPath:\=\\%"

:: Get the current PATH variable from the registry
for /f "tokens=2,*" %%A in ('reg query "HKEY_CURRENT_USER\Environment" /v PATH 2^>nul') do (
    set "currentPath=%%B"
)

:: Check if the new path is already in PATH
echo %currentPath% | findstr /i /c:"%newPath%" >nul
if %ERRORLEVEL%==0 (
    echo The path "%newPath%" is already in PATH
    goto :EOF
)

:: Append the new path to PATH
set "newPathToAdd=%currentPath%;%newPath%"

:: Update PATH in the registry
reg add "HKEY_CURRENT_USER\Environment" /v PATH /t REG_EXPAND_SZ /d "%newPathToAdd%" /f

:: Create a temporary VBScript file for notification
set "vbsFile=%TEMP%\broadcast.vbs"

:: Check if VBScript file creation succeeded
(
    echo Set objShell = CreateObject("WScript.Shell")
    echo objShell.Popup "The PATH environment variable has been updated. You might need to restart any open command prompts or your computer for the changes to take effect.", 0, "Notification", 64
) > "%vbsFile%"

if exist "%vbsFile%" (
    :: Run the VBScript
    cscript //nologo "%vbsFile%"
    
    :: Check if the VBScript ran successfully
    if %ERRORLEVEL% NEQ 0 (
        echo Error running VBScript.
    )
    
    :: Clean up
    del "%vbsFile%"
) else (
    echo Failed to create VBScript file.
)

echo PATH environment variable updated. You might need to restart any open command prompts or your computer for the changes to take effect.

endlocal
