# ManZila Aqlli Bola — Phase 9.1: Susambil Vertical Slice

**Base:** v56 Phase 8 (`manzila_Aqlli_Bola_v56_phase8.zip`)  
**Scope:** first playable vertical-slice implementation in the existing Susambil route.

## Implemented in this increment

- Replaced the old 10-question-only Susambil screen with a four-stage adventure flow.
- Added four sequential scenes: muddy path, damaged bridge, fast water channel, and helping Susambil villagers.
- Each stage presents a visible warning before the learning challenge; the player can reopen the warning from the AppBar.
- Embedded Mathematics, Ona tili, and Odobnoma tasks into the story progression.
- Added one-use Eshak companion-help interaction per run.
- Added answer feedback with short explanations and a continue action.
- Added two narrative endings: all challenges correct / adventure completed with some mistakes.
- Preserved the existing `SusambilMathScreen(profile, onUpdate)` constructor and route contract.
- On completion, updates profile stars and subject progress through the existing `onUpdate` callback.
- No robot-mascot artwork or design properties were recreated or modified.

## Not implemented yet

- Custom illustrated Susambil environment and character animation assets.
- Physical movement/platform gameplay; this increment is a guided interactive adventure prototype.
- Branching dialogue choices with persistent story flags.
- Persistent campaign snapshot across app restarts.
- Shared `GameStatsService` integration for Susambil.
- Game Editor content authoring integration.
- Adaptive difficulty and age/class-specific question bank.
- Audio/voice and accessibility review.

## Verification

- Source inspection: route still references `SusambilMathScreen`; constructor contract preserved.
- `UserProfile.copyWith` exposes `stars` and `subjectProgress`, used by this screen.
- Flutter/Dart SDK is not available in the working environment. `dart format`, `flutter analyze`, `flutter test`, and Android build were **not run**. Do not treat this increment as build-verified.
