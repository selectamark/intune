function LogAction {
    param ($message)
    Add-Content -Path $DIR\provisioner.log -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] - $message"
}

$WingetPath = Get-ChildItem -Recurse "C:\Program Files\WindowsApps" winget.exe | % { $_.FullName }

if (($WingetPath -is [array])) {
    $WingetPath = $WingetPath[-1]
}

LogAction("Winget Path = $($WingetPath)")

$WingetDir = Split-Path -Path $WingetPath -Parent
Set-Location $WingetDir

LogAction("Updating all WinGet Packages (2/2)")
.\winget.exe update --all -h

