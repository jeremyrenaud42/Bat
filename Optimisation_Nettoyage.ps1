Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.speech
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

#Set-ExecutionPolicy RemoteSigned

$driveletter = $pwd.drive.name
$root = "$driveletter" + ":"

set-location "$root\\_Tech\\Applications\\Optimisation_Nettoyage" -ErrorAction stop   #met la location au repertoir actuel
Import-Module "$root\_Tech\Applications\Source\update.psm1" | Out-Null
Import-Module "$root\_Tech\Applications\Source\task.psm1" | Out-Null #Module pour supprimer C:\_Tech

#Import-Module -Name "$root\\_TECH\\Applications\\Source\\Excel\\ImportExcel" #import le module Excel situ� dans la cl�
#$excel = Open-ExcelPackage -Path "$root\\_TECH\\Applications\\Source\\Excel\\Rapport.xlsm" #ouvre la grille Excel
#$worksheet = $excel.Workbook.Worksheets['Gabarit'] #pr�cise quelle grille Excel sera utilis�

<#
$worksheet.Cells['A1'].Value #get une valeur
$worksheet.Cells['B2'].Value = "4" #set une valeur

B2 = num_tel
4 � 13 = OS
16 � 20 = Composantes
A25 � A41 = Notes
Cases � cocher: B = Bon.  C = Jaune.  D= Rouge. E = Notes.
#>

$logfilepath = ".\Source\Logs\Log.txt"
function AddLog ($message)
{
    (Get-Date).ToString() + " - " + $message + "`r`n" | Out-File $logfilepath -Append
}

function zipsourceopti #Ce qui va toujours être redownloader à neuf à chaque lancement. Le pack obligatoire pour le fonctionnement + le reset des logs
{
    $sourcepath = test-Path ".\Source"
    if($sourcepath -eq $false)
    {
        New-Item ".\Source" -ItemType Directory | Out-Null #Créer le dossier source si il n'est pas là
    }
    $logpath = test-Path ".\source\Logs"
    if($logpath -eq $false)
    {
        New-Item ".\Source\Logs" -ItemType Directory | Out-Null #Créer le dossier Logs s'il n'est pas là
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/fondopti.jpg' -OutFile .\Source\fondopti.jpg | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/Icone.ico' -OutFile .\Source\Icone.ico | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/Logs/Log.txt' -OutFile .\Source\Logs\Log.txt | Out-Null
}
zipsourceopti

$image = [system.drawing.image]::FromFile(".\Source\fondopti.jpg") 
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Optimisation et nettoyage"
$Form.BackgroundImage = $image
$Form.Width = $image.Width
$Form.height = $image.height
$Form.MaximizeBox = $false
$Form.icon = New-Object system.drawing.icon (".\Source\Icone.ico") 

function zipccleaner
{
    $sourcepath = test-Path ".\Source\"
    $ccleanerpath = test-Path ".\Source\ccleaner\CCleaner64.exe"
    if($ccleanerpath -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item ".\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/Ccleaner.zip' -OutFile .\Source\Ccleaner.zip
    Expand-Archive .\Source\Ccleaner.zip .\Source -Force
    Remove-Item .\Source\Ccleaner.zip
    }
    Update "Optimisation_Nettoyage" "Ccleaner" 'https://raw.githubusercontent.com/jeremyrenaud42/versions/main/Optimisation_Nettoyage/ccleaner.version.txt' 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/Ccleaner.zip'
    $ccleanerpostpath = test-Path "$env:SystemDrive\Users\$env:UserName\Downloads\CCleaner\CCleaner64.exe"
    if(!($ccleanerpostpath))
    {
        New-Item "$env:SystemDrive\Users\$env:UserName\Downloads\CCleaner" -ItemType Directory
        Copy-Item ".\Source\Ccleaner\*" -Destination "$env:SystemDrive\Users\$env:UserName\Downloads\CCleaner" -Force | Out-Null #copy sur le dossier user pour pas bloquer la clé
    }
    Start-Process "$env:SystemDrive\Users\$env:UserName\Downloads\CCleaner\CCleaner64.exe"
    AddLog "Nettoyage CCleaner effectué"
}

function ziprevo
{
    $sourcepath = test-Path ".\Source\"
    $revopath = test-Path ".\Source\RevoUninstaller_Portable\RevoUPort.exe"
    if($revopath -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item ".\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUninstaller_Portable.zip' -OutFile .\Source\RevoUninstaller_Portable.zip
    Expand-Archive .\Source\RevoUninstaller_Portable.zip .\Source
    Remove-Item .\Source\RevoUninstaller_Portable.zip
    }
    Update "Optimisation_Nettoyage" "RevoUninstaller_Portable" 'https://raw.githubusercontent.com/jeremyrenaud42/versions/main/Optimisation_Nettoyage/RevoUninstaller_Portable.version.txt' 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUninstaller_Portable.zip'
    Start-Process ".\Source\RevoUninstaller_Portable\RevoUPort.exe"
    AddLog "Vérifier les programmes nuisibles"
}

function zipsfc
{
    $sourcepath = test-Path ".\Source\"
    $sfcpath = test-Path ".\Source\sfcScannow.bat"
    if($sfcpath -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item ".\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/sfcScannow.bat' -OutFile .\Source\sfcScannow.bat
    }
    Start-Process ".\Source\sfcScannow.bat" -verb runas
    AddLog "Vérifier les fichiers corrompus"  
}

function zipsysevent
{
    $sourcepath = test-Path ".\Source\"
    $syseventpath = test-Path ".\Source\sysevent.exe"
    if($syseventpath -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item ".\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/sysevent/sysevent.exe' -OutFile ".\Source\sysevent.exe"
    }
    Start-Process ".\Source\sysevent.exe"
    AddLog "Vérifier les evenements"
}

function ziphdtune
{
    $sourcepath = test-Path "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD"
    $PathHDTune = test-Path "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune\\_HDTune.exe"
    if($PathHDTune -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HD_Tune.zip' -OutFile "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune.zip"
    Expand-Archive "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune.zip" "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD"
    Remove-Item "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune\\_HDTune.exe"
    AddLog "Vérifier la Vitesse du disque dur"
}

function zipcdi
{
    $sourcepath = test-Path "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD"
    $cdipath = test-Path "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe" #path dans diag
    if($cdipath -eq $false)
    {   
        if($sourcepath -eq $false)
        {
            New-Item "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/CrystalDiskInfoPortable.zip' -OutFile "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\CrystalDiskInfoPortable.zip"
    Expand-Archive "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\CrystalDiskInfoPortable.zip" "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD"
    Remove-Item "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\CrystalDiskInfoPortable.zip"
        }
    Start-Process "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe"
    AddLog "Vérifier la santé du HDD"
}

function zipHitmanPro
{
    $sourcepath = test-Path "$root\\_Tech\\Applications\\Securite\\Source"
    $PathHitmanPro = test-Path "$root\\_Tech\\Applications\\Securite\\Source\\HitmanPro.exe"
    if($PathHitmanPro -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item "$root\\_Tech\\Applications\\Securite\\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/HitmanPro.exe' -OutFile "$root\\_Tech\\Applications\\Securite\\Source\\HitmanPro.exe"
    }
    Start-Process "$root\\_Tech\\Applications\\Securite\\Source\\HitmanPro.exe"
    AddLog "Vérifier les virus avec HitmanPro"
}

function zipautoruns
{
    $sourcepath = test-Path ".\Source"
    $pathautoruns = test-Path ".\Source\autoruns.exe"
    if($pathautoruns -eq $false)
    {
        if($sourcepath -eq $false)
        {
            New-Item ".\Source" -ItemType Directory
        }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/autoruns.exe' -OutFile ".\Source\autoruns.exe"
    }
    Start-Process ".\Source\autoruns.exe"
    start-sleep 5
    taskmgr
    AddLog "Vérifier les logiciels au démarrage"
}
#choco install hdtune
#choco install hdsentinel
#choco install revo-uninstaller
#choco install ccleaner.portable
#choco install ccenhancer
#choco install autoruns
#choco install hitmanpro

#RevoUninstaller.RevoUninstaller
#Piriform.CCleaner
#SingularLabs.CCEnhancer

function hdsslog
{
    $PathHDSentinelData = Get-Content "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\\HD_Sentinnel\\HDSData\\HDSentinel_5.70 PRO_report.txt"
    $lignedisk = "" #initialise la variable vide

    foreach ($ligne in $PathHDSentinelData) #pour chaque ligne dans le fichier, car chaque ligne est un objet
    {
        if($ligne -match "Drive \d+") #si une ligne match drive + un chiffre
        {
            $lignedisk = $ligne  #$lignedisk contient la ligne drive x
        }
   
        elseif($lignedisk -and $ligne -match "size") #si ma ligne drive x est $TRUe et ma ligne qui match size
        {
            $lignedisk,$ligne #afficher drive x et la size
        }

        elseif($lignedisk -and $ligne -match "Temperature" -and $ligne -notmatch "Max. Temperature"  -and $ligne -notmatch "Airflow Temperature" -and $ligne -notmatch "disk Temperature") #si ma ligne drive x est $TRUe et ma ligne qui match temprature
        {
            $ligne,$lignesize #la temperature et la taille
        }

        elseif($lignedisk -and $ligne -match "Power on time" -and $ligne -notmatch "Power on time measure" -and $ligne -notmatch "Power On Time Count") 
        {
            $ligne,$lignesize,$lignetemp
        }

        elseif($lignedisk -and $ligne -match "Remaining lifetime") 
        {
            $ligne,$lignesize,$lignetemp,$lignePoweronTime
        }

        elseif($lignedisk -and $ligne -match "Disk Performance") 
        {
            $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime
        }

        elseif($lignedisk -and $ligne -match "Interface used") 
        {
            $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime,$ligneperfo
        }

        elseif($lignedisk -and $ligne -match "Disk Fitness") 
        {
            $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime,$ligneperfo,$ligneInterfaceused
            [System.Windows.MessageBox]::Show("$lignedisk,$ligne","HDSentinel",0) | Out-Null
            $lignedisk = "" #flusher une fois la variable a la fin
        }
    }
}

function HDSentinel
{
    $PathHDSentinel= "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\\HD_Sentinnel\\_HDSentinel.exe"
    Start-Process "$PathHDSentinel"  -ArgumentList "/report"
    Start-Sleep -s 15
    Stop-Process -name _HDSentinel -Force
    hdsslog | Out-File $logfilepath -Append
}

function HDTune
{
$PathHDTune = "$root\\_Tech\\Applications\\Diagnostique\\Source\\HDD\HD_Tune\\_HDTune.exe"
Start-Process "$PathHDTune"
AddLog "Vérifier la Vitesse du disque dur"
}

Function Revo
{
$revobefore = "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\Logs\\RevoBefore.txt"
$revoafter = "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\Logs\\RevoAfter.txt"
Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName  | Sort-Object -Property DisplayName | Format-Table �AutoSize | Out-File $revobefore
Start-Process "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoUninstaller_Portable\\RevoUPort.exe"
AddLog "Vérifier les programmes nuisibles"
Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName  | Sort-Object -Property DisplayName | Format-Table �AutoSize | Out-File $revoafter
Compare-Object -ReferenceObject (Get-Content -path $revobefore) -DifferenceObject (Get-Content -path $revoafter) | Out-File $logfilepath -Append
Clear-Content $revobefore
Clear-Content $revoafter
}

#Windows Updates
$Updates = New-Object System.Windows.Forms.Button
$Updates.Location = New-Object System.Drawing.Point(460,100)
$Updates.Width = '120'
$Updates.Height = '55'
$Updates.ForeColor='black'
$Updates.BackColor = 'darkcyan'
$Updates.Text = "Windows Update"
$Updates.Font= 'Microsoft Sans Serif,13'
$Updates.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Updates.FlatAppearance.BorderSize = 2
$Updates.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Updates.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Updates.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Updates.Add_MouseEnter({$Updates.ForeColor = 'White'})
$Updates.Add_MouseLeave({$Updates.ForeColor = 'black'})
$Updates.Add_Click({
start-Process "ms-settings:windowsupdate"
AddLog "Mises à jours de Windows effectuées"
})

#Autoruns
$Autoruns = New-Object System.Windows.Forms.Button
$Autoruns.Location = New-Object System.Drawing.Point(330,200)
$Autoruns.Width = '120'
$Autoruns.Height = '55'
$Autoruns.ForeColor='black'
$Autoruns.BackColor = 'darkcyan'
$Autoruns.Text = "Logiciel demarrage"
$Autoruns.Font= 'Microsoft Sans Serif,13'
$Autoruns.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Autoruns.FlatAppearance.BorderSize = 2
$Autoruns.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Autoruns.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Autoruns.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Autoruns.Add_MouseEnter({$Autoruns.ForeColor = 'White'})
$Autoruns.Add_MouseLeave({$Autoruns.ForeColor = 'black'})
$Autoruns.Add_Click({
zipautoruns
})

#Revo
$Revo = New-Object System.Windows.Forms.Button
$Revo.Location = New-Object System.Drawing.Point(590,200)
$Revo.Width = '120'
$Revo.Height = '55'
$Revo.ForeColor='black'
$Revo.BackColor = 'darkcyan'
$Revo.Text = "Desinstaller programmes"
$Revo.Font= 'Microsoft Sans Serif,13'
$Revo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Revo.FlatAppearance.BorderSize = 2
$Revo.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Revo.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Revo.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Revo.Add_MouseEnter({$Revo.ForeColor = 'White'})
$Revo.Add_MouseLeave({$Revo.ForeColor = 'black'})
$Revo.Add_Click({
ziprevo
})


#Nettoyage
$HDD = New-Object System.Windows.Forms.Button
$HDD.Location = New-Object System.Drawing.Point(200,300)
$HDD.Width = '120'
$HDD.Height = '55'
$HDD.ForeColor='black'
$HDD.BackColor = 'darkcyan'
$HDD.Text = "Nettoyage HDD"
$HDD.Font= 'Microsoft Sans Serif,13'
$HDD.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$HDD.FlatAppearance.BorderSize = 2
$HDD.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$HDD.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HDD.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HDD.Add_MouseEnter({$HDD.ForeColor = 'White'})
$HDD.Add_MouseLeave({$HDD.ForeColor = 'black'})
$HDD.Add_Click({
Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
AddLog "Nettoyage du disque effectué"
})

#Ccleaner
$Ccleaner = New-Object System.Windows.Forms.Button
$Ccleaner.Location = New-Object System.Drawing.Point(460,300)
$Ccleaner.Width = '120'
$Ccleaner.Height = '55'
$Ccleaner.ForeColor='black'
$Ccleaner.BackColor = 'darkcyan'
$Ccleaner.Text = "Ccleaner"
$Ccleaner.Font= 'Microsoft Sans Serif,13'
$Ccleaner.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Ccleaner.FlatAppearance.BorderSize = 2
$Ccleaner.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Ccleaner.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Ccleaner.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Ccleaner.Add_MouseEnter({$Ccleaner.ForeColor = 'White'})
$Ccleaner.Add_MouseLeave({$Ccleaner.ForeColor = 'black'})
$Ccleaner.Add_Click({
zipccleaner
})

#sfc
$sfc = New-Object System.Windows.Forms.Button
$sfc.Location = New-Object System.Drawing.Point(670,300)
$sfc.Width = '120'
$sfc.Height = '55'
$sfc.ForeColor='black'
$sfc.BackColor = 'darkcyan'
$sfc.Text = "Fichiers corrompus"
$sfc.Font= 'Microsoft Sans Serif,13'
$sfc.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$sfc.FlatAppearance.BorderSize = 2
$sfc.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$sfc.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$sfc.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$sfc.Add_MouseEnter({$sfc.ForeColor = 'White'})
$sfc.Add_MouseLeave({$sfc.ForeColor = 'black'})
$sfc.Add_Click({
zipsfc
})

#HitmanPro
$HitmanPro = New-Object System.Windows.Forms.Button
$HitmanPro.Location = New-Object System.Drawing.Point(70,400)
$HitmanPro.Width = '120'
$HitmanPro.Height = '55'
$HitmanPro.ForeColor='black'
$HitmanPro.BackColor = 'darkcyan'
$HitmanPro.Text = "HitmanPro"
$HitmanPro.Font= 'Microsoft Sans Serif,13'
$HitmanPro.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$HitmanPro.FlatAppearance.BorderSize = 2
$HitmanPro.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$HitmanPro.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HitmanPro.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HitmanPro.Add_MouseEnter({$HitmanPro.ForeColor = 'White'})
$HitmanPro.Add_MouseLeave({$HitmanPro.ForeColor = 'black'})
$HitmanPro.Add_Click({
zipHitmanPro
})

#sysevent
$sysevent = New-Object System.Windows.Forms.Button
$sysevent.Location = New-Object System.Drawing.Point(330,400)
$sysevent.Width = '120'
$sysevent.Height = '55'
$sysevent.ForeColor='black'
$sysevent.BackColor = 'darkcyan'
$sysevent.Text = "SysEvent"
$sysevent.Font= 'Microsoft Sans Serif,13'
$sysevent.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$sysevent.FlatAppearance.BorderSize = 2
$sysevent.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$sysevent.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$sysevent.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$sysevent.Add_MouseEnter({$sysevent.ForeColor = 'White'})
$sysevent.Add_MouseLeave({$sysevent.ForeColor = 'black'})
$sysevent.Add_Click({
zipsysevent
})


#HDSentinel
$HDSentinel = New-Object System.Windows.Forms.Button
$HDSentinel.Location = New-Object System.Drawing.Point(590,400)
$HDSentinel.Width = '120'
$HDSentinel.Height = '55'
$HDSentinel.ForeColor='black'
$HDSentinel.BackColor = 'darkcyan'
$HDSentinel.Text = "Verifier Sante HDD"
$HDSentinel.Font= 'Microsoft Sans Serif,13'
$HDSentinel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$HDSentinel.FlatAppearance.BorderSize = 2
$HDSentinel.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$HDSentinel.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HDSentinel.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HDSentinel.Add_MouseEnter({$HDSentinel.ForeColor = 'White'})
$HDSentinel.Add_MouseLeave({$HDSentinel.ForeColor = 'black'})
$HDSentinel.Add_Click({
HDSentinel
})

#CrystalDiskInfo
$CrystalDiskInfo = New-Object System.Windows.Forms.Button
$CrystalDiskInfo.Location = New-Object System.Drawing.Point(590,400)
$CrystalDiskInfo.Width = '120'
$CrystalDiskInfo.Height = '55'
$CrystalDiskInfo.ForeColor='black'
$CrystalDiskInfo.BackColor = 'darkcyan'
$CrystalDiskInfo.Text = "Verifier Sante HDD"
$CrystalDiskInfo.Font= 'Microsoft Sans Serif,13'
$CrystalDiskInfo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$CrystalDiskInfo.FlatAppearance.BorderSize = 2
$CrystalDiskInfo.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$CrystalDiskInfo.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$CrystalDiskInfo.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$CrystalDiskInfo.Add_MouseEnter({$CrystalDiskInfo.ForeColor = 'White'})
$CrystalDiskInfo.Add_MouseLeave({$CrystalDiskInfo.ForeColor = 'black'})
$CrystalDiskInfo.Add_Click({
zipcdi
})

#HDTune
$HDTune = New-Object System.Windows.Forms.Button
$HDTune.Location = New-Object System.Drawing.Point(850,400)
$HDTune.Width = '120'
$HDTune.Height = '55'
$HDTune.ForeColor='black'
$HDTune.BackColor = 'darkcyan'
$HDTune.Text = "Verifier Vitesse HDD"
$HDTune.Font= 'Microsoft Sans Serif,13'
$HDTune.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$HDTune.FlatAppearance.BorderSize = 2
$HDTune.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$HDTune.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HDTune.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HDTune.Add_MouseEnter({$HDTune.ForeColor = 'White'})
$HDTune.Add_MouseLeave({$HDTune.ForeColor = 'black'})
$HDTune.Add_Click({
ziphdtune
#HDTune
})

#Quitter
$quit = New-Object System.Windows.Forms.Button
$quit.Location = New-Object System.Drawing.Point(460,570)
$quit.Width = '120'
$quit.Height = '55'
$quit.ForeColor='black'
$quit.BackColor = 'darkred'
$quit.Text = "Quitter"
$quit.Font= 'Microsoft Sans Serif,13'
$quit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$quit.FlatAppearance.BorderSize = 2
$quit.FlatAppearance.BorderColor = 'black'
$quit.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$quit.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$quit.Add_MouseEnter({$quit.ForeColor = 'White'})
$quit.Add_MouseLeave({$quit.ForeColor = 'black'})
$quit.Add_Click({
#Close-ExcelPackage $excel #Ferme la grille Excel
Task
$Form.Close()
})

#Menu principal
$Menuprincipal = New-Object System.Windows.Forms.Button
$Menuprincipal.Location = New-Object System.Drawing.Point(25,35)
$Menuprincipal.Width = '120'
$Menuprincipal.Height = '55'
$Menuprincipal.ForeColor='black'
$Menuprincipal.BackColor = 'darkred'
$Menuprincipal.Text = "Menu principal"
$Menuprincipal.Font= 'Microsoft Sans Serif,13'
$Menuprincipal.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Menuprincipal.FlatAppearance.BorderSize = 2
$Menuprincipal.FlatAppearance.BorderColor = 'black'
$Menuprincipal.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Menuprincipal.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Menuprincipal.Add_MouseEnter({$Menuprincipal.ForeColor = 'White'})
$Menuprincipal.Add_MouseLeave({$Menuprincipal.ForeColor = 'black'})
$Menuprincipal.Add_Click({
start-process "$root\\_Tech\\Menu.bat" -verb Runas
$Form.Close()
#Close-ExcelPackage $excel #Ferme la grille Excel
})

#Ouvrir Grille Excel
$OuvrirGrilleExcel = New-Object System.Windows.Forms.Button
$OuvrirGrilleExcel.Location = New-Object System.Drawing.Point(25,100)
$OuvrirGrilleExcel.Width = '120'
$OuvrirGrilleExcel.Height = '55'
$OuvrirGrilleExcel.ForeColor='black'
$OuvrirGrilleExcel.BackColor = 'darkgreen'
$OuvrirGrilleExcel.Text = "Ouvrir la Grille Excel"
$OuvrirGrilleExcel.Font= 'Microsoft Sans Serif,13'
$OuvrirGrilleExcel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$OuvrirGrilleExcel.FlatAppearance.BorderSize = 2
$OuvrirGrilleExcel.FlatAppearance.BorderColor = [System.Drawing.Color]::black
$OuvrirGrilleExcel.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$OuvrirGrilleExcel.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$OuvrirGrilleExcel.Add_MouseEnter({$OuvrirGrilleExcel.ForeColor = 'White'})
$OuvrirGrilleExcel.Add_MouseLeave({$OuvrirGrilleExcel.ForeColor = 'black'})
$OuvrirGrilleExcel.Add_Click({
Start-Process "$root\\_TECH\\Applications\\Source\\Excel\\Rapport.xlsm"
})
#$Form.controls.Add($OuvrirGrilleExcel)

#sysinfo
$Sysinfoz = New-Object System.Windows.Forms.Button
$Sysinfoz.Location = New-Object System.Drawing.Point(825,565)
$Sysinfoz.Width = '120'
$Sysinfoz.Height = '55'
$Sysinfoz.ForeColor='black'
$Sysinfoz.BackColor = 'darkred'
$Sysinfoz.Text = "Sysinfo"
$Sysinfoz.Font= 'Microsoft Sans Serif,13'
$Sysinfoz.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Sysinfoz.FlatAppearance.BorderSize = 2
$Sysinfoz.FlatAppearance.BorderColor = [System.Drawing.Color]::black
$Sysinfoz.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Sysinfoz.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Sysinfoz.Add_MouseEnter({$Sysinfoz.ForeColor = 'White'})
$Sysinfoz.Add_MouseLeave({$Sysinfoz.ForeColor = 'black'})
$Sysinfoz.Add_Click({
Start-Process "$root\\_TECH\\Applications\\Diagnostique\Source\SysToolbox\Sysinfo\sysinfoz.exe"
})
#$Form.controls.Add($Sysinfoz)

#Label
$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point(358,35)
$label.AutoSize = $false
$label.width = 345
$label.height = 55
$label.Font= 'Microsoft Sans Serif,16'
$label.ForeColor='white'
$label.BackColor = 'darkred'
$label.Text = "Choisissez une option"
$label.TextAlign = 'MiddleCenter'

#afficher la form
$Form.controls.AddRange(@($Menuprincipal,$HDTune,$CrystalDiskInfo,$Autoruns,$HDD,$Ccleaner,$Revo,$Updates,$Quit,$label,$HitmanPro,$sysevent,$sfc))
$Form.ShowDialog() | out-null