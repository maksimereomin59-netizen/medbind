class ConflictResolver {
    static Find(hotkey, ignoreBindId := "") {
        if hotkey = ""
            return ""
        for bind in DataModel.GetBinds() {
            if bind["id"] != ignoreBindId && StrLower(bind["hotkey"]) = StrLower(hotkey)
                return bind["id"]
        }
        return ""
    }
}
