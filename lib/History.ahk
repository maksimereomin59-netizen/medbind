class History {
    static Add(action, details := "") {
        line := Format("[{1}] {2}", Core.Now(), action)
        if details != ""
            line .= " — " details
        try Storage.WriteTextAppend(Core.PathJoin(Storage.HistoryDirectory, "history.log"), line "`r`n")
        Logger.Activity(line)
    }
}
