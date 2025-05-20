
$DIR = "C:\ProgramData\Selectamark"
$DIR_PUB = "C:\Users\Public\Desktop"


#WebClient
$dc = New-Object net.webclient
$dc.UseDefaultCredentials = $true
$dc.Headers.Add("user-agent", "Inter Explorer")
$dc.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")

function LogAction {
  param ($message)
  Add-Content -Path $DIR\provisioner.log -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] - $message"
}


$iconsToRemove = @(
  "Microsoft*",
  "VLC*",
  "OpenVPN*"
)

if($iconsToRemove.count -gt 0) {
  LogAction("Removing Icons on Desktop...")
}
foreach ($icon in $iconsToRemove) {
  Get-ChildItem -Recurse C:\Users\Public\Desktop\ $icon| % {$_.FullName} | Remove-Item
}

if ((Get-WmiObject win32_computersystem).Manufacturer -eq "LENOVO") {

  # Install Vantage Service...
  if (!(Test-Path 'C:\Program Files (x86)\Lenovo\VantageService')) {
    LogAction("Installing Vantage Service...")
    $file = "vantage-service.zip"

    $url = "https://raw.githubusercontent.com/selectamark/intune/main/$file"
    $dc.DownloadFile($url, "$DIR\$file")

    Expand-Archive "$DIR\$file" -DestinationPath "$DIR" -Force
    Set-Location $DIR
    powershell -ExecutionPolicy Bypass .\VantageService\Install-VantageService.ps1

    Remove-Item ".\__MACOSX" -Recurse -Force
    Remove-Item ".\VantageService" -Recurse -Force
    Remove-Item ".\$file" -Recurse -Force

    LogAction("Installing Vantage Drivers...")
    $file = "lenovo-sif-drivers.exe"
    $url = "https://raw.githubusercontent.com/selectamark/intune/main/$file"
    $dc.DownloadFile($url, "$DIR\$file")

    Set-Location $DIR
    Start-Process -FilePath .\$file -ArgumentList "/verysilent /NORESTART"

    Remove-Item ".\$file" -Recurse -Force
  }
}


LogAction("Stopping OneDrive Personal...")
$od = gci -recurse C:\Users OneDrive | % {$_.FullName}
if($od) {
  Remove-Item $od -Force -Recurse
  # Stop-Process -Name OneDrive
}

# Stop-Process -Name explorer -Force


$word = Get-ChildItem -Recurse "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" Word.lnk | % { $_.FullName }
if(!$word) {
  LogAction("Waiting for Office to be Installed...")
}
for(;;) {
  $word = Get-ChildItem -Recurse "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" Word.lnk | % { $_.FullName }

  if($word) {
    break
  } else {
    sleep 10
  }
}

LogAction("Setting Taskbar Icons...")
$DIR = "C:\ProgramData\Selectamark"

$url = "https://raw.githubusercontent.com/selectamark/intune/main/taskbar.xml"
$dc.DownloadFile($url, "$DIR\taskbar.xml")

Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name StartLayoutFile -Value "C:\ProgramData\Selectamark\taskbar.xml"
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name LockedStartLayout -Value 1
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name ReapplyStartLayoutEveryLogon -Value 1

Stop-Process -Name explorer -Force


# Set-ExecutionPolicy RemoteSigned

$nuget = Get-PackageProvider | Select-String NuGet
if(!$nuget) {
  Install-PackageProvider Nuget -Force
}
$module = Get-Command -Module PSWindowsUpdate
if(!$module) {
  Install-Module PSWindowsUpdate -Force
}

LogAction("Searching for available updates...")
$updates = Get-WindowsUpdate

if ($updates.count -gt 0) {
  LogAction("Installing updates ($($updates.count))... Restarts may occur automatically")
  $i = 1
  foreach($update in $updates) {
    LogAction("Installing update ($i/$($updates.count)) - $($update.Title) - $($update.Size)")
    Get-WindowsUpdate -Install -KBArticleID $update.KB -AcceptAll -AutoReboot
    $i = $i + 1
  }
}


LogAction("Provisioning Complete")

Remove-Item -Path $DIR_PUB\Progress.bat -Force

# shutdown /r
