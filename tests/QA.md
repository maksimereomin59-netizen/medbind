# Doctor Binder V3 — QA checklist

## Automated repository checks

- All `#Include` paths resolve to files in the repository.
- `git diff --check` passes.
- No `IsSet(this.Property)` calls remain.
- No unsupported `Gui.Focus()` calls remain.
- Overlay and Radial Menu use the AHK GUI `NA` show option.

## Windows smoke test

- [ ] AutoHotkey v2 launches `DoctorBinder.ahk`.
- [ ] `data/` directories and profile JSON are created.
- [ ] Main window opens and can be resized, minimized, maximized and closed.
- [ ] Navigation hides inactive workspace controls.
- [ ] A bind can be selected, edited, saved and reloaded.
- [ ] A multiline scenario can be saved and loaded.
- [ ] F1-F5 register from the profile.
- [ ] F10 toggles Overlay, F11 toggles Radial Menu, F12 toggles Binder.
- [ ] Ctrl+Z and Ctrl+Y exercise the application history.
- [ ] Test mode does not send text to GTA.
- [ ] Sender STOP cancels a running sequence.
- [ ] Variables and current patient ID are substituted.
- [ ] Chat Monitor reads only appended chatlog lines.
- [ ] Profile import/export round-trips a profile.
- [ ] Backup files are created before destructive changes.
- [ ] Statistics increase after a real bind run.
- [ ] Telegram remains optional and failures do not terminate Binder.

## Environment note

GUI, global hotkeys, WinHTTP, Overlay and GTA input require Windows with AutoHotkey v2.
They cannot be executed in the current Linux build environment.
