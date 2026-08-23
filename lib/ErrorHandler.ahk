class ErrorHandler {
    static Handle(err, context := "application", showMessage := true) {
        message := "Context: " context "`nMessage: " err.Message
        if err.HasProp("What") && err.What != ""
            message .= "`nFunction: " err.What
        if err.HasProp("File") && err.File != ""
            message .= "`nFile: " err.File "`nLine: " err.Line

        if Logger.initialized
            Logger.Critical(StrReplace(message, "`n", " | "))

        if showMessage
            MsgBox(message, Constants.AppName " — ошибка", "Iconx OK")
    }
}
