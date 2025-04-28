#SingleInstance Force
ProcessSetPriority("Realtime")

A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 200

;
; キー設定
;

;; vi風カーソル移動
!h::Left
!j::Down
!k::Up
!l::Right

;; Ctrl-o で半角/全角
^o::SC029

;; Alt-o/p でIMEのON/OFF
!o::IME_SET(1)
!p::IME_SET(0)

;; ホームポジションから手を動かさない設定
;; HOME/END
!n::Home
!m::End
!,::PgDn
!.::PgUp

;
; Outlook, Powerpoint, Teams でEmacs風キーバインドを設定。
;
#HotIf WinActive("ahk_exe outlook.exe", ) or WinActive("ahk_exe powerpnt.exe", ) or WinActive("ahk_exe ms-teams.exe", ) or WinActive("ahk_exe notepad.exe", )
^b::Send "{Left}"
^f::Send "{Right}"
^p::Send "{Up}"
^n::Send "{Down}"
^a::Send "{Home}"
^e::Send "{End}"
^d::Send "{Del}"
^h::Send "{BS}"
^m::Send "{Enter}"
^i::Send "{Tab}"
^o::Send "{vkF3sc029}" ; 半角/全角

^k::
{
    Send "{ShiftDown}{End}{ShiftUp}"
    Sleep 50 ; 遅延
    Send "{Del}"
    Return
}

^s::Send "^f"

#HotIf

;
; 閉じカッコの自動入力
;
$(::SendInput "({}){Left}"
$[::SendInput "[{}]{Left}"
${::SendInput "{{}{}}{Left}"

;
; アプリ起動 (Ctrl + Shift + アプリの頭文字)
;
^+e::Run "excel.exe"
^+p::Run "powerpnt.exe"
^+w::Run "winword.exe"
^+x::Run "explorer.exe"

;
; 日付を入力("yymmdd"形式)
;
^1::
{
    TimeString := FormatTime(,"yyMMdd")
    A_Clipboard := TimeString
    Send "+{INSERT}"
}

;
; 日付を入力("月/日(曜日)"形式)
;
^2::
{
    TimeString1 := FormatTime(,"M/d")
    TimeString2 := FormatTime(," HH:mm")
    downum := FormatTime(,"WDay")
    dowstr := get_dowstr(downum)
    A_Clipboard := TimeString1 . dowstr . TimeString2
    Send "+{INSERT}"
}

get_dowstr(theNum)
{
    dowtable := "日月火水木金土"
    ; Wday は日曜日が 1、
    dowstr := SubStr(dowtable, theNum, 1)
    return "(" . dowstr . ")"
}

;
; メモ帳を開く
;
^3::
{
    Run "notepad.exe",,, &notepad_pid
    WinWait "ahk_pid " notepad_pid
    WinActivate
    WinMove 0, 0, A_ScreenWidth/4, A_ScreenHeight/2
}

;
; アクティブウィンドウを閉じる
;
^4::
{
    If WinActive("ahk_exe chrome.exe")|| WinActive("ahk_exe msedge.exe")|| WinActive("ahk_exe firefox.exe")|| WinActive("ahk_exe Code.exe") {
        Send "^{w}"
    } Else {
        Send "!{F4}"
    }
}

;
; 任意の名前で空ファイルを作る(エクスプローラ上のみで動作)
;
^5::
{
global
    If (!WinActive("ahk_class CabinetWClass")) {
      MsgBox("explore is not active")
      Return
    }
    current_dir := get_current_dir()
    myGui := Gui()
    ogcEdit_str_filename := myGui.Add("Edit", "v_str_filename w380")
    ogcButtonAppend := myGui.Add("Button", "Default", "Append")
    ogcButtonAppend.OnEvent("Click", ButtonAppend.Bind("Normal"))
    myGui.Title := "ファイル名"
    myGui.Show("Center w400")
    Send("{vkF2}{vkF3}")
    Return
}
    ButtonAppend(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{
global
    oSaved := myGui.Submit()
    _str_filename := oSaved._str_filename
    FileAppend("", current_dir "\" _str_filename)
    _3GuiEscape:
    _3GuiClose:
        myGui.Destroy()
    Return
}

get_current_dir() {
  explorerHwnd := WinActive("ahk_class CabinetWClass")
  If (explorerHwnd) {
    for window in ComObject("Shell.Application").Windows {
      If (window.hwnd==explorerHwnd)
        Return window.Document.Folder.Self.Path
    }
  }
}

;
; 引用記号を追加してペースト
;
^6::
{
global
    StrRefMsg := "> " . RegExReplace(A_Clipboard, "\n", "`n> ")
    A_Clipboard := StrRefMsg
    Send("^v")
    return
}

;
; ダイアログで日付を入力し、"M/d(Wday)"形式で入力
;
::]d::
{
    {
        Sleep 150
        dateGui := Gui(,"今年日付入力")
        dateGui.Add("Text",, "指定日[4ケタ]")
        dateGui.Add("Edit", "vTargetDay Limit4 Number")
        dateGui.Add("Button", "default", "OK").OnEvent("Click", InsertDate)
        dateGui.Add("Button", " x+20" , "Cancel").OnEvent("Click", CloseWindow)
        dateGui.OnEvent("Escape", CloseWindow)
        dateGui.show()
    }

    CloseWindow(*)
    {
        dateGui.Destroy()
    }

    InsertDate(*)
    {
        Saved := dateGui.Submit()
        TargetDay := Saved.TargetDay

        datestr := FormatTime(,"yyyy") . TargetDay
        TimeString := FormatTime(datestr, "M/d")
        dowstr := get_dowstr(FormatTime(datestr, "WDay"))
        
        A_Clipboard := TimeString . dowstr
        Sleep 150
        Send "+{INSERT}"
    }
}

;
; 生成AIのプロンプトの入力支援。クリップボードの内容に、プロンプトを付加してペーストする
;
::]p::
{
    prompts := ["以下の文を日本語に翻訳してください。`n",
                "I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more scientific and academic. I want you to only reply the correction, the improvements and nothing else, do not write explanations. My sentences are as follows: `n",
                "以下の文をビジネスライクな英語に翻訳してください。`n"]
    
    {
        Sleep 150
        promptGui := Gui(,"Select Prompt for GAI")
        promptGui.Add("Text",, "プロンプト")
        promptGUI.Add("Radio", "vPromptRadioGroup", "英文和訳")
        promptGUI.Add("Radio", , "英文校正")
        promptGUI.Add("Radio", , "和文英訳")
        promptGUI.Add("Button", "default", "OK").OnEvent("Click", InsertPrompt)
        promptGUI.Add("Button", " x+20" , "Cancel").OnEvent("Click", CloseWindow)
        promptGUI.OnEvent("Escape", CloseWindow)
        promptGUI.show()
    }
    
    CloseWindow(*)
    {
        promptGUI.Destroy()
    }

    InsertPrompt(*)
    {
        Saved := promptGUI.Submit()
        Selection := Saved.PromptRadioGroup
        
        text_cb := A_Clipboard
    
        Sleep 150
        A_Clipboard := prompts[Selection]
        Send "+{INSERT}"
        Sleep 150
        A_Clipboard := text_cb
        Send "+{INSERT}"
    }
}

;
; クリップボードの文字列をGoogle検索(Edge前提)
;
!g::{
    copied := String(A_Clipboard)
    if (copied != "") {
        if WinExist("ahk_exe msedge.exe") {
            WinActivate
            Send "^t"
            Send copied
            Send "{Enter}"
        } else {
            MsgBox "Edge が起動していません"
        }
    }
}

;
; IME ON/OFF
;
IME_SET(SetSts, WinTitle:="A")    {
    hwnd := WinExist(WinTitle)
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4+4+(PtrSize*6)+16
        stGTI := Buffer(cbSize,0)
        NumPut("Uint", cbSize, stGTI.Ptr,0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint",0, "Uint",stGTI.Ptr)
                 ? NumGet(stGTI.Ptr,8+PtrSize,"Uint") : hwnd
    }
    return DllCall("SendMessage"
          , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd)
          , "UInt", 0x0283  ;Message : WM_IME_CONTROL
          ,  "Int", 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  "Int", SetSts) ;lParam  : 0 or 1
}
