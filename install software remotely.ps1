$computers = Get-Content "H:\chester\powershell\list.txt"
$username = "Sucden\chestery_a"
$password = Get-Content 'H:\chester\powershell\pwdforps2023.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password




foreach ($computer in $computers) {
    if (test-Connection -Cn $computer -quiet) {
        & C:\temp\pstools\psexec.exe \\$computer -s powershell Enable-PSRemoting -Force
    }
    else {
        "$computer is not online"
    }
}


foreach ($computer in $computers) {

    Invoke-Command -ComputerName $Computer -ScriptBlock {
   
        Stop-Process -Name "CQG.Trader.Application" -force 
    }
}

foreach ($computer in $computers) {

   
    Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock { &cmd.exe /c Msiexec /i "c:\temp\CQG_en-US_production_V7.03.103_Install.msi" /qn }

   

}


