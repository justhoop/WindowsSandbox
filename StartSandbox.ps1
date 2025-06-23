<#
.SYNOPSIS
    A Windows Sandbox script to handle the configuration of different options available.
.DESCRIPTION
    Currently has the option to create a sandbox with common development/management tools and another to handle suspect
    files/programs. 
.NOTES
    
.LINK
    
.EXAMPLE
    StartSandbox
    Run with an option to select which tools are installed after the creation of the sandbox
    StartSandbox -secure
    Run with a few security tools available in th sandbox and no network connection
#>

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $secure
)

function Get-Tools {
    param (
        [switch]
        $secure
    )
    if (-not (Test-Path .\Scripts\BurntToast)) {
        Invoke-WebRequest -Uri "https://github.com/Windos/BurntToast/releases/latest/download/BurntToast.zip" -OutFile .\Scripts\BurntToast.zip
        Expand-Archive .\Scripts\BurntToast.zip -DestinationPath .\Scripts\BurntToast
        Remove-Item .\Scripts\BurntToast.zip
    }
    if ($secure) {
        if (-not(Test-Path .\Scripts\mbam.exe)) {
            Invoke-WebRequest -Uri "https://downloads.malwarebytes.com/file/mb5_offline" -OutFile .\Scripts\mbam.exe
        }
        if (-not(Test-Path .\Scripts\msert.exe)) {
            Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkId=212732"  -OutFile .\Scripts\msert.exe
        }
        if (-not(Test-Path .\Scripts\Python.exe)) {
            Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.13.5/python-3.13.5-amd64.exe" -OutFile .\Scripts\Python.exe
        }
        if (-not(Test-Path .\Scripts\pdf-parser_V0_7_12.zip)) {
            Invoke-WebRequest -Uri "https://didierstevens.com/files/software/pdf-parser_V0_7_12.zip" -OutFile .\Scripts\pdf-parser_V0_7_12.zip
        }
        if (-not(Test-Path .\Scripts\pdfid_v0_2_10.zip)) {
            Invoke-WebRequest -Uri "https://didierstevens.com/files/software/pdfid_v0_2_10.zip" -OutFile .\Scripts\pdfid_v0_2_10.zip
        }
    }
}

[xml]$config = Get-Content .\BaseConfig.wsb

$config.configuration.MappedFolders.ChildNodes | Where-Object { $_.'#comment' -match "Scripts" } | ForEach-Object { $_.HostFolder = (Get-Location).path + "\Scripts" }
$config.configuration.MappedFolders.ChildNodes | Where-Object { $_.'#comment' -match "Data" } | ForEach-Object { $_.HostFolder = (Get-Location).path + "\Data" }
$config.configuration.MappedFolders.ChildNodes | Where-Object { $_.'#comment' -match "Suspect" } | ForEach-Object { $_.HostFolder = (Get-Location).path + "\Suspect" }

if ($secure) {
    Get-Tools -secure
    $config.configuration.Networking = "Disable"
    $config.OuterXml | out-file sandbox.wsb
}
else {
    Get-Tools
    $config.OuterXml | out-file sandbox.wsb
    $apps = @("Microsoft.PowerShell", "Microsoft.WindowsTerminal", "7zip.7zip", "Microsoft.VisualStudioCode", "Git.Git", "Notepad++.Notepad++", "WiresharkFoundation.Wireshark", "Google.Chrome", "Mozilla.Firefox")
    $selectedApps = $apps | Out-GridView -PassThru
    $selectedApps | ConvertTo-CliXml | Out-File .\Scripts\apps.xml
}

Copy-Item .\sandbox-config.ps1 .\Scripts
Copy-Item .\sandbox-setup.cmd .\Scripts

Invoke-Item .\sandbox.wsb
 