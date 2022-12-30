﻿Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.speech
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

#Cette fonction permet de relancer le script en mode Admin si besoin
function Admin
{
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
     {
        Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit #permet de fermer la session non-Admin
    }
}

function Zipsource #Download et création des fondamentaux
{
$fondpath = test-Path "$root\_Tech\applications\source\Images\fondpluiesize.gif" #Vérifie si le fond écran est présent
$iconepath = test-path "$root\_Tech\applications\source\Images\Icone.ico" #vérifie si l'icone existe
    if($fondpath -eq $false) #si fond pas présent
    {
        New-Item "$root\_Tech\Applications\Source\Images" -ItemType Directory -Force | Out-Null #créé les dossiers source\images
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$root\_Tech\applications\source\Images\fondpluiesize.gif" | Out-Null #Download le fond
    }
    if($iconepath -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$root\_Tech\applications\source\Images\Icone.ico" | Out-Null #Download l'icone
    } 
}


Admin
Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force #met la policy a unrestricted a cause de intermediate .ps1
$driveletter = $pwd.drive.name #retourne la lettre du disque actuel
$root = "$driveletter" + ":" #rajoute  : pour que sa fit dans le path
set-location "$env:SystemDrive\_Tech" #met la location au repertoir actuel
Zipsource #install les fichiers sources  
Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/task.psm1' -OutFile "$root\_Tech\applications\source\task.psm1" | Out-Null
Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/update.psm1' -OutFile "$root\_Tech\applications\source\update.psm1" | Out-Null
Import-Module "$root\_Tech\Applications\Source\task.psm1" | Out-Null #Module pour supprimer C:\_Tech
New-Item -ItemType Directory -Name "Temp" -Path "$env:SystemDrive\" -Force -ErrorAction SilentlyContinue | Out-Null #Creer dossier Temp  pour y copier/coller remove.
copy-item "$env:SystemDrive\_TECH\Applications\source\scripts\delete.ps1" -Destination "$env:SystemDrive\Temp" -Force | Out-Null #Copier delete dans $env:SystemDrive\temp
copy-item "$env:SystemDrive\_TECH\Remove.bat" -Destination "$env:SystemDrive\Temp" -Force | Out-Null #Copier remove dans c:\temp

$img = [system.drawing.image]::FromFile("$root\_Tech\Applications\Source\Images\fondpluiesize.gif") #Il faut mettre le chemin complet pour éviter des erreurs.
$pictureBoxBackGround = new-object Windows.Forms.PictureBox #permet d'afficher un gif
$pictureBoxBackGround.width = $img.width 
$pictureBoxBackGround.height = $img.height
$pictureBoxBackGround.Image = $img #contient l'image gif de background
$pictureBoxBackGround.AutoSize = $true 

$form = New-Object System.Windows.Forms.Form
$form.Text = "Menu - Boite à outils du technicien"
$form.Width = $img.Width
$form.height = $img.height
$form.MaximizeBox = $false
$form.icon = New-Object system.drawing.icon ("$root\_Tech\Applications\Source\Images\Icone.ico") #Il faut mettre le chemin complet pour éviter des erreurs.
$form.KeyPreview = $True
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {Task;$form.Close()}}) #si on fait échape sa ferme la fenetre
#$form.add_FormClosed({Task;$form.Close()})
$form.TopMost = $true
$form.StartPosition = "CenterScreen"
$form.BackgroundImageLayout = "Stretch"

function Zipinstallation
{
    $installationexepath = Test-Path "$root\_Tech\Applications\Installation\installation.ps1" #vérifie si le exe existe
    if($installationexepath) #S'Il existe
    {
        Remove-Item -Path "$root\_Tech\Applications\Installation\installation.ps1" -Recurse | Out-Null #supprime le .exe
    }
    #Créer le dossier vide Installation s'il n'existe pas
    $instapath = Test-Path "$root\_Tech\Applications\Installation" #vérifie si le dossier existe 
    if($instapath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Installation" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' -OutFile "$root\_Tech\Applications\Installation\Installation.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsInstallation.bat' -OutFile "$root\_Tech\Applications\Installation\RunAsInstallation.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Installation" #met le path dans le dossier Installation
    Start-Process "$root\_Tech\Applications\Installation\RunAsInstallation.bat" | Out-Null #Lance le script d'installation

}

#Installation
$boutonInstall = New-Object System.Windows.Forms.Button
$boutonInstall.Location = New-Object System.Drawing.Point(446,100)
$boutonInstall.AutoSize = $false
$boutonInstall.Width = '150'
$boutonInstall.Height = '65'
$boutonInstall.ForeColor='black'
$boutonInstall.BackColor = 'darkred'
$boutonInstall.Text = "Installation Windows"
$boutonInstall.Font= 'Microsoft Sans Serif,16'
$boutonInstall.FlatStyle = 'Flat'
$boutonInstall.FlatAppearance.BorderSize = 2
$boutonInstall.FlatAppearance.BorderColor = 'black'
$boutonInstall.FlatAppearance.MouseDownBackColor = 'darkcyan'
$boutonInstall.FlatAppearance.MouseOverBackColor = 'gray'
$boutonInstall.Add_MouseEnter({$boutonInstall.ForeColor = 'White'})
$boutonInstall.Add_MouseLeave({$boutonInstall.ForeColor = 'Black'})
$boutonInstall.Add_Click({
Zipinstallation
$form.Close()
})

function ZipOpti 
{
    #Mettre à jour le .exe s'il existe.
    $optiexepath = Test-Path "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" | Out-Null #vérifie si le .exe existe
    if($optiexepath) #si le .exe existe
    {
        Remove-Item -Path "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" -Recurse | Out-Null #supprime le .exe
    }
     #Créer le dossier vide Optimisation_Nettoyage s'il n'existe pas
    $optipath = Test-Path "$root\_Tech\Applications\Optimisation_Nettoyage" #vérifie si le dossier existe 
    if($optipath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Optimisation_Nettoyage" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' -OutFile "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsOptimisation_Nettoyage.bat' -OutFile "$root\_Tech\Applications\Optimisation_Nettoyage\RunAsOptimisation_Nettoyage.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Optimisation_Nettoyage" #met le path dans le dossier Optimisation
    Start-Process "$root\_Tech\Applications\Optimisation_Nettoyage\RunAsOptimisation_Nettoyage.bat" | Out-Null #Lance le script d'optimisation
}

#Optimisation et nettoyage
$boutonOptiNett = New-Object System.Windows.Forms.Button
$boutonOptiNett.Location = New-Object System.Drawing.Point(446,175)
$boutonOptiNett.AutoSize = $false
$boutonOptiNett.Width = '150'
$boutonOptiNett.Height = '65'
$boutonOptiNett.ForeColor='black'
$boutonOptiNett.BackColor = 'darkred'
$boutonOptiNett.Text = "Optimisation et Nettoyage"
$boutonOptiNett.Font= 'Microsoft Sans Serif,16'
$boutonOptiNett.FlatStyle = 'Flat'
$boutonOptiNett.FlatAppearance.BorderSize = 3
$boutonOptiNett.FlatAppearance.BorderColor = 'black'
$boutonOptiNett.FlatAppearance.MouseDownBackColor = 'darkcyan'
$boutonOptiNett.FlatAppearance.MouseOverBackColor = 'gray'
$boutonOptiNett.Add_MouseEnter({$boutonOptiNett.ForeColor = 'White'})
$boutonOptiNett.Add_MouseLeave({$boutonOptiNett.ForeColor = 'Black'})
$boutonOptiNett.Add_Click({
ZipOpti
$form.Close()
})

function Zipdiag
{
    #Mettre à jour le .exe s'il existe.
    $diagexepath = Test-Path "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1"  #vérifie si le .exe existe
    if($diagexepath) #s'il existe supprime le .exe
    {
        Remove-Item -Path "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
    #Créer le dossier vide Diagnostique s'il n'existe pas
    $diagpath = Test-Path "$root\_Tech\Applications\Diagnostique"  #vérifie si le dossier existe 
    if($diagpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Diagnostique" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' -OutFile "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsDiagnostique.bat' -OutFile "$root\_Tech\Applications\Diagnostique\RunAsDiagnostique.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Diagnostique" #met le path dans le dossier Diagnostique
    Start-Process "$root\_Tech\Applications\Diagnostique\RunAsDiagnostique.bat" | Out-Null #Lance le script de Diagnostique
}

#Diagnostic
$diagnostic = New-Object System.Windows.Forms.Button
$diagnostic.Location = New-Object System.Drawing.Point(446,250)
$diagnostic.Width = '150'
$diagnostic.Height = '65'
$diagnostic.ForeColor='black'
$diagnostic.BackColor = 'darkred'
$diagnostic.Text = "Diagnostique"
$diagnostic.Font= 'Microsoft Sans Serif,16'
$diagnostic.FlatStyle = 'Flat'
$diagnostic.FlatAppearance.BorderSize = 3
$diagnostic.FlatAppearance.BorderColor = 'black'
$diagnostic.FlatAppearance.MouseDownBackColor = 'darkcyan'
$diagnostic.FlatAppearance.MouseOverBackColor = 'gray'
$diagnostic.Add_MouseEnter({$diagnostic.ForeColor = 'White'})
$diagnostic.Add_MouseLeave({$diagnostic.ForeColor = 'Black'})
$diagnostic.Add_Click({
Zipdiag
$form.Close()
})

function Zipdesinfection 
{
    #Mettre à jour le .exe s'il existe.
    $desinfectionexepath = Test-Path "$root\_Tech\Applications\Securite\Desinfection.ps1"  #vérifie si le .exe existe
    if($desinfectionexepath) #s'il existe supprime le .exe
    {
        Remove-Item -Path "$root\_Tech\Applications\Securite\Desinfection.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
    #Créer le dossier vide Securite s'il n'existe pas
    $desinfectionpath = Test-Path "$root\_Tech\Applications\Securite"  #vérifie si le dossier existe 
    if($desinfectionpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Securite" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' -OutFile "$root\_Tech\Applications\Securite\Desinfection.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsDesinfection.bat' -OutFile "$root\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Securite" #met le path dans le dossier Securite
    Start-Process "$root\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #Lance le script de désinfcetion
}

#Desinfection
$desinfection = New-Object System.Windows.Forms.Button
$desinfection.Location = New-Object System.Drawing.Point(446,325)
$desinfection.Width = '150'
$desinfection.Height = '65'
$desinfection.ForeColor='black'
$desinfection.BackColor = 'darkred'
$desinfection.Text = "Désinfection"
$desinfection.Font= 'Microsoft Sans Serif,16'
$desinfection.FlatStyle = 'Flat'
$desinfection.FlatAppearance.BorderSize = 3
$desinfection.FlatAppearance.BorderColor = 'black'
$desinfection.FlatAppearance.MouseDownBackColor = 'darkcyan'
$desinfection.FlatAppearance.MouseOverBackColor = 'gray'
$desinfection.Add_MouseEnter({$desinfection.ForeColor = 'White'})
$desinfection.Add_MouseLeave({$desinfection.ForeColor = 'Black'})
$desinfection.Add_Click({
Zipdesinfection
$form.Close()
})

function Zipfix
{
    #Mettre à jour le .exe s'il existe.
    $fixexepath = Test-Path "$root\_Tech\Applications\Fix\Fix.ps1" #vérifie si le .exe existe
    if($fixexepath) #s'il existe supprime le fichier ps1
    {
        Remove-Item -Path "$root\_Tech\Applications\Fix\Fix.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
     #Créer le dossier vide Fix s'il n'existe pas
    $fixpath = Test-Path "$root\_Tech\Applications\Fix" #vérifie si le dossier existe 
    if($fixpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Fix" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' -OutFile "$root\_Tech\Applications\Fix\Fix.ps1" | Out-Null #download le .ps1
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsFix.bat' -OutFile "$root\_Tech\Applications\Fix\RunAsFix.bat" | Out-Null #download le .ps1
    set-location "$root\_Tech\\Applications\Fix" #met le path dans le dossier Fix
    Start-Process "$root\_Tech\Applications\Fix\RunAsFix.bat" | Out-Null #Lance le script de Fix
}

#Fix
$fix = New-Object System.Windows.Forms.Button
$fix.Location = New-Object System.Drawing.Point(446,400)
$fix.Width = '150'
$fix.Height = '65'
$fix.ForeColor='black'
$fix.BackColor = 'darkred'
$fix.Text = "Fix"
$fix.Font= 'Microsoft Sans Serif,16'
$fix.FlatStyle = 'Flat'
$fix.FlatAppearance.BorderSize = 3
$fix.FlatAppearance.BorderColor = 'black'
$fix.FlatAppearance.MouseDownBackColor = 'darkcyan'
$fix.FlatAppearance.MouseOverBackColor = 'gray'
$fix.Add_MouseEnter({$fix.ForeColor = 'White'})
$fix.Add_MouseLeave({$fix.ForeColor = 'Black'})
$fix.Add_Click({
Zipfix
$form.Close()
})


#quitter
$quit = New-Object System.Windows.Forms.Button
$quit.Location = New-Object System.Drawing.Point(446,575)
$quit.Width = '150'
$quit.Height = '65'
$quit.ForeColor= 'darkred'
$quit.BackColor = 'black'
$quit.Text = "Quitter"
$quit.Font= 'Microsoft Sans Serif,16'
$quit.FlatStyle = 'Flat'
$quit.FlatAppearance.BorderSize = 3
$quit.FlatAppearance.BorderColor = 'black'
$quit.FlatAppearance.MouseDownBackColor = 'Darkcyan'
$quit.FlatAppearance.MouseOverBackColor = 'darkred'
$quit.Add_MouseEnter({$quit.ForeColor = 'black'})
$quit.Add_MouseLeave({$quit.ForeColor = 'darkred'})
$quit.Add_Click({
Task
$form.Close()
})
 
#Choisissez une option
$labelchoisiroption = New-Object System.Windows.Forms.label
$labelchoisiroption.Location = New-Object System.Drawing.Point(359,35)
$labelchoisiroption.AutoSize = $true
$labelchoisiroption.width = 325
$labelchoisiroption.height = 55
$labelchoisiroption.TextAlign = 'MiddleCenter'
$labelchoisiroption.Font= 'Microsoft Sans Serif,22'
$labelchoisiroption.ForeColor='white'
$labelchoisiroption.BackColor = 'darkred'
$labelchoisiroption.Text = "Choisissez une option"
$labelchoisiroption.BorderStyle = 'fixed3D'

#signatureSTO
$signatureSTO = New-Object System.Windows.Forms.label
$signatureSTO.Location = New-Object System.Drawing.Point(861,633)
$signatureSTO.AutoSize = $true
$signatureSTO.width = 180
$signatureSTO.height = 20
$signatureSTO.Font= 'Centau,10'
$signatureSTO.ForeColor='gray'
$signatureSTO.BackColor = 'black'
$signatureSTO.Text = "Propriété de Jérémy Renaud"
$signatureSTO.TextAlign = 'Middleleft'

#afficher la form
$form.controls.AddRange(@($signatureSTO,$labelchoisiroption,$boutonInstall,$boutonOptiNett,$diagnostic,$desinfection,$fix,$quit,$pictureBoxBackGround))
$form.ShowDialog() | out-null