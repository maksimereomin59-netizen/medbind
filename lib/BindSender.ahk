class BindSender {
    static Current := false
    static TimerCallback := false

    static Start(bind) {
        if !State.Get("binderEnabled", true) {
            Toasts.Show("Binder выключен")
            return false
        }
        this.Stop(false)
        lines := []
        for line in bind["lines"]
            if line["enabled"]
                lines.Push(line)
        if lines.Length = 0 {
            Toasts.Show("В бинде нет активных строк")
            return false
        }
        this.Current := {bind: bind, lines: lines, index: 1, test: false, startedAt: Core.Now()}
        State.Set("activeSequence", true)
        Logger.Activity("Bind sequence started: " bind["id"])
        this.Schedule(1)
        return true
    }

    static Test(bind) {
        this.Stop(false)
        lines := []
        for line in bind["lines"]
            if line["enabled"]
                lines.Push(line)
        if lines.Length = 0 {
            Toasts.Show("В бинде нет активных строк")
            return false
        }
        this.Current := {bind: bind, lines: lines, index: 1, test: true, startedAt: Core.Now()}
        State.Set("activeSequence", true)
        Toasts.Show("Тест: строка 1 / " lines.Length)
        this.Schedule(1)
        return true
    }

    static Schedule(delay) {
        if this.TimerCallback
            SetTimer(this.TimerCallback, 0)
        this.TimerCallback := ObjBindMethod(BindSender, "Tick")
        SetTimer(this.TimerCallback, -Max(1, delay))
    }

    static Tick(*) {
        if !this.Current {
            State.Set("activeSequence", false)
            return
        }
        current := this.Current
        if current.index > current.lines.Length {
            bind := current.bind
            this.Stop(false)
            if current.test
                Toasts.Show("Тест завершён: " bind["name"])
            else {
                bind["statistics"]["launches"] += 1
                bind["statistics"]["lastLaunchAt"] := Core.Now()
                DataModel.Save()
                Logger.Activity("Bind sequence completed: " bind["id"])
                Toasts.Show("Бинд выполнен: " bind["name"])
            }
            return
        }

        line := current.lines[current.index]
        total := current.lines.Length
        if current.test {
            Toasts.Show("Тест: строка " current.index " / " total)
        } else {
            try {
                this.SendLine(line["text"])
            } catch Error as err {
                Logger.Error("Send failed: " err.Message)
                this.Stop(false)
                ErrorHandler.Handle(err, "send bind", true)
                return
            }
        }
        current.index += 1
        this.Current := current
        delay := line["delay"] + this.Jitter()
        this.Schedule(delay)
    }

    static SendLine(text) {
        settings := DataModel.Root["settings"]
        Send("t")
        Sleep(35)
        SendText(text)
        Sleep(settings["enterDelay"])
        Send("{Enter}")
        Sleep(settings["chatDelay"])
    }

    static Jitter() {
        jitter := DataModel.Root["settings"]["jitter"]
        return jitter > 0 ? Random(0, jitter) : 0
    }

    static Stop(showToast := true) {
        if this.TimerCallback
            SetTimer(this.TimerCallback, 0)
        this.TimerCallback := false
        wasRunning := !!this.Current
        this.Current := false
        State.Set("activeSequence", false)
        if wasRunning {
            Send("{t up}{Enter up}")
            Logger.Activity("Bind sequence stopped")
            if showToast
                Toasts.Show("Отправка остановлена")
        }
    }

    static IsRunning() {
        return !!this.Current
    }
}
