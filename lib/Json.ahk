class Json {
    static Stringify(value) {
        if value is Map {
            parts := []
            for key, item in value
                parts.Push('"' this.Escape(String(key)) '":' this.Stringify(item))
            return "{" this.Join(parts, ",") "}"
        }
        if value is Array {
            parts := []
            for item in value
                parts.Push(this.Stringify(item))
            return "[" this.Join(parts, ",") "]"
        }
        if IsObject(value)
            throw Error("JSON supports only Map and Array objects")
        if value = true
            return "true"
        if value = false
            return "false"
        if value = ""
            return '""'
        if value is Number
            return String(value)
        return '"' this.Escape(String(value)) '"'
    }

    static Join(items, separator) {
        result := ""
        for index, item in items
            result .= (index = 1 ? "" : separator) item
        return result
    }

    static Escape(value) {
        value := StrReplace(value, "\\", "\\\\")
        value := StrReplace(value, '"', '\\"')
        value := StrReplace(value, "`r", "\\r")
        value := StrReplace(value, "`n", "\\n")
        value := StrReplace(value, "`t", "\\t")
        return value
    }

    static Parse(text) {
        pos := 1
        value := this.ParseValue(text, &pos)
        this.SkipWhitespace(text, &pos)
        if pos <= StrLen(text)
            throw Error("Unexpected data after JSON value at position " pos)
        return value
    }

    static ParseValue(text, &pos) {
        this.SkipWhitespace(text, &pos)
        char := SubStr(text, pos, 1)
        if char = "{"
            return this.ParseObject(text, &pos)
        if char = "["
            return this.ParseArray(text, &pos)
        if char = '"'
            return this.ParseString(text, &pos)
        if SubStr(text, pos, 4) = "true" {
            pos += 4
            return true
        }
        if SubStr(text, pos, 5) = "false" {
            pos += 5
            return false
        }
        if SubStr(text, pos, 4) = "null" {
            pos += 4
            return ""
        }
        match := RegExMatch(SubStr(text, pos), "^-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?", &number)
        if match {
            pos += StrLen(number[0])
            return InStr(number[0], ".") || InStr(number[0], "e") || InStr(number[0], "E") ? Float(number[0]) : Integer(number[0])
        }
        throw Error("Invalid JSON value at position " pos)
    }

    static ParseObject(text, &pos) {
        result := Map()
        pos++
        this.SkipWhitespace(text, &pos)
        if SubStr(text, pos, 1) = "}" {
            pos++
            return result
        }
        loop {
            this.SkipWhitespace(text, &pos)
            if SubStr(text, pos, 1) != '"'
                throw Error("JSON object key expected at position " pos)
            key := this.ParseString(text, &pos)
            this.SkipWhitespace(text, &pos)
            if SubStr(text, pos, 1) != ":"
                throw Error("Colon expected at position " pos)
            pos++
            result[key] := this.ParseValue(text, &pos)
            this.SkipWhitespace(text, &pos)
            char := SubStr(text, pos, 1)
            if char = "}" {
                pos++
                return result
            }
            if char != ","
                throw Error("Comma expected at position " pos)
            pos++
        }
    }

    static ParseArray(text, &pos) {
        result := []
        pos++
        this.SkipWhitespace(text, &pos)
        if SubStr(text, pos, 1) = "]" {
            pos++
            return result
        }
        loop {
            result.Push(this.ParseValue(text, &pos))
            this.SkipWhitespace(text, &pos)
            char := SubStr(text, pos, 1)
            if char = "]" {
                pos++
                return result
            }
            if char != ","
                throw Error("Comma expected at position " pos)
            pos++
        }
    }

    static ParseString(text, &pos) {
        pos++
        result := ""
        while pos <= StrLen(text) {
            char := SubStr(text, pos++, 1)
            if char = '"'
                return result
            if char != "\\" {
                result .= char
                continue
            }
            escape := SubStr(text, pos++, 1)
            switch escape {
                case '"': result .= '"'
                case "\\": result .= "\\"
                case "/": result .= "/"
                case "b": result .= Chr(8)
                case "f": result .= Chr(12)
                case "n": result .= "`n"
                case "r": result .= "`r"
                case "t": result .= "`t"
                case "u":
                    hex := SubStr(text, pos, 4)
                    if StrLen(hex) != 4 || !RegExMatch(hex, "^[0-9A-Fa-f]{4}$")
                        throw Error("Invalid unicode escape at position " pos)
                    result .= Chr("0x" hex)
                    pos += 4
                default: throw Error("Invalid string escape at position " pos)
            }
        }
        throw Error("Unterminated JSON string")
    }

    static SkipWhitespace(text, &pos) {
        while pos <= StrLen(text) && InStr(" `t`r`n", SubStr(text, pos, 1))
            pos++
    }
}
