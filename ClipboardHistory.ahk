#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Global Initializations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClipboardContentsArray := []
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
  OnClipboardChange("clipboardContentChanged")
return

^Ins::
  showListContents()
return

^!r::
  Reload
return

clipboardContentChanged(status) {
  if (status = 1) { ; clipboard has contents that can be intepreted as text, and is not empty
    appendToList(clipboard)
  }
}

appendToList(contents) {
  global ClipboardContentsArray
  ClipboardContentsArray.Push(contents)
}

showListContents() { 
  global ClipboardContentsArray
  list := "" 
  index := 0
  
  for key, value in ClipboardContentsArray {
    list .= index . ": " . value . "`r`n"
    index++
  }
  
  ToolTip, Clipboard Contents:`r`n%list%
  Sleep 3000
  ToolTip, 
}
