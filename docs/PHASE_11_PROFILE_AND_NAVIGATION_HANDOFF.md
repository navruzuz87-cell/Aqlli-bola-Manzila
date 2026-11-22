# ManZila: Aqlli Bola — Phase 11 Handoff

## Scope
Core MVP reliability: profile persistence, active-child selection, and route argument integrity.

## Implemented
- Added `ProfileStorageService` as the single local persistence layer for child profiles.
- Added stable `active_profile_id` selection while retaining the legacy `user_profile` key for backward compatibility.
- Added migration from the legacy single-profile record into `all_profiles`.
- Splash now restores the selected active profile rather than always loading the first/legacy profile.
- First onboarding profile is written into the profile collection and marked active.
- Profile selection, editing, and deletion use the shared storage service.
- Profile updates from routes without a custom callback are persisted centrally.
- Settings deletion now removes the selected child from the same profile collection (previously it used a separate, incompatible `profiles` key).
- Fixed Home navigation arguments for Daily Missions and Settings, both of which require a profile.
- Replaced the Home star badge's unregistered `/profile` route with the existing profile selector route.
- Added automated tests for active-profile restore, legacy migration, profile updates, and active-profile deletion fallback.

## Preserved
- Existing `UserProfile` JSON structure and legacy key compatibility.
- Existing route constructors and game screens.
- Approved robot mascot artwork and design.

## Verification
- Static source audit: 88 Dart files; zero missing relative import/export targets.
- Static navigation checks confirm Home supplies the required profile to Missions and Settings.
- Added `test/profile_storage_service_test.dart`.
- Flutter/Dart SDK is unavailable in this environment. `dart format`, `flutter analyze`, `flutter test`, dependency resolution, and Android APK build were not run. The new tests are authored but not executed.

## Next consolidated block
Audit and connect the learning content and test flows; then run the entire project in a Flutter-enabled environment and fix analyzer/build errors as one batch.
