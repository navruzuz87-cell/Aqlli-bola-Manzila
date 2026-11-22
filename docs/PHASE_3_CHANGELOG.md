# Phase 3 — Change Log

- Added `GameEditorScreen` with per-game settings for six initial game profiles.
- Added local JSON persistence via `SharedPreferences` key `manzila_game_editor_configs_v1`.
- Added editable story fields and learning settings (age range, difficulty, timer, hints, rewards).
- Added `StoryCharacterCatalog` for Alpomish, Susambil donkey, Zumrad, Qimmat, Shiroq, Tomiris, Al-Khwarizmi and the Manzila robot.
- Added `/settings/parental/game-editor` route.
- Added Game Editor entry card to parental panel.
- Corrected router widget reference from undefined `ParentScreen` to declared `ParentalScreen`.
- Not yet connected: stored editor configuration is not consumed by game runtime screens; server CMS/sync is not implemented.
- Not tested with Flutter SDK or Android build in this environment.
