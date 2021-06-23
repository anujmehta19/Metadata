#Script to perform sorting of folder and delete empty folders, Script to be run second.
#Next Script is Copy files to unique folders.ps1

#Removing the variables of the current powershell session.
#Remove-Variable * -ErrorAction SilentlyContinue
Function Perform_File_folder_sorting_operations {
    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )
        Function Log-EmptyFolders {
            param(
                [Parameter(Mandatory=$true)]$Logemptyfolders
            )
            
            Add-Content "$takeoutfolderpath\$name\Logs\Log-EmptyFolders.txt" $Logemptyfolders
        }

        Function Log-Subfolderfiles {
            param(
                [Parameter(Mandatory=$true)]$LogSubfolderfiles
            )
            
            Add-Content "$takeoutfolderpath\$name\Logs\Log-Subfolderfiles.txt" $LogSubfolderfiles
        }


$seperator = "-----------------------------------------------------------------------"

#$name = "test"

#$takeoutfolderpath = "F:\Google photos"

#Create a new folder to collect Logs
New-Item -Path "$takeoutfolderpath\$name" -Name "Logs" -ItemType Directory -Force -ErrorAction Stop | Out-Null

#Joining the main path to find the sub folders
$jointpath = "$takeoutfolderpath\$name"

#Getting Subfolders from the path
$takeoutfolderdetails = Get-ChildItem $jointpath\t* -Force -Directory

#Selecting the path of all the sub folder.
$takeoutfolders = $takeoutfolderdetails | Select-Object -ExpandProperty Fullname

#Finding childfolder from each subfolders.
    foreach ($takeoutfolder in $takeoutfolders){

        $subfolderdetails = Get-ChildItem -Path "$takeoutfolder\takeout\google photos\*" -Force -Directory
        $subfolders = $subfolderdetails | Select-Object -ExpandProperty Fullname

        #Getting files from each childfolder.
        foreach ($subfolder in $subfolders){

        $subfolderfiles = Get-ChildItem -Path $subfolder -file -Force -Recurse -ErrorAction SilentlyContinue 
        #Fetching the count of each folder.
        $count = ($subfolderfiles | Measure-Object).Count
                #if the count of the folder is 0 then perform the following operation.
                if($count -eq "0"){

                    $subfoldername = $subfolder.Split("\")[-1]

                    $Logemptyfolders = $seperator
                    Log-EmptyFolders $Logemptyfolders

                    $Logemptyfolders = "There are $count files in the folder $subfoldername"
                    Log-EmptyFolders $Logemptyfolders

                    $takeoutfoldername = $subfolder.Split("*\")[3]

                    if((Test-Path "$takeoutfolderpath\$name\Empty Folders") -like "false" ){
                    $movefileshere = New-Item -Path "$takeoutfolderpath\$name\Empty Folders\$takeoutfoldername" -ItemType "Directory" -ErrorAction SilentlyContinue
                    }
                    else{
                    $movefileshere = "$takeoutfolderpath\$name\Empty Folders\$takeoutfoldername"
                    }

                    if((Test-Path $movefileshere) -contains "$takeoutfoldername"){
                    Move-Item -Path $subfolder -Destination $movefileshere 
                    }
                    else{
                    $movefileshere = New-Item -Path "$takeoutfolderpath\$name\Empty Folders\$takeoutfoldername" -ItemType "Directory" -ErrorAction SilentlyContinue

                    Move-Item -Path $subfolder -Destination $movefileshere 
                    }

                    $Logemptyfolders = "The folder $subfolder is empty hence moved to $movefileshere"
                    Log-EmptyFolders $Logemptyfolders

                    $Logemptyfolders = $seperator
                    Log-EmptyFolders $Logemptyfolders

                }
                else{

                    $subfoldername = $subfolder.Split("\")[-1]

                    $count = ($subfolderfiles | Measure-Object).Count

                    $LogSubfolderfiles = $seperator
                    Log-Subfolderfiles $LogSubfolderfiles

                    $LogSubfolderfiles = $subfoldername
                    Log-Subfolderfiles $LogSubfolderfiles

                    $LogSubfolderfiles = "There are $count files in the folder $subfoldername"
                    Log-Subfolderfiles $LogSubfolderfiles

                    $LogSubfolderfiles = $subfolderfiles 
                    Log-Subfolderfiles $LogSubfolderfiles

                    $LogSubfolderfiles = $seperator
                    Log-Subfolderfiles $LogSubfolderfiles

                }

        }

    }
}
Perform_File_folder_sorting_operations -takeoutfolderpath 'F:\Google photos' -name 'Neelam'
