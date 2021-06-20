Remove-Variable * -ErrorAction SilentlyContinue

$allfolder = Get-ChildItem -Path C:\Neelam\2017 -Recurse
$allfolderpath = $allfolder.Fullname
foreach($folder in $allfolderpath){
Copy-Item -Path "C:\Photos\*" -Destination $folder}