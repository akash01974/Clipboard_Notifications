; Script Configuration
#SingleInstance Force  
#NoEnv  
SetWorkingDir %A_ScriptDir%  
SetBatchLines -1  

; Hotkey Definitions
; When Ctrl+C is pressed, show a "Copied" notification
~^c::  
    SetTimer, ShowToastCopy, -1  ; Run ShowToast immediately but non-blocking
return  

; When Ctrl+X is pressed, show a "Cut" notification
~^x::  
    Clipboard := Clipboard  ; Ensures clipboard content is available immediately
    SetTimer, ShowToastCut, -1
return  

; When Ctrl+V is pressed, show a "Pasted" notification
~^v::  
    SetTimer, ShowToastPaste, -1
return  

; Helper functions for different notification types
ShowToastCopy() {
    ShowToast("Copied!")
}

ShowToastCut() {
    ShowToast("Cut!")
}

ShowToastPaste() {
    ShowToast("Pasted!")
}

; Main toast notification function
ShowToast(message) {  
    global ToastText  
    static Duration := 800  ; How long the toast stays visible (in milliseconds)
    static FadeSteps := 10  ; Number of steps in fade animation
    static FadeDelay := 20  ; Delay between fade steps (in milliseconds)

    ; GUI dimensions  
    GuiWidth := 100  
    GuiHeight := 35  
    Padding := 15    
    CornerRadius := 60  

    ; Screen boundaries  
    SysGet, Monitor, MonitorWorkArea  ; Get working area of primary monitor
    MaxX := MonitorRight - GuiWidth - Padding  
    MaxY := MonitorBottom - GuiHeight - Padding  

    ; Position toast at bottom center with 150px upward offset
    PosX := (MonitorRight - GuiWidth) // 2  
    PosY := MonitorBottom - GuiHeight - Padding - 150  

    ; Create background layer for visual effect
    Gui, ToastBg:New, -Caption +AlwaysOnTop +ToolWindow +E0x20 -SysMenu +Owner
    Gui, ToastBg:Color, 3A3A3A  ; Dark gray background
    hRegionBg := CreateRoundRectRgn(0, 0, GuiWidth, GuiHeight, CornerRadius, CornerRadius)
    WinSet, Region, % "HRGN:" hRegionBg, ahk_class AutoHotkeyGUI
    Gui, ToastBg:Show, x%PosX% y%PosY% w%GuiWidth% h%GuiHeight% NA
    WinSet, Transparent, 10, ahk_class AutoHotkeyGUI

    ; Create front GUI
    Gui, Toast:New, -Caption +AlwaysOnTop +ToolWindow +E0x20 -SysMenu +Owner  
    Gui, Toast:Color, 3A3A3A  
    Gui, Toast:Font, s12 w500, Segoe UI  
    Gui, Toast:Add, Text, vToastText cFFFFFF, %message%  
    Gui, Toast:Margin, 0, 0  

    ; Center text  
    GuiControlGet, TextSize, Toast:Pos, ToastText  
    TextX := (GuiWidth - TextSizeW) // 2  
    TextY := (GuiHeight - TextSizeH) // 2  
    GuiControl, Toast:Move, ToastText, x%TextX% y%TextY% w%TextSizeW% h%TextSizeH%  

    ; Create a rounded region for front window
    hRegion := CreateRoundRectRgn(0, 0, GuiWidth, GuiHeight, 20, 20)  
    WinSet, Region, % "HRGN:" hRegion, ahk_class AutoHotkeyGUI  

    ; Show front GUI
    Gui, Toast:Show, x%PosX% y%PosY% w%GuiWidth% h%GuiHeight% NA  
    WinSet, Transparent, 10, ahk_class AutoHotkeyGUI  

    ; Fade in both GUIs
    Loop, %FadeSteps%  
    {  
        Transparency := (A_Index * 255) // FadeSteps  
        WinSet, Transparent, %Transparency%, ahk_class AutoHotkeyGUI  
        Sleep, %FadeDelay%  
    }  

    ; Display duration  
    Sleep, %Duration%  

    ; Fade out both GUIs
    Loop, %FadeSteps%  
    {  
        Transparency := 255 - (A_Index * 255) // FadeSteps  
        WinSet, Transparent, %Transparency%, ahk_class AutoHotkeyGUI  
        Sleep, %FadeDelay%  
    }  

    ; Clean up  
    DllCall("DeleteObject", "Ptr", hRegion)
    DllCall("DeleteObject", "Ptr", hRegionBg)
    Gui, Toast:Destroy
    Gui, ToastBg:Destroy  
}  

; Utility function to create rounded corners for the toast
CreateRoundRectRgn(x1, y1, x2, y2, w, h) {  
    return DllCall("CreateRoundRectRgn"  
        , "Int", x1    ; left  
        , "Int", y1    ; top  
        , "Int", x2    ; right  
        , "Int", y2    ; bottom  
        , "Int", w     ; width of ellipse  
        , "Int", h     ; height of ellipse  
        , "Ptr")       ; returns HRGN  
}