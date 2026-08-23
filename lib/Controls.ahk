class Controls {
    static AddLabel(gui, options, text, color := "text", size := 10, weight := "") {
        gui.SetFont(Theme.Font(size, color, weight), "Segoe UI")
        control := gui.Add("Text", options, text)
        return control
    }

    static AddButton(gui, options, text, callback := unset) {
        gui.SetFont(Theme.Font(10, "text"), "Segoe UI")
        options := options " -Theme"
        control := gui.Add("Button", options, text)
        if IsSet(callback)
            control.OnEvent("Click", callback)
        return control
    }

    static AddCard(gui, options, title, value, accent := "accent") {
        card := gui.Add("GroupBox", options " c" Theme.Get("border"), "")
        titleControl := Controls.AddLabel(gui, options, title, "muted", 9)
        valueControl := Controls.AddLabel(gui, options, value, accent, 18, "600")
        return {card: card, title: titleControl, value: valueControl}
    }
}
