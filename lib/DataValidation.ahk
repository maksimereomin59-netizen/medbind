class DataValidation {
    static IsValidBind(bind) {
        return bind is Map && bind.Has("id") && bind.Has("name") && bind.Has("lines") && bind["lines"] is Array
    }

    static IsValidCategory(category) {
        return category is Map && category.Has("id") && category.Has("name")
    }
}
