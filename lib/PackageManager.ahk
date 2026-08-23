class PackageManager {
    static FormatVersion := 1

    static ExportCurrent(*) {
        profile := DataModel.CurrentProfile
        defaultPath := Core.PathJoin(Storage.PackagesDirectory, profile["id"] ".doctorprofile")
        path := FileSelect("S", defaultPath, "Экспорт профиля", "Doctor Binder Profile (*.doctorprofile)")
        if path = ""
            return false
        if !RegExMatch(path, "i)\\.doctorprofile$")
            path .= ".doctorprofile"
        package := Map(
            "formatVersion", this.FormatVersion,
            "applicationVersion", Constants.AppVersion,
            "createdAt", Core.Now(),
            "type", "profile",
            "profile", profile
        )
        try {
            Storage.WriteText(path, Json.Stringify(package))
            Logger.Activity("Profile exported: " path)
            Toasts.Show("Профиль экспортирован")
            return true
        } catch Error as err {
            ErrorHandler.Handle(err, "export profile")
            return false
        }
    }

    static ImportProfile(*) {
        path := FileSelect("O", Storage.PackagesDirectory, "Импорт профиля", "Doctor Binder Profile (*.doctorprofile)")
        if path = ""
            return false
        try {
            package := Json.Parse(Storage.ReadText(path))
            this.Validate(package)
            profile := package["profile"]
            bindCount := profile["binds"].Length
            categoryCount := profile["categories"].Length
            prompt := "Будет импортировано:`n`n"
            prompt .= "Профиль: " profile["name"] "`n"
            prompt .= bindCount " биндов`n"
            prompt .= categoryCount " категорий`n`n"
            prompt .= "Продолжить импорт?"
            answer := MsgBox(prompt, Constants.AppName " — импорт", "Iconi YesNo")
            if answer != "Yes"
                return false
            DataModel.SaveProfile(profile)
            if profile["id"] = DataModel.CurrentProfile["id"] {
                DataModel.CurrentProfile := DataModel.LoadProfile(profile["id"])
                IDManager.Initialize()
                HotkeyManager.Refresh()
                Overlay.Stop()
                Overlay.Initialize()
                RadialMenu.Stop()
                RadialMenu.Initialize()
                if MainWindow.Gui
                    MainWindow.Refresh()
            }
            Logger.Activity("Profile imported: " profile["id"])
            Toasts.Show("Импорт завершён")
            return true
        } catch Error as err {
            ErrorHandler.Handle(err, "import profile")
            return false
        }
    }

    static Validate(package) {
        if !(package is Map)
            throw Error("Package root must be an object")
        if !package.Has("formatVersion") || !package.Has("profile")
            throw Error("Invalid Doctor Binder package")
        if package["formatVersion"] > this.FormatVersion
            throw Error("Package requires a newer Binder version")
        DataModel.ValidateProfile(package["profile"])
    }
}
