class Navigation {
    static Items := [
        ["binds", "⌘  БИНДЫ"],
        ["categories", "▦  КАТЕГОРИИ"],
        ["profiles", "♙  ПРОФИЛИ"],
        ["overlay", "◈  OVERLAY"],
        ["radial", "◎  RADIAL MENU"],
        ["chat", "◉  CHAT MONITOR"],
        ["statistics", "▥  СТАТИСТИКА"],
        ["settings", "⚙  НАСТРОЙКИ"],
        ["help", "?  ИНСТРУКЦИЯ"]
    ]

    static PageTitle(page) {
        titles := Map(
            "binds", "СПИСОК БИНДОВ",
            "categories", "КАТЕГОРИИ",
            "profiles", "ПРОФИЛИ",
            "overlay", "OVERLAY",
            "radial", "RADIAL MENU",
            "chat", "CHAT MONITOR",
            "statistics", "СТАТИСТИКА",
            "settings", "НАСТРОЙКИ",
            "help", "ИНСТРУКЦИЯ"
        )
        return titles.Has(page) ? titles[page] : "РАЗДЕЛ"
    }
}
