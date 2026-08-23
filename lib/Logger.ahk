class Logger {
    static initialized := false
    static logPath := ""
    static errorLogPath := ""
    static activityLogPath := ""

    static Initialize(logDirectory) {
        if !DirExist(logDirectory)
            DirCreate(logDirectory)

        this.logPath := Core.PathJoin(logDirectory, Constants.LogFileName)
        this.errorLogPath := Core.PathJoin(logDirectory, Constants.ErrorLogFileName)
        this.activityLogPath := Core.PathJoin(logDirectory, Constants.ActivityLogFileName)
        this.initialized := true
        this.Info("Logger initialized")
    }

    static Write(level, message, path := "") {
        if !this.initialized
            return
        if path = ""
            path := this.logPath
        line := Format("[{1}] [{2}] {3}`r`n", Core.Now(), level, message)
        try FileAppend(line, path, "UTF-8")
    }

    static Debug(message) => this.Write("DEBUG", message)
    static Info(message) => this.Write("INFO", message)
    static Warning(message) => this.Write("WARNING", message)
    static Error(message) => this.Write("ERROR", message, this.errorLogPath)
    static Critical(message) => this.Write("CRITICAL", message, this.errorLogPath)

    static Activity(message) => this.Write("ACTIVITY", message, this.activityLogPath)
}
