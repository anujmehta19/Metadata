

#script to move the files to main folder after they have been proccessed, script to be run Fifth
#Next Script is ************************

function Move_filestomainfolder {

param (
    [Parameter(Mandatory=$true)][string]$takeoutfolderpath,
    [Parameter(Mandatory=$true)][string]$name
    )

Remove-Variable * -ErrorAction SilentlyContinue

$mainpath = "$takeoutfolderpath\$name\File_Operations"

$childitemmainpath = Get-ChildItem $mainpath

foreach ($childitem in $childitemmainpath) {

$childitemfullpath = $childitem.Fullname

$childitemsfromthefolder = Get-ChildItem -Path $childitemfullpath -Recurse -Force -ErrorAction SilentlyContinue

$destinationfolder = New-Item -Path "$takeoutfolderpath\$name\" -Name FinalData -ItemType Directory -Force -ErrorAction SilentlyContinue

$destinationfolderpath = $destinationfolder.FullName

$movethefilestomainfolder = Move-Item -Path "$childitemfullpath\*" -Destination $destinationfolderpath -Force -ErrorAction SilentlyContinue

}
}
Move_filestomainfolder