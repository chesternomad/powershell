#This script requires that RSAT be installed on your PC and the ImportExcel module also be installed.
#Import-Excel can be installed from the Powershell Gallery using install-module ImportExcel
#You may need to add the PSGallery repository to your PC first 
#Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
#Ideally the script should be run from a PC with Excel installed as well, although it might run without(?)
#If you have any issues please contact brendan.dadswell@zurich.co.jp
#It will produce an Excel file with one worksheet for all JP GAD users and another with inactive users. 
#It will CSV file of inactive users which can be used for the user deletion stage.

$output_folder_base1 = "C:\Users\username\OneDrive - Zurich APAC\Documents\work\ADReports"
$output_folder_base2 = "\\server01.jp.zurich.com\systems$\■System_ITOP\ITS-PST\001.Infrastructure\002.Security\001.Monthly Account Disable\LastLogon"
$folder_month = "$(get-date -f yyyy_MM)"
$year="$(get-date -f yyyy)"
$output_folder1 = $output_folder_base1 + "\" + $folder_month
if (!(Test-Path $output_folder1)) {
    New-Item $output_folder1 -ItemType Directory
}
$output_folder2 = $output_folder_base2 + "\" + $year + "\" + $folder_month
if (!(Test-Path $output_folder2)) {
    New-Item $output_folder2 -ItemType Directory
}

$output_file = $output_folder1 + "\LastLogonGAD_V2_" + $(get-date -f yyyyMMdd) + ".xlsx"

remove-item $output_file -ErrorAction SilentlyContinue

$mydate = (get-date).AddDays(-30)
$baddate = [DateTime]::FromFileTime("")

$users = Get-ADUser -Server zurich.com -filter * -Properties Emailaddress, Enabled, Created, lastlogon, description, lastlogondate, department, zurCompanyCode, GITDIRQMM95, Manager -SearchBase "OU=Users,OU=Japan,OU=APAC,DC=zurich,DC=com" `
| select-object SAMAccountName, givenname, surname, Emailaddress, Enabled, Created, lastlogon, lastlogondate, description, department, zurCompanyCode, GITDIRQMM95, Manager 

#$users = $users | select -last 1000

$GADservers = get-addomain -server zurich.com | select -ExpandProperty  ReplicaDirectoryServers

$logon_data = foreach ($GADserver in $GADservers) {
    Get-ADUser -Server $GADserver -filter * -Properties lastlogon -SearchBase "OU=Users,OU=Japan,OU=APAC,DC=zurich,DC=com" -ErrorAction SilentlyContinue | select-object SAMAccountName, lastlogon
}

$results = foreach ($user in $users) {
    $name = $user.SamAccountName
    $lastlogon = $user.lastLogon
    foreach ($logon in $logon_data) {
        $logonname = $logon.SAMaccountName
        $candidatelastlogon = $logon.lastlogon
        if (($logonname -eq $name) -and ($candidatelastlogon -ge $lastlogon) ) {
            #write-host "Name: $logonname , CurrentLastLogon: $lastlogon CandidateLastLogon:  $candidatelastlogon"
            $lastlogon = $candidatelastlogon
            #write-host "ResultantLastLogon: $lastlogon"
        }
    }

    $lastlogonFormatted = [DateTime]::FromFileTime($lastlogon)
    if ($lastlogonFormatted -eq $baddate) {
        if ($user.lastlogondate -notlike "") {
            $lastlogonFormatted = $user.lastlogondate
        }
        else {
            $lastlogonFormatted = "Never logged in"
        }
            
    }
    
    $company = switch ($user.ZurCompanyCode) {
        "3900" { "GI" }
        "3910" { "Life" }
        default { $user.ZurCompanyCode }
    }
    
    # added by chester on 2023/10/25 to fix user's Manager attribute is not set
    $manager = if ($null -eq $user.Manager) {
        @{ ManagerName = "Not Found"; ManagerEmail = "Not Found" }
    } else {
        $managerUser = Get-ADUser -Server zurich.com $user.Manager -Properties EmailAddress
        @{ ManagerName = $managerUser.SAMAccountName; ManagerEmail = $managerUser.EmailAddress }
    }

   
    $userObject = New-Object -TypeName psobject
    $userObject | Add-Member -MemberType NoteProperty -Name SAMAccountName -Value $user.SamAccountName
    $userObject | Add-Member -MemberType NoteProperty -Name FirstName -Value $user.givenname
    $userObject | Add-Member -MemberType NoteProperty -Name Surname -Value $user.surname
    $userObject | Add-Member -MemberType NoteProperty -Name Emailaddress -Value $user.EmailAddress
    $userObject | Add-Member -MemberType NoteProperty -Name Created -Value $user.Created
    $userObject | Add-Member -MemberType NoteProperty -Name Enabled -Value $user.Enabled
    $userObject | Add-Member -MemberType NoteProperty -Name LastLogOn -Value $lastlogonFormatted
    $userObject | Add-Member -MemberType NoteProperty -Name LastLogOnDate -Value $user.lastlogonDate
    $userObject | Add-Member -MemberType NoteProperty -Name Company -Value $company
    $userObject | Add-Member -MemberType NoteProperty -Name Description -Value $user.Description
    $userObject | Add-Member -MemberType NoteProperty -Name Department -Value $user.Department
    $userObject | Add-Member -MemberType NoteProperty -Name JAD -Value $user.GITDIRQMM95
    $userObject | Add-Member -MemberType NoteProperty -Name ManagerName -Value $manager.ManagerName
    $userObject | Add-Member -MemberType NoteProperty -Name ManagerEmail -Value $manager.ManagerEmail
    $userObject
    
   

}

$results | where-object { $_.Company -ne "Life" } | Export-Excel -WorksheetName "GAD Users" -TableName "GADUsers" -FreezeTopRow -Append -path $output_file -AutoSize
Copy-Item $output_file -destination $output_folder2