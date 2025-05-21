#Requires AutoHotkey v2.0
#SingleInstance Force

;^=Control
;+=Shift
;!=Alt
;#=Win


;#:*:eee::chesteryeung2008@gmail.com
;#w::Run "C:\users\" A_Username "\Downloads"
;#e::Run "exe path"
;#h::Run A_ProgramFiles "\autohotkey\v2\autohotkey.chm"
;+^,::Send A_DD '/' A_MM '/' A_YYYY

/*
#hotif
xbutton2 & q::{
If WinExist("ahk_exe Obsidian.exe")
WinActivate("ahk_exe Obsidian.exe")
Else
Run "C: \Users\Daniel\AppData\Local\Obsidian\Obsidian.exe"
}
xbutton2 & w::{
If WinExist("ahk_exe chrome.exe")
WinActivate("ahk_exe chrome.exe")
Else
Run "chrome"
}
xbutton2 & e: :{
If WinExist("ahk_exe Code.exe")
WinActivate("ahk_exe Code.exe")
Else
Run "C:\Users\Daniel\AppData\Local\Programs\Microsoft VS Code\Code
xbutton2 & r::{
If WinExist("ahk_exe resolve.exe")
WinActivate("ahk_exe resolve.exe")
Else
Run "C: \Program Files\Blackmagic Design\DaVinci Resolve\Resolve.exe
}




/*
#HotIf WinActive("ahk_exe Acrobat.exe")
w:: {
MouseClick "left"
MouseClick "left"
A_Clipboard := ""
Send "^c"
ClipWait 1
WinActivate("ahk_exe EXCEL.EXE")
WinWaitActive("ahk_exe EXCEL.EXE")
Send "Av"
Sleep 100
Send "{Down}"
WinActivate("ahk_exe Acrobat.exe")
WinWaitActive("ahk_exe Acrobat.exe")
Send "AW"
}
*/



^5::{
    A_Clipboard := "restart-computer -force"
    
}


HotIfWinActive
!f::Sendtext "adminPassword#`n" 
!c::{
    A_Clipboard := "adminPassword#"
    Send  "^v"
}

!x::{
    A_Clipboard := "gitdir\adm-account"  
    Send  "^v"
}

^6::{
    A_Clipboard := "exit" 
}

!g::Sendtext "runas /user:gitdir\adm-account`n"
!d::Sendtext "userPassword`n"
!a::Sendtext "adm-account"
!s::Sendtext "username"
!h::Sendtext "HRPassword`n"
!t::Sendtext "terminalPassword`n"
!z::Sendtext "https://zurichapac.cloud.com"
!p::{
    A_Clipboard := "start-process powershell_ise -verb runas"  
    Send  "^v"
    Send "`n"
}

;example to escape double quotes. !o::Sendtext "apple `"testing`""
;!p::{
;    A_Clipboard := "`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installershell.exe`" update --passive --force --installPath `"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional`""
;    Send  "^v"
;}



!l::{
    A_Clipboard := "`"C:\temp\vs_Professional.exe`" --update --passive --force"
    Send  "^v"
}


!u::{
    A_Clipboard := "`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\InstallCleanup.exe`" -f"
    Send  "^v"
}

!w::{
    A_Clipboard := "`"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe`""
    Send  "^v"
}


^#r::{
    send "^l"
    sendtext 'a:restart`n'
}

^#m::{
    send "^l"
    sendtext 'a:remote`n'
    sleep 5000
    send "{Tab}"
    send "!t"
}


^!5::Send "{F5}"

!r::Reload
