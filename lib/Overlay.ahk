class Overlay {
    static Gui := false
    static Visible := false
    static Labels := []
    static IdLabel := false

    static Initialize() {
        settings := DataModel.CurrentProfile["overlay"]
        this.Visible := settings.Has("visible") ? settings["visible"] : false
        if this.Visible
            this.Show()
    }

    static Create() {
        if this.Gui
            return
        this.Gui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20", Constants.AppName " Overlay")
        this.Gui.BackColor := "07101C"
        this.Gui.MarginX := 16
        this.Gui.MarginY := 14
        this.Gui.SetFont(Theme.Font(10, "text", "600"), "Segoe UI")
        this.Gui.Add("Text", "xm ym w260 h26 c" Theme.Get("accent"), "⚡ DOCTOR BINDER")
        this.IdLabel := this.Gui.Add("Text", "xm y+2 w260 h22 c" Theme.Get("muted"), "CURRENT ID: " IDManager.Get())
        this.Gui.Add("Text", "xm y+12 w260 h18 c" Theme.Get("muted"), "QUICK BINDS")
        this.Labels := []
        index := 0
        for bind in DataModel.GetBinds() {
            if index >= 4
                break
            index += 1
            label := this.Gui.Add("Text", "xm y+5 w260 h22 c" Theme.Get("text"), bind["hotkey"] "    " bind["name"])
            label.OnEvent("Click", ObjBindMethod(Overlay, "RunBind", bind["id"]))
            this.Labels.Push(label)
        }
        this.Gui.OnEvent("Close", ObjBindMethod(Overlay, "Hide"))
        this.Gui.Show("x40 y120 w300 h220 NoActivate")
        WinSetTransparent(230, "ahk_id " this.Gui.Hwnd)
        WinSetAlwaysOnTop(true, "ahk_id " this.Gui.Hwnd)
        this.Gui.Hide()
    }

    static Show(*) {
        this.Create()
        settings := DataModel.CurrentProfile["overlay"]
        x := settings.Has("x") ? settings["x"] : 40
        y := settings.Has("y") ? settings["y"] : 120
        this.Refresh()
        this.Gui.Show("x" x " y" y " w300 h220 NoActivate")
        WinSetTransparent(230, "ahk_id " this.Gui.Hwnd)
        this.Visible := true
        State.Set("overlayVisible", true)
        DataModel.CurrentProfile["overlay"]["visible"] := true
        DataModel.Save()
        Toasts.Show("Overlay включён")
    }

    static Hide(*) {
        if this.Gui
            this.Gui.Hide()
        this.Visible := false
        State.Set("overlayVisible", false)
        if DataModel.CurrentProfile.Count > 0 {
            DataModel.CurrentProfile["overlay"]["visible"] := false
            DataModel.Save()
        }
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
        if this.IdLabel
            this.IdLabel.Text := "CURRENT ID: " IDManager.Get()
    }

    static RunBind(bindId, *) {
        bind := BindManager.Find(bindId)
        if bind
            BindSender.Start(bind)
    }

    static Stop() {
        if this.Gui
            this.Gui.Destroy()
        this.Gui := false
        this.Visible := false
    }
}
