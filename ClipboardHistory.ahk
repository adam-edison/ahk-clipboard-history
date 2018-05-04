#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Global Initializations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClipboardContentsArray := []
LastCopied := ""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

~^c::
  copyTextToClipboard()
  appendClipboardContentsToList()
return

^F1::
  alertClipboardContents()
return

^F2::
  Reload
return

copyTextToClipboard() {
  global LastCopied
  copyFromClipboardReliably()
  LastCopied := clipboard
}

copyFromClipboardReliably() {
  clipboard :=  ; Start off empty to allow ClipWait to detect when the text has arrived.
  Send ^c
  ClipWait  ; Wait for the clipboard to contain text.
}

appendClipboardContentsToList() {
  global ClipboardContentsArray, LastCopied
  ClipboardContentsArray.Push(LastCopied)
}

alertClipboardContents() { 
  global ClipboardContentsArray
  list := "" 
  
  for key, value in ClipboardContentsArray {
    list .= value . "`r`n"
  }
  
  MsgBox, Clipboard Contents: `r`n %list%
}
