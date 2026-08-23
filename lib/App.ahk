class App {
    static started := false

    static Start() {
        if this.started
            return

        Core.EnsureAutoHotkeyVersion()
        State.Initialize()
        Storage.Initialize(A_ScriptDir)
        Logger.Initialize(Storage.LogsDirectory)
        Logger.Info(Constants.AppName " " Constants.AppVersion " starting")
        DataModel.Initialize()
        Logger.Info("Data model initialized")
        IDManager.Initialize()
        ChatMonitor.Initialize()
        HotkeyManager.Initialize()

        ; Class methods must be explicitly bound when used as callbacks in AHK v2.
        OnExit(ObjBindMethod(App, "HandleExit"))
        this.ConfigureTray()
        MainWindow.Show()

        State.Set("initialized", true)
        State.Set("isRunning", true)
        State.Set("startedAt", Core.Now())
        this.started := true
        Logger.Info("Binder started successfully")

        A_IconTip := Constants.AppName
        Persistent(true)
    }

    static ConfigureTray() {
        A_TrayMenu.Delete()
        A_TrayMenu.Add(Constants.AppName " " Constants.AppVersion, ObjBindMethod(App, "TrayAbout"))
        A_TrayMenu.Disable(Constants.AppName " " Constants.AppVersion)
        A_TrayMenu.Add()
        A_TrayMenu.Add("Открыть Binder", ObjBindMethod(App, "TrayNotReady"))
        A_TrayMenu.Add("Включить / выключить", ObjBindMethod(App, "TrayToggle"))
        A_TrayMenu.Add()
        A_TrayMenu.Add("Выход", ObjBindMethod(App, "TrayExit"))
        A_TrayMenu.Default := "Открыть Binder"
        A_TrayMenu.ClickCount := 1
    }

    static TrayAbout(*) {
        MsgBox(Constants.AppName "`nВерсия: " Constants.AppVersion "`n`nФундамент приложения инициализирован.", Constants.AppName, "Iconi")
    }

    static TrayNotReady(*) {
        MainWindow.Show()
    }

    static TrayToggle(*) {
        enabled := State.Get("binderEnabled")
        State.Set("binderEnabled", !enabled)
        status := !enabled ? "включён" : "выключен"
        Logger.Activity("Binder " status)
        TrayTip(Constants.AppName, "Binder " status, "Iconi")
    }

    static TrayExit(*) {
        ExitApp(Constants.ExitCodeSuccess)
    }

    static HandleExit(exitReason, exitCode) {
        if !this.started
            return
        try {
            ChatMonitor.Stop()
            BindSender.Stop(false)
            HotkeyManager.UnregisterAll()
            State.Set("isRunning", false)
            Logger.Info("Binder stopped. Reason: " exitReason "; code: " exitCode)
        }
    }
}
