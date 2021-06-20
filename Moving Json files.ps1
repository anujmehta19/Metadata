#Script to move json files to other location, Script to be run first.
#Next Script is Perform_File_folder_sorting_operations.ps1

Remove-Variable * -ErrorAction SilentlyContinue

Function Moving_JsonFiles {
    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )
    
    #$name = "Anuj"

    $details = Get-ChildItem "$takeoutfolderpath\$name\takeout-*\Takeout\Google Photos\*"
    $subfolders = $details.Name
    $subfolders.Count
    $unique_sub_folder = $details.Name | Sort-Object -Unique
    $unique_sub_folder.Count

    $jsonfiles = Get-ChildItem "$takeoutfolderpath\$name\takeout-*" -Filter "*.json" -File -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "Total Json Files:" $jsonfiles.Count

    $jsonfiles | Out-File "$takeoutfolderpath\$name\Jsonlog.txt" -Force

    New-Item -Path "$takeoutfolderpath\$name\Jsonfiles" -Force -ItemType Directory

    $jsonfiles | Move-Item -Destination "$takeoutfolderpath\$name\Jsonfiles" -Force -ErrorAction SilentlyContinue
}