#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2 ; title contains the string supplied
CoordMode, ToolTip, Screen ; absolute screen coordinates, top left (0,0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Global Initializations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClipboardContentsArray := []
doNotProcessAsClipboardChange := false
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
  global doNotProcessAsClipboardChange
  
  if (doNotProcessAsClipboardChange = true) {
    return
  }


  if (status = 1) { ; clipboard has contents that can be intepreted as text, and is not empty
    appendToList(clipboard)
  }
}

appendToList(contents) {
  global ClipboardContentsArray

  if (ClipboardContentsArray.Length() = 10) {
    ClipboardContentsArray.RemoveAt(1) ; remove oldest entry
    ClipboardContentsArray.Push(contents)
  }
  else {
    ClipboardContentsArray.Push(contents)
  }
}

showListContents() { 
  global ClipboardContentsArray
  list := "" 
  itemCount := 0
  
  for key, value in ClipboardContentsArray {

    if (StrLen(value) > 20) {
      preview := SubStr(value, 1, 20) . "..."
    }
    else {
      preview := value
    }

    entry := itemCount . ": " . preview . "`r`n"
    list := entry . list
    itemCount++
  }
  
  if (itemCount = 0) {
    showEmptyListMessage() 
  }
  else {
    promptListChoice(list, itemCount)  
  }
}

showEmptyListMessage() {
  Tooltip, Nothing in your Clipboard List to paste., 0, 0
  Sleep 2000
  Tooltip,
}

promptListChoice(list, itemCount) {
  global ClipboardContentsArray
  
  ToolTip, Paste Contents:`r`n(Choose from list or press Esc to cancel...)`r`n%list%, 0, 0
  
  input, selection, L1
  
  if (selection is not digit) {
    ToolTip, 
    return
  }
  
  if (selection between 1 and itemCount) { ; inclusive
    arrayPosition := selection + 1
    item := ClipboardContentsArray[arrayPosition]
    ToolTip, 
    pasteSend(item)
  } 
  else {
    ToolTip, 
  }
}

pasteSend(item) {
  global doNotProcessAsClipboardChange
  doNotProcessAsClipboardChange := true
  
  temp := clipboard
  clipboard := item
  Sleep 200
  Send ^v
  Sleep 200
  clipboard := temp
  Sleep 200
  doNotProcessAsClipboardChange := false
}
