﻿Add-Type -AssemblyName PresentationFramework,System.speech,System.Drawing,presentationCore

function Get-RequiredModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

Get-RequiredModules
$appName = "Diagnostique"
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$appPath = "$applicationPath\$appName"
$appPathSource = "$appPath\source"
set-location $appPath
$logFileName = Initialize-LogFile $appPathSource
$lockFile = "$applicationPath\source\$appName.lock"
Get-RemoteFile "DiagApps.JSON" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/DiagApps.JSON' "$appPathSource"  

$xamlFile = "$appPathSource\MainWindow.xaml"
$xamlContent = Read-XamlFileContent $xamlFile
$formatedXamlFile = Format-XamlFile $xamlContent
$xamlDoc = Convert-ToXmlDocument $formatedXamlFile
$XamlReader = New-XamlReader $xamlDoc
$window = New-WPFWindowFromXaml $XamlReader
$formControls = Get-WPFControlsFromXaml $xamlDoc $window

$formControls.btnMenu.Add_Click({
    Open-Menu
})

$formControls.btnQuit.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnbat.Add_Click({
    $formControls.btnBattinfo.Visibility="Visible"
    $formControls.btnDontsleep.Visibility="Visible"
    $formControls.btnBattMonitor.Visibility="Visible"
    $formControls.btnbat.Visibility="Collapsed"
    Get-RemoteFile "Batterie.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Batterie.zip" "$appPathSource"
})
$formControls.btnCPU.Add_Click({
    $formControls.btnAida.Visibility="Visible"
    $formControls.btnCoretemp.Visibility="Visible"
    $formControls.btnPrime95.Visibility="Visible"
    $formControls.btnHeavyLoad.Visibility="Visible"
    $formControls.btnThrottleStop.Visibility="Visible"
    $formControls.btnCPU.Visibility="Collapsed"
    New-Folder "$appPathSource\CPU"
})
$formControls.btnHDD.Add_Click({
    $formControls.btnHDSentinnel.Visibility="Visible"
    $formControls.btnHDTune.Visibility="Visible"
    $formControls.btnASSD.Visibility="Visible"
    $formControls.btnDiskmark.Visibility="Visible"
    $formControls.btnHDD.Visibility="Collapsed"
    Get-RemoteFile "HDD.zip" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HDD.zip' "$appPathSource"
})
$formControls.btnGPU.Add_Click({
    $formControls.btnFurmark.Visibility="Visible"
    $formControls.btnFurmarkV2.Visibility="Visible"
    $formControls.btnUnigine.Visibility="Visible"
    $formControls.btnGPU.Visibility="Collapsed"
    Get-RemoteFile "GPU.zip" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/GPU.zip' "$appPathSource"
})
$formControls.btnRAM.Add_Click({
    mdsched.exe
    Add-Log $logFileName "Memtest effectué"
})

$formControls.btnBattinfo.Add_Click({
    Start-App "batteryinfoview.exe" "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\battinfoview"
    Add-Log $logFileName "Usure de la batterie vérifié"
})
$formControls.btnBattMonitor.Add_Click({
    Start-App "BatteryMonx64.exe" "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\BatteryMonx64"
    Add-Log $logFileName "Usure de la batterie vérifié"
})
    
$formControls.btnDontsleep.Add_Click({
    Start-App "DontSleep_x64_p.exe" "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\DontSleep"
    Add-Log $logFileName "Dontsleep a été utilisé pour tester la batterie"
})
    
$formControls.btnAida.Add_Click({
   $scriptBlock = {
        $appPathSource = "$env:SystemDrive\_Tech\Applications\Diagnostique\source"
        $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
        foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
        {
            Import-Module $modulesFolder\$module
        }
    Invoke-App "Aida64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Aida64.zip" "$appPathSource\cpu" 
    Add-Log $logFileName "Test de stabilité du système effectué"
    } 
    if ($PSVersionTable.PSVersion.Major -lt 7 -and -not (Get-Command -Type Cmdlet Start-ThreadJob -ErrorAction SilentlyContinue)) 
    {
        Install-Nuget
        Install-Module -Scope CurrentUser ThreadJob -Force #ca prend nuget
    }
    Import-Module -Name ThreadJob     
    Start-ThreadJob -ScriptBlock $scriptBlock | Wait-Job | Remove-Job
})
    
$formControls.btnCoretemp.Add_Click({
    Invoke-App "Core Temp.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Core Temp.zip" "$appPathSource\cpu"
    Add-Log $logFileName "Température du CPU vérifié"
})

$formControls.btnPrime95.Add_Click({
    Invoke-App "Prime95.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Prime95.zip" "$appPathSource\cpu"
    Add-Log $logFileName "Stress test du CPU effectué"
})

$formControls.btnHeavyLoad.Add_Click({
    Invoke-App "HeavyLoad.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HeavyLoad.zip" "$appPathSource\cpu"
    Add-Log $logFileName "Test de stabilité du système effectué"
})
$formControls.btnThrottleStop.Add_Click({
    Invoke-App "ThrottleStop.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/ThrottleStop.zip" "$appPathSource\cpu"
    Add-Log $logFileName "Stress test du CPU effectué"
})

function diskmarkinfoLog
{
    $logfile = "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\App\CrystalDiskInfo\diskinfo.txt"
    $contentlogfile = Get-Content $logfile
    $lignedisk = "" #initialise la variable vide
    foreach ($ligne in $contentlogfile) #pour chaque ligne dans le fichier, car chaque ligne est un objet
    {
        if($ligne -match "Model") #si une ligne match drive + un chiffre
        {
            $lignedisk = $ligne
        }
        elseif($lignedisk -and $ligne -match "Interface") 
        {       
            "$lignedisk `r`n $ligne`r`n"    
        }
        elseif($lignedisk -and $ligne -match " Health Status") 
        {
            "$ligne $ligneInterfaceused`r`n"
            $lignedisk = "" #flusher une fois la variable a la fin
        }
    }
}

$formControls.btnHDSentinnel.Add_Click({
    function HDSentinnel
    {
        $pathHDS = "C:\Program Files (x86)\Hard Disk Sentinel"
        Add-Log $logFileName "Vérifier la santé du disque dur"
        $apppath = Test-AppPresence $pathHDS
        if($apppath)
        {
            Start-App "HDSentinel.exe" $pathHDS
        }
        elseif($apppath -eq $false)
        {
            Install-Winget  
            winget install -e --id XPDNXG5333CSVK --accept-package-agreements --accept-source-agreements --silent | Out-Null
            $apppath = Test-AppPresence $pathHDS
            if($apppath -eq $false)
            {
                Chocoinstall
                choco install hdsentinel -y | Out-Null
            }
            Start-App "HDSentinel.exe" $pathHDS
        }
    }
    HDSentinnel
})

$formControls.btnHDTune.Add_Click({
    Start-App "_HDTune.exe" "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\_HDTune"
    Add-Log $logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnASSD.Add_Click({
    Start-App "AS SSD Benchmark.exe" "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\As_SSD"
    Add-Log $logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnDiskmark.Add_Click({
    Start-Process -wait  "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe"  -ArgumentList "/copy"
    Add-Log $logFileName "Vérifier la santé du disque dur"
    #diskmarkinfolog | Out-File $logfilepath -Append
})

$formControls.btnFurmark.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\FurMark\FurMark.exe"
Add-Log $logFileName "Stress test du GPU"
})

$formControls.btnFurmarkV2.Add_Click({
    Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\FurMark_GUI\FurMark_GUI.exe"
    Add-Log $logFileName "Stress test du GPU"
})
    
$formControls.btnUnigine.Add_Click({
    Start-Process "https://benchmark.unigine.com/"
    Add-Log $logFileName "Vérifier les performances du GPU"
})

$formControls.btnSpeccy.Add_Click({
    Invoke-App "Speccy.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Speccy.zip" "$appPathSource"
})

$formControls.btnHWMonitor.Add_Click({
    Invoke-App "HWMonitor_x64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HWMonitor_x64.zip" "$appPathSource"
})

$formControls.btnWhocrashed.Add_Click({
    Invoke-App "WhoCrashedEx.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/WhoCrashedEx.zip" "$appPathSource"
})

$formControls.btnSysinfo.Add_Click({
    msinfo32
})

$window.add_Closed({
    Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
})

Start-WPFAppDialog $window

<#
$JSONFilePath = "$env:SystemDrive\_Tech\Applications\Diagnostique\source\DiagApps.JSON"
$jsonString = Get-Content -Raw $JSONFilePath
$appsInfo = ConvertFrom-Json $jsonString
$appNames = $appsInfo.psobject.Properties.Name
#Iterate over the applications in the JSON and interpolate the variables
$appNames | ForEach-Object {
    $appName = $_
    $appsInfo.$appName.path64 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path64)
    $appsInfo.$appName.path32 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path32)
    $appsInfo.$appName.pathAppData = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.pathAppData)
    $appsInfo.$appName.NiniteName = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.NiniteName)
    }
#>