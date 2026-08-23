class SettingsManager {
    static Gui := false
    static Controls := Map()

    static Open(*) {
        if this.Gui {
            this.LoadValues()
            this.Gui.Show()
            return
        }
        this.Gui := Gui("+Resize +MinSize520x430", "Настройки — " Constants.AppName)
        this.Gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        this.Gui.Add("Text", "x20 y18 w460 h25", "НАСТРОЙКИ DOCTOR BINDER V3")
        tabs := this.Gui.Add("Tab3", "x18 y55 w484 h300", ["Общие", "Отправка", "Chat Monitor", "Overlay", "Telegram"])

        tabs.UseTab(1)
        this.Controls["autosave"] := this.Gui.Add("CheckBox", "x40 y95 w220 h25", "Автосохранение")
        this.Gui.Add("Text", "x40 y135 w150 h20", "Тема")
        this.Controls["theme"] := this.Gui.Add("Edit", "x190 y132 w190 h26")
        this.Gui.Add("Text", "x40 y180 w150 h20", "Язык интерфейса")
        this.Controls["language"] := this.Gui.Add("Edit", "x190 y177 w190 h26", "Русский")

        tabs.UseTab(2)
        this.Gui.Add("Text", "x40 y95 w220 h20", "Base Delay, мс")
        this.Controls["baseDelay"] := this.Gui.Add("Edit", "x270 y92 w100 h26")
        this.Gui.Add("Text", "x40 y140 w220 h20", "Chat Delay, мс")
        this.Controls["chatDelay"] := this.Gui.Add("Edit", "x270 y137 w100 h26")
        this.Gui.Add("Text", "x40 y185 w220 h20", "Enter Delay, мс")
        this.Controls["enterDelay"] := this.Gui.Add("Edit", "x270 y182 w100 h26")
        this.Gui.Add("Text", "x40 y230 w220 h20", "Jitter, мс")
        this.Controls["jitter"] := this.Gui.Add("Edit", "x270 y227 w100 h26")

        tabs.UseTab(3)
        this.Gui.Add("Text", "x40 y95 w420 h20", "Путь к chatlog.txt")
        this.Controls["chatLogPath"] := this.Gui.Add("Edit", "x40 y125 w330 h26")
        this.Controls["browseChat"] := this.Gui.Add("Button", "x380 y125 w90 h26", "Обзор")
        this.Controls["browseChat"].OnEvent("Click", ObjBindMethod(SettingsManager, "BrowseChat"))
        this.Controls["chatEnabled"] := this.Gui.Add("CheckBox", "x40 y175 w300 h25", "Включить Chat Monitor")
        this.Gui.Add("Text", "x40 y220 w400 h40", "Монитор читает только новые строки и не изменяет chatlog.")

        tabs.UseTab(4)
        this.Gui.Add("Text", "x40 y95 w220 h20", "Масштаб Overlay")
        this.Controls["overlayScale"] := this.Gui.Add("Edit", "x270 y92 w100 h26")
        this.Gui.Add("Text", "x40 y140 w220 h20", "Прозрачность, 0–255")
        this.Controls["overlayOpacity"] := this.Gui.Add("Edit", "x270 y137 w100 h26")
        this.Controls["overlayEnabled"] := this.Gui.Add("CheckBox", "x40 y190 w300 h25", "Показывать Overlay при запуске")
        tabs.UseTab(5)
        this.Gui.Add("Text", "x40 y95 w220 h20", "Bot Token")
        this.Controls["telegramToken"] := this.Gui.Add("Edit", "x40 y125 w420 h26 Password")
        this.Gui.Add("Text", "x40 y165 w220 h20", "Chat ID")
        this.Controls["telegramChatId"] := this.Gui.Add("Edit", "x40 y195 w220 h26")
        this.Controls["telegramEnabled"] := this.Gui.Add("CheckBox", "x40 y240 w300 h25", "Включить Telegram")
        this.Controls["telegramTest"] := this.Gui.Add("Button", "x40 y275 w180 h28", "ТЕСТОВОЕ СООБЩЕНИЕ")
        this.Controls["telegramTest"].OnEvent("Click", ObjBindMethod(SettingsManager, "TelegramTest"))
        tabs.UseTab()

        this.Controls["save"] := this.Gui.Add("Button", "x300 y375 w100 h32", "СОХРАНИТЬ")
        this.Controls["save"].OnEvent("Click", ObjBindMethod(SettingsManager, "Save"))
        this.Controls["cancel"] := this.Gui.Add("Button", "x410 y375 w90 h32", "ОТМЕНА")
        this.Controls["cancel"].OnEvent("Click", ObjBindMethod(SettingsManager, "Close"))
        this.Gui.OnEvent("Close", ObjBindMethod(SettingsManager, "Close"))
        this.LoadValues()
        this.Gui.Show("w520 h430")
    }

    static LoadValues() {
        settings := DataModel.Root["settings"]
        this.Controls["autosave"].Value := settings.Has("autosave") ? settings["autosave"] : true
        this.Controls["theme"].Value := settings.Has("theme") ? settings["theme"] : "midnight"
        this.Controls["language"].Value := settings.Has("language") ? settings["language"] : "Русский"
        this.Controls["baseDelay"].Value := settings.Has("baseDelay") ? settings["baseDelay"] : 250
        this.Controls["chatDelay"].Value := settings.Has("chatDelay") ? settings["chatDelay"] : 100
        this.Controls["enterDelay"].Value := settings.Has("enterDelay") ? settings["enterDelay"] : 80
        this.Controls["jitter"].Value := settings.Has("jitter") ? settings["jitter"] : 0
        this.Controls["chatLogPath"].Value := settings.Has("chatLogPath") ? settings["chatLogPath"] : ""
        this.Controls["chatEnabled"].Value := settings.Has("chatMonitorEnabled") ? settings["chatMonitorEnabled"] : false
        this.Controls["telegramToken"].Value := settings.Has("telegramToken") ? settings["telegramToken"] : ""
        this.Controls["telegramChatId"].Value := settings.Has("telegramChatId") ? settings["telegramChatId"] : ""
        this.Controls["telegramEnabled"].Value := settings.Has("telegramEnabled") ? settings["telegramEnabled"] : false
        overlay := DataModel.CurrentProfile["overlay"]
        this.Controls["overlayScale"].Value := overlay.Has("scale") ? overlay["scale"] : 1.0
        this.Controls["overlayOpacity"].Value := overlay.Has("opacity") ? Round(overlay["opacity"] * 255) : 230
        this.Controls["overlayEnabled"].Value := overlay.Has("visible") ? overlay["visible"] : false
    }

    static Save(*) {
        try {
            settings := DataModel.Root["settings"]
            settings["autosave"] := this.Controls["autosave"].Value = 1
            settings["theme"] := this.Controls["theme"].Value
            settings["language"] := this.Controls["language"].Value
            settings["baseDelay"] := this.Number(this.Controls["baseDelay"].Value, 250)
            settings["chatDelay"] := this.Number(this.Controls["chatDelay"].Value, 100)
            settings["enterDelay"] := this.Number(this.Controls["enterDelay"].Value, 80)
            settings["jitter"] := this.Number(this.Controls["jitter"].Value, 0)
            settings["chatLogPath"] := this.Controls["chatLogPath"].Value
            settings["chatMonitorEnabled"] := this.Controls["chatEnabled"].Value = 1
            settings["telegramToken"] := this.Controls["telegramToken"].Value
            settings["telegramChatId"] := this.Controls["telegramChatId"].Value
            settings["telegramEnabled"] := this.Controls["telegramEnabled"].Value = 1
            Telegram.Enabled := settings["telegramEnabled"]
            overlay := DataModel.CurrentProfile["overlay"]
            overlay["scale"] := Max(0.5, this.Number(this.Controls["overlayScale"].Value, 1.0))
            overlay["opacity"] := Max(0.1, Min(1.0, this.Number(this.Controls["overlayOpacity"].Value, 230) / 255))
            overlay["visible"] := this.Controls["overlayEnabled"].Value = 1
            DataModel.Save()
            if settings["chatMonitorEnabled"] && settings["chatLogPath"] != ""
                ChatMonitor.Start(settings["chatLogPath"], false)
            else if !settings["chatMonitorEnabled"]
                ChatMonitor.Stop()
            if overlay["visible"]
                Overlay.Show()
            else
                Overlay.Hide()
            Toasts.Show("Настройки сохранены")
            this.Close()
        } catch Error as err {
            ErrorHandler.Handle(err, "save settings")
        }
    }

    static TelegramTest(*) {
        settings := DataModel.Root["settings"]
        settings["telegramToken"] := this.Controls["telegramToken"].Value
        settings["telegramChatId"] := this.Controls["telegramChatId"].Value
        settings["telegramEnabled"] := true
        Telegram.Enabled := true
        Telegram.Test()
    }

    static BrowseChat(*) {
        path := FileSelect("O", this.Controls["chatLogPath"].Value, "Выберите chatlog.txt", "Text files (*.txt)")
        if path != ""
            this.Controls["chatLogPath"].Value := path
    }

    static Number(value, fallback) {
        return RegExMatch(String(value), "^-?\\d+(?:\\.\\d+)?$") ? Number(value) : fallback
    }

    static Close(*) {
        if this.Gui
            this.Gui.Hide()
    }
}
