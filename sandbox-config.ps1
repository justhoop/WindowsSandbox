Function Write-Log {
    Param([string]$message)
    $now = (get-date).tostring("yyyy-MM-dd::HH:mm:ss")
    $log = $now + " - $message"
    Write-Host $log
    $log | Out-File -filepath "c:\data\log.txt" -Append
}

$start = Get-Date
Write-Log "Start"

if (Get-NetAdapter) {
    #run updates and installs in the background
    Write-Log "Downloading WinGet and its dependencies..."
    $progressPreference = 'silentlyContinue'
    Write-Log "Installing WinGet PowerShell module from PSGallery..."
    Install-PackageProvider -Name NuGet -Force 
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
    Write-Log "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
    Repair-WinGetPackageManager

    while (-not (Get-Command winget.exe)) {
        Write-Log "Waiting for winget"
        Start-Sleep -Seconds 5
    }
    $apps = Import-Clixml C:\Scripts\apps.xml
    foreach ($app in $apps) {
        Write-Log "Installing $app"
        winget install $app --accept-source-agreements --accept-package-agreements --source winget
    }
}
else {
    Start-Process -FilePath "c:\Scripts\mbam.exe" -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" -Wait -Verb runas
    Start-Process -FilePath "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe" -Verb runas -Wait
}
Write-Log "Installing BurntToast module"
import-module -Name C:\Scripts\BurntToast -Force
$elapsed = New-TimeSpan -Start $start -End (Get-Date)
$finished = "Sandbox created in " + $elapsed.totalminutes.tostring().split(".")[0] + " minutes and " + $elapsed.Seconds + " seconds"
Write-Log $finished
$params = @{
    Text   = $finished
    Header = $(New-BTHeader -Id 1 -Title "Sandbox")
}

New-BurntToastNotification @params
Write-Log "Done"