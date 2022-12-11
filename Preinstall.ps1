﻿Add-Type -AssemblyName Microsoft.VisualBasic
function Testconnexion
{
    $internet = $false
    $ping = test-connection 8.8.8.8 -Count 1 -quiet -ErrorAction Ignore
    if ($ping -eq $true)
    {
       $internet = $true 
    } 
    else 
    {

        [Microsoft.VisualBasic.Interaction]::MsgBox("Vous n'êtes pas connecté à Internet, certaines fonctionnalités ne pourraient pas fonctionner",'OKOnly,SystemModal,Information', "Menu") | Out-Null
    }
    return $internet
}


function SourceMenu #Créer dossier et met à jours tout ce qui touche menu, sauf preinstall.ps1 (lui meme) , tout ce passe dans la clé USB
{
    $Applications = test-path "$Psscriptroot\Applications" 
    if($Applications -eq $false)
    {
        New-Item "$Psscriptroot\Applications" -ItemType Directory -Force | Out-Null
    }

    $Source = test-path "$Psscriptroot\Applications\Source"  
    if($Source -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source" -ItemType Directory -Force | Out-Null
    }
    
    $scripts = test-path "$Psscriptroot\Applications\Source\scripts" 
    if($scripts -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source\scripts" -ItemType Directory -Force | Out-Null
    }
    
    $images = test-path "$Psscriptroot\Applications\Source\images" 
    if($images -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source\images" -ItemType Directory -Force | Out-Null
    }
    start-sleep -s 2

    if(Testconnexion)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/delete.ps1' -OutFile "$Psscriptroot\applications\source\scripts\delete.ps1" | Out-Null 
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsMenu.bat' -OutFile "$Psscriptroot\applications\source\scripts\RunAsMenu.bat" | Out-Null  
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.bat' -OutFile "$Psscriptroot\Remove.bat" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.bat' -OutFile "$Psscriptroot\Menu.bat" | Out-Null 
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1' -OutFile "$Psscriptroot\Menu.ps1" | Out-Null 
    
    $a = Test-Path "$Psscriptroot\applications\source\Images\fondpluiesize.gif"
    $b = Test-path  "$Psscriptroot\applications\source\Images\Icone.ico" 
    if($a -and $b -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$Psscriptroot\applications\source\Images\fondpluiesize.gif" | Out-Null #Download le fond
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$Psscriptroot\applications\source\Images\Icone.ico" | Out-Null #Download l'icone
    }
    }
}

function Launch #Copie tout dans la clé ou lance le script
{
    $menups1 = Test-Path "C:\_Tech\Menu.ps1" 
    $menubat = Test-Path "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat"

    if($menups1 -and $menubat)
    {
        Start-Process "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat" -WindowStyle Hidden
        exit
    }
    else
    {
        Write-Host "Le dossier C:\_Tech a été créé"
        Start-Sleep -s 1
        New-Item -ItemType Directory "C:\_Tech" -Force | Out-Null #Créer le dossier _Tech sur le C:
        New-Item -ItemType Directory -Name "Temp" -Path "C:\" -Force -ErrorAction SilentlyContinue | Out-Null #Creer dossier Temp  pour y copier/coller remove.
        write-host "Copie des fichiers sur le C:"
        Start-Sleep -s 1
        Copy-Item "$Psscriptroot\*" "C:\_TECH" -Recurse -Force | Out-Null #copy tous le dossier _Tech de la clé USB vers le dossier _Tech du C:
        Start-Sleep -s 1
        copy-item "C:\_TECH\Applications\source\scripts\delete.ps1" "c:\Temp" -Force #Copier delete dans c:\temp
        copy-item "C:\_TECH\Remove.bat" "c:\Temp" -Force #Copier remove dans c:\temp
        Start-Process "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat" -WindowStyle Hidden
        exit
    }
}





SourceMenu
Launch