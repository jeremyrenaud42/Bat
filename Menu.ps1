﻿#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

function CheckAdminStatus
{
    $adminStatus = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') 
    return $adminStatus
}
function ReloadAsAdmin
{
    Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit #permet de fermer la session non-Admin
}

function CreateFolder($folder) 
{
    $folderPath = "$env:SystemDrive\$folder"
    $folderExist = test-path $folderPath 
    if($folderExist -eq $false)
    {
        New-Item $folderPath -ItemType 'Directory' -Force | Out-Null
    }
}

function DownloadFolder($appName,$remotePs1Link,$remoteBatLink)
{
    Invoke-WebRequest $remotePs1Link -OutFile "$env:SystemDrive\_Tech\Applications\$appName\$appName.ps1" | Out-Null 
    Invoke-WebRequest $remoteBatLink -OutFile "$env:SystemDrive\_Tech\Applications\$appName\RunAs$appName.bat" | Out-Null
}

function DeployApp($appName,$remotePs1Link,$remoteBatLink)
{
    CreateFolder "_Tech\Applications\$appName"
    DownloadFolder $appName $remotePs1Link $remoteBatLink
    set-location "$env:SystemDrive\_Tech\Applications\$appName" 
    Start-Process "$env:SystemDrive\_Tech\Applications\$appName\RunAs$appName.bat" | Out-Null
}

function DownloadRemoveScript
{
    CreateFolder "Temp"
    $deletePath = test-path "$env:SystemDrive\Temp\remove.ps1"
    $removePath = test-path "$env:SystemDrive\Temp\Remove.bat"
    if(($deletePath) -eq $false -and ($removePath -eq $false))
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' -OutFile "$env:SystemDrive\Temp\Remove.ps1" | Out-Null
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' -OutFile "$env:SystemDrive\Temp\Remove.bat" | Out-Null
    }
}

function DownloadModules
{
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip' -OutFile "$env:SystemDrive\_Tech\applications\source\Modules.zip" | Out-Null
    Expand-Archive "$env:SystemDrive\_Tech\applications\source\Modules.zip" "$env:SystemDrive\_Tech\applications\source" -Force
    Remove-Item "$env:SystemDrive\_Tech\applications\source\Modules.zip"
}

function DownloadImages
{
    CreateFolder "_Tech\Applications\Source\images"
    $fondpath = test-Path "$env:SystemDrive\_Tech\applications\source\Images\fondpluiesize.gif"
    $iconepath = test-path "$env:SystemDrive\_Tech\applications\source\Images\Icone.ico"
        if($fondpath -eq $false) 
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$env:SystemDrive\_Tech\applications\source\Images\fondpluiesize.gif" | Out-Null
        }
        if($iconepath -eq $false) 
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$env:SystemDrive\_Tech\applications\source\Images\Icone.ico" | Out-Null
        } 
}
    
function PrepareDependencies
{
    CreateFolder "_Tech\Applications"
    CreateFolder "_Tech\Applications\Source" 
    DownloadImages
    DownloadRemoveScript
    DownloadModules
}

$adminStatus = CheckAdminStatus
if($adminStatus -eq $false)
{
    ReloadAsAdmin
}
Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force
set-location "$env:SystemDrive\_Tech" 
PrepareDependencies
$importTaskModule = Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\task.psm1" | Out-Null #Module pour supprimer C:\_Tech

$imgFile = [system.drawing.image]::FromFile("$env:SystemDrive\_Tech\Applications\Source\Images\fondpluiesize.gif") #Il faut mettre le chemin complet pour éviter des erreurs.
$pictureBoxBackGround = new-object Windows.Forms.PictureBox #permet d'afficher un gif
$pictureBoxBackGround.width = $imgFile.width 
$pictureBoxBackGround.height = $imgFile.height
$pictureBoxBackGround.Image = $imgFile #contient l'image gif de background
$pictureBoxBackGround.AutoSize = $true 

$form = New-Object System.Windows.Forms.Form
$form.Text = "Menu - Boite à outils du technicien"
$form.Width = $imgFile.Width
$form.height = $imgFile.height
$form.MaximizeBox = $false
$form.icon = New-Object system.drawing.icon ("$env:SystemDrive\_Tech\Applications\Source\Images\Icone.ico") #Il faut mettre le chemin complet pour éviter des erreurs.
$form.KeyPreview = $True
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$importTaskModule;Task;$form.Close()}}) #si on fait échape sa ferme la fenetre
$form.TopMost = $true
$form.StartPosition = "CenterScreen"
$form.BackgroundImageLayout = "Stretch"

#Installation
$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Location = New-Object System.Drawing.Point(446,100)
$btnInstall.AutoSize = $false
$btnInstall.Width = '150'
$btnInstall.Height = '65'
$btnInstall.ForeColor='black'
$btnInstall.BackColor = 'darkred'
$btnInstall.Text = "Installation Windows"
$btnInstall.Font= 'Microsoft Sans Serif,16'
$btnInstall.FlatStyle = 'Flat'
$btnInstall.FlatAppearance.BorderSize = 2
$btnInstall.FlatAppearance.BorderColor = 'black'
$btnInstall.FlatAppearance.MouseDownBackColor = 'darkcyan'
$btnInstall.FlatAppearance.MouseOverBackColor = 'gray'
$btnInstall.Add_MouseEnter({$btnInstall.ForeColor = 'White'})
$btnInstall.Add_MouseLeave({$btnInstall.ForeColor = 'Black'})
$btnInstall.Add_Click({
DeployApp "Installation" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsInstallation.bat'
$form.Close()
})

#Optimisation et nettoyage
$btnOptiNett = New-Object System.Windows.Forms.Button
$btnOptiNett.Location = New-Object System.Drawing.Point(446,175)
$btnOptiNett.AutoSize = $false
$btnOptiNett.Width = '150'
$btnOptiNett.Height = '65'
$btnOptiNett.ForeColor='black'
$btnOptiNett.BackColor = 'darkred'
$btnOptiNett.Text = "Optimisation et Nettoyage"
$btnOptiNett.Font= 'Microsoft Sans Serif,16'
$btnOptiNett.FlatStyle = 'Flat'
$btnOptiNett.FlatAppearance.BorderSize = 3
$btnOptiNett.FlatAppearance.BorderColor = 'black'
$btnOptiNett.FlatAppearance.MouseDownBackColor = 'darkcyan'
$btnOptiNett.FlatAppearance.MouseOverBackColor = 'gray'
$btnOptiNett.Add_MouseEnter({$btnOptiNett.ForeColor = 'White'})
$btnOptiNett.Add_MouseLeave({$btnOptiNett.ForeColor = 'Black'})
$btnOptiNett.Add_Click({
DeployApp "Optimisation_Nettoyage" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsOptimisation_Nettoyage.bat'
$form.Close()
})

#Diagnostic
$btnDiagnostic = New-Object System.Windows.Forms.Button
$btnDiagnostic.Location = New-Object System.Drawing.Point(446,250)
$btnDiagnostic.Width = '150'
$btnDiagnostic.Height = '65'
$btnDiagnostic.ForeColor='black'
$btnDiagnostic.BackColor = 'darkred'
$btnDiagnostic.Text = "Diagnostique"
$btnDiagnostic.Font= 'Microsoft Sans Serif,16'
$btnDiagnostic.FlatStyle = 'Flat'
$btnDiagnostic.FlatAppearance.BorderSize = 3
$btnDiagnostic.FlatAppearance.BorderColor = 'black'
$btnDiagnostic.FlatAppearance.MouseDownBackColor = 'darkcyan'
$btnDiagnostic.FlatAppearance.MouseOverBackColor = 'gray'
$btnDiagnostic.Add_MouseEnter({$btnDiagnostic.ForeColor = 'White'})
$btnDiagnostic.Add_MouseLeave({$btnDiagnostic.ForeColor = 'Black'})
$btnDiagnostic.Add_Click({
DeployApp "Diagnostique" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDiagnostique.bat'
$form.Close()
})

<#
function Zipdesinfection 
{
    CreateFolder "_Tech\Applications\Securite" #Créer le dossier vide Securite s'il n'existe pas
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' -OutFile "$env:SystemDrive\_Tech\Applications\Securite\Desinfection.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat' -OutFile "$env:SystemDrive\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #download le .exe
    set-location "$env:SystemDrive\_Tech\Applications\Securite" #met le path dans le dossier Securite
    Start-Process "$env:SystemDrive\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #Lance le script de désinfcetion
}
#>

#Desinfection
$btnDesinfection = New-Object System.Windows.Forms.Button
$btnDesinfection.Location = New-Object System.Drawing.Point(446,325)
$btnDesinfection.Width = '150'
$btnDesinfection.Height = '65'
$btnDesinfection.ForeColor='black'
$btnDesinfection.BackColor = 'darkred'
$btnDesinfection.Text = "Désinfection"
$btnDesinfection.Font= 'Microsoft Sans Serif,16'
$btnDesinfection.FlatStyle = 'Flat'
$btnDesinfection.FlatAppearance.BorderSize = 3
$btnDesinfection.FlatAppearance.BorderColor = 'black'
$btnDesinfection.FlatAppearance.MouseDownBackColor = 'darkcyan'
$btnDesinfection.FlatAppearance.MouseOverBackColor = 'gray'
$btnDesinfection.Add_MouseEnter({$btnDesinfection.ForeColor = 'White'})
$btnDesinfection.Add_MouseLeave({$btnDesinfection.ForeColor = 'Black'})
$btnDesinfection.Add_Click({
DeployApp "Desinfection" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat'
$form.Close()
})

#Fix
$btnFix = New-Object System.Windows.Forms.Button
$btnFix.Location = New-Object System.Drawing.Point(446,400)
$btnFix.Width = '150'
$btnFix.Height = '65'
$btnFix.ForeColor='black'
$btnFix.BackColor = 'darkred'
$btnFix.Text = "Fix"
$btnFix.Font= 'Microsoft Sans Serif,16'
$btnFix.FlatStyle = 'Flat'
$btnFix.FlatAppearance.BorderSize = 3
$btnFix.FlatAppearance.BorderColor = 'black'
$btnFix.FlatAppearance.MouseDownBackColor = 'darkcyan'
$btnFix.FlatAppearance.MouseOverBackColor = 'gray'
$btnFix.Add_MouseEnter({$btnFix.ForeColor = 'White'})
$btnFix.Add_MouseLeave({$btnFix.ForeColor = 'Black'})
$btnFix.Add_Click({
DeployApp "Fix" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsFix.bat'
$form.Close()
})

#changelog
$btnChangeLog = New-Object System.Windows.Forms.Button
$btnChangeLog.Location = New-Object System.Drawing.Point(026,600)
$btnChangeLog.Width = '115'
$btnChangeLog.Height = '40'
$btnChangeLog.ForeColor= 'white'
$btnChangeLog.BackColor = 'black'
$btnChangeLog.Text = "Changelog"
$btnChangeLog.Font= 'Microsoft Sans Serif,10'
$btnChangeLog.FlatStyle = 'Flat'
$btnChangeLog.FlatAppearance.BorderSize = 3
$btnChangeLog.FlatAppearance.BorderColor = 'black'
$btnChangeLog.FlatAppearance.MouseDownBackColor = 'Darkcyan'
$btnChangeLog.FlatAppearance.MouseOverBackColor = 'darkred'
$btnChangeLog.Add_MouseEnter({$btnChangeLog.ForeColor = 'black'})
$btnChangeLog.Add_MouseLeave({$btnChangeLog.ForeColor = 'darkred'})
$btnChangeLog.Add_Click({
    $form.TopMost = $false
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/changelog.txt' -OutFile "$env:SystemDrive\_Tech\changelog.txt" | Out-Null #download le .ps1
    Start-Process "$env:SystemDrive\_Tech\changelog.txt"
    Start-Sleep -s 5
    $form.TopMost = $true
})

#quitter
$btnQuit = New-Object System.Windows.Forms.Button
$btnQuit.Location = New-Object System.Drawing.Point(446,575)
$btnQuit.Width = '150'
$btnQuit.Height = '65'
$btnQuit.ForeColor= 'darkred'
$btnQuit.BackColor = 'black'
$btnQuit.Text = "Quitter"
$btnQuit.Font= 'Microsoft Sans Serif,16'
$btnQuit.FlatStyle = 'Flat'
$btnQuit.FlatAppearance.BorderSize = 3
$btnQuit.FlatAppearance.BorderColor = 'black'
$btnQuit.FlatAppearance.MouseDownBackColor = 'Darkcyan'
$btnQuit.FlatAppearance.MouseOverBackColor = 'darkred'
$btnQuit.Add_MouseEnter({$btnQuit.ForeColor = 'black'})
$btnQuit.Add_MouseLeave({$btnQuit.ForeColor = 'darkred'})
$btnQuit.Add_Click({
$importTaskModule
Task
$form.Close()
})
 
#Choisissez une option
$lblChoisirOption = New-Object System.Windows.Forms.label
$lblChoisirOption.Location = New-Object System.Drawing.Point(359,35)
$lblChoisirOption.AutoSize = $true
$lblChoisirOption.width = 325
$lblChoisirOption.height = 55
$lblChoisirOption.TextAlign = 'MiddleCenter'
$lblChoisirOption.Font= 'Microsoft Sans Serif,22'
$lblChoisirOption.ForeColor='white'
$lblChoisirOption.BackColor = 'darkred'
$lblChoisirOption.Text = "Choisissez une option"
$lblChoisirOption.BorderStyle = 'fixed3D'

#signatureSTO
$lblSignatureSTO = New-Object System.Windows.Forms.label
$lblSignatureSTO.Location = New-Object System.Drawing.Point(861,633)
$lblSignatureSTO.AutoSize = $true
$lblSignatureSTO.width = 180
$lblSignatureSTO.height = 20
$lblSignatureSTO.Font= 'Centau,10'
$lblSignatureSTO.ForeColor='gray'
$lblSignatureSTO.BackColor = 'black'
$lblSignatureSTO.Text = "Propriété de Jérémy Renaud"
$lblSignatureSTO.TextAlign = 'Middleleft'

#afficher la form
$form.controls.AddRange(@($lblSignatureSTO,$lblChoisirOption,$btnInstall,$btnOptiNett ,$btnDiagnostic,$btnDesinfection,$btnFix,$btnQuit,$btnChangeLog,$pictureBoxBackGround))
$form.ShowDialog() | out-null