$body = @"
<html>
<body lang=EN-US style='font-family:"Arial";color:black;font-size:16'>Hi Andy,<br><br>
Here is the tape recording testing record for this week.<br><br>
Regards,<br>
</body>
</html>
"@
$attachmentpath = "\\hkdc1\hdrive\it\Operations\Voice Recording Check Log\Tape recording test log.xlsx"

send-mailmessage -to chester.yeung@sucfin.com, andy.leung@sucfin.com -From chester.yeung@sucfin.com -cc chesteryeung101@outlook.com -Subject 'Tape recording test' -bodyashtml $body -attachments $attachmentpath -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer mail.sucfin.com