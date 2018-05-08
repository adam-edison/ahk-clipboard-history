#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2 ; title contains the string supplied
DetectHiddenText, On ; to aide in ahk_class window detection
CoordMode, ToolTip, Screen ; absolute screen coordinates, top left (0,0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Global Initializations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClipboardContentsArray := []
ShortcutMap := []
loadShortcutMapping()
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

  if (listContains(contents) = true) {
    return
  }
  else if (ClipboardContentsArray.Length() = 10) {
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
  temp := clipboard
  clipboard := item
  Sleep 200
  pasteAccordingToApplicationShortcut()
  Sleep 200
  clipboard := temp
  Sleep 200
}

listContains(contents) {
  global ClipboardContentsArray

  for key, value in ClipboardContentsArray {
    if (value == contents) { ; case-sensitive
      return true
    }
  }

  return false
}

pasteAccordingToApplicationShortcut() {
  global ShortcutMap
  
  mapped := 0
  
  for key, value in ShortcutMap {
    if (WinActive(key)) {
      mapped := value
      break
    }
  }
  
  usePasteShortcut(value)
}

usePasteShortcut(value) {
  if (value == "1") {
    Send +{Ins}
  }
  else if (value == "2") {
    Click, down, right
    Sleep 100
    Click, up, right
    Sleep 100
    Send p
  }
  else {
    Send ^v
  }
}

loadShortcutMapping() {
  Loop
  {
    FileReadLine, line, paste-shortcut-map.txt, %A_Index%
    if (ErrorLevel) {
      break
    }
    else if (isSettingLine(line)) {
      addShortcutMapping(line)
    }
  }
}

isSettingLine(line) {
  if (InStr(line, ";") > 0) {
    return false
  }
  else if ((InStr(line, ",") > 0) and (InStr(line, " ") > 0)) {
    return true
  }
  else {
    return false
  }
}

addShortcutMapping(line) {
  global ShortcutMap
  setting := StrSplit(line, ",", " ") ; comma-separated, trim spaces
  first := setting[1]
  key := setting[1]
  value := setting[2]
  ShortcutMap[key] := value
}

