class UndoRedo {
    static UndoStack := []
    static RedoStack := []
    static Limit := 20

    static Record(action) {
        if DataModel.CurrentProfile.Count = 0
            return
        snapshot := Json.Parse(Json.Stringify(DataModel.CurrentProfile))
        this.UndoStack.Push({action: action, profile: snapshot})
        while this.UndoStack.Length > this.Limit
            this.UndoStack.RemoveAt(1)
        this.RedoStack := []
        History.Add("Изменение: " action)
    }

    static Undo(*) {
        if this.UndoStack.Length = 0 {
            Toasts.Show("Нет изменений для отмены")
            return false
        }
        current := Json.Parse(Json.Stringify(DataModel.CurrentProfile))
        this.RedoStack.Push(current)
        entry := this.UndoStack.Pop()
        this.Apply(entry.profile)
        Toasts.Show("Отменено: " entry.action)
        return true
    }

    static Redo(*) {
        if this.RedoStack.Length = 0 {
            Toasts.Show("Нет изменений для повтора")
            return false
        }
        current := Json.Parse(Json.Stringify(DataModel.CurrentProfile))
        this.UndoStack.Push({action: "redo", profile: current})
        profile := this.RedoStack.Pop()
        this.Apply(profile)
        Toasts.Show("Изменение повторено")
        return true
    }

    static Apply(profile) {
        DataModel.CurrentProfile := profile
        DataModel.Save()
        IDManager.Initialize()
        HotkeyManager.Refresh()
        if MainWindow.Gui
            MainWindow.Refresh()
    }
}
