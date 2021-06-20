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

Validate-date -DateTaken (get-date).AddYears(500)