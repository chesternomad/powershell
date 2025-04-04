$computers = Get-Content "H:\chester\powershell\list.txt"

winrm set winrm/config/client ‘@{TrustedHosts="*"}’


foreach ($computer in $computers) {

#& C:\temp\pstools\psexec.exe \\$computer -s powershell Enable-PSRemoting -Force

#Invoke-command -computername $computer -scriptblock {Set-ExecutionPolicy unrestricted -force}
 
#Invoke-Command -ComputerName $computer -ScriptBlock {Install-WindowsUpdate -microsoftupdate -AcceptAll -Install} >> \\hkpc022\c\temp\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log

#Invoke-WUjob -ComputerName $computer -Script {ipmo PSWindowsUpdate; install-WindowsUpdate -microsoftupdate -AcceptAll -AutoReboot} -Confirm:$false -Verbose –RunNow

Invoke-WUjob -ComputerName $computer -Script {ipmo PSWindowsUpdate; install-WindowsUpdate -microsoftupdate -AcceptAll} -Confirm:$false -Verbose –RunNow


}
