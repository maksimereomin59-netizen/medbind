class ProfileManager {
    static Gui := false
    static ProfileIds := []
    static List := false

    static ListProfiles() {
        result := []
        if DirExist(Storage.ProfilesDirectory) {
            Loop Files, Core.PathJoin(Storage.ProfilesDirectory, "*"), "D"
                result.Push(A_LoopFileName)
        }
        if result.Length = 0
            result.Push("profile-default")
        return result
    }

    static Create(name := "Новый профиль") {
        name := Trim(name)
        if name = ""
            throw Error("Profile name cannot be empty")
        id := "profile-" RegExReplace(StrLower(name), "[^a-z0-9а-яё]+", "-")
        id := RegExReplace(id, "-+$", "")
        if id = "profile-"
            id := "profile-" FormatTime(, "HHmmss")
        if this.Exists(id)
            id .= "-" FormatTime(, "HHmmss")
        profile := DataModel.DefaultProfile(id, name)
        DataModel.SaveProfile(profile)
        Logger.Activity("Created profile: " id)
        return profile
    }

    static Exists(id) {
        return DirExist(Core.PathJoin(Storage.ProfilesDirectory, id))
    }

    static Switch(id) {
        if id = DataModel.CurrentProfile["id"]
            return true
        if !this.Exists(id)
            throw Error("Profile not found: " id)
        BindSender.Stop(false)
        Overlay.Stop()
        RadialMenu.Stop()
        DataModel.SaveProfile(DataModel.CurrentProfile)
        profile := DataModel.LoadProfile(id)
        DataModel.CurrentProfile := profile
        DataModel.Root["currentProfileId"] := id
        IDManager.Initialize()
        Overlay.Initialize()
        RadialMenu.Initialize()
        HotkeyManager.Refresh()
        DataModel.Save()
        if MainWindow.Gui
            MainWindow.Refresh()
        Logger.Activity("Switched profile: " id)
        Toasts.Show("Профиль переключён: " profile["name"])
        return true
    }

    static Delete(id) {
        if id = "profile-default" || id = DataModel.CurrentProfile["id"]
            throw Error("Нельзя удалить текущий профиль или профиль по умолчанию")
        path := Core.PathJoin(Storage.ProfilesDirectory, id)
        if DirExist(path)
            DirDelete(path, true)
        Logger.Activity("Deleted profile: " id)
    }

    static Show(*) {
        if this.Gui {
            this.Gui.Show()
            return
        }
        this.Gui := Gui("+AlwaysOnTop +Resize", "Профили — " Constants.AppName)
        this.Gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        this.Gui.Add("Text", "x20 y18 w330 h26", "УПРАВЛЕНИЕ ПРОФИЛЯМИ")
        this.List := this.Gui.Add("ListBox", "x20 y55 w330 h180")
        this.Gui.Add("Button", "x20 y250 w100 h30", "+ Создать").OnEvent("Click", ObjBindMethod(ProfileManager, "CreateAction"))
        this.Gui.Add("Button", "x130 y250 w100 h30", "Выбрать").OnEvent("Click", ObjBindMethod(ProfileManager, "SwitchAction"))
        this.Gui.Add("Button", "x240 y250 w110 h30", "Удалить").OnEvent("Click", ObjBindMethod(ProfileManager, "DeleteAction"))
        this.Gui.OnEvent("Close", ObjBindMethod(ProfileManager, "Close"))
        this.RefreshList()
        this.Gui.Show("w370 h300")
    }

    static RefreshList() {
        this.ProfileIds := this.ListProfiles()
        names := []
        selected := 1
        for index, id in this.ProfileIds {
            profile := DataModel.LoadProfile(id)
            names.Push(profile["name"] "  [" id "]")
            if id = DataModel.CurrentProfile["id"]
                selected := index
        }
        this.List.Delete()
        this.List.Add(names)
        this.List.Value := selected
    }

    static SelectedId() {
        index := this.List.Value
        return index >= 1 && index <= this.ProfileIds.Length ? this.ProfileIds[index] : ""
    }

    static CreateAction(*) {
        result := InputBox("Введите название нового профиля:", Constants.AppName, "w360 h140", "Новый профиль")
        if result.Result = "Cancel"
            return
        try {
            this.Create(result.Value)
            this.RefreshList()
            Toasts.Show("Профиль создан")
        } catch Error as err {
            ErrorHandler.Handle(err, "create profile")
        }
    }

    static SwitchAction(*) {
        try this.Switch(this.SelectedId())
        catch Error as err
            ErrorHandler.Handle(err, "switch profile")
        this.RefreshList()
    }

    static DeleteAction(*) {
        try {
            this.Delete(this.SelectedId())
            this.RefreshList()
            Toasts.Show("Профиль удалён")
        } catch Error as err {
            ErrorHandler.Handle(err, "delete profile")
        }
    }

    static Close(gui, *) {
        gui.Hide()
    }
}
