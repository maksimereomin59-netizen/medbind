#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, StdOut
Persistent

; Doctor Binder V3 - application entry point.
; Stage 1 contains only the executable foundation. UI modules are added later.

#Include lib\Constants.ahk
#Include lib\State.ahk
#Include lib\Core.ahk
#Include lib\Logger.ahk
#Include lib\ErrorHandler.ahk
#Include lib\Storage.ahk
#Include lib\Theme.ahk
#Include lib\Controls.ahk
#Include lib\Navigation.ahk
#Include lib\Toasts.ahk
#Include lib\MainWindow.ahk
#Include lib\App.ahk

try {
    App.Start()
} catch Error as err {
    ErrorHandler.Handle(err, "startup")
    ExitApp(1)
}
