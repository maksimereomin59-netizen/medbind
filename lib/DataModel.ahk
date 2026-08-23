class DataModel {
    static Root := Map()
    static CurrentProfile := Map()

    static Initialize() {
        this.Root := Map()
        this.Root["schemaVersion"] := Constants.SchemaVersion
        this.Root["applicationVersion"] := Constants.AppVersion
        this.Root["currentProfileId"] := "profile-default"
        this.Root["profiles"] := []
        this.Root["settings"] := this.DefaultSettings()

        profile := this.LoadProfile("profile-default")
        this.CurrentProfile := profile
        this.Root["profiles"].Push(Map("id", profile["id"], "name", profile["name"]))
        this.Save()
    }

    static DefaultSettings() {
        return Map(
            "theme", "midnight",
            "autosave", true,
            "baseDelay", 250,
            "chatDelay", 100,
            "enterDelay", 80,
            "jitter", 0,
            "chatMonitorEnabled", false,
            "overlayEnabled", false
        )
    }

    static DefaultProfile(id, name := "Больница LS") {
        categories := []
        categories.Push(Map("id", "general", "name", "Общие", "color", "22D3EE", "system", true, "order", 1))
        categories.Push(Map("id", "treatment", "name", "Лечение", "color", "34D399", "system", true, "order", 2))
        categories.Push(Map("id", "rp", "name", "RP", "color", "A78BFA", "system", true, "order", 3))
        binds := []
        binds.Push(this.MakeBind("bind-001", "Приветствие", "general", "F1", "/r Здравствуйте, я ваш лечащий врач...", 0, 1))
        binds.Push(this.MakeBind("bind-002", "Лечение", "treatment", "F2", "/me передал таблетку пациенту", 500, 2))
        binds.Push(this.MakeBind("bind-003", "Вакцинация", "treatment", "F3", "/me достал шприц с вакциной", 600, 3))
        binds.Push(this.MakeBind("bind-004", "Мед. осмотр", "general", "F4", "/do Давление в норме.", 700, 4))
        binds.Push(this.MakeBind("bind-005", "Вызов коллег", "general", "F5", "/r Нужен хирург в операционную", 1000, 5))
        return Map(
            "id", id,
            "name", name,
            "nick", "",
            "hospital", "Больница LS",
            "rank", "",
            "specialty", "",
            "currentPatientId", "",
            "categories", categories,
            "binds", binds,
            "hotkeys", Map(),
            "overlay", Map("visible", false, "x", 40, "y", 120, "scale", 1.0, "opacity", 0.9),
            "radialMenu", Map("enabled", false, "items", []),
            "settings", Map()
        )
    }

    static MakeBind(id, name, categoryId, hotkey, text, delay, order) {
        line := Map("id", id "-line-001", "text", text, "delay", delay, "enabled", true, "sendEnter", true, "type", "command")
        return Map("id", id, "name", name, "categoryId", categoryId, "hotkey", hotkey, "enabled", true, "favorite", name = "Лечение", "order", order, "delay", delay, "statistics", Map("launches", 0, "lastLaunchAt", ""), "lines", [line])
    }

    static LoadProfile(id) {
        path := Core.PathJoin(Storage.ProfilesDirectory, id, "profile.json")
        if !FileExist(path) {
            profile := this.DefaultProfile(id)
            this.SaveProfile(profile)
            return profile
        }
        try {
            profile := Json.Parse(Storage.ReadText(path))
            this.ValidateProfile(profile)
            return profile
        } catch Error as err {
            Logger.Error("Profile load failed: " id " — " err.Message)
            backup := this.DefaultProfile(id)
            this.SaveProfile(backup)
            Logger.Warning("Default profile created after load failure: " id)
            return backup
        }
    }

    static ValidateProfile(profile) {
        required := ["id", "name", "categories", "binds"]
        for key in required {
            if !profile.Has(key)
                throw Error("Profile field is missing: " key)
        }
        if !(profile["binds"] is Array)
            throw Error("Profile binds must be an array")
    }

    static SaveProfile(profile) {
        profileDirectory := Core.PathJoin(Storage.ProfilesDirectory, profile["id"])
        if !DirExist(profileDirectory)
            DirCreate(profileDirectory)
        Storage.WriteText(Core.PathJoin(profileDirectory, "profile.json"), Json.Stringify(profile))
    }

    static Save() {
        if this.CurrentProfile.Count = 0
            return
        this.SaveProfile(this.CurrentProfile)
        this.Root["currentProfileId"] := this.CurrentProfile["id"]
        Storage.WriteText(Core.PathJoin(Storage.ConfigDirectory, "app.json"), Json.Stringify(this.Root))
        Logger.Info("Data model saved")
    }

    static GetBinds() {
        return this.CurrentProfile.Has("binds") ? this.CurrentProfile["binds"] : []
    }
}
