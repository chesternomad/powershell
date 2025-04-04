$computers = Get-Content "H:\chester\powershell\list.txt"


# kill application accordingly before uninstallation if necessary
foreach ($computer in $computers) {

Invoke-Command -ComputerName $Computer -ScriptBlock {
   
    Stop-Process -Name "javaw" -force 
}
}
 
foreach ($computer in $computers) {

write-host "uninstall application for $computer"

(Get-WmiObject Win32_Product -ComputerName $computer | Where-Object {$_.name -like "*star*"}).uninstall()


}