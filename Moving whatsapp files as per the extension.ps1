#cls
Remove-Variable * -Force -ErrorAction SilentlyContinue

$path = "C:\Photos_1\Subfolder1"

$data = Get-ChildItem -Path $path -File -Recurse

$extensioninfo = $data | Group-Object -Property Extension
$Extensionnames = $extensioninfo | Select-Object -ExpandProperty Name
#$Extensionnames

foreach ($Extensionname in $Extensionnames){

$Extensionname_without_dot = [string]$Extensionname.Split(".")

$Extensionname_without_dot = $Extensionname_without_dot.Trim()

$newextensionfolder = New-Item -Path $path -Name $Extensionname_without_dot -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path "$path\*" -Filter "*$Extensionname" -Destination $newextensionfolder -Force -ErrorAction SilentlyContinue

$file_details = Get-ChildItem -Path "$path\$Extensionname_without_dot\*-WA*"

$file_path = $file_details.FullName

    foreach($file_detail in $file_details){

        $files_With_WA_in_name = $file_detail

        $filename = $files_With_WA_in_name.Name
        $size = [math]::Round($files_With_WA_in_name.Length/1MB,2)
        
        "*********************************************"
        Write-Output "File Name: $filename"
        Write-Output "File Size: $size MB"

}

if($file_detail -like "*$Extensionname*"){

$Extensionname_without_dot = [string]$Extensionname.Split(".")

$Extensionname_without_dot = $Extensionname_without_dot.Trim()

$newextensionfolder = New-Item -Path "$path\Whatsapp" -Name $Extensionname_without_dot -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path "$path\$Extensionname_without_dot\*-WA*" -Filter "*$Extensionname" -Destination $newextensionfolder -Force -ErrorAction SilentlyContinue

}

}