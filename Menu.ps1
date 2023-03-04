﻿#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore,Microsoft.VisualBasic
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

function CheckInternetStatus
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
    [Microsoft.VisualBasic.Interaction]::MsgBox("Veuillez vous connecter à Internet et cliquer sur OK",'OKOnly,SystemModal,Information', "Menu - Boite à outils du technicien") | Out-Null
    start-sleep 5
    }
}

function DownloadModules
{
    $modulepath = test-path "$applicationPath\source\Modules"
    if($modulepath -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip' -OutFile "$applicationPath\source\Modules.zip" | Out-Null
        Expand-Archive "$applicationPath\source\Modules.zip" "$applicationPath\source" -Force
        Remove-Item "$applicationPath\source\Modules.zip"
    }
}

function ImportModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

function DownloadAndImportModules
{
    DownloadModules
    ImportModules
}

function DownloadBackgroundAndIcone
{
    DownloadFile "fondpluiesize.gif" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' "$applicationPath\Source\Images"
    DownloadFile "Icone.ico" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' "$applicationPath\source\Images"
}

function CreateDesktopShortcut
{
    $desktop= [Environment]::GetFolderPath("Desktop")
    $shortcutExist = Test-Path "$desktop\Menu.lnk"
    if($shortcutExist -eq $false)
    {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$desktop\Menu.lnk")
    $Shortcut.TargetPath = "$env:SystemDrive\_Tech\Menu.bat"
    $Shortcut.IconLocation = "$applicationPath\Source\Images\Icone.ico"
    $Shortcut.Save()
    }
}

function DownloadRemoveScripts
{
    DownloadFile "Remove.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' "$env:SystemDrive\Temp"
    DownloadFile "Remove.bat" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' "$env:SystemDrive\Temp"
}

function DeployApp($appName,$githubPs1Link,$githubBatLink)
{
    CreateFolder "_Tech\Applications\$appName"
    set-location "$applicationPath\$appName" 
    DownloadFile "$appName\$appName.ps1" $githubPs1Link $applicationPath
    DownloadFile "$appName\RunAs$appName.bat" $githubBatLink $applicationPath
    Start-Process "$applicationPath\$appName\RunAs$appName.bat" | Out-Null
}

$adminStatus = CheckAdminStatus
if($adminStatus -eq $false)
{
    ReloadAsAdmin
}
CheckInternetStatus
$applicationPath = "$env:SystemDrive\_Tech\Applications"
set-location "$env:SystemDrive\_Tech" 
New-Item "$applicationPath\Source" -ItemType 'Directory' -Force | Out-Null   
DownloadAndImportModules
CreateFolder "_Tech\Applications\Source\images"
DownloadBackgroundAndIcone
CreateDesktopShortcut
CreateFolder "Temp"
DownloadRemoveScripts

$imgFile = [system.drawing.image]::FromFile("$applicationPath\Source\Images\fondpluiesize.gif") #Il faut mettre le chemin complet pour éviter des erreurs.
$pictureBoxBackGround = new-object Windows.Forms.PictureBox #permet d'afficher un gif
$pictureBoxBackGround.width = $imgFile.width 
$pictureBoxBackGround.height = $imgFile.height
$pictureBoxBackGround.Image = $imgFile 
$pictureBoxBackGround.AutoSize = $true 

$form = New-Object System.Windows.Forms.Form
$form.Text = "Menu - Boite à outils du technicien"
$form.Width = $imgFile.Width
$form.height = $imgFile.height
$form.MaximizeBox = $false
$form.icon = New-Object system.drawing.icon ("$applicationPath\Source\Images\Icone.ico") #Il faut mettre le chemin complet pour éviter des erreurs.
$form.KeyPreview = $True
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {Task;$form.Close()}}) #si on fait échape sa ferme la fenetre
$form.TopMost = $true
$form.StartPosition = "CenterScreen"
$form.BackgroundImageLayout = "Stretch"

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
Task
$form.Close()
})
 
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

$lblSignature = New-Object System.Windows.Forms.label
$lblSignature.Location = New-Object System.Drawing.Point(861,633)
$lblSignature.AutoSize = $true
$lblSignature.width = 180
$lblSignature.height = 20
$lblSignature.Font= 'Centau,10'
$lblSignature.ForeColor='gray'
$lblSignature.BackColor = 'black'
$lblSignature.Text = "Propriété de Jérémy Renaud"
$lblSignature.TextAlign = 'Middleleft'

$form.controls.AddRange(@($lblSignature,$lblChoisirOption,$btnInstall,$btnOptiNett,$btnDiagnostic,$btnDesinfection,$btnFix,$btnQuit,$btnChangeLog,$pictureBoxBackGround))
$form.ShowDialog() | out-null