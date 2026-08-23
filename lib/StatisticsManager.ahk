class StatisticsManager {
    static Gui := false
    static Controls := Map()

    static Summary() {
        total := 0
        active := 0
        inactive := 0
        favorites := 0
        launches := 0
        for bind in DataModel.GetBinds() {
            total += 1
            active += bind["enabled"] ? 1 : 0
            inactive += bind["enabled"] ? 0 : 1
            favorites += bind["favorite"] ? 1 : 0
            launches += bind["statistics"]["launches"]
        }
        return Map("total", total, "active", active, "inactive", inactive, "favorites", favorites, "launches", launches)
    }

    static Open(*) {
        if this.Gui {
            this.Refresh()
            this.Gui.Show()
            return
        }
        this.Gui := Gui("+Resize +MinSize520x400", "Статистика — " Constants.AppName)
        this.Gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        this.Gui.Add("Text", "x20 y18 w450 h26", "СТАТИСТИКА ИСПОЛЬЗОВАНИЯ")
        this.Controls["summary"] := this.Gui.Add("Text", "x20 y55 w450 h110 Background" Theme.Get("card"))
        this.Controls["topTitle"] := this.Gui.Add("Text", "x20 y185 w450 h22", "САМЫЕ ИСПОЛЬЗУЕМЫЕ БИНДЫ")
        this.Controls["top"] := this.Gui.Add("ListView", "x20 y215 w450 h120", ["Бинд", "Запусков"])
        this.Controls["refresh"] := this.Gui.Add("Button", "x360 y350 w110 h30", "ОБНОВИТЬ")
        this.Controls["refresh"].OnEvent("Click", ObjBindMethod(StatisticsManager, "Refresh"))
        this.Gui.OnEvent("Close", ObjBindMethod(StatisticsManager, "Close"))
        this.Refresh()
        this.Gui.Show("w490 h400")
    }

    static Refresh(*) {
        if !this.Gui
            return
        summary := this.Summary()
        text := "  Всего биндов: " summary["total"] "`n"
        text .= "  Активных: " summary["active"] "     Отключённых: " summary["inactive"] "`n"
        text .= "  Избранных: " summary["favorites"] "`n"
        text .= "  Всего запусков: " summary["launches"]
        this.Controls["summary"].Text := text
        this.Controls["top"].Delete()
        binds := DataModel.GetBinds().Clone()
        binds.Sort((a, b) => a["statistics"]["launches"] > b["statistics"]["launches"] ? -1 : 1)
        limit := Min(5, binds.Length)
        Loop limit {
            bind := binds[A_Index]
            this.Controls["top"].Add("", bind["name"], bind["statistics"]["launches"])
        }
    }

    static Close(*) {
        if this.Gui
            this.Gui.Hide()
    }
}
