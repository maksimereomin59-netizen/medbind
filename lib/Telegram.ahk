class Telegram {
    static Enabled := false

    static Initialize() {
        settings := DataModel.Root["settings"]
        this.Enabled := settings.Has("telegramEnabled") && settings["telegramEnabled"]
        if this.Enabled
            this.Notify(Constants.AppName " запущен")
    }

    static Notify(message) {
        settings := DataModel.Root["settings"]
        if !settings.Has("telegramEnabled") || !settings["telegramEnabled"]
            return false
        token := settings.Has("telegramToken") ? settings["telegramToken"] : ""
        chatId := settings.Has("telegramChatId") ? settings["telegramChatId"] : ""
        if token = "" || chatId = ""
            return false
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            url := "https://api.telegram.org/bot" token "/sendMessage"
            request.Open("POST", url, false)
            request.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
            body := Json.Stringify(Map("chat_id", chatId, "text", message))
            request.Send(body)
            if request.Status < 200 || request.Status >= 300
                throw Error("Telegram HTTP status: " request.Status)
            Logger.Info("Telegram notification sent")
            return true
        } catch Error as err {
            Logger.Warning("Telegram notification failed: " err.Message)
            return false
        }
    }

    static Test() {
        if this.Notify("Тестовое уведомление Doctor Binder V3")
            Toasts.Show("Telegram: сообщение отправлено")
        else
            Toasts.Show("Telegram: не удалось отправить сообщение")
    }
}
