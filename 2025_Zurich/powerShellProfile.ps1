
#Import-Module "C:\Users\adm-account\Downloads\Powershell\get-remotesession.psm1"
#Import-Module "C:\Users\username\OneDrive - Zurich APAC\Documents\work\powershell\remoteCopy.psm1"
#Import-Module "C:\Users\adm-account\Documents\WindowsPowerShell\Modules\get-adm\get-adm.psm1"
oh-my-posh init pwsh --config 'C:\Users\adm-account\AppData\Local\Programs\oh-my-posh\themes\quick-term.omp.json' | Invoke-Expression
Import-Module Terminal-Icons
Set-Alias pop Pop-Location
Set-Alias push push-location
Set-Alias drive set-location
Set-Alias g git

New-PSDrive -name "P" -root "\\server01\jpfs296_fslogix_profile$" -persist -psprovider filesystem -erroraction silentlycontinue
New-PSDrive -name "K" -root "\\server02\jpfs196_fslogix_profile$" -persist -psprovider filesystem -erroraction silentlycontinue
$global:driveMapping = import-excel -Path "C:\Users\username\OneDrive - Zurich APAC\Documents\work\DriveMappings.xlsx" -WorksheetName "DataForPowershell"


if ($host.name -match "consolehost") {
    
    set-PSReadLineOption -predictionsource History
    set-PSReadLineOption -PredictionViewStyle ListView

}

set-psreadlinekeyhandler -key uparrow -Function HistorySearchBackward
set-psreadlinekeyhandler -key downarrow -Function HistorySearchForward




function listfile {

    Get-ChildItem | Sort-Object LastWriteTime -Descending

}

function get-currentdate {

    get-date -format yyyyMMdd

}

function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

Set-Location "C:\Users\username\OneDrive - Zurich APAC\Documents\work\powershell" -ErrorAction SilentlyContinue

function touch($file) { "" | Out-File $file -Encoding ASCII }

function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.directory)\$($_)"
    }
}

function pgrep($name) {
    Get-Process | where-object {$_.Name -match "$name"}
}

function pkill($name) {
    Stop-Process -id (Get-Process | where-object {$_.Name -match "$name"}).Id
}

function reload-profile {

 & $profile.AllUsersAllHosts

}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}


function edit-profile{

if ($host.name -match "ise") {

    $psise.CurrentPowerShellTab.Files.add($profile.AllUsersAllHosts)

} else {
 
  code $profile

} 


}



function remotedir {
    param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$remoteComputer
    )

    invoke-item "\\$remoteComputer\c$"
}

function grep-ADUser {
    param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$user
    )
    Get-ADUser -server 'zurich.com' -Identity $user -Properties *  |Select-Object -Property @{Name= "ADNAME";Expression={$_.SamAccountName}},@{Name="PasswordExpiryDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},passwordlastset, whencreated, LockedOut, lastlogondate, sid,company,enabled

}

function grep-JADUser {
    param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$user
    )
    Get-ADUser -server 'jp.zurich.com' -Identity $user -Properties *  |Select-Object -Property @{Name= "ADNAME";Expression={$_.SamAccountName}},@{Name="PasswordExpiryDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},passwordlastset, whencreated, LockedOut, lastlogondate, sid,company,enabled

}

function grep-ADGroup {
   param (
       [Parameter(Mandatory=$true,position=0)]
       [string]$UserId,
       [Parameter(Mandatory=$false,position=1)]
       [string]$Keyword
   )
   # Get all groups for the specified user
   $groups = Get-ADUser -Identity $UserId -Property MemberOf | Select-Object -ExpandProperty MemberOf
   if (-not $groups) {
       Write-Output "No groups found for user $UserId"
       return
   }
   # Initialize a list to store matched groups
   #$matchedGroups = New-Object System.Collections.Generic.List[System.String]
   # Check if any group contains the keyword
   $matchedGroups = foreach ($group in $groups) {
       $groupName = (Get-ADGroup -Identity $group).Name
       if ($groupName -like "*$Keyword*") {
           $groupName
       }
   }
   if ($matchedGroups.Count -eq 0) {
       Write-Output "No groups found containing the keyword '$Keyword' for user $UserId"
   } else {
       Write-Output "Groups for user $UserId containing the keyword '$Keyword':"
       #$matchedGroups
       if($matchedGroups.where{ $_ -match "(MAP\S+)"}){
        $matchedGroups
        #write-host  $global:driveMapping
        write-host ("`nDrive Mappings for the user are:")
        $($global:driveMapping.("JPZ_"+$matches[0]))
       } else{
        $matchedGroups

   }
}
}


function grep-FolderGroup{

    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$folderPath
        )

        (get-acl $folderPath).access.IdentityReference | select-object -Unique

}

<#
function grep-ADGroup {

    param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$user,
    [Parameter(Mandatory=$false, Position=1)]
    [string]$ADGroupToFind
    )

    $groups = (Get-ADUser -Identity $user -Properties memberof).memberof | Sort-Object

    if (-not $ADGroupToFind){
    
    $groups | %  {write-host (Get-ADGroup -Identity $_).Name} 
    
    }
   else {
   $isMember = $false

   foreach ($group in $groups) {
       $groupName = (Get-ADGroup -Identity $group).Name
       if ($groupName -like "*$ADGroupToFind*") {
           Write-Output "$User is a member of $groupName."
           $isMember = $true
           
       }
       }
          if (-not $isMember) {
       Write-Output "$User is not a member of $ADGroupToFind."
     }
   }
   }
  #>

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

<#function prompt {
    $lastCommand = (Get-History)[-1]
    $time = [math]::round(($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).Totalseconds,2)
    return "[$time s] $((get-location).Path)> "
}#>



$cred=get-adm
