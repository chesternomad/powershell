
function Get-UserDevices {
   param (
       [string]$target
   )
   $target = $target.Trim().Replace("`n", "")
   $givenname, $surname = $target -split "[.\s]"
   $user = Get-ADUser -Server 'zurich.com' -Filter {
       givenname -like $givenname -and
       surname -like $surname -and
       name -notlike "adm-*"
   } | Select-Object -First 1 -Property UserPrincipalName
   if ($user -eq $null) {
       Write-Host "User not found."
       return
   }
   $userId = (Get-MgUser -UserId $user.UserPrincipalName).Id
   $devices = Get-MgUserManagedDevice -UserId $userId
   if ($devices -eq $null) {
       Write-Host "No managed devices found for the user."
       return
   }
   Write-Host "`nAll devices:"
   $devices | ForEach-Object { Write-Host $_.DeviceName }
   Write-Host "`nVDI Hostname:"
   $devices | Where-Object { $_.DeviceName -match "hkvd" -or $_.DeviceName -match "sgvd" } | ForEach-Object { Write-Host $_.DeviceName }
}
#$target = Read-Host -Prompt 'input username or hostname'
#Get-UserDevices -target $target