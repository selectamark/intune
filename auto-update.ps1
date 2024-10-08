$DIR = "C:\ProgramData\Selectamark"

function LogAction {
    param ($message)
    Add-Content -Path $DIR\provisioner.log -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] - $message"
}

$WingetPath = Get-ChildItem -Recurse "C:\Program Files\WindowsApps" winget.exe | % { $_.FullName }

if (($WingetPath -is [array])) {
    $WingetPath = $WingetPath[-1]
}

# LogAction("Winget Path = $($WingetPath)")

LogAction("-- App Provisioner -- 2024-10-08")

$WingetDir = Split-Path -Path $WingetPath -Parent
Set-Location $WingetDir

LogAction("Updating all WinGet Packages")
.\winget.exe update --all -h --accept-package-agreements --accept-source-agreements
LogAction("Finished updating WinGet Packages")

