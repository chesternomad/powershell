$computers = Get-Content "H:\chester\powershell\list.txt"

winrm set winrm/config/client ‘@{TrustedHosts="*"}’

foreach ($computer in $computers) {

& C:\temp\pstools\psexec.exe -accepteula \\$computer -s powershell Enable-PSRemoting -Force

Invoke-command -computername $computer -scriptblock {Set-ExecutionPolicy unrestricted -force}

Update-WUModule -ComputerName $computer -Local -Confirm:$false

#get-wulist -MicrosoftUpdate -ComputerName $computers >> \\hkpc022\c\temp\${computers}-wsus_logs.log

#get-wulist -MicrosoftUpdate -ComputerName $computer >> \\hkpc022\c\temp\wsus_logs.log

Invoke-Command -ComputerName $computer -ScriptBlock {get-wulist -microsoftupdate -verbose } >> \\hkpc022\c\temp\${computer}-wsus_log.log

}



#$Script = {ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll | Out-File C:\PSWindowsUpdate.log -Append}

#Invoke-WUjob -ComputerName $computer -Script $Script -Confirm:$false -RunNow