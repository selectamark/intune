$DIR = "C:\ProgramData\Selectamark"
$templateFilePath = "$DIR\startup.ps1"

[system.io.directory]::CreateDirectory("$DIR")

Invoke-WebRequest `
-Uri "https://raw.githubusercontent.com/selectamark/intune/main/startup.ps1" `
-OutFile $templateFilePath `
-UseBasicParsing `
-Headers @{"Cache-Control"="no-cache"}

$stt = New-ScheduledTaskTrigger -AtLogOn
$sta = New-ScheduledTaskAction -Execute conhost.exe -Argument "--headless powershell.exe -ExecutionPolicy Bypass $templateFilePath"
$stp = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest

Register-ScheduledTask SM_LoginTask -Trigger $stt -Action $sta -Principal $stp -Force

for(;;) {
  if(Get-Command winget -ErrorAction SilentlyContinue) {
    break
  } else {
    sleep 15
  }
}


$di = "--disable-interactivity"
$hdi = "-h $di"
$hdiaa = "$hdi --accept-source-agreements --accept-package-agreements"

winget source update $di

winget uninstall "Xbox Game Bar" $hdi
winget uninstall "9N0866FS04W8" $hdi
winget uninstall "MirametrixInc.GlancebyMirametrix_17mer8kcn3j54" $hdi
winget uninstall "Microsoft Clipchamp" $hdi
winget uninstall "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe" $hdi

winget install OpenVPNTechnologies.OpenVPNConnect $hdiaa
winget install 7zip.7zip $hdiaa
winget install Adobe.Acrobat.Reader.64-bit $hdiaa

winget upgrade --all $hdiaa
