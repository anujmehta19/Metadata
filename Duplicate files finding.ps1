#Script to finds duplicate files and moves them, Script to be run Sixth.
#Next Script is Moving whatsapp files as per the extension.ps1

#Removing all the variables from the current powershell session
Remove-Variable * -ErrorAction SilentlyContinue

Function Duplicate_files_sorting{

    param (
        [Parameter(Mandatory=$true)][string]$Rootfolder
    )

    Function Log_single_file_details {
        param(
            [Parameter(Mandatory=$true)]$Single_files_Logs
        )
        
        Add-Content "$Rootfolder\logs\Single_files.txt" $Single_files_Logs
    }

    Function Log_Duplicate_file_details {
        param(
            [Parameter(Mandatory=$true)]$Duplicate_files_Logs
        )
        
        Add-Content "$Rootfolder\logs\Duplicate_files.txt" $Duplicate_files_Logs
    }


    $seperator = "*****************************************************************************************************************************************"
    $seperator1 = "#########################################################################################################################################"
    $seperator2 = "----------------------------------------------------------------------------------------------------------------------------------------"

    if(Test-Path $Rootfolder){

    $duplicates = Get-ChildItem -Path $Rootfolder -File -Recurse -ErrorAction SilentlyContinue | 
    Get-FileHash | Group-Object -Property Hash | Where-Object Count -gt 1
    
    $singles = Get-ChildItem -Path $Rootfolder -File -Recurse -ErrorAction SilentlyContinue | 
    Get-FileHash | Group-Object -Property Hash | Where-Object Count -le 1

    }
    
    foreach ($s in $singles){
    
    $singleoutput = $s.Group | Select-Object -ExpandProperty Path #, Hash
    $singlefilepath = Get-Item $singleoutput | Select-Object -ExpandProperty FullName
    
    $Single_files_Logs = $seperator
    Log_single_file_details $Single_files_Logs

    $Single_files_Logs = $singlefilepath
    Log_single_file_details $Single_files_Logs

    $singlefilefolder = New-Item $Rootfolder -Name "Single Files" -ItemType Directory -Force -ErrorAction Stop
    $singlefilepath | Move-Item -Destination $singlefilefolder -Force -ErrorAction Stop

    $Single_files_Logs = "The file $singlefilepath has been moved to $singlefilefolder successfully."
    Log_single_file_details $Single_files_Logs

    $Single_files_Logs = $seperator
    Log_single_file_details $Single_files_Logs

    }

    foreach ($d in $duplicates){

        $Duplicateoutput = $d.Group | Select-Object -Property Path, Hash

        $duplicatefilecount = $Duplicateoutput.Count
        
        $One_of_the_duplicate_files = $Duplicateoutput | Select-Object -First 1 -ExpandProperty Path

        $Duplicate_files_Logs = "$seperator"
        Log_Duplicate_file_details $Duplicate_files_Logs

        $Duplicate_files_Logs = "$seperator1"
        Log_Duplicate_file_details $Duplicate_files_Logs

        $Duplicate_files_Logs = "Single Image:- $One_of_the_duplicate_files"
        Log_Duplicate_file_details $Duplicate_files_Logs

        $Duplicate_files_Logs = "$seperator1"
        Log_Duplicate_file_details $Duplicate_files_Logs

        $remainingduplicatefiles = $Duplicateoutput | Select-Object -Last ($duplicatefilecount-1) -ExpandProperty Path

            foreach($remainingduplicatefile in $remainingduplicatefiles){

                Resolve-Path -Path $remainingduplicatefile -ErrorVariable Errorinpath | Out-Null

                    if(!$Errorinpath){

                        $duplicatefileproperty = Get-ItemProperty -Path $remainingduplicatefile | Select-Object -Property DirectoryName
                        $duplicatefile_directory = $duplicatefileproperty.DirectoryName

                        $Duplicate_files_Logs = "Folder Name:- $duplicatefile_directory"
                        Log_Duplicate_file_details $Duplicate_files_Logs

                        $duplicatefolder = New-Item -Path "C:\Neelam" -Name "Duplicate Files" -ItemType Directory -Force #| Out-Null
                        Move-Item -Path $remainingduplicatefile -Destination $duplicatefolder -Force

                        $Duplicate_files_Logs = "Duplicate Image:- $remainingduplicatefile moved to $duplicatefolder successfully"
                        Log_Duplicate_file_details $Duplicate_files_Logs

                        $Duplicate_files_Logs = $seperator2
                        Log_Duplicate_file_details $Duplicate_files_Logs

                    }# If block ends here

            }# foreach block ends here

            $Duplicate_files_Logs = "$seperator1"
            Log_Duplicate_file_details $Duplicate_files_Logs

            $Duplicate_files_Logs = "$seperator`n"
            Log_Duplicate_file_details $Duplicate_files_Logs

    } #foreach block ends here


} # function ends here

Duplicate_files_sorting -Rootfolder "C:\Neelam"
