workflow parallelRemoteCopy {
<#

   .DESCRIPTION
   This function accepts two parameters,targetComputers and copyItem.It uses default values 'C:\temp\OneDrive - Zurich APAC\Documents\work\powershell\computers.txt' for targetComputers if they are not provided by the user.
   This function makes use of parallel workflow to copy items to targeted computers in parallel

   .Parameter targetComputers
   text file containing list of target computer hostnames

   .Parameter copyItem
   Full filepath containes the file to copy to targetComputers


#>
param (

[Parameter(HelpMessage="Please provide filepath of text file containing list of targeted computers.Deafult value is 'C:\temp\OneDrive - Zurich APAC\Documents\work\powershell\computers.txt' .")]
[string]$targetComputers = "C:\Users\C.YEUNG\OneDrive - Zurich APAC\Documents\work\powershell\computers.txt",
[Parameter(Mandatory=$true, HelpMessage="Please provide filepath of file to copy to targeted computers.For Example, 'C:\Temp\teamsbootstrapper.exe' .")]
[string]$copyItem
)

write-host $copyItem

$computers = Get-Content -Path $targetComputers
$destinationPath = "c$\temp\"

foreach -parallel ($remotecomputer in $computers) {


inlinescript{

Copy-Item $using:copyItem -Destination "\\$using:remotecomputer\$using:destinationPath"  -Recurse


write-output "$using:copyItem are copied to C:\temp of $using:remotecomputer computers already."
}
}

}
