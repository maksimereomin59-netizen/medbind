class Core {
    static EnsureAutoHotkeyVersion() {
        version := StrSplit(A_AhkVersion, ".")
        major := Integer(version[1])
        if major < Constants.MinAutoHotkeyMajor
            throw Error("AutoHotkey v2 is required. Detected: " A_AhkVersion)
    }

    static Now() {
        return FormatTime(, "yyyy-MM-dd HH:mm:ss")
    }

    static TimestampForFile() {
        return FormatTime(, "yyyyMMdd-HHmmss")
    }

    static PathJoin(parts*) {
        result := ""
        for index, part in parts {
            if part = ""
                continue
            if result = "" {
                result := part
                continue
            }
            result := RTrim(result, "\\/") "\\" LTrim(part, "\\/")
        }
        return result
    }

    static IsDirectory(path) {
        return DirExist(path) != ""
    }

    static IsFile(path) {
        return FileExist(path) != "" && !DirExist(path)
    }
}
