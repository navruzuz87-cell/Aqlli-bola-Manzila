# ManZila: Aqlli Bola — Phase 9.3 Changelog

**Version:** v56 Phase 9.3  
**Base:** v56 Phase 9.2  
**Scope:** Susambil campaign persistence and narrative branching

## Changes

- Added a profile-specific local campaign snapshot using the existing `shared_preferences` dependency.
- Saved and restored the current stage, selected answers, correct-answer count, companion-skill usage, elapsed-time start, completion state, and story choice.
- The adventure now restores its last saved state when the same profile opens Susambil again.
- Added a required village decision before the final learning question: distribute water fairly or prioritize one's own household.
- The final story text now reflects both learning performance and the selected story path.
- Restarting begins a fresh campaign snapshot; the completed campaign remains available until restarted.
- Preserved the existing `SusambilMathScreen(profile, onUpdate)` route contract, shared game-statistics recording, profile progress callback, and approved robot-mascot design.

## Not included in this increment

- Dedicated history/results screen.
- New custom illustrated environment or animated sprites.
- Physical platform movement and collision gameplay.
- CMS/Game Editor integration, adaptive question bank, voice/audio, and accessibility audit.

## Verification

- Source-level checks cover persistence fields, restore path, branching decision, profile-key isolation, and existing statistics integration.
- `shared_preferences` is already declared in `pubspec.yaml`; no dependency change was required.
- Flutter/Dart SDK is unavailable in this environment. `dart format`, `flutter analyze`, `flutter test`, and Android build were not run. This increment is not build-verified.
