class State {
    static Data := {}

    static Initialize() {
        this.Data := {
            initialized: false,
            isRunning: false,
            binderEnabled: true,
            currentProfileId: "",
            activePage: "binds",
            selectedBindId: "",
            currentPatientId: "",
            activeSequence: false,
            overlayVisible: false,
            radialVisible: false,
            firstRun: true,
            startedAt: ""
        }
    }

    static Set(name, value) {
        if !this.Data.HasOwnProp(name)
            throw Error("Unknown application state: " name)
        this.Data.%name% := value
    }

    static Get(name, defaultValue := unset) {
        if this.Data.HasOwnProp(name)
            return this.Data.%name%
        if IsSet(defaultValue)
            return defaultValue
        throw Error("Unknown application state: " name)
    }
}
