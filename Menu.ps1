﻿<#
.SYNOPSIS
    Affiche un menu qui permet de sélectionner les actions à faire
.DESCRIPTION
    Directement téléchargé par le .exe il va permettre de poser les bases pour que tout fonctionne.
    vérifie donc qu'Internet soit présent, que le script soit en admin
    Créer les dossiers nécéssaires
    télécharge les modules et les importes (executionpolicy doit etre a unrestricted pour que ca importe)
    télécharge le script qui permet d'effacer/desisntaller le tout
    affiche un menu généré en WPF par un fichier XAML
    Permet d'installer winget et choco tout de suite au besoin
    Affiche les boutons qui ouvre les autres scripts
.NOTES
    est initialement downloadé par Stoolbox.exe depuis github
    Par la suite il ya un raccourci sur le bureau pour l'appeler
    Ou directement via le menu.bat dans c:\_tech
#>

#Load les assemblies nécéssaire au fonctionnement
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
########################Fonctions nécéssaire au déroulement########################

function Test-InternetConnection
{
    <#
    .SYNOPSIS
        Vérifie si il y a Internet de connecté
    .DESCRIPTION
        Envoi une seule requête PING vers 8.8.8.8 (google.com)
        Tant que la requête échoue ca affiche un message aux 5 secondes qui mentionne qu'il n'y a pas Internet
        Le message disparait après avoir cliquer OK si Internet est connecté.
    .PARAMETER PingAddress
        Adresse IP utilisé pour le ping. Defaut = 8.8.8.8 (Google.com)
    .PARAMETER CheckInterval
        Le nombre de délai avant de recommencer la reqête ping. Defaut = 5 secondes
    .EXAMPLE
        Test-InternetConnection
        Tests the internet connection using default parameters (pinging 8.8.8.8 every 5 seconds).
    .EXAMPLE
        Test-InternetConnection -PingAddress "1.1.1.1" -CheckInterval 10
        Tests the internet connection by pinging 1.1.1.1 and checking every 10 seconds.
    .Notes
        Ne prend pas la fonction deja inclus dans le module Verifiation car a ce moment la on a pas les modules de downloadé
    #>


    [CmdletBinding()]
    param
    (
        [string]$PingAddress = "8.8.8.8",

        [int]$CheckInterval = 5
    )


    while (!(test-connection $PingAddress -Count 1 -quiet))
    {
        $messageBoxText = "Veuillez vous connecter à Internet et cliquer sur OK"
        $messageBoxTitle = "Menu - Boite à outils du technicien"
        $failMessageBox = [System.Windows.MessageBox]::Show($messageBoxText,$messageBoxTitle,1,48)
        if($failMessageBox -eq 'Cancel')
        {
            exit
        }
        start-sleep $CheckInterval
    }
}

function Get-RemotePsm1Files
{
    <#
    .SYNOPSIS
        Download les modules nécéssaires pour tous les scripts
    .DESCRIPTION
        Download depuis github vers c:\_tech\applications\source
        C'est un zip qui les contient tous qui va être dezippé sous le dossier module
    #>
    $modulesFolderPath = "$sourceFolderPath\Modules"
    $modulesFolderPathExist = test-path -Path $modulesFolderPath
    if($modulesFolderPathExist -eq $false)
    {
        $zipFileDownloadLink = "https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip"
        $zipFile = "Modules.zip"
        Invoke-WebRequest -Uri $zipFileDownloadLink -OutFile $sourceFolderPath\$zipFile
        Expand-Archive -Path $sourceFolderPath\$zipFile -DestinationPath $sourceFolderPath -Force
        Remove-Item -Path $sourceFolderPath\$zipFile
    }
}

function Get-RequiredModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

function Show-Grid {
    param 
    (
        [Parameter(Mandatory)]
        [System.Windows.Controls.Grid]$GridToShow,
        [System.Collections.ArrayList]$AllGrids
    )
    # Hide all grids
    $AllGrids | ForEach-Object { $_.Visibility = 'Collapsed' }
    # Show the selected grid
    $GridToShow.Visibility = 'Visible'
}

function Initialize-Application($appName)
{
    <#
    .SYNOPSIS
        Configure et lance les scripts
    .DESCRIPTION
        Est utilisé lorsque qu'un bouton est cliqué
        Créer un dossier au nom de l'application
        Download le .ps1
        Execute le script
    .NOTES
        N'est pas dans un module, car c'est spécific au menu seulement
    #>
    $appPath = "$applicationPath\$appName"
    $appPathSource = "$appPath\source"
    Get-RemoteFile "Background_$appName.jpeg" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/assets/$Global:seasonFolderName/$Global:NumberRDM.jpeg" $appPathSource
    New-Item -Path $appPath -ItemType 'Directory' -Force
    Get-RemoteFile "$appName.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/$appName.ps1" $appPath 
    set-location $appPath
    $logFileName = Initialize-LogFile $appPathSource $appName
    if ($appName -eq "Installation")
    {
        Get-RemoteFile "$($appName)MainWindow.xaml" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/$($appName)MainWindow.xaml" $appPathSource
        $Global:appIdentifier = "$appName.ps1"
        $lockFile = "$sourceFolderPath\$appName.lock"
        Test-ScriptInstance $lockFile $Global:appIdentifier
    }
    else
    {
        $formControls.gridMenu.Visibility = 'collapsed'
        $formControls.imgBackGround.source = "c:\_tech\Applications\$appName\source\Background_$appName.jpeg"
        $formControls.lblTitre.Content = $appName
        # Dynamically construct the grid variable name
        $gridVariableName = "grid$appName"
        # Retrieve the value of the variable dynamically
        $GridToShow = (Get-Variable -Name $gridVariableName -ValueOnly)
        Show-Grid -GridToShow $GridToShow -AllGrids $grids
    }
    . $appPath\$appName.ps1
}

########################Déroulement########################
Test-InternetConnection
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$sourceFolderPath = "$applicationPath\source"
New-Item -Path $sourceFolderPath -ItemType 'Directory' -Force
Get-RemotePsm1Files
Get-RequiredModules
$global:sync['flag'] = $true 
$dateFile = "$sourceFolderPath\installedDate.txt"
$adminStatus = Get-AdminStatus
if($adminStatus -eq $false)
{
    Restart-Elevated -Path "$env:SystemDrive\_Tech\Menu.ps1"
}
if (-not (Test-Path $dateFile)) 
{
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss", [System.Globalization.CultureInfo]::CreateSpecificCulture("fr-FR")) | Out-File -FilePath $dateFile
}

$lockFile = "$sourceFolderPath\Menu.lock"
$Global:appIdentifier = "Menu.ps1"
Test-ScriptInstance $lockFile $Global:appIdentifier


#runspaces pour le GUI
#Définitions des ScriptBlocks
    $downloadXamlFile = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
    Get-RemoteFile "MenuMainWindow.xaml" "https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/MenuMainWindow.xaml" $sourceFolderPath
    Get-RemoteFile "Resources.xaml" "https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Resources.xaml" $sourceFolderPath
    }

    $downloadAssetsFile = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
    Import-Module "$sourceFolderPath\Modules\AssetsManagement.psm1"
    Get-RemoteFile "Background_menu.jpeg" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/assets/$Global:seasonFolderName/$Global:NumberRDM.jpeg" "$sourceFolderPath\Images"
    Get-RemoteFile "Icone.ico" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/assets/$Global:seasonFolderName/Icone.ico" "$sourceFolderPath\Images"
    Get-RemoteFile "Settings.JSON" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Settings.JSON" $sourceFolderPath
}

#Définitions des variables
$xamlPathExist = Test-Path $sourceFolderPath\MainWindow.xaml
$guiPathExist = Test-Path $sourceFolderPath\Images

$downloadXamlFileKey = "downloadXamlFile"
$downloadAssetsFileKey = "downloadAssetsFile"

#Lancement des runspaces
if($xamlPathExist -eq $false)
{
    $global:sync['downloadXamlFileResult'] =  Start-Runspace -RunspaceKey $downloadXamlFileKey -ScriptBlock $downloadXamlFile
    Write-Host "downloadXamlFileResult"
    Get-RunspaceState $global:sync['downloadXamlFileResult']
}

if($guiPathExist -eq $false)
{
    $global:sync['downloadAssetsFileResult'] = Start-Runspace -RunspaceKey $downloadAssetsFileKey -ScriptBlock $downloadAssetsFile
    Write-Host "downloadAssetsFileResult"
    Get-RunspaceState $global:sync['downloadAssetsFileResult']  
}

#nettoyage des runspaces
if ($global:runspaceStates.ContainsKey('downloadXamlFile') -and $global:runspaceStates['downloadXamlFile'] -eq 'Opened') 
{
    Write-Host "downloadXamlFileResult"
    Complete-AsyncOperation -RunspaceResult $global:sync['downloadXamlFileResult']
    Close-Runspace -RunspaceResult $global:sync['downloadXamlFileResult'] -RunspaceKey $downloadXamlFileKey
    Get-RunspaceState $global:sync['downloadXamlFileResult']
}


if ($global:runspaceStates.ContainsKey('downloadAssetsFile') -and $global:runspaceStates['downloadAssetsFile'] -eq 'Opened') 
{
    Write-Host "downloadAssetsFile"
    Complete-AsyncOperation -RunspaceResult $global:sync['downloadAssetsFileResult']
    Close-Runspace -RunspaceResult $global:sync['downloadAssetsFileResult'] -RunspaceKey $downloadAssetsFileKey
    Get-RunspaceState $global:sync['downloadAssetsFileResult']
}

########################GUI########################
Import-Module "$sourceFolderPath\Modules\WPF.psm1"
$xamlFile = "$sourceFolderPath\MenuMainWindow.xaml"
$xamlContent = Read-XamlFileContent $xamlFile
$formatedXamlFile = Format-XamlFile $xamlContent
$xamlDoc = Convert-ToXmlDocument $formatedXamlFile
$XamlReader = New-XamlReader $xamlDoc
$window = New-WPFWindowFromXaml $XamlReader
$formControls = Get-WPFControlsFromXaml $xamlDoc $window $global:sync

$gridMenu = $formcontrols.gridMenu
$gridOptimisation_Nettoyage = $formcontrols.gridOptimisation_Nettoyage
$gridDiagnostique= $formcontrols.gridDiagnostique
$gridDesinfection = $formcontrols.gridDesinfection
$gridFix= $formcontrols.gridFix
$grids = @($gridMenu, $gridOptimisation_Nettoyage, $gridDiagnostique,$gridDesinfection,$gridFix)

#Fonctions pour runspaces
$menuWinget = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\Verification.psm1"

    function Set-MenuWinget 
    {
        $version = Get-WingetStatus

        if ($version -ne $previousWingetVersion) 
        {
            $previousWingetVersion = $version

            if ($version -eq $null) 
            {
                $Text = "Non installé"
                $ForeColor = "Red"
                $buttonVisibility = "Visible"
                $buttonContent = "Installer"
            } 
            elseif ($version -ge 1.8) 
            {
                $Text = $version
                $ForeColor = "Green"
                $buttonVisibility = "Collapsed"
                $buttonContent = $null
            } 
            elseif ($version -lt 1.8) 
            {
                $Text = $version
                $ForeColor = "Orange"
                $buttonVisibility = "Visible"
                $buttonContent = "Mettre à jour"
            }

            # Update the GUI with the new status details
            $global:sync["txtBlkWingetVersion_Menu"].Dispatcher.Invoke([action]{
                $global:sync["txtBlkWingetVersion_Menu"].Foreground = $ForeColor
                $global:sync["txtBlkWingetVersion_Menu"].Text = $Text
                $global:sync["btnWinget_Menu"].Visibility = $buttonVisibility
                $global:sync["btnWinget_Menu"].Content = $buttonContent
            })
        }
        return $previousWingetVersion
        }
    $previousWingetVersion = 0
    while ($global:sync['flag'] -eq $true) 
    {
        $previousWingetVersion = Set-MenuWinget $previousWingetVersion
        Start-Sleep -s 2 
    }
    return
}

$menuChoco = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\Verification.psm1"
    Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"

    function Set-MenuChoco 
    {
        $currentChocoStatus = Get-ChocoStatus

        if ($currentChocoStatus -ne $previousChocoStatus) 
        {
            $previousChocoStatus = $currentChocoStatus

            if ($currentChocoStatus -eq $true) 
            {
                $Text = "Installé"
                $ForeColor = "Green"
                $buttonVisibility = "Collapsed"
            } 
            elseif ($currentChocoStatus -eq $false) 
            {
                $Text = "Non installé"
                $ForeColor = "Red"
                $buttonVisibility = "Visible"
                $buttonContent = "Installer"
            } 
            else 
            {
                $Text = "Erreur"
                $ForeColor = "Black"
                $buttonVisibility = "Visible"
            }

            # Update the GUI with the new status details
            $global:sync["txtBlkChocoVersion_Menu"].Dispatcher.Invoke([action]{
                $global:sync["txtBlkChocoVersion_Menu"].Foreground = $ForeColor
                $global:sync["txtBlkChocoVersion_Menu"].Text = $Text
                $global:sync["btnChoco_Menu"].Visibility = $buttonVisibility
                $global:sync["btnChoco_Menu"].Content = $buttonContent
            })
        }
        return $previousChocoStatus
    }

    $previousChocoStatus = $null
    while ($global:sync['flag'] -eq $true) 
    {
        $previousChocoStatus =  Set-MenuChoco $previousChocoStatus
        Start-Sleep -s 2
    }
    return
}

$menuFTP = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\Verification.psm1"

    function Set-MenuFTP 
    {
        $ftpStatus = Get-FtpStatus

        if ($ftpStatus -ne $previousFtpStatus) 
        {
            $previousFtpStatus = $ftpStatus

            if ($ftpStatus -eq $true) 
            {
                $Text = "Valide"
                $ForeColor = "Green"
            }
            else
            {
                $Text = "Injoignable"
                $ForeColor = "Red"
            }

            # Update the GUI with the new status details
            $global:sync["txtBlkFTPVersion_Menu"].Dispatcher.Invoke([action]{
                $global:sync["txtBlkFTPVersion_Menu"].Foreground = $ForeColor
                $global:sync["txtBlkFTPVersion_Menu"].Text = $Text
            })
        }
        return $previousFtpStatus
    }
    $previousFtpStatus = $null
    while ($global:sync['flag'] -eq $true) 
    {
        $previousFtpStatus = Set-MenuFTP $previousFtpStatus
        Start-Sleep -s 2
    }
    return
}

$menuGit = {
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\Verification.psm1"

    function Set-MenuGit 
    {
        $gitStatus = Get-GitStatus

        if ($gitStatus -ne $previousGitStatus) 
        {
            $previousGitStatus = $gitStatus

            if ($gitStatus -eq $true) 
            {
                $Text = "Valide"
                $ForeColor = "Green"
            }
            else 
            {
                $Text = "Injoignable"
                $ForeColor = "Red"
            }

            # Update the GUI with the new status details
            $global:sync["txtBlkGitVersion_Menu"].Dispatcher.Invoke([action]{
                $global:sync["txtBlkGitVersion_Menu"].Foreground = $ForeColor
                $global:sync["txtBlkGitVersion_Menu"].Text = $Text
            })
        }
        return $previousGitStatus
    }
    $previousGitStatus = $null
    while ($global:sync['flag'] -eq $true) 
    {
        $previousGitStatus = Set-MenuGit $previousGitStatus
        Start-Sleep -s 2
    }
    return
}

#variable pour runspaces
$menuChocoKey = "menuChoco"
$menuWingetKey = "menuWinget"
$menuFTPKey = "menuFTP"
$menuGitKey = "menuGit"
#Lancement des runspaces
$global:sync['menuChocoResult'] = Start-Runspace -ScriptBlock $menuChoco -RunspaceKey $menuChocoKey 
Write-Host "menuChocoResult"
Get-RunspaceState $global:sync['menuChocoResult']

$global:sync['menuWingetResult'] = Start-Runspace -RunspaceKey $menuWingetKey -ScriptBlock $menuWinget
Write-Host "menuWingetResult"
Get-RunspaceState $global:sync['menuWingetResult']

$global:sync['menuFTPResult'] = Start-Runspace -RunspaceKey $menuFTPKey -ScriptBlock $menuFTP
Write-Host "menuFTPResult"
Get-RunspaceState $global:sync['menuFTPResult']

$global:sync['menuGitResult'] = Start-Runspace -RunspaceKey $menuGitKey -ScriptBlock $menuGit
Write-Host "menuGitResult"
Get-RunspaceState $global:sync['menuGitResult']

########################GUI Events########################
$Window.add_Loaded({
    $formControls.btnLancementInstallation_Menu.Add_Click({
        $window.Close()
        Initialize-Application "Installation"
    })
    $formControls.btnLancementOptimisation_Nettoyage_Menu.Add_Click({
        Initialize-Application "Optimisation_Nettoyage"
    })
    $formControls.btnLancementDiagnostique_Menu.Add_Click({
        Initialize-Application "Diagnostique"
    })
    $formControls.btnLancementDesinfection_Menu.Add_Click({
        Initialize-Application "Desinfection"
    })
    $formControls.btnLancementFix_Menu.Add_Click({
        Initialize-Application "Fix"
    })
    $formControls.btnChangeLog_Menu.Add_Click({
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Get-RemoteFile "changelog.txt" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/changelog.txt" "$env:SystemDrive\_Tech\Applications\source"
        Start-Process "$env:SystemDrive\_Tech\Applications\source\changelog.txt"
    })
    $formControls.btnForceUpdate_Menu.Add_Click({
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Get-RemoteFileForce  "Installation.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1" "$env:SystemDrive\_Tech\Applications\Installation"
        Get-RemoteFileForce  "Optimisation_Nettoyage.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1" "$env:SystemDrive\_Tech\Applications\Optimisation_Nettoyage"
        Get-RemoteFileForce  "Diagnostique.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1" "$env:SystemDrive\_Tech\Applications\Diagnostique"
        Get-RemoteFileForce  "Desinfection.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1" "$env:SystemDrive\_Tech\Applications\Desinfection"
        Get-RemoteFileForce  "Fix.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1" "$env:SystemDrive\_Tech\Applications\Fix"
        Get-RemoteFileForce "Remove.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1" "$env:SystemDrive\Temp\Stoolbox"
        Get-RemoteFileForce  "Menu.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1" "$env:SystemDrive\_Tech"
        Invoke-WebRequest "https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip" -OutFile "$applicationPath\source\Modules.zip" | Out-Null
        Expand-Archive "$applicationPath\source\Modules.zip" "$applicationPath\source" -Force
        Remove-Item "$applicationPath\source\Modules.zip"
	    $window.Close()
        Restart-Elevated -Path "$env:SystemDrive\_Tech\Menu.ps1"
    })
    $formControls.btnUninstall_Menu.Add_Click({
        Remove-StoolboxApp
    })
    $formControls.gridMain.Add_MouseDown({
        $window.DragMove()
    })
    $formControls.btnClose.Add_Click({
        $window.Close()
        Exit
    })
    $formControls.btnMin.Add_Click({
        $window.WindowState = [System.Windows.WindowState]::Minimized
    })
    $formControls.btnWinget_Menu.Add_Click({
        $installWinget = {
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\Verification.psm1"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Install-Winget
        }
        $installWingetKey = "installWinget"
        $global:sync['installWingetResult'] =  Start-Runspace -RunspaceKey $installWingetKey -ScriptBlock $installWinget
        Write-Host "installWingetResult"
        Get-RunspaceState $global:sync['installWingetResult']
   })
   
   $formControls.btnChoco_Menu.Add_Click({
        $installChoco = {
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\Verification.psm1"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Install-Choco
        }
        $installChocoKey = "installChoco"
        $global:sync['installChocoResult'] =  Start-Runspace -RunspaceKey $installChocoKey -ScriptBlock $installChoco
        Write-Host "installChocoResult"
        Get-RunspaceState $global:sync['installChocoResult']
   })     
})

$window.add_Closing({
    #variable pour runspaces
    $global:sync['flag'] = $false #stop the loop
    $desktop = [Environment]::GetFolderPath("Desktop")

    $shortcutExist = test-path "$desktop\Menu.lnk"
    $removePs1Exist = test-path "$env:SystemDrive\Temp\Stoolbox\remove.ps1"

    $createShortcutKey = "createShortcut"
    $downloadRemoveScriptKey = "downloadRemoveScript"

    #scriptsblocks pour runspaces   
    $createShortcut = {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Add-DesktopShortcut "$desktop\Menu.lnk" "$env:SystemDrive\_Tech\Menu.ps1" "$sourceFolderPath\Images\Icone.ico"   
    }

    $downloadRemoveScript = {
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
        Get-RemoteFile "Remove.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1" "$env:SystemDrive\Temp\Stoolbox"
    } 
    #Lancement des runspaces
    if($shortcutExist -eq $false)
    {    
        $global:sync['createShortcutResult'] =  Start-Runspace -RunspaceKey $createShortcutKey -ScriptBlock $createShortcut
        Write-Host "createShortcutResult"
        Get-RunspaceState $global:sync['createShortcutResult']
    }

    if($removePs1Exist -eq $false)
    {
        $global:sync['downloadRemoveScriptResult'] =  Start-Runspace -RunspaceKey $downloadRemoveScriptKey -ScriptBlock $downloadRemoveScript
        Write-Host "downloadRemoveScriptResult"
        Get-RunspaceState $global:sync['downloadRemoveScriptResult']  
    }

    #Nettoyage des runspaces
    Write-Host "menuFTPResult"
    Close-Runspace -RunspaceResult $global:sync['menuFTPResult'] -RunspaceKey $menuFTPKey
    Get-RunspaceState $global:sync['menuFTPResult']

    Write-Host "menuGitResult"
    Close-Runspace -RunspaceResult $global:sync['menuGitResult'] -RunspaceKey $menuGitKey
    Get-RunspaceState $global:sync['menuGitResult']

    Write-Host "menuChocoResult"
    Close-Runspace -RunspaceResult $global:sync['menuChocoResult'] -RunspaceKey $menuChocoKey
    Get-RunspaceState $global:sync['menuChocoResult']

    Write-Host "menuWingetResult"
    Close-Runspace -RunspaceResult $global:sync['menuWingetResult'] -RunspaceKey $menuWingetKey
    Get-RunspaceState $global:sync['menuWingetResult']

    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    Import-Module "$sourceFolderPath\Modules\Verification.psm1"
    Import-Module "$sourceFolderPath\Modules\AppManagement.psm1"
    $chocostatus = Get-ChocoStatus

    if ($global:sync['installChocoResult'].Runspace.RunspaceStateInfo.State -eq 'Opened' -and $chocostatus -eq $false)
    {
        Write-Host "En attente de l'installation de Choco"
        $installChocoKey = "installChoco"
        $messageBoxText = "En attente de l'installation de Choco"
        $messageBoxTitle = "Menu - Boite à outils du technicien"
        $chocoMessageBox = [System.Windows.MessageBox]::Show($messageBoxText,$messageBoxTitle,0,64)
        Write-Host "installChocoResult"
        Complete-AsyncOperation -RunspaceResult $global:sync['installChocoResult']
        Close-Runspace -RunspaceResult $global:sync['installChocoResult'] -RunspaceKey $installChocoKey
        Get-RunspaceState $global:sync['installChocoResult']
    }
    elseif ($global:sync['installChocoResult'].Runspace.RunspaceStateInfo.State -eq 'Opened' -and $chocostatus -eq $true)
    {
        $installChocoKey = "installChoco"
        Write-Host "installChocoResult"
        Close-Runspace -RunspaceResult $global:sync['installChocoResult'] -RunspaceKey $installChocoKey
        Get-RunspaceState $global:sync['installChocoResult']
    }

    $wingetStatus = Get-WingetStatus
    if ($global:sync['installWingetResult'].Runspace.RunspaceStateInfo.State -eq 'Opened' -and
    ([string]::IsNullOrEmpty($wingetStatus) -or $wingetStatus -le '1.8'))
    {
        Write-Host "En attente de l'installation de Winget"
        $installWingetKey = "installWinget"
        $messageBoxText = "En attente de l'installation de Winget"
        $messageBoxTitle = "Menu - Boite à outils du technicien"
        $wingetMessageBox = [System.Windows.MessageBox]::Show($messageBoxText,$messageBoxTitle,0,64)
        Write-Host "installWingetResult"
        Complete-AsyncOperation -RunspaceResult $global:sync['installWingetResult']
        Close-Runspace -RunspaceResult $global:sync['installWingetResult'] -RunspaceKey $installWingetKey
        Get-RunspaceState $global:sync['installWingetResult']
    }
    elseif ($global:sync['installWingetResult'].Runspace.RunspaceStateInfo.State -eq 'Opened' -and $wingetStatus -ge '1.8')
    {
        $installWingetKey = "installWinget"
        Write-Host "installWingetResult"
        Close-Runspace -RunspaceResult $global:sync['installWingetResult'] -RunspaceKey $installWingetKey
        Get-RunspaceState $global:sync['installWingetResult']
    }

    if ($global:runspaceStates.ContainsKey('createShortcut') -and $global:runspaceStates['createShortcut'] -eq 'Opened') 
    {
        Write-Host "createShortcutResult"
        Complete-AsyncOperation -RunspaceResult $global:sync['createShortcutResult']
        Close-Runspace -RunspaceResult $global:sync['createShortcutResult'] -RunspaceKey $createShortcutKey
        Get-RunspaceState $global:sync['createShortcutResult']
    }

    if ($global:runspaceStates.ContainsKey('downloadRemoveScript') -and $global:runspaceStates['downloadRemoveScript'] -eq 'Opened') 
    {
        Write-Host "downloadRemoveScriptResult"
        Complete-AsyncOperation -RunspaceResult $global:sync['downloadRemoveScriptResult']
        Close-Runspace -RunspaceResult $global:sync['downloadRemoveScriptResult'] -RunspaceKey $downloadRemoveScriptKey
        Get-RunspaceState $global:sync['downloadRemoveScriptResult']
    }
})

$Window.add_Closed({
    Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
})

Start-WPFAppDialog $window