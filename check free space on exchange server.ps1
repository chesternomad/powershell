$minsizeGB = 10

$disk = Get-WmiObject Win32_LogicalDisk -ComputerName svwexcpps02 -Filter "DeviceID='C:'" | Select-Object Size,FreeSpace ;

$freespaceGB = [Math]::Round([float]$disk.FreeSpace / 1073741824 ) ;

if ($freespaceGB -lt $minsizeGB )

    {
    $body = "Mail Exchange - C Drive Diskspace of exchange is below threshold of 10GB . Free Space of C drive is $($freespaceGB)GB. Please delete all log files except for the current one within C:\inetpub\logs\LogFiles W3SVC1 & W3SVC2."
    send-mailmessage -to stanley.ngai@sucfin.com, chester.yeung@sucfin.com -From chester.yeung@sucfin.com -Subject '[Action Required!]Mail Exchange - C Drive Free Space Daily Check' -body $body -SmtpServer mail.sucfin.com
    }
    else 
    
    {
    $body = "Mail Exchange - C Drive Diskspace of exchange is above threshold of 10GB. Free Space of C drive is $($freespaceGB)GB"
    send-mailmessage -to stanley.ngai@sucfin.com, chester.yeung@sucfin.com -From chester.yeung@sucfin.com -Subject 'Mail Exchange - C Drive Free Space Daily Check' -body $body -SmtpServer mail.sucfin.com}
