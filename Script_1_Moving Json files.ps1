#Next Script is Perform_File_folder_sorting_operations.ps1
<#
    .Synopsis
       Script to move json files to other location, Script to be run first.
    .Description
       Script to move json files to other location, Script to be run first.
    .Parameter takeoutfolderpath
       The path of the main folder where the Google Photos have been kept, e.g - C:\Google Photos
    .Parameter Name
       The Name of the person whose Google Photos have been downloaded.
    .Example
       Moving_JsonFiles -takeoutfolderpath "C:\Google Photos" -Name "Anuj"
    .Outputs
       It will save a copy of the logs of the Json files
    .Notes
       This script needs the Zip files to be extracted and kept in a folder in the following format
       "Drive:\$takeoutfolderpath\$name\takeout-*\Takeout\Google Photos\*"
       The Takeoutfolder = Google Photos
       The Name = "Name of the person whose pics are in the folder"
    .Functionality
       Script to move json files to other location, Script to be run first.
    #>

#Remove-Variable * -ErrorAction SilentlyContinue
Function Moving_JsonFiles {
    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )
    
    $details = Get-ChildItem "$takeoutfolderpath\$name\takeout-*\Takeout\Google Photos\*"
    
    $subfolders = $details.Name
    $subfolders.Count
    $unique_sub_folder = $details.Name | Sort-Object -Unique
    $unique_sub_folder.Count

    $jsonfiles = Get-ChildItem "$takeoutfolderpath\$name\takeout-*" -Filter "*.json" -File -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Output "Total Json Files:" $jsonfiles.Count

    New-Item -Path "$takeoutfolderpath\$name" -Name "Logs" -ItemType Directory -Force -ErrorAction Stop | Out-Null
    
    $jsonfiles | Out-File "$takeoutfolderpath\$name\Jsonlog.txt" -Force

    New-Item -Path "$takeoutfolderpath\$name" -Name "Jsonfiles" -ItemType Directory -Force -ErrorAction Stop | Out-Null

    $jsonfiles | Move-Item -Destination "$takeoutfolderpath\$name\Jsonfiles" -Force -ErrorAction SilentlyContinue
}