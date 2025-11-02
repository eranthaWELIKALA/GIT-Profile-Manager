@echo off
setlocal

set "name=PERSONAL"
set "sshKeyFile=C:\Users\%USERNAME%\.ssh\id_rsa_%name%"

echo The SSH key file path is: "%sshKeyFile%"

if exist "%sshKeyFile%" (
    echo File exists.
) else (
    echo File does not exist.
)

endlocal
pause
