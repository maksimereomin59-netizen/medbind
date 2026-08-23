class BindManager {
    static Create(name := "Новый бинд", categoryId := "general", hotkey := "") {
        binds := DataModel.GetBinds()
        id := this.NextId(binds)
        line := Map("id", id "-line-001", "text", "/me действие", "delay", 500, "enabled", true, "sendEnter", true, "type", "command")
        bind := Map(
            "id", id,
            "name", name,
            "categoryId", categoryId,
            "hotkey", hotkey,
            "enabled", true,
            "favorite", false,
            "order", binds.Length + 1,
            "delay", 500,
            "statistics", Map("launches", 0, "lastLaunchAt", ""),
            "lines", [line]
        )
        binds.Push(bind)
        DataModel.Save()
        Logger.Activity("Created bind: " id)
        return bind
    }

    static Update(bindId, name, categoryId, hotkey, text, delay) {
        bind := this.Find(bindId)
        if !bind
            throw Error("Bind not found: " bindId)
        bind["name"] := name != "" ? name : "Без названия"
        bind["categoryId"] := categoryId != "" ? categoryId : "general"
        bind["hotkey"] := hotkey
        bind["delay"] := Max(0, Integer(delay = "" ? 0 : delay))
        if bind["lines"].Length = 0
            bind["lines"].Push(Map("id", bindId "-line-001", "text", text, "delay", bind["delay"], "enabled", true, "sendEnter", true, "type", "command"))
        else
            bind["lines"][1]["text"] := text
        bind["lines"][1]["delay"] := bind["delay"]
        DataModel.Save()
        Logger.Activity("Updated bind: " bindId)
        return bind
    }

    static Delete(bindId) {
        binds := DataModel.GetBinds()
        for index, bind in binds {
            if bind["id"] = bindId {
                binds.RemoveAt(index)
                DataModel.Save()
                Logger.Activity("Deleted bind: " bindId)
                return true
            }
        }
        return false
    }

    static Duplicate(bindId) {
        source := this.Find(bindId)
        if !source
            throw Error("Bind not found: " bindId)
        copy := this.Create(source["name"] " — копия", source["categoryId"], "")
        copy["favorite"] := source["favorite"]
        copy["lines"][1]["text"] := source["lines"][1]["text"]
        copy["delay"] := source["delay"]
        DataModel.Save()
        return copy
    }

    static Toggle(bindId) {
        bind := this.Find(bindId)
        if !bind
            return false
        bind["enabled"] := !bind["enabled"]
        DataModel.Save()
        return bind["enabled"]
    }

    static SetFavorite(bindId, value := unset) {
        bind := this.Find(bindId)
        if !bind
            return false
        bind["favorite"] := IsSet(value) ? value : !bind["favorite"]
        DataModel.Save()
        return bind["favorite"]
    }

    static Find(bindId) {
        for bind in DataModel.GetBinds()
            if bind["id"] = bindId
                return bind
        return false
    }

    static NextId(binds) {
        highest := 0
        for bind in binds {
            if RegExMatch(bind["id"], "(\\d+)$", &match)
                highest := Max(highest, Integer(match[1]))
        }
        return "bind-" Format("{1:03}", highest + 1)
    }
}
