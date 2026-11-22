# Phase 4 — Change Log

- Added typed `GameConfigData` and `GameConfigService` with safe defaults, validation ranges and cache invalidation.
- Game Editor invalidates config cache after saving.
- Math Blocks now reads difficulty, timer, question count, robot hint behavior and reward cap from Game Editor config.
- Math Blocks counts a question as solved only after the answer block is placed.
- Alpomish Runner now reads enabled/speed/rewardStars from Game Editor config.
- Runner rewards each completed level only once per current play session.
- Not yet integrated: age range (profile has grade, not age), Runner timer/hints/difficulty/questionCount, Math Blocks speed, CMS sync.
- Flutter analyze/test/build not run because Flutter/Dart SDK is unavailable in this environment.
