# ManZila Aqlli Bola — Phase 6 implementation

## Scope completed in this phase

### 1. Age entry in profile onboarding
- Added a required age-selection page to the first-run onboarding flow.
- Added the same age-selection page to the multi-profile onboarding flow.
- Supported age range in the current child-facing UI: 5–12 years.
- Kept `age` separate from `grade`; the grade remains the school class.
- Added age display to profile cards.

### 2. Profile editing
- Added an edit control to each profile card.
- Existing profile data is prefilled in the four-step editor.
- Saving edits uses `copyWith`, preserving accumulated stars, progress, resources, and other profile state.

### 3. Math Blocks 2×2 equation assembly
- Added a separate 2×2 drag-and-drop puzzle opened from the Math Blocks app bar.
- The four slots represent first number, operation, second number, and answer.
- Correctly placed tiles complete the puzzle and award 15 bonus points.
- Existing answer-selection and 6×5 block-board gameplay remain available and unchanged in flow.

### 4. Profile compatibility corrections discovered during integration
- Added `avatarEmoji` to the current `UserProfile` model because profile and home screens read it.
- Made `fromJson` accept either an already-decoded map or a JSON string, matching existing call sites.
- Corrected profile-list serialization/deserialization to use JSON encoding consistently.
- Added a fallback ID for older profile JSON records that do not contain an `id`.
- Updated onboarding constructors to supply the required profile ID and removed stale constructor arguments that are not part of the current model.

## Files changed
- `lib/data/models/user_profile.dart`
- `lib/features/profile/profile_select_screen.dart`
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/games/mathblocks/math_blocks_screen.dart`

## Validation status
- Source-level review and delimiter checks performed on changed files.
- Flutter/Dart SDK is not available in this environment. Therefore `dart format`, `flutter analyze`, `flutter test`, `flutter pub get`, and Android build were not run.
- UI behavior, drag/drop behavior, JSON migration on a device, and visual layout still require runtime testing.

## Not included yet
- Shared `GameStatsService`.
- Story character dialogue and branching endings.
- Full Game Editor content authoring interface.
- Backend/multiplayer functionality.
- New 3D character rigs, facial animation, or original soundtrack.

## Mascot/design constraint
The ManZila robot mascot's face, eyes and eye placement, mouth/smile, antenna, head shape, white-blue outfit, colors, and chest `M` mark must remain unchanged in all future design work.
