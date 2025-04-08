#Make all kinds of Error as termination error so try and catch can work in any kinds of error
$ErrorActionPreference = "stop"
$edgepath ="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$no = @("no","nah","nope","n")
$yes = @("yes","yup","yeah","y")
$failedWallBoards =@()
$wallBoards = @(
    [pscustomobject]@{wyseTerminal='JWHQWB401';vdi='HKVDJPP0323';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1689'}
    [pscustomobject]@{wyseTerminal='JWHQWB402';vdi='HKVDJPP0324';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1666'}
    [pscustomobject]@{wyseTerminal='JWHQWB403';vdi='HKVDJPP0325';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1718'}
    [pscustomobject]@{wyseTerminal='JWHQWB404';vdi='HKVDJPP0326';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1720'}
    [pscustomobject]@{wyseTerminal='JWHQWB405';vdi='HKVDJPP0327';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1690'}
    [pscustomobject]@{wyseTerminal='JWHQWB406';vdi='HKVDJPP0328';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1715'}
    [pscustomobject]@{wyseTerminal='JWHQWB407';vdi='HKVDJPP0329';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1716'}
    [pscustomobject]@{wyseTerminal='JWHQWB408';vdi='HKVDJPP0330';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1717'}
    [pscustomobject]@{wyseTerminal='JWHQWB409';vdi='HKVDJPP3202';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/1719'}
    [pscustomobject]@{wyseTerminal='JWOCWB101';vdi='HKVDJPP0331';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2815'}
    [pscustomobject]@{wyseTerminal='JWOCWB102';vdi='HKVDJPP0332';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2816'}
    [pscustomobject]@{wyseTerminal='JWOCWB103';vdi='HKVDJPP0333';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2817'}
    [pscustomobject]@{wyseTerminal='JWNSWB101';vdi='HKVDJPP0334';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2498'}
    [pscustomobject]@{wyseTerminal='JWNSWB102';vdi='HKVDJPP0335';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2493'}
    [pscustomobject]@{wyseTerminal='JWNSWB103';vdi='HKVDJPP0336';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2494'}
    [pscustomobject]@{wyseTerminal='JWNSWB104';vdi='HKVDJPP0337';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2495'}
    [pscustomobject]@{wyseTerminal='JWNSWB105';vdi='HKVDJPP0338';url='https://hkwwmsp01.ap.zurich.com/ccm-web/admin/wms20/configuration/device/2496'}

)

function get-adm {
    <#
    
       .DESCRIPTION
       This function makes use of microsoft secureManagement and Microsoft secreStore modules to store your adm password into secureVault.This function accepts two parameters,admUsername and inputPassword.
       It returns credential object variable $cred.
    
       .Parameter admUsername
       adm username following with gitdir\
    
       .Parameter inputPassword
       adm password
    
    
    #>
    param (
    
    [Parameter(Mandatory=$true, HelpMessage="Please input your adm username following with gitdir\' .")]
    [string]$admUsername,
    
    [Parameter(Mandatory=$true, HelpMessage="Please input your adm password' .")]
    [string]$inputPassword
    )
    
    
    
    Set-Secret -Name adm -Secret $inputPassword
    
    $secureStringPwd = Get-secret -Name adm
    
    $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $admUsername, $secureStringPwd
    
    Write-Host "secure Object with variable name `$cred is created"
    return $credObject
    
    }
    

function checkMsaccess {

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$remoteComputer,
    [Parameter(Mandatory=$false, Position=1)]
    [string]$wyseTerminal
)

$remoteIp = (Test-Connection $remoteComputer -Count 1 -ErrorAction SilentlyContinue).ipv4Address | Select-Object -ExpandProperty IPAddressToString

$cimParam = @{
    CimSession  = New-CimSession -ComputerName $remoteComputer -SessionOption (New-CimSessionOption -Protocol Dcom)
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'cmd.exe /c winrm quickconfig -q' }
}

Invoke-CimMethod @cimParam > $null


$session  = New-PSSession -ComputerName $remoteIp  -Credential $cred

$proc = Invoke-Command -Session $session -ScriptBlock {  Get-Process msaccess -ErrorAction SilentlyContinue | Select-Object name, cpu }

if(!$proc) { 

write-host "MSACCESS is not running on $remoteComputer($wyseTerminal). Please remote to $remoteComputer for troubleshooting"

}

else { 
    <# From observation, a microsoft access process running idle without properly wallboard display 
    usually consumes far less CPU in term of CPU times. 10 second of CPU is a good threshold to determine
    if a microsoft access application displays wallboard
    #>
    if (((get-date).hour -ge 8 -and (get-date).hour -le 9) -and ($proc.cpu -lt 10 -or $proc.cpu -gt 800)) {

           Write-Host "The wallboard may not display properly on $remoteComputer($wyseTerminal) due to unusual low or high CPU usage and CPU time usage is $($proc.cpu)s.`n Please remote to $wyseTerminal to start the wallboard manually again"
    }

    elseif ($proc.cpu -lt 10) 
    
    {
        write-host ("The wallboard may not display properly on $remoteComputer($wyseTerminal) due to low CPU usage and CPU time usage is $($proc.cpu)s.`n Please remote to $wyseTerminal to start the wallboard manually again")

    }
    
    
    else {
    
    write-host "wallboard is running properly on $remoteComputer($wyseTerminal) and CPU time usage is $($proc.cpu)s"
    }

    }

}

ipconfig /flushdns


#Check user session exists on wallBoard VDIs

if($host.name -like "*ISE*") {

foreach($wallBoard in $wallBoards) {
 
try {
    quser /server:$($wallBoard.vdi)
}
catch [System.Management.Automation.RemoteException] {
    $failedWallBoards += $wallBoard
}

}
}
else{

   foreach($wallBoard in $wallBoards) {
    quser /server:$($wallBoard.vdi)

   if (-not $?) { $failedWallBoards += $wallBoard }

} 
}



if ($failedWallBoards.Count -gt 0){

for($i = 0; $i -lt $failedWallBoards.Count; $i++) {

Write-Host ("`nThere is no user session on $($failedWallBoards[$i].vdi). Please restart the $($failedWallBoards[$i].wyseTerminal).")

}

}

#Check MSACCESS process running on wallboard VDIs
do
{
    $answ = read-host "`nDo you want to check the wallboard VDIs are running MSACCESS(It may take 5 minutes)? yes or no?"
}
until($no -contains $answ -or $yes -contains $answ)

if ($yes -contains $answ) {


write-host "`n"
# create admin credential object if not exist
if ($null -eq $cred) {
    Write-Host ("Please enter the admin username and password.`nThe username should include the domain (e.g., gitdir\username).")
    $cred = get-adm
}

foreach($wallBoard in $wallBoards) {

if ($failedWallBoards -notcontains $wallBoard){

try {checkMsaccess $wallboard.vdi $wallBoard.wyseTerminal}

catch{

write-host "$($wallboard.vdi)($($wallBoard.wyseTerminal)) cannot remote. Please remote to $($wallboard.vdi) manually for troubleshooting"


}

} 
}
}

