Remove-Variable * -ErrorAction SilentlyContinue

$filepath = "C:\Neelam\New folder"
$files = Get-ChildItem -Path $filepath -File -Force
#$file.Name
$newregex_for_yyyymmddhhmmss = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2}).*([0-9]{2})'
$newregex_for_yyyymmdd = '.*([0-9]{4}).*([0-9]{2}).*([0-9]{2})'
$newregex_for_mm_dd_yyyy_hhmm = '.*([0-9]{2}).*([0-9]{2}).*([0-9]{4}).*([0-9]{4})'
$regex = '(?<filedate>\d{4}(?:\.|-|_)?\d{2}(?:\.|-|_)?\d{2})[^0-9]'
$newregex_for_dd_mm_yy = '([0-9]{2})-([0-9]{2})-([0-9]{2})'

#$CharWhiteList = '[^: \w\/]'

foreach ($file in $files){

$filename = $file.Name
$filename

#$ErrorActionPreference = "silentlycontinue"

try{
If($filename -match $regex) {

$date = $Matches['filedate'] -replace '(\.|-|_)',''

$date = [datetime]::ParseExact($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
#$date

}
}
catch{
$date = "Date not found moving to next step"
}
try{
if(($date -eq $null) -or ($date -ge (get-date)) -or ($date.GetType().name -ne "DateTime") -or ($date -le (Get-Date).AddYears(-100))){
If($file.BaseName -match $newregex_for_yyyymmddhhmmss) {

$date = ($Matches[2,3,1] -join "/") + " " + ($Matches[4..6] -join ":")
#$date = [datetime]($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
$date = [datetime]$date
#$date

}}
}
catch{
$date = "Date not found moving to next step"
}
try{
if(($date -eq $null) -or ($date -ge (get-date)) -or ($date.GetType().name -ne "DateTime") -or ($date -le (Get-Date).AddYears(-100))){
if($file.BaseName -match $newregex_for_yyyymmdd){


$date = ($Matches[2,3,1] -join "/")
#$date = [datetime]($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
$date = [datetime]$date
#$date

#[datetime]$date

}}
}
catch{
$date = "Date not found moving to next step"
}
try{
if(($date -eq $null) -or ($date -ge (get-date)) -or ($date.GetType().name -ne "DateTime") -or ($date -le (Get-Date).AddYears(-100))){
if($file.BaseName -match $newregex_for_mm_dd_yyyy_hhmm){


$date = ($Matches[3,2,1] -join "/")
#$date = [datetime]($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
$date = [datetime]$date
#$date

#[datetime]$date

}}
}
catch{
$date = "Date not found moving to next step"
}
try{
if(($date -eq $null) -or ($date -ge (get-date)) -or ($date.GetType().name -ne "DateTime") -or ($date -le (Get-Date).AddYears(-100))){
if($file.BaseName -match $newregex_for_dd_mm_yy){


$date = ($Matches[0])
#$date = [datetime]($date,'yyyyMMdd',[cultureinfo]::InvariantCulture)
$date = [datetime]$date
#$date

#[datetime]$date

}}
}
catch{
$date = "Date not found moving to next step"
}

if(($date -ne $null) -and ($date -le (get-date)) -and ($date -ne $Error[0]) -and ($date -le (Get-Date).AddYears(-100))){

New-Item -Path $filepath -Name "Datefound" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$file | Move-Item -Destination "$filepath\Datefound" -Force
"File moved"

}
else{ $date = "Date not found" }
$date
"*************************************************"

}