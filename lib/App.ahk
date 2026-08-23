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

        OnExit(App.HandleExit)
        this.ConfigureTray()

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
        A_TrayMenu.Add(Constants.AppName " " Constants.AppVersion, App.TrayAbout)
        A_TrayMenu.Disable(Constants.AppName " " Constants.AppVersion)
        A_TrayMenu.Add()
        A_TrayMenu.Add("Открыть Binder", App.TrayNotReady)
        A_TrayMenu.Add("Включить / выключить", App.TrayToggle)
        A_TrayMenu.Add()
        A_TrayMenu.Add("Выход", App.TrayExit)
        A_TrayMenu.Default := "Открыть Binder"
        A_TrayMenu.ClickCount := 1
    }

    static TrayAbout(*) {
        MsgBox(Constants.AppName "`nВерсия: " Constants.AppVersion "`n`nФундамент приложения инициализирован.", Constants.AppName, "Iconi")
    }

    static TrayNotReady(*) {
        MsgBox("Главное окно будет добавлено на этапе 2.", Constants.AppName, "Iconi")
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
            State.Set("isRunning", false)
            Logger.Info("Binder stopped. Reason: " exitReason "; code: " exitCode)
        }
    }
}
