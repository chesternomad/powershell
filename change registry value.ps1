$computers = Get-Content "H:\chester\powershell\list.txt"
$username = "Sucden\chestery_a"
$password = Get-Content 'H:\chester\powershell\pwdforps2022.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



foreach ($computer in $computers) {

#Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock {&cmd.exe /c "reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports\192.168.1.71" /v "SNMP Enabled" /t REG_DWORD /d 0x00000000 /f"}

 #Set-Service -ComputerName $computer -name RemoteRegistry -StartupType Automatic -Status Running

 Invoke-Command -Computer $computer  -ScriptBlock {Get-ItemProperty -Path: "HKLM:SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports\192.168.1.71" -Name "SNMP Enabled"} | Select-Object PSComputerName, "SNMP Enabled" |
         Out-File c:\temp\snmpvalue.txt -append

 }