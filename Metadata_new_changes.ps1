#Script to perform datechange and sorting, Script to be run Fourth.
#Next Script is Moving processed files to main folder.ps1

#Removing all the variables from the current powershell session
Remove-Variable * -ErrorAction SilentlyContinue

Function Metadata{

param (
    [Parameter(Mandatory=$true)][string]$mainpath
    )

<#

Date modified = 18th June 2021

#>

Function Validate-date{

param (
    [Parameter(Mandatory=$true)]$DateTaken
    )


$startdate = (Get-Date).AddYears(-60)
$futuredate = (Get-Date).AddYears(60)


if($DateTaken -ne $null){

if($DateTaken.gettype().name -eq "Datetime"){

if(($DateTaken -ge $startdate) -and ($DateTaken -le $futuredate)){

return $true

}
return $false
}
return $false
}
return $false
}

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

#$mainpath = "C:\Photos_1"

$childitemmainpath = Get-ChildItem $mainpath

foreach ($childitem in $childitemmainpath) {

#Fetching the folder of the files
$filepath = $childitem.Fullname
$filepath
$filepath_name = (Get-ItemProperty -Path $filepath).Name
$filepath_name

New-Item -Path $mainpath -Name Logs -ItemType "directory" -Force -ErrorAction SilentlyContinue | Out-Null

$startdate = (Get-Date).AddYears(-60)
$futuredate = (Get-Date).AddYears(60)

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

                    if($DateTaken -eq "No Date Available"){
                        try{
                            #Checking for the file name to find date.
                            $file | ForEach-Object{
                                $regex = '(?<filedate>\d{4}(?:\.|-|_)?\d{2}(?:\.|-|_)?\d{2})[^0-9]'
                                $ErrorActionPreference = "silentlycontinue"
                                if($filename -match $regex) {
                                    $date = $Matches['filedate'] -replace '(\.|-|_)',''
                                    $date = [datetime]::ParseExact($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
                                    $DateTaken = $date
                                    #if (($DateTaken -ne $null) -and ($DateTaken.gettype().name -eq "Datetime") -and ($DateTaken -le (Get-Date).AddYears(60)) ) {
                                        $validatedate = Validate-date -DateTaken $DateTaken
                                        if($validatedate -eq $true){                                      
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
                                        else{
                                        $DateTaken = "No Date found from 1st step."
                                        }
                               }
                                else{
                                    $DateTaken = "No Date found from 1st step."
                                    }

                            }
                        }
                        catch{
                             $DateTaken = "No Date found from 1st step."
                        }
                    }
                    
                    if($DateTaken -like "No Date found from*"){
                        try{
                            if($filename -like ("IMG-*-*.*")){
                                $checkfilename = $true
                                    if ($checkfilename -ne $false) {
                                        $extractdatefromfilename = $filename.Split("-")[1]
                                        $datefromfile = $extractdatefromfilename.Insert(4,"/")
                                        $datefromfile = $datefromfile.Insert(7,"/")
                                        $datefromfile = [DateTime]$datefromfile
                                        $DateTaken = $datefromfile
                                            if (($DateTaken -ne $null) -and ($DateTaken.gettype().name -eq "Datetime") -and ($DateTaken -le (Get-Date).AddYears(60)) ) {

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
                                            else{
                                                $DateTaken = "No Date found from 2nd step."
                                                }
                                    }
                            }
                           }
                        catch{
                             $DateTaken = "No Date found from 2nd step."                    
                             }
                     }

                    if($DateTaken -like "No Date found from*"){
                        try{
                            $newregex_for_yyyymmddhhmmss = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2})'
                                if($file.BaseName -match $newregex_for_yyyymmddhhmmss) {
                                $date = ($Matches[2,3,1] -join "/") + " " + ($Matches[4..6] -join ":")
                                $DateTaken = [datetime]$date

                                }
                                    $validatedate = Validate-date -DateTaken $DateTaken
                                    if($validatedate -eq $true) {

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
                                    else{
                                        $DateTaken = "No Date found from 3rd step."
                                        }

                        }
                        catch{
                        $DateTaken = "No Date found from 3rd step."
                        }
                     }

                    if($DateTaken -like "No Date found from*"){
                        try{
                            $newregex_for_yyyymmdd = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2})'
                                if($file.BaseName -match $newregex_for_yyyymmdd){
                                    $date = ($Matches[2,3,1] -join "/")
                                    $date = [datetime]$date
                                    $DateTaken = $date
                                }
                                    $validatedate = Validate-date -DateTaken $DateTaken
                                    if($validatedate -eq $true) {

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
                                    else{
                                        $DateTaken = "No Date found from 4th step."
                                        }

                           }
                        catch{
                            $DateTaken = "No Date found from 4th step."
                             }
                    }

                    if($DateTaken -like "No Date found from*"){                    
                        try{
                            $newregex_for_mm_dd_yyyy_hhmm = '.*([0-9]{2}).*([0-9]{2}).*([0-9]{4}).*([0-9]{4})'
                                if($file.BaseName -match $newregex_for_mm_dd_yyyy_hhmm){
                                    $date = ($Matches[3,2,1] -join "/")
                                    $date = [datetime]$date
                                    $DateTaken = $date
                                }
                                    $validatedate = Validate-date -DateTaken $DateTaken
                                    if($validatedate -eq $true) {

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
                                    else{
                                        $DateTaken = "No Date found from 5th step."
                                        }

                           }
                        catch{
                            $DateTaken = "No Date found from 5th step."
                             }                   
                    }

                    if($DateTaken -like "No Date found from*"){
                         try{
                            $newregex_for_dd_mm_yy = '([0-9]{2})-([0-9]{2})-([0-9]{2})'
                                if($file.BaseName -match $newregex_for_dd_mm_yy){
                                    $date = ($Matches[0])
                                    $date = [datetime]$date
                                    $DateTaken = $date
                                }
                                    $validatedate = Validate-date -DateTaken $DateTaken
                                    if($validatedate -eq $true) {

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
                                   else{
                                        $DateTaken = "No Date details in the name available cannot change Metadata."
                                        }

                        }
                         catch{
                        $DateTaken = "No Date details in the name available cannot change Metadata."
                        }
                      }
                    
                    #Last step after all steps are exhausted
                    if($DateTaken -eq "No Date details in the name available cannot change Metadata."){
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
            #main else block
            else{
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
            if($DateTaken -ne "No Date details in the name available cannot change Metadata."){
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

Remove-Variable datetaken, matches -Force -ErrorAction SilentlyContinue | Out-Null

}

$seperator
$filesworked = ((Get-ChildItem $copyfilepath -File -Recurse -ErrorAction SilentlyContinue) | Measure-Object).Count
Write-Output "Total files processed:" $filesworked 
$filesnotworked = ((Get-ChildItem $copyfilepath1 -File -Recurse -ErrorAction SilentlyContinue) | Measure-Object).Count
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
}
Metadata -mainpath "C:\Neelam"