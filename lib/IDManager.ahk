class IDManager {
    static Recent := []
    static Current := ""

    static Initialize() {
        this.Recent := []
        this.Current := DataModel.CurrentProfile.Has("currentPatientId") ? DataModel.CurrentProfile["currentPatientId"] : ""
    }

    static Set(value, save := true) {
        value := Trim(String(value))
        if value != "" && !RegExMatch(value, "^\\d+$")
            throw Error("Patient ID must contain only digits")
        this.Current := value
        if value != "" {
            for index, oldValue in this.Recent
                if oldValue = value {
                    this.Recent.RemoveAt(index)
                    break
                }
            this.Recent.InsertAt(1, value)
            while this.Recent.Length > 10
                this.Recent.Pop()
        }
        DataModel.CurrentProfile["currentPatientId"] := value
        if save
            DataModel.Save()
        Logger.Activity("Current patient ID: " (value = "" ? "cleared" : value))
        return value
    }

    static Get() {
        return this.Current
    }

    static GetRecent() {
        return this.Recent.Clone()
    }

    static Clear() {
        return this.Set("", true)
    }
}
