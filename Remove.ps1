﻿Add-Type -AssemblyName PresentationCore,PresentationFramework

$desktop = [Environment]::GetFolderPath("Desktop")
$TechFolder = "$env:SystemDrive\_Tech"
$lockfile = "$env:SystemDrive\_Tech\Applications\source\*.lock"
$maxAttempts = 5
$attempt = 0
$dateFile = "C:\_tech\Applications\Source\installedDate.txt"

function Remove-DownloadFolder 
{
    Write-Host "Nettoyer le dossier des téléchargements"

    if (Test-Path "$env:USERPROFILE\Downloads\stoolbox.exe")
    {
         Remove-Item -Path "$env:USERPROFILE\Downloads\stoolbox.exe" -Force
    }

    if (-not (test-path $dateFile) -or (Get-Content -Path $dateFile -ErrorAction SilentlyContinue).Trim().Length -eq 0) 
    {
        Write-Host "Aucune date d'installation trouvée"
        return
    }
    # Read the date and time string from the file
    $logContent = Get-Content -Path $dateFile
    # Define the date and time string
    $dateString = $logContent.Trim()  # Trim whitespace and newlines
    # Convert the date string to a DateTime object
    $targetDateTime = [DateTime]::ParseExact($dateString, "yyyy-MM-dd HH:mm:ss", $null)
    
    # Get the list of files with a LastWriteTime on or before the target date and time
    $files = Get-ChildItem -Path "$env:USERPROFILE\Downloads" | Where-Object { $_.LastWriteTime -ge $targetDateTime }
    
    if ($files.Count -eq 0) 
    {
        Write-Host "Aucun fichiers récents trouvé dans le dossier des téléchargements."
        Start-Sleep -s 1
        return
    }
    # Remove the filtered files
    foreach ($file in $files) 
    {
        Remove-Item -Path $file.FullName -Recurse -Force
        Write-Output "$($file.FullName) a été supprimé"
    }
    Start-Sleep -s 1
}

function Remove-Task
{
    $TaskName = 'delete _tech'
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $task) 
    {
        if ($task.State -eq 'Ready') 
        {
            try 
            {
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "La tâche planifiée a été supprimée"
            } 
            catch 
            {
                Write-Host "Erreur lors de la suppression de la tâche: $($_.Exception.Message)"
            }
        } 
        else 
        {
            Write-Host "La tâche n'est pas en état 'Ready'. État actuel: $($task.State)"
        }
    } 
    else 
    {
        Write-Host "La tâche planifiée '$TaskName' n'existe pas."
    }
    Start-Sleep -Seconds 2
}

#Main
if (Test-Path $TechFolder)
{
    while(Test-Path $lockfile)
    {
        Write-Host "En attente de la fermeture des scripts [$attempt/$maxAttempts]"
        Start-Sleep -s 2
        $attempt++

        if ($attempt -ge $maxAttempts) 
        {
            Write-Host "La suppression de $TechFolder va se poursuivre, mais pourrait contenir des erreurs."
            break
        }
    }

    Remove-DownloadFolder
    Write-Host "Suppression du dossier $TechFolder"
    Remove-Item "$TechFolder\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $TechFolder -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Suppression du raccourci"
    Remove-Item "$desktop\Menu.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
    Start-Sleep -Seconds 2
    Write-Host "Vidage de la corbeille"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "La corbeille a été vidé"
    Start-Sleep -Seconds 2

    if (Test-Path $TechFolder)
    {
        [System.Windows.MessageBox]::Show("La suppression du dossier C:\_Tech a échoué","Suppression",0,48) | Out-Null
    }
}
#si C:\_Tech n'existe pas
else
{
    if (-not (Test-Path "$env:APPDATA\remove.ps1"))
    {
        Write-Host "Le dossier C:\_Tech n'existe pas."
        Start-Sleep -Seconds 2
    }
}

if (Test-Path "C:\Temp\Stoolbox\remove.ps1" -ErrorAction SilentlyContinue)
{
    Move-Item "C:\Temp\Stoolbox\remove.ps1" -Destination "$env:APPDATA\remove.ps1" -Force -ErrorAction SilentlyContinue | Out-Null
    Move-Item "C:\Temp\Stoolbox\remove.bat" -Destination "$env:APPDATA\remove.bat" -Force -ErrorAction SilentlyContinue | Out-Null
    $scriptPath = "$env:APPDATA\remove.ps1"
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
    exit
}

remove-Item -Path "$env:SystemDrive\Temp\Stoolbox\*" -Force -ErrorAction SilentlyContinue | Out-Null
remove-Item -Path "$env:SystemDrive\Temp\Stoolbox" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:APPDATA\remove.ps1" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:APPDATA\remove.bat" -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "Le dossier Temp a été supprimé"
Start-Sleep -Seconds 1
Remove-Task