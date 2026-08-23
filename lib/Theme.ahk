class Theme {
    static Colors := {
        window: "07101C",
        sidebar: "0A1422",
        panel: "0D1928",
        card: "101D2E",
        cardAlt: "142238",
        border: "1E344D",
        text: "E7F1FA",
        muted: "8FA7BC",
        accent: "22D3EE",
        accentBlue: "38BDF8",
        purple: "A78BFA",
        green: "34D399",
        yellow: "FBBF24",
        red: "FB7185"
    }

    static Get(name) {
        if this.Colors.HasOwnProp(name)
            return this.Colors.%name%
        throw Error("Unknown theme color: " name)
    }

    static Font(size := 10, color := "text", weight := "") {
        option := "s" size " c" this.Get(color)
        if weight != ""
            option .= " w" weight
        return option
    }
}
