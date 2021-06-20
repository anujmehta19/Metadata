Remove-Variable * -ErrorAction SilentlyContinue

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
            
            
        #$FileItems = Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable ResolveError
        #If ($ResolveError) {
            #Write-Warning -Message "Bad path '$Path' ($($ResolveError[0].CategoryInfo.Category))"
        #}
    
        #Foreach ($FileItem in $FileItems) {
            # Read the current file and extract the Exif DateTaken property
            #$ImageFile = (Get-ChildItem $FileItem.Path).FullName
            # Parameters for FileStream: Open/Read/SequentialScan
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
    
                
            # Finally, if requested, decorate the path object with the EXIF dates and pass it on...
    
            #If ($PassThru) {
                #$FileItem | 
                    #Add-Member -MemberType NoteProperty -Name ExifDateTaken -Value $NewTime -PassThru |
                    #Add-Member -MemberType NoteProperty -Name ExifOriginalDateTaken -Value $OldTime -PassThru -ErrorAction SilentlyContinue
           #}
    
    
        #} # End Foreach Path
    
    } # End Process Block
    
    
    
    #End {
        # There is no end processing...
    #}
    
    
} # End Function

Update-ExifDateTaken -ImageFile (Get-Item "C:\Photos_1\Testing\VID-20170308-WA0000.3gp").FullName -datetaken (Get-Date).AddYears(2)