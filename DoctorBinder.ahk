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
#Include lib\Json.ahk
#Include lib\DataValidation.ahk
#Include lib\DataModel.ahk
#Include lib\History.ahk
#Include lib\Backup.ahk
#Include lib\UndoRedo.ahk
#Include lib\BindManager.ahk
#Include lib\BindEditor.ahk
#Include lib\ConflictResolver.ahk
#Include lib\HotkeyManager.ahk
#Include lib\BindSender.ahk
#Include lib\IDManager.ahk
#Include lib\Variables.ahk
#Include lib\EventBus.ahk
#Include lib\ChatParser.ahk
#Include lib\ChatMonitor.ahk
#Include lib\Overlay.ahk
#Include lib\RadialMenu.ahk
#Include lib\ProfileManager.ahk
#Include lib\PackageManager.ahk
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
