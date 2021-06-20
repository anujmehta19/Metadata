$files = Get-ChildItem "C:\Users\Administrator\Documents\Photos Script\Working for final user" -Filter '*.txt' -File

$files | Rename-Item -NewName {$_.Name -replace '.txt','.ps1'}