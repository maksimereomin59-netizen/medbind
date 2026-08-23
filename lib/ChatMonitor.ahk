class ChatMonitor {
    static Path := ""
    static Position := 0
    static TimerCallback := false
    static Running := false

    static Initialize() {
        this.Path := DataModel.Root["settings"].Has("chatLogPath") ? DataModel.Root["settings"]["chatLogPath"] : ""
        this.Position := 0
        if this.Path != "" && FileExist(this.Path)
            this.Start(this.Path, false)
    }

    static Configure(*) {
        selected := FileSelect("S", this.Path, "Выберите chatlog.txt", "Text files (*.txt)")
        if selected = ""
            return false
        return this.Start(selected, true)
    }

    static Start(path, save := true) {
        if !FileExist(path)
            throw Error("Chatlog file not found: " path)
        this.Stop()
        this.Path := path
        this.Position := FileGetSize(path)
        this.Running := true
        this.TimerCallback := ObjBindMethod(ChatMonitor, "Scan")
        SetTimer(this.TimerCallback, 500)
        DataModel.Root["settings"]["chatLogPath"] := path
        DataModel.Root["settings"]["chatMonitorEnabled"] := true
        if save
            DataModel.Save()
        Logger.Info("Chat Monitor started: " path)
        Toasts.Show("Chat Monitor включён")
        return true
    }

    static Stop(*) {
        if this.TimerCallback
            SetTimer(this.TimerCallback, 0)
        this.TimerCallback := false
        this.Running := false
        DataModel.Root["settings"]["chatMonitorEnabled"] := false
    }

    static Scan(*) {
        if !this.Running || this.Path = ""
            return
        try {
            size := FileGetSize(this.Path)
            if size < this.Position
                this.Position := 0
            if size = this.Position
                return
            file := FileOpen(this.Path, "r", "UTF-8")
            if !file
                throw Error("Unable to open chatlog")
            file.Pos := this.Position
            content := file.Read()
            this.Position := file.Pos
            file.Close()
            for line in StrSplit(StrReplace(content, "`r", ""), "`n")
                if Trim(line) != ""
                    this.ProcessLine(line)
        } catch Error as err {
            Logger.Error("Chat Monitor scan failed: " err.Message)
        }
    }

    static ProcessLine(line) {
        parsed := ChatParser.Parse(line)
        if parsed["id"] != "" {
            IDManager.Set(parsed["id"], false)
            EventBus.Publish("NewIdDetected", parsed)
            Toasts.Show("Найден ID пациента: " parsed["id"])
        }
        EventBus.Publish("ChatMessageDetected", parsed)
        Logger.Debug("Chat line: " line)
    }
}
