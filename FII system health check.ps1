$date = get-date -Format "yyyy-MM-dd HH:mm"

cd 'C:\Program Files (x86)\Google\Chrome\Application\'

.\chrome.exe --headless --disable-gpu --virtual-time-budget=1000000 --screenshot="c:\temp\FII_Health_Check.png" "http://live-bosup1-vm/ServicesMonitoring"

#cmd /c "c:\Program Files\Google\Chrome\Application\chrome.exe" --headless --screenshot="c:\temp\FII_Health_Check.png" "http://live-bosup1-vm/ServicesMonitoring"

Start-Sleep -s 60

$attachment = get-item c:\temp\FII_Health_Check.png

$params = @{
    #To =  "chester.yeung@sucfin.com"
    #Bcc = "chesteryeung101@outlook.com"
    To =  "projects@sucfin.com","futures2dev@sucfin.com"
    Bcc = "chester.yeung@sucfin.com","stanley.ngai@sucfin.com"
    From = "hkit@sucfin.com"
    SMTPServer = "mail.sucfin.com"
    Subject = "FII System Health Check"
    BodyAsHTML = $true
    Body = 'F2 Health Check on {0} <br /><img src="{1}" />' -f ($date) , ($attachment.Name)
    Attachments = $attachment.FullName
}


#send-mailmessage -to chester.yeung@sucfin.com -From chester.yeung@sucfin.com -Subject 'FII System Health Check' -bodyashtml $body -attachments $attachmentpath -SmtpServer mail.sucfin.com

Send-MailMessage @params

Start-Sleep -s 20

Remove-Item C:\temp\FII_Health_Check.png