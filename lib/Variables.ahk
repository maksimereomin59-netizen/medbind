class Variables {
    static Resolve(text) {
        profile := DataModel.CurrentProfile
        values := Map(
            "ID", IDManager.Get(),
            "NAME", this.ProfileValue(profile, "nick"),
            "MY", this.ProfileValue(profile, "nick"),
            "P", IDManager.Get(),
            "HOSPITAL", this.ProfileValue(profile, "hospital"),
            "SPECIALTY", this.ProfileValue(profile, "specialty"),
            "RANK", this.ProfileValue(profile, "rank"),
            "TIME", FormatTime(, "HH:mm")
        )
        for name, value in values
            text := StrReplace(text, "{" name "}", value)
        return text
    }

    static ProfileValue(profile, key) {
        return profile.Has(key) ? String(profile[key]) : ""
    }
}
