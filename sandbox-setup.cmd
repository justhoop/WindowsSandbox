REM sandbox-setup.cmd
REM This code runs in the context of the Windows Sandbox

REM set execution policy first so that a setup script can be run
powershell.exe -command "&{Set-ExecutionPolicy RemoteSigned -force}"

REM Now run the true configuration script
powershell.exe -file c:\scripts\sandbox-config.ps1