#Script to perform datechange and sorting, Script to be run Fourth.
#Next Script is Moving processed files to main folder.ps1


#Removing all the variables from the current powershell session
Remove-Variable * -ErrorAction SilentlyContinue

<#

Date modified = 4th June 2021

#>

Function Log-Metadataoperations {
    param(
        [Parameter(Mandatory=$true)]$LogMetadataoperations
    )
    
    Add-Content "$mainpath\logs\LogMetadataoperations_$childitemName.txt" $LogMetadataoperations
}

Function Log-Filenotperformactionon {
    param(
        [Parameter(Mandatory=$true)]$LogFilenotperformactionon
    )
    
    Add-Content "$mainpath\logs\LogFilenotperformactionon_$childitemName.txt" $LogFilenotperformactionon
}

$mainpath = "C:\Photos_1"

$childitemmainpath = Get-ChildItem $mainpath



foreach ($childitem in $childitemmainpath) {

New-Item -Path $mainpath -Name Logs -ItemType "directory" -Force -ErrorAction SilentlyContinue

$childitemfullpath = $childitem.Fullname
$childitemfullpath
$childitemName = $childitem.Name
$childitemName

#Fetching the folder of the files
$filepath = $childitemfullpath

$filepath_name = (Get-ItemProperty -Path $filepath).Name

#Fetching all the files withing the folder
$Path = (Get-ChildItem $filepath -Recurse -ErrorAction SilentlyContinue)

#fetching the Count of the files
$Filecount = ((Get-ChildItem $filepath -Recurse -ErrorAction SilentlyContinue) | Measure-Object).Count

$ErrorActionPreference = "silentlycontinue"

$seperator = "*****************************************"

$seperator
$seperator
Write-Output "Total Files in the folder : $Filecount"
$seperator
$seperator

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = "Total Files in the folder : $Filecount"
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations


foreach ($file in $Path){


    
    #Using for removing junk character
    $CharWhiteList = '[^: \w\/]'

    #defined a shell object
    $Shell = New-Object -ComObject shell.application
    

    $newfilepath = New-Item -Path "$mainpath\File_Operations" -Name $filepath_name -ItemType "directory" -Force
    $copyfilepath = $newfilepath.FullName

    #Performing the operation for getting the metadata
            $file | ForEach-Object{
            
            $dir = $Shell.Namespace($_.DirectoryName)
            $filename = $file.name
            $filedata = Get-Item $filepath\$file

            #main try catch block        
                        
            try{
                $ErrorActionPreference = "Stop"

                #Getting the date taken from the file
                $DateTaken = [DateTime]($dir.GetDetailsOf($dir.ParseName($_.Name),12) -replace $CharWhiteList)
                $OldDateModified = [DateTime]($dir.GetDetailsOf($dir.ParseName($_.Name),3) -replace $CharWhiteList)

                $ErrorActionPreference = "Continue" 
                           
            }
            catch{
                $DateTaken = "No Date Available"
                }
            
            #main if block
            if($DateTaken -eq "No Date Available"){
                try{
                    $checkfilename = $filename
                    if($checkfilename -like ("IMG-*-*.*")){
                    $checkfilename = $true
                    }else{
                    $checkfilename = $false
                    $DateTaken = "No Date details in the name available cannot change Metadata."                    
                    }
                }
                catch{
                    $checkfilename = $false
                }
                if ($checkfilename -ne $false) {
                    $extractdatefromfilename = $filename.Split("-")[1]
                    $datefromfile = $extractdatefromfilename.Insert(4,"/")
                    $datefromfile = $datefromfile.Insert(7,"/")
                    $datefromfile = [DateTime]$datefromfile
                    $DateTaken = $datefromfile
                    if ($datefromfile -ne $null) {
                         try{
                            $ErrorActionPreference = "Stop"
                                        
                            #Getting the date details.
                             
                            $oldcreationdate = $filedata.CreationTime
                            $oldlastwritedate = $filedata.LastWriteTime
                            $oldlastaccessdate = $filedata.LastAccessTime
                            
                            $ErrorActionPreference = "Continue" 
                             
                            #performing the date change operation.
                             
                            if($oldcreationdate -ne $null){
                            $newcreationdate = $filedata.CreationTime = $DateTaken
                            }
                            if($oldlastwritedate -ne $null){
                            $newlastwritedate = $filedata.LastWriteTime = $DateTaken
                            }
                            if($oldlastaccessdate -ne $null){
                            $newlastaccessdate = $filedata.LastAccessTime = $DateTaken
                            }

                            }
                        catch{ 
                              $oldcreationdate = "Not available"
                              $oldlastwritedate = "Not available"
                              $oldlastaccessdate = "Not available"
                              $newcreationdate = "Not available"
                              $newlastwritedate = "Not available"
                              $newlastaccessdate = "Not available"
                              }

                    }   
                }

                if($DateTaken -eq "No Date details in the name available cannot change Metadata."){
                
                try{
                    if($DateTaken -like "No Date*"){
                        try{
                            #Checking for the file name to find date.
                            $file | ForEach-Object{
                            $regex = '(?<filedate>\d{4}(?:\.|-|_)?\d{2}(?:\.|-|_)?\d{2})[^0-9]'
                            $ErrorActionPreference = "silentlycontinue"
                                
                                If($filename -match $regex) {
                                $date = $Matches['filedate'] -replace '(\.|-|_)',''
                                $date = [datetime]::ParseExact($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
                                $DateTaken = $date

                                if ($DateTaken -ne $null) {
                        try{
                            $ErrorActionPreference = "Stop"
                                        
                            #Getting the date details.
                             
                            $oldcreationdate = $filedata.CreationTime
                            $oldlastwritedate = $filedata.LastWriteTime
                            $oldlastaccessdate = $filedata.LastAccessTime
                            
                            $ErrorActionPreference = "Continue" 
                             
                            #performing the date change operation.
                             
                            if($oldcreationdate -ne $null){
                            $newcreationdate = $filedata.CreationTime = $DateTaken
                            }
                            if($oldlastwritedate -ne $null){
                            $newlastwritedate = $filedata.LastWriteTime = $DateTaken
                            }
                            if($oldlastaccessdate -ne $null){
                            $newlastaccessdate = $filedata.LastAccessTime = $DateTaken
                            }

                            }
                        catch{ 
                              $oldcreationdate = "Not available"
                              $oldlastwritedate = "Not available"
                              $oldlastaccessdate = "Not available"
                              $newcreationdate = "Not available"
                              $newlastwritedate = "Not available"
                              $newlastaccessdate = "Not available"
                              }

                                }
                                
                                }
                            }
                        }
                        catch{
                                $DateTaken -eq "No Date details in the name available cannot change Metadata."
                        }
                        }
                }
                catch{
                    $DateTaken -eq "No Date details in the name available cannot change Metadata."
                }
                if($DateTaken -like "No Date*"){
                        try{
                            $ErrorActionPreference = "Stop"
                                        
                            #Getting the date details.
                             
                            $oldcreationdate = $filedata.CreationTime
                            $oldlastwritedate = $filedata.LastWriteTime
                            $oldlastaccessdate = $filedata.LastAccessTime
                            
                            $ErrorActionPreference = "Continue" 
                             
                            #performing the date change operation.
                             
                            if($oldcreationdate -ne $null){
                            $newcreationdate = $filedata.CreationTime = $DateTaken
                            }
                            if($oldlastwritedate -ne $null){
                            $newlastwritedate = $filedata.LastWriteTime = $DateTaken
                            }
                            if($oldlastaccessdate -ne $null){
                            $newlastaccessdate = $filedata.LastAccessTime = $DateTaken
                            }

                            }
                        catch{ 
                              $oldcreationdate = "Not available"
                              $oldlastwritedate = "Not available"
                              $oldlastaccessdate = "Not available"
                              $newcreationdate = "Not available"
                              $newlastwritedate = "Not available"
                              $newlastaccessdate = "Not available"
                              }

                }

            }
            }
            
            #main else block
            else {
                         try{
                            $ErrorActionPreference = "Stop"
                                        
                            #Getting the date details.
                             
                            $oldcreationdate = $filedata.CreationTime
                            $oldlastwritedate = $filedata.LastWriteTime
                            $oldlastaccessdate = $filedata.LastAccessTime
                            
                            $ErrorActionPreference = "Continue" 
                             
                            #performing the date change operation.
                             
                            if($oldcreationdate -ne $null){
                            $newcreationdate = $filedata.CreationTime = $DateTaken
                            }
                            if($oldlastwritedate -ne $null){
                            $newlastwritedate = $filedata.LastWriteTime = $DateTaken
                            }
                            if($oldlastaccessdate -ne $null){
                            $newlastaccessdate = $filedata.LastAccessTime = $DateTaken
                            }

                            }
                        catch{ 
                              $oldcreationdate = "Not available"
                              $oldlastwritedate = "Not available"
                              $oldlastaccessdate = "Not available"
                              $newcreationdate = "Not available"
                              $newlastwritedate = "Not available"
                              $newlastaccessdate = "Not available"
                              }

                }
            
            #Moving processed files to new folder
            if($DateTaken -notlike "No Date*"){
            Move-Item -Path "$filepath\$file" -Destination $copyfilepath -Force
            $filestatus = "File moved to $copyfilepath successfully."
            
                        $gatherdata = [ordered]@{'File Name'= $filename
                                        'Date Photo was Taken' = $DateTaken
                                        'Old Date Modified'= $OldDateModified
                                                        
                                        'Old Creation Date' = $oldcreationdate
                                        'New Creation date'= $newcreationdate
                                        
                                        'Old Last write date' = $oldlastwritedate
                                        'New Last write date' = $newlastwritedate
                                        
                                        'Old Last access date' = $oldlastaccessdate
                                        'New Last access date' = $newlastaccessdate
                                        'File Status' = $filestatus}


            }
            else{
                $newfilepath1 = New-Item -Path "$mainpath\No action taken" -Name $filepath_name -ItemType "Directory" -Force
                $copyfilepath1 = $newfilepath1.FullName
                Move-Item -Path "$filepath\$file" -Destination $copyfilepath1 -Force
                $filestatus = "File not performed action, please check manually."

                        $gatherdata = [ordered]@{'File Name'= $filename
                                        'Date Photo was Taken' = $DateTaken
                                        'Old Date Modified'= $OldDateModified
                                                        
                                        'Old Creation Date' = $oldcreationdate
                                        'New Creation date'= $newcreationdate
                                        
                                        'Old Last write date' = $oldlastwritedate
                                        'New Last write date' = $newlastwritedate
                                        
                                        'Old Last access date' = $oldlastaccessdate
                                        'New Last access date' = $newlastaccessdate
                                        'File Status' = $filestatus}
            
            }

            $Filemetadata = New-Object -TypeName PSobject -Property $gatherdata
            Write-Output $Filemetadata
            $seperator

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

            if($filestatus -like "File moved*"){

            $LogMetadataoperations = $Filemetadata | Out-String
            Log-Metadataoperations $LogMetadataoperations
            
            }
            else{
            
            $LogFilenotperformactionon = $seperator
            Log-Filenotperformactionon $LogFilenotperformactionon

            $LogFilenotperformactionon = $Filemetadata | Out-String
            Log-Filenotperformactionon $LogFilenotperformactionon

            $LogFilenotperformactionon = $seperator
            Log-Filenotperformactionon $LogFilenotperformactionon

            }
            
            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

        }

}


$seperator
$filesworked = ((Get-ChildItem $copyfilepath -Recurse -ErrorAction SilentlyContinue) | Measure-Object).Count
Write-Output "Total files processed:" $filesworked 
$filesnotworked = ((Get-ChildItem $copyfilepath1 -Recurse -ErrorAction SilentlyContinue) | Measure-Object).Count
Write-Output "Total files failed to processed:" $filesnotworked 
$seperator

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = "Total files processed: $filesworked"
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = "Total files failed to processed: $filesnotworked"
            Log-Metadataoperations $LogMetadataoperations

            $LogMetadataoperations = $seperator
            Log-Metadataoperations $LogMetadataoperations

}