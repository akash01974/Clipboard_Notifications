#SingleInstance Force  
#NoEnv  
SetWorkingDir %A_ScriptDir%  
SetBatchLines -1  

; Detect Ctrl+V  
~^v::  
    SetTimer, ShowToast, -1  ; Run ShowToast immediately but non-blocking
return  

ShowToast() {  
    global ToastText  
    static Duration := 800  
    static FadeSteps := 10  
    static FadeDelay := 20  

    ; GUI dimensions  
    GuiWidth := 100  ; Back to original width
    GuiHeight := 35  
    Padding := 15    
    CornerRadius := 60  
    IconSize := 16   ; Size of the icon

    ; Screen boundaries  
    SysGet, Monitor, MonitorWorkArea  
    MaxX := MonitorRight - GuiWidth - Padding  
    MaxY := MonitorBottom - GuiHeight - Padding  

    ; Bottom center + slight upward offset (150px)  
    PosX := (MonitorRight - GuiWidth) // 2  
    PosY := MonitorBottom - GuiHeight - Padding - 150  

    ; Create background GUI
    Gui, ToastBg:New, -Caption +AlwaysOnTop +ToolWindow +E0x20 -SysMenu +Owner
    Gui, ToastBg:Color, 3A3A3A
    hRegionBg := CreateRoundRectRgn(0, 0, GuiWidth, GuiHeight, CornerRadius, CornerRadius)
    WinSet, Region, % "HRGN:" hRegionBg, ahk_class AutoHotkeyGUI
    Gui, ToastBg:Show, x%PosX% y%PosY% w%GuiWidth% h%GuiHeight% NA
    WinSet, Transparent, 10, ahk_class AutoHotkeyGUI

    ; Create front GUI
    Gui, Toast:New, -Caption +AlwaysOnTop +ToolWindow +E0x20 -SysMenu +Owner  
    Gui, Toast:Color, 3A3A3A  
    Gui, Toast:Font, s12 w500, Segoe UI  
    Gui, Toast:Add, Text, vToastText cFFFFFF, Pasted!  
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

; Function to create rounded rectangle region  
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