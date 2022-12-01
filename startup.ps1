$DIR = "C:\ProgramData\Selectamark"
[system.io.directory]::CreateDirectory("$DIR")

$templateFilePath = "$DIR\startup.ps1"

$stt = New-ScheduledTaskTrigger -AtLogOn
$sta = New-ScheduledTaskAction -Execute "conhost.exe --headless powershell.exe -ExecutionPolicy Bypass $templateFilePath"
$stp = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators"

Register-ScheduledTask SM_Task01 -Trigger $stp -Action $sta -Principal $stp -Force

winget uninstall "Xbox Game Bar"
