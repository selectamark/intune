$DIR = "C:\ProgramData\Selectamark"
[system.io.directory]::CreateDirectory("$DIR")

$templateFilePath = "$DIR\startup.ps1"

$stt = New-ScheduledTaskTrigger -AtLogOn
$sta = New-ScheduledTaskAction -Execute "conhost.exe --headless powershell.exe -ExecutionPolicy Bypass $templateFilePath"
$stp = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest

Register-ScheduledTask SM_Task01 -Trigger $stt -Action $sta -Principal $stp -Force

Invoke-WebRequest `
-Uri "https://raw.githubusercontent.com/selectamark/intune/main/startup.ps1" `
-OutFile $templateFilePath `
-UseBasicParsing `
-Headers @{"Cache-Control"="no-cache"}

winget uninstall "Xbox Game Bar"
winget upgrade --all --silent
