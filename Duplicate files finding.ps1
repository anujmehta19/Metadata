Remove-Variable * -ErrorAction SilentlyContinue

$filepath = "C:\Files"

if(Test-Path $filepath){

$duplicates = Get-ChildItem -Path $filepath -File -Recurse -ErrorAction SilentlyContinue | Get-FileHash | Group-Object -Property Hash |Where-Object Count -gt 1

}

foreach ($d in $duplicates){

$output = $d.Group | Select-Object -Property Path, Hash
$output
}
#$result