class Backup {
    static CreateCurrent(reason := "manual") {
        profile := DataModel.CurrentProfile
        if profile.Count = 0
            return ""
        name := Format("{1}-{2}-{3}.json", profile["id"], Core.TimestampForFile(), reason)
        path := Core.PathJoin(Storage.BackupsDirectory, name)
        Storage.WriteText(path, Json.Stringify(profile))
        this.Trim(profile["id"], 10)
        Logger.Info("Backup created: " path)
        return path
    }

    static Trim(profileId, limit := 10) {
        files := []
        Loop Files, Core.PathJoin(Storage.BackupsDirectory, profileId "-*.json"), "F"
            files.Push({path: A_LoopFileFullPath, time: FileGetTime(A_LoopFileFullPath, "M")})
        files.Sort((a, b) => a.time < b.time ? -1 : a.time > b.time ? 1 : 0)
        while files.Length > limit {
            FileDelete(files[1].path)
            files.RemoveAt(1)
        }
    }

    static Restore(path) {
        profile := Json.Parse(Storage.ReadText(path))
        DataModel.ValidateProfile(profile)
        this.CreateCurrent("before-restore")
        DataModel.SaveProfile(profile)
        DataModel.CurrentProfile := profile
        DataModel.Save()
        IDManager.Initialize()
        HotkeyManager.Refresh()
        Overlay.Stop()
        Overlay.Initialize()
        RadialMenu.Stop()
        RadialMenu.Initialize()
        if MainWindow.Gui
            MainWindow.Refresh()
        History.Add("Backup restored", profile["id"])
    }
}
