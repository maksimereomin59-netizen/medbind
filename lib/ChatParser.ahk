class ChatParser {
    static Parse(line) {
        result := Map("text", line, "id", "", "type", "message")
        if RegExMatch(line, "(?<!\\d)(\\d{1,5})(?!\\d)", &match)
            result["id"] := match[1]
        lower := StrLower(line)
        if InStr(lower, "sms") || InStr(lower, "смс") || InStr(lower, "сообщ")
            result["type"] := "sms"
        else if InStr(lower, "doctor") || InStr(lower, "доктор")
            result["type"] := "mention"
        return result
    }
}
