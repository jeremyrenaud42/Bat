function Task()
{
    $t = Get-ScheduledTask 'delete _tech' | Select-Object -expand state
    if($t -match 'Ready')
    {
        Unregister-ScheduledTask -TaskName "delete _tech" -Confirm:$false
    }
        $taskname = 'Delete _Tech'
        $Action = New-ScheduledTaskAction -Execute '$env:SystemDrive\Temp\Remove.bat'
        $seconds = '05'
        $Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddSeconds($seconds ) -Once
        $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -Compatibility Win8 #si ordi éteint, le refait après 10 minutes
        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
        Register-ScheduledTask -TaskName $taskname -InputObject $Task
}
