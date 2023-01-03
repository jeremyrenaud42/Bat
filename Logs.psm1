function AddLog ($filename,$message)
{
    $logfilepath = ".\Source\$filename"
    (Get-Date).ToString() + " - " + $message + "`r`n" | Out-file -filepath $logfilepath -append -force
}

function AddErrorsLog ($filename,$message)
{
    $errorslogfilepath = ".\Source\$filename" #chemin du fichier texte
    (Get-Date).ToString() + " - " + $message + "`r`n" | Out-file -filepath $errorslogfilepath -append -force #ajoute le texte dans le fichier
}