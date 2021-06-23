#Script to perform datechange and sorting, Script to be run Fourth.
#Next Script is Moving processed files to main folder.ps1

#Removing all the variables from the current powershell session
Remove-Variable * -ErrorAction SilentlyContinue

Function Metadata{

    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )

<#
Date modified = 23rd June 2021
#>

    Function Update-ExifDateTaken {

    <#
        .Synopsis
        Changes the DateTaken EXIF property in an image file.
        .Description
        This cmdlet updates the EXIF DateTaken property in an image by adding an offset to the 
        existing DateTaken value.  The offset (which must be able to be interpreted as a [TimeSpan] type)
        can be positive or negative - moving the DateTaken value to a later or earlier time, respectively.
        This can be useful (for example) to correct times where the camera clock was wrong for some reason - 
        perhaps because of timezones; or to synchronise photo times from different cameras.
        .Parameter Path
        The image file or files to process.
        .Parameter Offset
        The time offset by which the EXIF DateTaken value should be adjusted.
        Offset can be positive or negative and must be convertible to a [TimeSpan] type.
        .Parameter PassThru
        Switch parameter, if specified the paths of the image files processed are written to the pipeline.
        The PathInfo objects are additionally decorated with the Old and New EXIF DateTaken values.
        .Example
        Update-ExifDateTaken img3.jpg -Offset 0:10:0  -WhatIf
        Update the img3.jpg file, adding 10 minutes to the DateTaken property
        .Example
        Update-ExifDateTaken *3.jpg -Offset -0:01:30 -Passthru|ft path, exifdatetaken
        Subtract 1 Minute 30 Seconds from the DateTaken value on all matching files in the current folder
        .Example
        gci *.jpeg,*.jpg|Update-ExifDateTaken -Offset 0:05:00
        Update multiple files from the pipeline
        .Example
        gci *.jpg|Update-ExifDateTaken -Offset 0:5:0 -PassThru|Rename-Item -NewName {"Holday Snap {0:MM-dd HH.mm.ss}.jpg" -f $_.ExifDateTaken}
        Updates the EXIF DateTaken on multiple files and renames the files based on the new time
        .Outputs
        If -PassThru is specified, the scripcmdlet outputs FileInfo objects with additional ExifDateTaken
        and ExifOriginalDateTaken properties that can be used for later processing.
        .Notes
        This scriptcmdlet will overwrite files without warning - take backups first...
        .Functionality
        Modifies the EXIF DateTaken image property on a specified image file.
        #>

        [CmdletBinding(SupportsShouldProcess = $True)]
        [OutputType([System.IO.FileInfo])]
        Param (
            [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
            [Alias('FullName', 'FileName')]
            $ImageFile, 
        
            [Parameter(Mandatory = $True)]
            [DateTime]$datetaken 
        
            #[Switch]$PassThru
        )
        Begin {
            Set-StrictMode -Version Latest
            If ($PSVersionTable.PSVersion.Major -lt 3) {
                Add-Type -AssemblyName 'System.Drawing'
            }
        
        }
        
        Process {
            # Cater for arrays of filenames and wild-cards by using Resolve-Path
            Write-Output "Processing input item '$ImageFile'"
                $FileStreamArgs = @(
                    $ImageFile
                    [System.IO.FileMode]::Open
                    [System.IO.FileAccess]::Read
                    [System.IO.FileShare]::Read
                    1024, # Buffer size
                    [System.IO.FileOptions]::SequentialScan
                )
        
                Try {
                    $FileStream = New-Object System.IO.FileStream -ArgumentList $FileStreamArgs
                    $Img = [System.Drawing.Imaging.Metafile]::FromStream($FileStream)
                }
                Catch {
                    Write-Warning -Message "Check $ImageFile is a valid image file ($_)"
                    If ($Img) {$Img.Dispose()}
                    If ($FileStream) {$FileStream.Close()}
                    Break
                }
        
                # Convert to a string, changing slashes back to colons in the date.  Include trailing 0x00...
                $ExifTime = $datetaken.ToString("yyyy:MM:dd HH:mm:ss`0")
        
                Write-Verbose -Message "New Time is $($datetaken.ToString('F')) (Exif: $ExifTime)" 
        
                #endregion   
                # Overwrite the EXIF DateTime property in the image and set
                $propertyItem = [System.Runtime.Serialization.FormatterServices]::GetUninitializedObject( [System.Drawing.Imaging.PropertyItem] )
                $propertyItem.Id = 36867
                $propertyItem.Type = 2
                #$propertyItem.Length = 20
                $propertyItem.Value = [Byte[]][System.Text.Encoding]::ASCII.GetBytes($ExifTime)
                $Img.SetPropertyItem($propertyItem)
        
                # Create a memory stream to save the modified image...
                $MemoryStream = New-Object System.IO.MemoryStream
        
                Try {
                    # Save to the memory stream then close the original objects
                    # Save as type $Img.RawFormat  (Usually [System.Drawing.Imaging.ImageFormat]::JPEG)
                    $Img.Save($MemoryStream, $Img.RawFormat)
                }
                Catch {
                    Write-Warning -Message "Problem modifying image $ImageFile ($_)"
                    $MemoryStream.Close()
                    $MemoryStream.Dispose()
                    Break
                }
                Finally {
                    $Img.Dispose()
                    $FileStream.Close()
                }
        
        
                # Update the file (Open with Create mode will truncate the file)
        
                If ($PSCmdlet.ShouldProcess($ImageFile, 'Update EXIF DateTaken')) {
                    Try {
                        $Writer = New-Object System.IO.FileStream($ImageFile, [System.IO.FileMode]::Create)
                        $MemoryStream.WriteTo($Writer)
                    }
                    Catch {
                        Write-Warning -Message "Problem saving to $OutFile ($_)"
                        Break
                    }
                    Finally {
                        If ($Writer) {$Writer.Flush(); $Writer.Close()}
                        $MemoryStream.Close(); $MemoryStream.Dispose()
                    }return $true

                }
                else{
                return $false
                }
        } # End Process Block  
        
    } # End Function

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

    $mainpath = "$takeoutfolderpath\$name"

    $childitemmainpath = Get-ChildItem $mainpath

    foreach ($childitem in $childitemmainpath) {

        #Fetching the folder of the files
        $filepath = $childitem.Fullname
        $filepath_name = (Get-ItemProperty -Path $filepath).Name

        New-Item -Path $mainpath -Name Logs -ItemType "directory" -Force -ErrorAction SilentlyContinue | Out-Null
        
        #defining the start and end date to compare the date.
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
                $ImageFile = $file.fullname
                
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
                            #Start checing the date from the filenames
                                #Step 1
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
                                                    $validatedate = Validate-date -DateTaken $DateTaken
                                                    if($validatedate -eq $true){
                                                        if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                        try{
                                                        $ErrorActionPreference = "stop"
                                                        $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                        }
                                                        catch{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        if($setdatetaken -eq $true){
                                                        $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
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

                                #Step 2
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
                                                    $validatedate = Validate-date -DateTaken $DateTaken
                                                    if($validatedate -eq $true){
                                                        if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                        try{
                                                        $ErrorActionPreference = "stop"
                                                        $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                        }
                                                        catch{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        if($setdatetaken -eq $true){
                                                        $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
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
                                                else{
                                                $DateTaken = "No Date found from 2nd step."
                                                }
                                        }
                                        else{
                                        $DateTaken = "No Date found from 2nd step."
                                        }
                                    }
                                    catch{
                                    $DateTaken = "No Date found from 2nd step."
                                    }
                                }

                                #Step 3
                                if($DateTaken -like "No Date found from*"){
                                    try{
                                    $newregex_for_yyyymmddhhmmss = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2})'
                                        if($file.BaseName -match $newregex_for_yyyymmddhhmmss) {
                                            $date = ($Matches[2,3,1] -join "/") + " " + ($Matches[4..6] -join ":")
                                            $DateTaken = [datetime]$date
                                        
                                            $validatedate = Validate-date -DateTaken $DateTaken
                                            if($validatedate -eq $true){
                                                if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                try{
                                                $ErrorActionPreference = "stop"
                                                $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                }
                                                catch{
                                                $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                }
                                                }
                                                else{
                                                $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                }
                                                if($setdatetaken -eq $true){
                                                $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                }
                                                else{
                                                $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                }
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
                                        else{
                                        $DateTaken = "No Date found from 3rd step."
                                        }
                                    }
                                    catch{
                                    $DateTaken = "No Date found from 3rd step."
                                    }
                                }
                                
                                #Step 4
                                if($DateTaken -like "No Date found from*"){
                                    try{
                                        $newregex_for_yyyymmdd = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2})'
                                            if($file.BaseName -match $newregex_for_yyyymmdd){
                                                $date = ($Matches[2,3,1] -join "/")
                                                $date = [datetime]$date
                                                $DateTaken = $date

                                                $validatedate = Validate-date -DateTaken $DateTaken
                                                if($validatedate -eq $true){
                                                    if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                    try{
                                                    $ErrorActionPreference = "stop"
                                                    $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                    }
                                                    catch{
                                                    $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                    }
                                                    }
                                                    else{
                                                    $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                    }
                                                    if($setdatetaken -eq $true){
                                                    $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                    }
                                                    else{
                                                    $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                    }
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
                                            else{
                                            $DateTaken = "No Date found from 4th step."
                                            }
                                    }
                                    catch{
                                    $DateTaken = "No Date found from 4th step."
                                    }
                                }

                                #Step 5
                                if($DateTaken -like "No Date found from*"){                    
                                    try{
                                        $newregex_for_mm_dd_yyyy_hhmm = '.*([0-9]{2}).*([0-9]{2}).*([0-9]{4}).*([0-9]{4})'
                                            if($file.BaseName -match $newregex_for_mm_dd_yyyy_hhmm){
                                                $date = ($Matches[3,2,1] -join "/")
                                                $date = [datetime]$date
                                                $DateTaken = $date
                                                
                                                $validatedate = Validate-date -DateTaken $DateTaken
                                                    if($validatedate -eq $true){
                                                        if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                        try{
                                                        $ErrorActionPreference = "stop"
                                                        $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                        }
                                                        catch{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        if($setdatetaken -eq $true){
                                                        $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
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
                                                
                                                $validatedate = Validate-date -DateTaken $DateTaken
                                                    if($validatedate -eq $true){
                                                        if(($filename -like "*.Jpg") -or ($filename -like "*.Jpeg")){
                                                        try{
                                                        $ErrorActionPreference = "stop"
                                                        $setdatetaken = Update-ExifDateTaken -ImageFile $ImageFile -datetaken $DateTaken
                                                        }
                                                        catch{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
                                                        if($setdatetaken -eq $true){
                                                        $setdatetakenstatus = "Date Taken $DateTaken inserted to the $filename."
                                                        }
                                                        else{
                                                        $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
                                                        }
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
                                    $setdatetakenstatus = "Date Taken $DateTaken cannot be inserted to the $filename."
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
                            $setdatetakenstatus = "Date Taken $DateTaken already present in the $filename."
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
                                            'File Status' = $filestatus
                                            'Date Taken Inserted status' = $setdatetakenstatus}
                        }
                        else{
                            $newfilepath1 = New-Item -Path "$mainpath\No action taken" -Name $filepath_name -ItemType "Directory" -Force
                            $copyfilepath1 = $newfilepath1.FullName
                            Move-Item -Path "$filepath\$file" -Destination $copyfilepath1 -Force
                            $filestatus = "No action Performed, please check manually."
                            $gatherdata = [ordered]@{'File Name'= $filename
                                            'Date Photo was Taken' = $DateTaken
                                            'Old Date Modified'= $OldDateModified
                                                            
                                            'Old Creation Date' = $oldcreationdate
                                            'New Creation date'= $newcreationdate
                                            
                                            'Old Last write date' = $oldlastwritedate
                                            'New Last write date' = $newlastwritedate
                                            
                                            'Old Last access date' = $oldlastaccessdate
                                            'New Last access date' = $newlastaccessdate
                                            'File Status' = $filestatus
                                            'Date Taken Inserted status' = $setdatetakenstatus}
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

                    } # end of ForEach-Object Block
                    Remove-Variable datetaken, matches, date  -Force -ErrorAction SilentlyContinue | Out-Null
            } # End Of For each Block where file action is performed

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

                    $LogFilenotperformactionon = $seperator
                    Log-Filenotperformactionon $LogFilenotperformactionon

                    $LogFilenotperformactionon = "Total files processed: $filesworked"
                    Log-Filenotperformactionon $LogFilenotperformactionon

                    $LogFilenotperformactionon = "Total files failed to processed: $filesnotworked"
                    Log-Filenotperformactionon $LogFilenotperformactionon

                    $LogFilenotperformactionon = $seperator
                    Log-Filenotperformactionon $LogFilenotperformactionon
                    
    } # End of Main For Each Block

} # End of Function
Metadata
