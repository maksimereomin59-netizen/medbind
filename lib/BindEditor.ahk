class BindEditor {
    static SplitLines(text) {
        text := StrReplace(text, "`r`n", "`n")
        text := StrReplace(text, "`r", "`n")
        result := []
        for line in StrSplit(text, "`n") {
            line := Trim(line)
            if line != ""
                result.Push(line)
        }
        if result.Length = 0
            result.Push("/me действие")
        return result
    }

    static AddLine(text, value := "/me новое действие") {
        return Trim(text) = "" ? value : RTrim(text, "`r`n") "`n" value
    }

    static RemoveLastLine(text) {
        lines := this.SplitLines(text)
        if lines.Length > 1
            lines.Pop()
        return this.JoinLines(lines)
    }

    static MoveLineUp(text) {
        lines := this.SplitLines(text)
        if lines.Length > 1 {
            last := lines.Pop()
            lines.InsertAt(1, last)
        }
        return this.JoinLines(lines)
    }

    static JoinLines(lines) {
        result := ""
        for index, line in lines
            result .= (index = 1 ? "" : "`n") line
        return result
    }
}
