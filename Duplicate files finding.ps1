Remove-Variable * -ErrorAction SilentlyContinue

Function Duplicate_files_sorting{

    param (
        [Parameter(Mandatory=$true)][string]$filepath
        )

    Function Log_Duplicate_file_details {
        param(
            [Parameter(Mandatory=$true)]$Duplicate_files
        )
        
        Add-Content "$filepath\logs\Duplicate_files.txt" $Duplicate_files
    }

    #$filepath = "C:\Neelam"
    $seperator = "*****************************************************************************************************************************************"
    $seperator1 = "#########################################################################################################################################"
    $seperator2 = "----------------------------------------------------------------------------------------------------------------------------------------"

    if(Test-Path $filepath){

    $duplicates = Get-ChildItem -Path $filepath -File -Recurse -ErrorAction SilentlyContinue | Get-FileHash | Group-Object -Property Hash | Where-Object Count -gt 1

    }

    foreach ($d in $duplicates){

        $output = $d.Group | Select-Object -Property Path, Hash

        $duplicatefilecount = $output.Count

        $singlefile = $output | Select-Object -First 1 -ExpandProperty Path

        $Duplicate_files = $filecount
        Log_Duplicate_file_details $Duplicate_files

        $Duplicate_files = "$seperator"
        Log_Duplicate_file_details $Duplicate_files

        $Duplicate_files = "$seperator1"
        Log_Duplicate_file_details $Duplicate_files

        $Duplicate_files = "Single Image:- $singlefile"
        Log_Duplicate_file_details $Duplicate_files

        $Duplicate_files = "$seperator1"
        Log_Duplicate_file_details $Duplicate_files

        $remainingduplicatefiles = $output | Select-Object -Last ($duplicatefilecount-1) -ExpandProperty Path

            foreach($remainingduplicatefile in $remainingduplicatefiles){

                Resolve-Path -Path $remainingduplicatefile -ErrorVariable Errorinpath | Out-Null

                    if(!$Errorinpath){

                        $duplicatefileproperty = Get-ItemProperty -Path $remainingduplicatefile | Select-Object -Property DirectoryName

                        $duplicatefile_directory = $duplicatefileproperty.DirectoryName

                        $Duplicate_files = "Folder Name:- $duplicatefile_directory"
                        Log_Duplicate_file_details $Duplicate_files

                        $duplicatefolder = New-Item -Path "C:\Neelam" -Name "Duplicate Files" -ItemType Directory -Force #| Out-Null

                        Move-Item -Path $remainingduplicatefile -Destination $duplicatefolder -Force

                        $Duplicate_files = "Duplicate Image:- $remainingduplicatefile moved to $duplicatefolder successfully"
                        Log_Duplicate_file_details $Duplicate_files

                        $Duplicate_files = $seperator2
                        Log_Duplicate_file_details $Duplicate_files

                    }# If block ends here

            } # foreach block ends here

            $Duplicate_files = "$seperator1"
            Log_Duplicate_file_details $Duplicate_files

            $Duplicate_files = "$seperator`n"
            Log_Duplicate_file_details $Duplicate_files

    } #foreach block ends here

} # function ends here

Duplicate_files_sorting -filepath "C:\Neelam"
