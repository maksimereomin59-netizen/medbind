class HotkeyManager {
    static Registered := Map()
    static Initialized := false

    static Initialize() {
        this.UnregisterAll()
        this.RegisterSystemHotkeys()
        for bind in DataModel.GetBinds() {
            if bind["enabled"] && bind["hotkey"] != ""
                this.RegisterBind(bind)
        }
        this.Initialized := true
        Logger.Info("Hotkey manager initialized: " this.Registered.Count " hotkeys")
    }

    static RegisterSystemHotkeys() {
        this.Register("F12", ObjBindMethod(HotkeyManager, "ToggleBinder"), "system:F12")
    }

    static RegisterBind(bind) {
        conflictId := ConflictResolver.Find(bind["hotkey"], bind["id"])
        if conflictId != "" {
            Logger.Warning("Hotkey conflict: " bind["hotkey"] " for " bind["id"] " and " conflictId)
            return false
        }
        return this.Register(bind["hotkey"], ObjBindMethod(HotkeyManager, "RunBind", bind["id"]), bind["id"])
    }

    static Register(hotkey, callback, ownerId) {
        key := StrLower(hotkey)
        if key = ""
            return false
        if this.Registered.Has(key)
            return false
        try {
            Hotkey(hotkey, callback, "On")
            this.Registered[key] := {hotkey: hotkey, ownerId: ownerId}
            return true
        } catch Error as err {
            Logger.Warning("Hotkey registration failed: " hotkey " — " err.Message)
            return false
        }
    }

    static UnregisterAll() {
        for key, item in this.Registered {
            try Hotkey(item.hotkey, "Off")
        }
        this.Registered := Map()
        this.Initialized := false
    }

    static Refresh() {
        this.Initialize()
    }

    static RunBind(bindId, *) {
        if !State.Get("binderEnabled", true) {
            Toasts.Show("Binder выключен")
            return
        }
        bind := BindManager.Find(bindId)
        if !bind {
            Logger.Warning("Hotkey target not found: " bindId)
            return
        }
        State.Set("selectedBindId", bindId)
        Logger.Activity("Hotkey pressed: " bind["hotkey"] " → " bind["name"])
        Toasts.Show("Запуск: " bind["name"])
    }

    static ToggleBinder(*) {
        enabled := !State.Get("binderEnabled", true)
        State.Set("binderEnabled", enabled)
        Logger.Activity("Binder " (enabled ? "enabled" : "disabled") " by F12")
        Toasts.Show(enabled ? "Binder включён" : "Binder выключен")
    }
}
