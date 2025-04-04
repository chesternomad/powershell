#! /usr/bin/pwsh

<#

This comment block help you get all sid from users in userlist.txt

$users = Get-Content "H:\chester\powershell\userlist.txt"

foreach ($user in $users){

Get-WmiObject win32_useraccount -filter "name = '$user'" | Select name, sid | Export-Csv -Path "H:\chester\powershell\sid.csv" -NoTypeInformation -Append

}
#>
$sids = Import-Csv .\sid.csv | select -ExpandProperty sid
$computers = Import-Csv .\sid.csv | select -ExpandProperty computernames
$action = Read-host -Prompt "Enter 1 to turn off proxy`nEnter 2 to turn on proxy"
$parm1 = '/v', 'AutoConfigURL', '/f', '/d', '0'
$parm2 = '/v', 'AutoConfigURL', '/f', '/d', 'http://pac.webdefence.global.blackspider.com:8082/proxy.pac?p=ffgrxt66'

#winrm set winrm/config/client @{TrustedHosts = "*" }
$computers.length
For ($i = 0; $i -lt $computers.length; $i++) {
    
    $computers[$i]

    $RemoteRegistry = Get-CimInstance -Class Win32_Service -ComputerName $computers[$i] -Filter 'Name = "RemoteRegistry"' -ErrorAction Stop

    Set-Service -Name RemoteRegistry -ComputerName $computers[$i] -StartupType Manual -ErrorAction Stop

    Start-Service -InputObject (Get-Service -Name RemoteRegistry -ComputerName $computers[$i]) -ErrorAction Stop

    $cmd = '\\' + $computers[$i] + '\HKEY_USERS\' + $sids[$i] + '\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'

    if ($action -eq '1') {
        reg add $cmd $parm1
    }
    elseif ($action -eq '2') {
        reg add $cmd $parm2
    }
}