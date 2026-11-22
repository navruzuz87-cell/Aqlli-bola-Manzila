# Phase 11 — Profile Persistence and Navigation Hardening

- Centralized child profile storage in `ProfileStorageService`.
- Added active profile ID persistence and legacy single-profile migration.
- Routed onboarding, splash restoration, profile selection, profile editing/deletion, and route update callbacks through the shared service.
- Fixed Home routes that omitted required profile arguments for Daily Missions and Settings.
- Replaced an unregistered profile-detail navigation target with the existing family profile selector.
- Replaced Settings' obsolete `profiles` string-list deletion path with the canonical `all_profiles` collection.
- Added storage regression tests for active profile selection, legacy migration, updates, and deletion fallback.

Verification remains source-level only because Flutter/Dart SDK is unavailable in the build environment.
