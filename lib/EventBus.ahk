class EventBus {
    static Listeners := Map()

    static Subscribe(eventName, callback) {
        if !this.Listeners.Has(eventName)
            this.Listeners[eventName] := []
        this.Listeners[eventName].Push(callback)
    }

    static Publish(eventName, payload := unset) {
        if !this.Listeners.Has(eventName)
            return
        for callback in this.Listeners[eventName]
            try {
                if IsSet(payload)
                    callback(payload)
                else
                    callback()
            }
    }
}
