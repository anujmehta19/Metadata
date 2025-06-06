#Script to copy files from multiple folders to unique folders, Script to be run third.
#Next Script is Metadata_New.ps1

#Removing the variables of the current powershell session.
#Remove-Variable * -ErrorAction SilentlyContinue

function Copy_Files_to_unique_folder {

    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )

    Function Log_file_moved_details {
        param(
            [Parameter(Mandatory=$true)]$Log_file_moved_details
        )

        Add-Content "$takeoutfolderpath\$name\Logs\Log_file_moved_details.txt" $Log_file_moved_details
    }

    $seperator = "-----------------------------------------------------------------------"

    New-Item -Path "$takeoutfolderpath\$name" -Name "Logs" -ItemType Directory -Force -ErrorAction Stop | Out-Null

    $jointpath = "$takeoutfolderpath\$name"

    $folder = Get-ChildItem -Path $jointpath

    $folderdetails = $folder | Select-Object -Property Name, FullName

    $sortedfolderdetails = $folderdetails | Sort-Object -Property Name

    $foldername = $folder | Select-Object -ExpandProperty Name

    $folderpath = $folder | Select-Object -Property FullName

    $foldername = $folder | Select-Object -ExpandProperty Name

    $sortedfolderpath = $folderpath | Sort-Object -Unique

    $sortedfoldername = $foldername | Sort-Object -Unique

    foreach($name in $sortedfolderdetails){

        $nameoffolder = $name.Name
        $pathoffolder = $name.FullName

            if($foldername -contains $nameoffolder){

                $create_new_folder = New-Item -Path "$takeoutfolderpath\$name\Data Ready to be processed\$name\$nameoffolder" -ItemType "Directory" -Force -ErrorAction SilentlyContinue

                $get_content_of_nameoffolder = Get-ChildItem -Path "$pathoffolder\*" -Recurse -Force -ErrorAction SilentlyContinue

                $nooffilespresent = $get_content_of_nameoffolder.count

                $move_content_of_nameoffolder = Move-Item -Path "$pathoffolder\*" -Destination $create_new_folder -Force -ErrorAction SilentlyContinue

                $Log_file_moved_details = $seperator
                Log_file_moved_details $Log_file_moved_details

                $Log_file_moved_details = "The name of the folder :$nameoffolder"
                Log_file_moved_details $Log_file_moved_details

                $Log_file_moved_details = "The path of the folder :$pathoffolder"
                Log_file_moved_details $Log_file_moved_details

                $Log_file_moved_details = "Total Files in the folder: $nooffilespresent"
                Log_file_moved_details $Log_file_moved_details

                $Log_file_moved_details = $seperator
                Log_file_moved_details $Log_file_moved_details

            }

    }

}
Copy_Files_to_unique_folder -takeoutfolderpath -name
