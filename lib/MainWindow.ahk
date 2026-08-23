class MainWindow {
    static Gui := unset
    static Controls := Map()
    static NavControls := Map()
    static CurrentPage := "binds"
    static IsMaximized := false

    static Create() {
        if IsSet(this.Gui)
            return this.Gui

        this.Gui := Gui("-Caption +Resize +MinSize1000x620", Constants.AppName)
        this.Gui.BackColor := Theme.Get("window")
        this.Gui.MarginX := 0
        this.Gui.MarginY := 0
        this.Gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        this.Gui.OnEvent("Close", MainWindow.HandleClose)
        this.Gui.OnEvent("Size", MainWindow.HandleResize)

        this.BuildTitleBar()
        this.BuildSidebar()
        this.BuildContent()
        this.BuildStatusBar()
        this.Layout(1400, 850)
        return this.Gui
    }

    static BuildTitleBar() {
        this.Controls["titleBar"] := this.Gui.Add("Text", "x0 y0 w1400 h48 Background" Theme.Get("sidebar"))
        this.Controls["titleBar"].OnEvent("Click", MainWindow.BeginDrag)
        this.Controls["brand"] := Controls.AddLabel(this.Gui, "x24 y10 w300 h28", "⚡  DOCTOR BINDER V3", "accent", 14, "600")
        this.Controls["brand"].OnEvent("Click", MainWindow.BeginDrag)

        this.Controls["search"] := this.Gui.Add("Edit", "x390 y10 w290 h28 Background" Theme.Get("card") " c" Theme.Get("muted"), "Поиск биндов  •  Ctrl+K")
        this.Controls["search"].SetFont(Theme.Font(9, "muted"), "Segoe UI")

        this.Controls["profile"] := Controls.AddLabel(this.Gui, "x720 y12 w240 h24", "ПРОФИЛЬ  ·  Больница LS", "muted", 9)
        this.Controls["profile"].OnEvent("Click", MainWindow.ProfileInfo)

        this.Controls["minimize"] := Controls.AddButton(this.Gui, "x1300 y8 w30 h30", "—", MainWindow.Minimize)
        this.Controls["maximize"] := Controls.AddButton(this.Gui, "x1334 y8 w30 h30", "□", MainWindow.ToggleMaximize)
        this.Controls["close"] := Controls.AddButton(this.Gui, "x1368 y8 w30 h30", "×", MainWindow.HandleClose)
    }

    static BuildSidebar() {
        this.Controls["sidebar"] := this.Gui.Add("Text", "x0 y48 w230 h760 Background" Theme.Get("sidebar"))
        Controls.AddLabel(this.Gui, "x24 y72 w170 h20", "РАЗДЕЛЫ", "muted", 9, "600")

        y := 106
        for item in Navigation.Items {
            page := item[1]
            label := item[2]
            control := Controls.AddLabel(this.Gui, "x12 y" y " w206 h34", label, page = "binds" ? "accent" : "muted", 10, "600")
            control.OnEvent("Click", (ctrl, *) => this.SwitchPage(page))
            this.NavControls[page] := control
            y += 40
        }

        this.Controls["sidebarHint"] := Controls.AddLabel(this.Gui, "x24 y700 w180 h55", "V3 FOUNDATION`nСистема готова к работе", "muted", 9)
    }

    static BuildContent() {
        this.Controls["content"] := this.Gui.Add("Text", "x230 y48 w920 h760 Background" Theme.Get("panel"))
        this.Controls["pageTitle"] := Controls.AddLabel(this.Gui, "x264 y78 w500 h32", "СПИСОК БИНДОВ", "text", 18, "600")
        this.Controls["pageSubtitle"] := Controls.AddLabel(this.Gui, "x264 y112 w650 h24", "Управление сценариями и быстрыми действиями", "muted", 9)

        this.Controls["newBind"] := Controls.AddButton(this.Gui, "x940 y78 w170 h34", "+  НОВЫЙ БИНД", MainWindow.NewBind)

        this.Controls["filterBar"] := this.Gui.Add("Text", "x264 y152 w846 h44 Background" Theme.Get("card"))
        this.Controls["filterAll"] := Controls.AddLabel(this.Gui, "x282 y166 w70 h20", "Все  0 / 100", "accent", 9, "600")
        this.Controls["filterFav"] := Controls.AddLabel(this.Gui, "x370 y166 w120 h20", "★ Избранное", "muted", 9)
        this.Controls["filterCategory"] := Controls.AddLabel(this.Gui, "x520 y166 w180 h20", "Категория: Все ▾", "muted", 9)

        this.Controls["listCard"] := this.Gui.Add("GroupBox", "x264 y216 w846 h400 c" Theme.Get("border"), "")
        this.Controls["listHeader"] := Controls.AddLabel(this.Gui, "x286 y238 w800 h22", "#       НАЗВАНИЕ                         КАТЕГОРИЯ        HOTKEY        СТАТУС", "muted", 9, "600")
        this.Controls["emptyState"] := Controls.AddLabel(this.Gui, "x450 y360 w470 h90 Center", "БИНДЫ ЕЩЁ НЕ СОЗДАНЫ`n`nДобавьте первый сценарий кнопкой «Новый бинд»", "muted", 11)

        this.Controls["quickTitle"] := Controls.AddLabel(this.Gui, "x264 y650 w300 h24", "БЫСТРЫЕ ДЕЙСТВИЯ", "muted", 9, "600")
        this.Controls["quickTest"] := Controls.AddButton(this.Gui, "x264 y682 w150 h34", "▶  ТЕСТ", MainWindow.TestAction)
        this.Controls["quickImport"] := Controls.AddButton(this.Gui, "x424 y682 w150 h34", "↓  ИМПОРТ", MainWindow.ImportAction)
        this.Controls["quickExport"] := Controls.AddButton(this.Gui, "x584 y682 w150 h34", "↑  ЭКСПОРТ", MainWindow.ExportAction)
        this.Controls["quickOverlay"] := Controls.AddButton(this.Gui, "x744 y682 w150 h34", "◈  OVERLAY", MainWindow.OverlayAction)
    }

    static BuildStatusBar() {
        this.Controls["statusBar"] := this.Gui.Add("Text", "x0 y808 w1400 h42 Background" Theme.Get("sidebar"))
        this.Controls["status"] := Controls.AddLabel(this.Gui, "x24 y820 w500 h22", "●  Binder Active     Autosave: ON", "green", 9, "600")
        this.Controls["statusProfile"] := Controls.AddLabel(this.Gui, "x1080 y820 w300 h22", "Profile: Hospital LS", "muted", 9)
        this.Controls["version"] := Controls.AddLabel(this.Gui, "x1290 y820 w100 h22", "V3.0", "muted", 9)
    }

    static Show() {
        this.Create()
        this.Gui.Show("w1400 h850")
        this.Gui.Focus()
    }

    static Layout(width, height) {
        if !IsSet(this.Gui)
            return
        width := Max(width, 1000)
        height := Max(height, 620)
        sidebarWidth := 230
        rightWidth := 250
        contentWidth := width - sidebarWidth - rightWidth

        this.Controls["titleBar"].Move(0, 0, width, 48)
        this.Controls["brand"].Move(24, 10)
        this.Controls["search"].Move(Max(350, contentWidth // 2), 10, 290, 28)
        this.Controls["profile"].Move(width - 670, 12, 240, 24)
        this.Controls["minimize"].Move(width - 100, 8, 30, 30)
        this.Controls["maximize"].Move(width - 66, 8, 30, 30)
        this.Controls["close"].Move(width - 32, 8, 30, 30)

        this.Controls["sidebar"].Move(0, 48, sidebarWidth, height - 90)
        this.Controls["statusBar"].Move(0, height - 42, width, 42)
        this.Controls["statusProfile"].Move(width - 320, height - 30)
        this.Controls["version"].Move(width - 110, height - 30)
        this.Controls["content"].Move(sidebarWidth, 48, contentWidth, height - 90)

        contentX := sidebarWidth + 34
        rightX := width - rightWidth - 34
        this.Controls["pageTitle"].Move(contentX, 78)
        this.Controls["pageSubtitle"].Move(contentX, 112)
        this.Controls["newBind"].Move(rightX - 170, 78)
        this.Controls["filterBar"].Move(contentX, 152, contentWidth - 68, 44)
        this.Controls["listCard"].Move(contentX, 216, contentWidth - 68, Max(250, height - 450))
        this.Controls["listHeader"].Move(contentX + 22, 238, contentWidth - 110)
        this.Controls["emptyState"].Move(contentX + 120, 360, contentWidth - 300, 90)
        this.Controls["quickTitle"].Move(contentX, height - 200)
        this.Controls["quickTest"].Move(contentX, height - 168)
        this.Controls["quickImport"].Move(contentX + 160, height - 168)
        this.Controls["quickExport"].Move(contentX + 320, height - 168)
        this.Controls["quickOverlay"].Move(contentX + 480, height - 168)

        this.BuildRightPanel(width - rightWidth, 48, rightWidth, height - 90)
    }

    static BuildRightPanel(x, y, width, height) {
        if !this.Controls.Has("rightPanel") {
            this.Controls["rightPanel"] := this.Gui.Add("Text", "Background" Theme.Get("sidebar"))
            this.Controls["rightTitle"] := Controls.AddLabel(this.Gui, "", "SYSTEM STATUS", "muted", 9, "600")
            this.Controls["systemCard"] := this.Gui.Add("GroupBox", "c" Theme.Get("border"), "")
            this.Controls["systemText"] := Controls.AddLabel(this.Gui, "", "●  CORE ONLINE`n●  STORAGE READY`n○  OVERLAY OFF`n○  CHAT MONITOR OFF", "green", 9)
            this.Controls["rightHotkeysTitle"] := Controls.AddLabel(this.Gui, "", "HOTKEYS", "muted", 9, "600")
            this.Controls["rightHotkeys"] := Controls.AddLabel(this.Gui, "", "Ctrl+K    Command Palette`nF12       Toggle Binder`nF10       Overlay", "text", 9)
            this.Controls["rightLogTitle"] := Controls.AddLabel(this.Gui, "", "LAST ACTION", "muted", 9, "600")
            this.Controls["rightLog"] := Controls.AddLabel(this.Gui, "", "Binder started successfully", "muted", 9)
        }
        this.Controls["rightPanel"].Move(x, y, width, height)
        this.Controls["rightTitle"].Move(x + 24, y + 30, width - 40, 20)
        this.Controls["systemCard"].Move(x + 18, y + 62, width - 36, 145)
        this.Controls["systemText"].Move(x + 36, y + 90, width - 60, 90)
        this.Controls["rightHotkeysTitle"].Move(x + 24, y + 240, width - 40, 20)
        this.Controls["rightHotkeys"].Move(x + 24, y + 270, width - 40, 85)
        this.Controls["rightLogTitle"].Move(x + 24, y + 400, width - 40, 20)
        this.Controls["rightLog"].Move(x + 24, y + 430, width - 40, 60)
    }

    static HandleResize(gui, minMax, width, height) {
        if minMax = -1
            return
        this.Layout(width, height)
    }

    static BeginDrag(*) {
        PostMessage(0xA1, 2,,, MainWindow.Gui.Hwnd)
    }

    static HandleClose(*) {
        ExitApp(Constants.ExitCodeSuccess)
    }

    static Minimize(*) {
        MainWindow.Gui.Minimize()
    }

    static ToggleMaximize(*) {
        if MainWindow.IsMaximized {
            MainWindow.Gui.Restore()
            MainWindow.IsMaximized := false
        } else {
            MainWindow.Gui.Maximize()
            MainWindow.IsMaximized := true
        }
    }

    static ProfileInfo(*) {
        Toasts.Show("Редактор профилей будет доступен на этапе 12.")
    }

    static NewBind(*) {
        Toasts.Show("Менеджер биндов будет подключён на этапе 4.")
    }

    static TestAction(*) {
        Toasts.Show("Тестовый режим будет подключён на этапе 5.")
    }

    static ImportAction(*) {
        Toasts.Show("Импорт и экспорт будут подключены на этапе 13.")
    }

    static ExportAction(*) {
        Toasts.Show("Импорт и экспорт будут подключены на этапе 13.")
    }

    static OverlayAction(*) {
        Toasts.Show("Overlay будет подключён на этапе 10.")
    }

    static SwitchPage(page) {
        this.CurrentPage := page
        this.Controls["pageTitle"].Text := Navigation.PageTitle(page)
        this.Controls["pageSubtitle"].Text := page = "binds" ? "Управление сценариями и быстрыми действиями" : "Раздел подготовлен для следующего этапа разработки"
        for key, control in this.NavControls {
            control.SetFont(Theme.Font(10, key = page ? "accent" : "muted", "600"), "Segoe UI")
        }
        Logger.Activity("Opened page: " page)
        Toasts.Show("Открыт раздел: " Navigation.PageTitle(page))
    }
}
