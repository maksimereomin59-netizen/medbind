class MainWindow {
    ; AHK v2 IsSet() accepts variables, not object properties.
    ; Use a false sentinel until the GUI object is created.
    static Gui := false
    static Controls := Map()
    static NavControls := Map()
    static CurrentPage := "binds"
    static IsMaximized := false

    static Create() {
        if this.Gui
            return this.Gui

        this.Gui := Gui("-Caption +Resize +MinSize1000x620", Constants.AppName)
        this.Gui.BackColor := Theme.Get("window")
        this.Gui.MarginX := 0
        this.Gui.MarginY := 0
        this.Gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        this.Gui.OnEvent("Close", ObjBindMethod(MainWindow, "HandleClose"))
        this.Gui.OnEvent("Size", ObjBindMethod(MainWindow, "HandleResize"))

        this.BuildTitleBar()
        this.BuildSidebar()
        this.BuildContent()
        this.BuildStatusBar()
        this.Layout(1400, 850)
        return this.Gui
    }

    static BuildTitleBar() {
        this.Controls["titleBar"] := this.Gui.Add("Text", "x0 y0 w1400 h48 Background" Theme.Get("sidebar"))
        this.Controls["titleBar"].OnEvent("Click", ObjBindMethod(MainWindow, "BeginDrag"))
        this.Controls["brand"] := Controls.AddLabel(this.Gui, "x24 y10 w300 h28", "⚡  DOCTOR BINDER V3", "accent", 14, "600")
        this.Controls["brand"].OnEvent("Click", ObjBindMethod(MainWindow, "BeginDrag"))

        this.Controls["search"] := this.Gui.Add("Edit", "x390 y10 w290 h28 Background" Theme.Get("card") " c" Theme.Get("muted"), "Поиск биндов  •  Ctrl+K")
        this.Controls["search"].SetFont(Theme.Font(9, "muted"), "Segoe UI")

        this.Controls["profile"] := Controls.AddLabel(this.Gui, "x720 y12 w240 h24", "ПРОФИЛЬ  ·  Больница LS", "muted", 9)
        this.Controls["profile"].OnEvent("Click", ObjBindMethod(MainWindow, "ProfileInfo"))

        this.Controls["minimize"] := Controls.AddButton(this.Gui, "x1300 y8 w30 h30", "—", ObjBindMethod(MainWindow, "Minimize"))
        this.Controls["maximize"] := Controls.AddButton(this.Gui, "x1334 y8 w30 h30", "□", ObjBindMethod(MainWindow, "ToggleMaximize"))
        this.Controls["close"] := Controls.AddButton(this.Gui, "x1368 y8 w30 h30", "×", ObjBindMethod(MainWindow, "HandleClose"))
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
        this.Controls["pageTitle"] := Controls.AddLabel(this.Gui, "x264 y78 w500 h32", "СПИСОК БИНДОВ (8 / 100)", "accent", 17, "600")
        this.Controls["pageSubtitle"] := Controls.AddLabel(this.Gui, "x264 y112 w650 h24", "Сценарии, команды и быстрые действия", "muted", 9)
        this.Controls["newBind"] := Controls.AddButton(this.Gui, "x940 y78 w170 h34", "+  НОВЫЙ БИНД", ObjBindMethod(MainWindow, "NewBind"))

        this.Controls["filterBar"] := this.Gui.Add("Text", "x264 y152 w846 h44 Background" Theme.Get("card"))
        this.Controls["filterAll"] := Controls.AddLabel(this.Gui, "x282 y166 w95 h20", "Все  8 / 100", "accent", 9, "600")
        this.Controls["filterFav"] := Controls.AddLabel(this.Gui, "x395 y166 w120 h20", "★ Избранное", "muted", 9)
        this.Controls["filterCategory"] := Controls.AddLabel(this.Gui, "x560 y166 w180 h20", "Все категории  ▾", "muted", 9)
        this.Controls["filterStatus"] := Controls.AddLabel(this.Gui, "x825 y166 w160 h20", "Активные  7", "green", 9)

        this.Controls["listCard"] := this.Gui.Add("GroupBox", "x264 y216 w846 h255 c" Theme.Get("border"), "")
        this.Controls["listHeader"] := Controls.AddLabel(this.Gui, "x286 y232 w800 h22", "#       НАЗВАНИЕ                 КЛАВИША        ДЕЙСТВИЕ                         ЗАДЕРЖКА", "muted", 8, "600")
        binds := DataModel.GetBinds()
        if binds.Length > 0
            State.Set("selectedBindId", binds.Length >= 2 ? binds[2]["id"] : binds[1]["id"])
        bindCount := binds.Length
        this.Controls["pageTitle"].Text := "СПИСОК БИНДОВ (" bindCount " / 100)"
        this.Controls["filterAll"].Text := "Все  " bindCount " / 100"
        this.Controls["filterStatus"].Text := "Активные  " bindCount
        y := 265
        this.SampleRows := []
        for index, bind in binds {
            if index > 5
                break
            row := [Format("{1:03}", index), bind["name"], bind["hotkey"], bind["lines"][1]["text"], bind["delay"] " мс"]
            bg := this.Gui.Add("Text", "x276 y" y " w822 h34 Background" (Mod(index, 2) ? Theme.Get("card") : Theme.Get("panel")))
            number := Controls.AddLabel(this.Gui, "x292 y" (y + 8) " w40 h18", row[1], "muted", 9)
            name := Controls.AddLabel(this.Gui, "x340 y" (y + 8) " w155 h18", (index = 2 ? "★  " : "") row[2], index = 2 ? "accent" : "text", 9, "600")
            key := Controls.AddLabel(this.Gui, "x510 y" (y + 8) " w65 h18", row[3], "accentBlue", 9, "600")
            action := Controls.AddLabel(this.Gui, "x590 y" (y + 8) " w300 h18", row[4], "text", 9)
            delay := Controls.AddLabel(this.Gui, "x930 y" (y + 8) " w75 h18", row[5], "muted", 9)
            status := Controls.AddLabel(this.Gui, "x1028 y" (y + 8) " w55 h18", bind["enabled"] ? "● ON" : "○ OFF", bind["enabled"] ? "green" : "muted", 8, "600")
            selectBind := ObjBindMethod(MainWindow, "SelectBind", bind["id"])
            bg.OnEvent("Click", selectBind)
            number.OnEvent("Click", selectBind)
            name.OnEvent("Click", selectBind)
            key.OnEvent("Click", selectBind)
            action.OnEvent("Click", selectBind)
            this.SampleRows.Push({bg: bg, number: number, name: name, key: key, action: action, delay: delay, status: status})
            y += 37
        }

        this.Controls["editorCard"] := this.Gui.Add("GroupBox", "x264 y486 w846 h188 c" Theme.Get("border"), "")
        this.Controls["editorTitle"] := Controls.AddLabel(this.Gui, "x286 y505 w400 h22", "РЕДАКТОР БИНДА #002", "accent", 11, "600")
        this.Controls["editorClose"] := Controls.AddLabel(this.Gui, "x1070 y505 w20 h22", "×", "muted", 14)
        this.Controls["fieldNameLabel"] := Controls.AddLabel(this.Gui, "x286 y538 w100 h18", "НАЗВАНИЕ", "muted", 8, "600")
        this.Controls["fieldName"] := this.Gui.Add("Edit", "x286 y558 w220 h28 Background" Theme.Get("card") " c" Theme.Get("text"), "Лечение")
        this.Controls["fieldCategoryLabel"] := Controls.AddLabel(this.Gui, "x520 y538 w100 h18", "КАТЕГОРИЯ", "muted", 8, "600")
        this.Controls["fieldCategory"] := this.Gui.Add("Edit", "x520 y558 w150 h28 Background" Theme.Get("card") " c" Theme.Get("text"), "Лечение")
        this.Controls["fieldKeyLabel"] := Controls.AddLabel(this.Gui, "x684 y538 w100 h18", "КЛАВИША", "muted", 8, "600")
        this.Controls["fieldKey"] := this.Gui.Add("Edit", "x684 y558 w100 h28 Background" Theme.Get("card") " c" Theme.Get("text"), "F2")
        this.Controls["fieldDelayLabel"] := Controls.AddLabel(this.Gui, "x798 y538 w150 h18", "ЗАДЕРЖКА, МС", "muted", 8, "600")
        this.Controls["fieldDelay"] := this.Gui.Add("Edit", "x798 y558 w100 h28 Background" Theme.Get("card") " c" Theme.Get("text"), "500")
        this.Controls["enterToggle"] := Controls.AddLabel(this.Gui, "x920 y566 w160 h18", "○  ENTER ПОСЛЕ СТРОКИ", "muted", 8)
        this.Controls["scenarioLabel"] := Controls.AddLabel(this.Gui, "x286 y600 w160 h18", "ТЕКСТ СЦЕНАРИЯ", "muted", 8, "600")
        this.Controls["scenario"] := this.Gui.Add("Edit", "x286 y620 w500 h42 +Multi Background" Theme.Get("card") " c" Theme.Get("text"), "/me передал таблетку пациенту")
        this.Controls["addLineButton"] := Controls.AddButton(this.Gui, "x800 y620 w90 h30", "+ СТРОКА", ObjBindMethod(MainWindow, "AddLine"))
        this.Controls["removeLineButton"] := Controls.AddButton(this.Gui, "x800 y654 w90 h30", "− СТРОКА", ObjBindMethod(MainWindow, "RemoveLine"))
        this.Controls["testButton"] := Controls.AddButton(this.Gui, "x900 y620 w90 h30", "▶ ТЕСТ", ObjBindMethod(MainWindow, "TestAction"))
        this.Controls["saveButton"] := Controls.AddButton(this.Gui, "x1000 y620 w90 h30", "СОХРАНИТЬ", ObjBindMethod(MainWindow, "SaveAction"))

        this.Controls["categoriesTitle"] := Controls.AddLabel(this.Gui, "x264 y704 w160 h20", "КАТЕГОРИИ", "muted", 8, "600")
        categories := [["Все", "accent"], ["Общие", "text"], ["Лечение", "green"], ["RP", "purple"], ["Операции", "accentBlue"]]
        x := 345
        for category in categories {
            chip := Controls.AddLabel(this.Gui, "x" x " y700 w100 h26 Center", category[1], category[2], 8, "600")
            x += 108
        }
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
        WinActivate("ahk_id " this.Gui.Hwnd)
    }

    static Layout(width, height) {
        if !this.Gui
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
        this.Controls["listCard"].Move(contentX, 216, contentWidth - 68, 255)
        this.Controls["listHeader"].Move(contentX + 22, 232, contentWidth - 110)
        y := 265
        for row in this.SampleRows {
            row.bg.Move(contentX + 12, y, contentWidth - 92, 34)
            row.number.Move(contentX + 28, y + 8)
            row.name.Move(contentX + 76, y + 8)
            row.key.Move(contentX + 246, y + 8)
            row.action.Move(contentX + 326, y + 8)
            row.delay.Move(contentX + 666, y + 8)
            row.status.Move(contentX + 764, y + 8)
            y += 37
        }
        this.Controls["editorCard"].Move(contentX, 486, contentWidth - 68, 188)
        this.Controls["editorTitle"].Move(contentX + 22, 505)
        this.Controls["editorClose"].Move(contentX + contentWidth - 112, 505)
        this.Controls["fieldNameLabel"].Move(contentX + 22, 538)
        this.Controls["fieldName"].Move(contentX + 22, 558)
        this.Controls["fieldCategoryLabel"].Move(contentX + 256, 538)
        this.Controls["fieldCategory"].Move(contentX + 256, 558)
        this.Controls["fieldKeyLabel"].Move(contentX + 420, 538)
        this.Controls["fieldKey"].Move(contentX + 420, 558)
        this.Controls["fieldDelayLabel"].Move(contentX + 534, 538)
        this.Controls["fieldDelay"].Move(contentX + 534, 558)
        this.Controls["enterToggle"].Move(contentX + 656, 566)
        this.Controls["scenarioLabel"].Move(contentX + 22, 600)
        this.Controls["scenario"].Move(contentX + 22, 620, 500, 42)
        this.Controls["addLineButton"].Move(contentX + 536, 620)
        this.Controls["removeLineButton"].Move(contentX + 536, 654)
        this.Controls["testButton"].Move(contentX + 636, 620)
        this.Controls["saveButton"].Move(contentX + 736, 620)
        this.Controls["categoriesTitle"].Move(contentX, 704)

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
        try {
            bind := BindManager.Create()
            State.Set("selectedBindId", bind["id"])
            this.Refresh()
            Toasts.Show("Создан новый бинд: " bind["name"])
        } catch Error as err {
            ErrorHandler.Handle(err, "create bind")
        }
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

    static SelectBind(bindId, *) {
        try {
            bind := BindManager.Find(bindId)
            if !bind
                throw Error("Bind not found: " bindId)
            State.Set("selectedBindId", bindId)
            this.Controls["editorTitle"].Text := "РЕДАКТОР БИНДА #" SubStr(bindId, -2)
            this.Controls["fieldName"].Value := bind["name"]
            this.Controls["fieldCategory"].Value := bind["categoryId"]
            this.Controls["fieldKey"].Value := bind["hotkey"]
            this.Controls["fieldDelay"].Value := bind["delay"]
            lines := []
            for line in bind["lines"]
                if line["enabled"]
                    lines.Push(line["text"])
            this.Controls["scenario"].Value := BindEditor.JoinLines(lines)
        } catch Error as err {
            ErrorHandler.Handle(err, "select bind")
        }
    }

    static AddLine(*) {
        this.Controls["scenario"].Value := BindEditor.AddLine(this.Controls["scenario"].Value)
    }

    static RemoveLine(*) {
        this.Controls["scenario"].Value := BindEditor.RemoveLastLine(this.Controls["scenario"].Value)
    }

    static SaveAction(*) {
        try {
            bindId := State.Get("selectedBindId", "")
            if bindId = ""
                throw Error("No bind is selected")
            BindManager.Update(
                bindId,
                this.Controls["fieldName"].Value,
                this.Controls["fieldCategory"].Value,
                this.Controls["fieldKey"].Value,
                this.Controls["scenario"].Value,
                this.Controls["fieldDelay"].Value
            )
            this.Refresh()
            Toasts.Show("Бинд сохранён")
        } catch Error as err {
            ErrorHandler.Handle(err, "save bind")
        }
    }

    static Refresh() {
        if this.Gui
            this.Gui.Destroy()
        this.Gui := false
        this.Controls := Map()
        this.NavControls := Map()
        this.Create()
        this.Gui.Show("w1400 h850")
        WinActivate("ahk_id " this.Gui.Hwnd)
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
