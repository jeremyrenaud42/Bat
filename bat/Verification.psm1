﻿# Fonction pour tester l'URL
Add-Type -AssemblyName "System.Net.Http"
function Test-Url {
    param (
        [string]$Url
    )

    try {
        # Send a HEAD request using Invoke-WebRequest
        $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -ErrorAction Stop

        # Return $true if the request was successful
        return $true
    }
    catch {
        # Handle and log errors
        Write-Error "Error checking URL: $_"
        return $false
    }
}


function Get-AdminStatus
{
    $adminStatus = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') 
    return $adminStatus
}
function Restart-Elevated
{
    <#
    .SYNOPSIS
        Relance le script en tant qu'administrateur
    .DESCRIPTION
        Si le script est pas executé en admin il va le relancer en admin et fermer l'ancien pas admin
    .PARAMETER Path
        Emplacement du fichier .ps1
    .EXAMPLE
        Restart-Elevated -Path c:\pathtomyscipt\myscript.ps1
        Va redémarer le script en admin
    #>  

    [CmdletBinding()]
    param
    (
        [string]$Path
    )


    Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $Path) -Verb RunAs
    Exit
}
function Get-InternetStatus
{
   $InternetStatus =  test-connection 8.8.8.8 -Count 1 -quiet
   return $InternetStatus
}
function Get-InternetStatusLoop
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
        $result = [System.Windows.MessageBox]::Show("Veuillez vous connecter à Internet et cliquer sur OK","Menu - Boite à outils du technicien",1,48)
        if($result -eq 'Cancel')
        {
            exit
        }
            start-sleep $CheckInterval
    }
}
function Get-NugetStatus
{
    $nugetStatus = Get-PackageProvider -name Nuget | Select-Object -expand name
    return $nugetStatus
}
function Get-WingetStatus
{
    $wingetVersion = winget -v
    $nb = $wingetVersion.substring(1)
    return $nb
}
function Get-ChocoStatus
{
    $chocoExist = Test-AppPresence "$env:SystemDrive\ProgramData\chocolatey"
    return $chocoExist
}
function Get-GitStatus
{
    $url = 'https://github.com/jeremyrenaud42/Bat'
    $test = Test-Url -url $url
    return $test
}
function Get-FtpStatus
{
    $url = 'https://ftp.alexchato9.com'
    $test = Test-Url -url $url
    return $test
}