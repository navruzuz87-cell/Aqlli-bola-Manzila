# ManZila Aqlli Bola — Phase 9.2 Changelog

**Base:** v56 Phase 9.1 (`manzila_Aqlli_Bola_v56_phase9_1.zip`)
**Increment:** Susambil shared-statistics integration

## Changes

- Registered `susambil` in `GameStatsService.gameName` as “Susambil: Yo‘qolgan buloq”.
- Susambil completion now records one `GameResult` per completed run.
- Stored fields: profile ID, game ID, mixed-subject label, stars, correct-answer score, maximum score, elapsed seconds, and completion timestamp.
- Adventure timer starts when a run begins and resets when the player restarts.
- Existing `SusambilMathScreen(profile, onUpdate)` route/constructor contract remains unchanged.
- Existing profile star and subject-progress updates are preserved.

## Not included

- Persistent mid-run checkpoint/resume.
- New illustrated art or animated character sprites.
- Physical movement/platform controls.
- Branching dialogue flags and Game Editor integration.

## Verification

- Source-level inspection confirms the new service import, game ID registration, and completion record call.
- Flutter/Dart SDK is unavailable in this environment; formatting, analyzer, automated tests, and Android build remain unverified.
- Do not label this increment as build-tested.
