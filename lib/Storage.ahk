class Storage {
    static RootDirectory := ""
    static DataDirectory := ""
    static ConfigDirectory := ""
    static ProfilesDirectory := ""
    static BackupsDirectory := ""
    static PackagesDirectory := ""
    static HistoryDirectory := ""
    static LogsDirectory := ""

    static Initialize(rootDirectory := "") {
        if rootDirectory = ""
            rootDirectory := A_ScriptDir

        this.RootDirectory := rootDirectory
        this.DataDirectory := Core.PathJoin(rootDirectory, Constants.DataDirectoryName)
        this.ConfigDirectory := Core.PathJoin(this.DataDirectory, Constants.ConfigDirectoryName)
        this.ProfilesDirectory := Core.PathJoin(this.DataDirectory, Constants.ProfilesDirectoryName)
        this.BackupsDirectory := Core.PathJoin(this.DataDirectory, Constants.BackupsDirectoryName)
        this.PackagesDirectory := Core.PathJoin(this.DataDirectory, Constants.PackagesDirectoryName)
        this.HistoryDirectory := Core.PathJoin(this.DataDirectory, Constants.HistoryDirectoryName)
        this.LogsDirectory := Core.PathJoin(this.DataDirectory, Constants.LogsDirectoryName)

        this.EnsureDirectories()
    }

    static EnsureDirectories() {
        directories := [
            this.DataDirectory,
            this.ConfigDirectory,
            this.ProfilesDirectory,
            this.BackupsDirectory,
            this.PackagesDirectory,
            this.HistoryDirectory,
            this.LogsDirectory
        ]
        for directory in directories {
            if !DirExist(directory)
                DirCreate(directory)
        }
    }

    static ReadText(path, encoding := "UTF-8") {
        if !FileExist(path)
            throw Error("File does not exist: " path)
        return FileRead(path, encoding)
    }

    static WriteTextAppend(path, content, encoding := "UTF-8") {
        directory := RegExReplace(path, "[\\/][^\\/]+$", "")
        if directory != "" && !DirExist(directory)
            DirCreate(directory)
        FileAppend(content, path, encoding)
    }

    static WriteText(path, content, encoding := "UTF-8") {
        directory := RegExReplace(path, "[\\/][^\\/]+$", "")
        if directory != "" && !DirExist(directory)
            DirCreate(directory)
        temporaryPath := path ".tmp"
        if FileExist(temporaryPath)
            FileDelete(temporaryPath)
        FileAppend(content, temporaryPath, encoding)
        if FileExist(path)
            FileDelete(path)
        FileMove(temporaryPath, path, true)
    }
}
