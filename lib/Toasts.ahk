class Toasts {
    static Show(message, title := Constants.AppName) {
        TrayTip(title, message, "Iconi")
    }
}
