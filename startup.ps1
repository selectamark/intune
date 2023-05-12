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

winget ls --disable-interactivity --accept-source-agreements

winget source update --disable-interactivity

winget rm -h "Xbox Game Bar" --disable-interactivity 
winget rm -h "9N0866FS04W8" --disable-interactivity
winget rm -h "Clean Your Device" --disable-interactivity 
winget rm -h "MirametrixInc.GlancebyMirametrix_17mer8kcn3j54" --disable-interactivity 
winget rm -h "Microsoft Clipchamp" --disable-interactivity 
winget rm -h "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe" --disable-interactivity 

winget add -h OpenVPNTechnologies.OpenVPNConnect --disable-interactivity --accept-package-agreements
winget add -h 7zip.7zip --disable-interactivity --accept-package-agreements
winget add -h Adobe.Acrobat.Reader.64-bit --disable-interactivity --accept-package-agreements

winget upgrade -h --all --disable-interactivity
