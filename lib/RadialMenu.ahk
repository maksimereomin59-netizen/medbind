class RadialMenu {
    static Gui := false
    static Visible := false
    static Center := false
    static Buttons := []

    static Initialize() {
        if !DataModel.CurrentProfile.Has("radialMenu")
            DataModel.CurrentProfile["radialMenu"] := Map("enabled", true, "items", [])
    }

    static Create() {
        if this.Gui
            return
        this.Gui := Gui("-Caption +AlwaysOnTop +ToolWindow", Constants.AppName " Radial Menu")
        this.Gui.BackColor := Theme.Get("window")
        this.Gui.MarginX := 0
        this.Gui.MarginY := 0
        this.Center := this.Gui.Add("Text", "x145 y175 w130 h55 Center Background" Theme.Get("card") " c" Theme.Get("accent"), "ID: " IDManager.Get())
        this.Center.SetFont(Theme.Font(14, "accent", "600"), "Segoe UI")
        labels := ["ОСМОТР", "ЛЕЧЕНИЕ", "ВАКЦИНАЦИЯ", "ОПЕРАЦИЯ", "ВЫЗОВ", "RP"]
        binds := DataModel.GetBinds()
        this.Buttons := []
        positions := [[145, 25], [290, 100], [290, 250], [145, 335], [0, 250], [0, 100]]
        for index, labelText in labels {
            bindId := binds.Length >= index ? binds[index]["id"] : ""
            button := this.Gui.Add("Button", "x" positions[index][1] " y" positions[index][2] " w130 h42", labelText)
            button.OnEvent("Click", ObjBindMethod(RadialMenu, "Select", bindId))
            this.Buttons.Push(button)
        }
        this.Gui.OnEvent("Close", ObjBindMethod(RadialMenu, "Hide"))
    }

    static Show(*) {
        this.Create()
        this.Refresh()
        x := A_ScreenWidth // 2 - 210
        y := A_ScreenHeight // 2 - 210
        this.Gui.Show("x" x " y" y " w420 h420 NA")
        WinSetTransparent(245, "ahk_id " this.Gui.Hwnd)
        this.Visible := true
        State.Set("radialVisible", true)
    }

    static Hide(*) {
        if this.Gui
            this.Gui.Hide()
        this.Visible := false
        State.Set("radialVisible", false)
    }

    static Toggle(*) {
        if this.Visible
            this.Hide()
        else
            this.Show()
    }

    static Refresh() {
        if !this.Gui
            return
        this.Center.Text := "ID: " IDManager.Get()
    }

    static Select(bindId, *) {
        this.Hide()
        if bindId = "" {
            Toasts.Show("Для этого сектора пока нет бинда")
            return
        }
        bind := BindManager.Find(bindId)
        if bind
            BindSender.Start(bind)
    }

    static Stop() {
        if this.Gui
            this.Gui.Destroy()
        this.Gui := false
        this.Center := false
        this.Buttons := []
        this.Visible := false
    }
}
