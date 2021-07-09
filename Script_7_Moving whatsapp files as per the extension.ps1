#Script to move the whats app files as per the extension to folders, Script to be run 7th.
#Next Script is ***********************************************

#Removing all the variables from the current powershell session
Remove-Variable * -Force -ErrorAction SilentlyContinue
function Sort_Whatsapp_files {
    
    param (
        [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
        [Parameter(Mandatory=$true)][string]$name
    )

    Function Validate-Year{

        param (
            [Parameter(Mandatory=$true)]$File_lastwriteyear
            )

        $startyear = (Get-Date).AddYears(-60).Year
        $futureyear = (Get-Date).AddYears(60).Year

        if($File_lastwriteyear -ne $null){

        if($File_lastwriteyear.gettype().name -eq "Int32"){

        if(($File_lastwriteyear -ge $startyear) -and ($File_lastwriteyear -le $futureyear)){

        return $true

        }
        return $false
        }
        return $false
        }
        return $false
        }


    $path = "$takeoutfolderpath\$name"
    $data = Get-ChildItem -Path $path -File -Recurse
    $extensioninfo = $data | Group-Object -Property Extension
    $Extensionnames = $extensioninfo | Select-Object -ExpandProperty Name

    foreach ($Extensionname in $Extensionnames){

    $filefullpaths = $extensioninfo | Where-Object -Property Name -eq "$Extensionname" | Select-Object -ExpandProperty Group | Select-Object -ExpandProperty FullName

    foreach ($filefullpath in $filefullpaths){

            $childfiledetails = Get-Item $filefullpath -Force
            $file_extensions = $childfiledetails.Extension
            $File_lastwriteyear = $childfiledetails.CreationTime.Year
            $File_name = $childfiledetails.Name
            
            if($File_name -like "*-WA*"){
                
                $whatsappfolder = New-Item -Path $takeoutfolderpath -Name "Whats app" -ItemType Directory -Force -ErrorAction Stop
                
                $validateyear = Validate-Year -File_lastwriteyear $File_lastwriteyear
                
                if($validateyear -eq $true){

                    $yearfolder = New-Item -Path $whatsappfolder -Name $File_lastwriteyear -ItemType Directory -Force -ErrorAction Stop

                    if($File_name -like "*$file_extensions"){
                
                        $extensionfolder = New-Item -Path $yearfolder -Name $file_extensions -ItemType Directory -Force -ErrorAction Stop
                        Move-Item -Path $filefullpath -Destination $extensionfolder -Force -ErrorAction Stop
                
                    }
                }
                else{
                
                    $noyearfound = New-Item -Path $whatsappfolder -Name "No Year Found" -ItemType Directory -Force -ErrorAction Stop
       
                    if($File_name -like "*$file_extensions"){
                
                    $extensionfolder = New-Item -Path $noyearfound -Name $file_extensions -ItemType Directory -Force -ErrorAction Stop
                    Move-Item -Path $filefullpath -Destination $extensionfolder -Force -ErrorAction Stop
                
                    }

                }

            }
            else {
            
                $Sorteddata = New-Item -Path $takeoutfolderpath -Name "Sorted Data" -ItemType Directory -Force -ErrorAction Stop
                
                    $validateyear = Validate-Year -File_lastwriteyear $File_lastwriteyear
                
                    if($validateyear -eq $true){
                
                        $yearfolder = New-Item -Path $Sorteddata -Name $File_lastwriteyear -ItemType Directory -Force -ErrorAction Stop

                        $extensionfolder = New-Item -Path $yearfolder -Name $file_extensions -ItemType Directory -Force -ErrorAction Stop
                        Move-Item -Path $filefullpath -Destination $extensionfolder -Force -ErrorAction Stop
                    
                        }
                    else{
                    
                        $noyearfound = New-Item -Path $Sorteddata -Name "No Year Found" -ItemType Directory -Force -ErrorAction Stop
                    
                        if($File_name -like "*$file_extensions"){
                            $extensionfolder = New-Item -Path $noyearfound -Name $file_extensions -ItemType Directory -Force -ErrorAction Stop
                            Move-Item -Path $filefullpath -Destination $extensionfolder -Force -ErrorAction Stop
                        }
            
                    }
             

            }

}

}

}
Sort_Whatsapp_files -takeoutfolderpath "C:\Neelam" -name "New folder"