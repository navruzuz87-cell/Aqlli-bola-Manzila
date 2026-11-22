import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_profile.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_select_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/city/city_screen.dart';
import '../../features/missions/daily_missions_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/sound_settings_screen.dart';
import '../../features/parent/parent_screen.dart';
import '../../features/parent/game_editor_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/ancestors/great_ancestors_screen.dart';
import '../../features/avatar/avatar_creator_screen.dart';
import '../../features/companion/companion_select_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/seasons/season_screen.dart';
import '../../features/games/archery/alpomish_archery_screen.dart';
import '../../features/games/wordle/zumrad_wordle_screen.dart';
import '../../features/games/semurg/semurg_flight_screen.dart';
import '../../features/games/fortress/spitamen_fortress_screen.dart';
import '../../features/games/donkey/donkey_road_screen.dart';
import '../../features/games/geomap/rustam_map_screen.dart';
import '../../features/games/car_race/car_race_screen.dart';
import '../../features/games/geography/geography_game_screen.dart';
import '../../features/games/history/history_game_screen.dart';
import '../../features/games/english/english_game_screen.dart';
import '../../features/games/odobnoma/odobnoma_screen.dart';
import '../../features/games/uzbek/uzbek_game_screen.dart';
import '../../features/games/word/word_game_screen.dart';
import '../../features/games/multiplayer/multiplayer_screen.dart';
// ── Ertak o'yinlari ──────────────────────────────────────────────────────────
import '../../features/games/susambil/susambil_math_screen.dart';
import '../../features/games/zumrad/zumrad_onatili_screen.dart';
import '../../features/games/shiroq/shiroq_history_screen.dart';
import '../../features/games/alpomish/alpomish_geo_screen.dart';
import '../../features/games/tumarisxon/tumarisxon_english_screen.dart';
import '../../features/games/avazxon/avazxon_odobnoma_screen.dart';
import '../../features/games/runner/alpomish_runner_screen.dart';
import '../../features/games/mathzuma/math_zuma_screen.dart';
import '../../features/games/mathblocks/math_blocks_screen.dart';
import '../../features/games/bubble/manzila_bubble_screen.dart';
import '../../features/games/tower/tomaris_tower_screen.dart';
import '../../features/worldmap/world_map_screen.dart';
import '../../features/worldmap/uz_mixed_stage_screen.dart';
import '../../data/models/uzbekistan_map.dart';
import '../services/profile_storage_service.dart';

// ── Route yo'llari ───────────────────────────────────────────────────────────
class AppRoutes {
  static const splash         = '/';
  static const onboarding     = '/onboarding';
  static const profileSelect  = '/profiles';
  static const home           = '/home';
  static const profile        = '/profile';
  static const city           = '/city';
  static const missions       = '/missions';
  static const stats          = '/stats';
  static const settings       = '/settings';
  static const soundSettings  = '/settings/sound';
  static const parentalPanel  = '/settings/parental';
  static const gameEditor = '/settings/parental/game-editor';
  static const shop           = '/shop';
  static const achievements   = '/achievements';
  static const leaderboard    = '/leaderboard';
  static const progress       = '/progress';
  static const ancestors      = '/ancestors';
  static const avatarCreator  = '/avatar';
  static const companionSelect = '/companion';
  static const notifications  = '/notifications';
  static const seasons        = '/seasons';
  // O'yinlar
  static const archeryGame    = '/game/archery';
  static const wordleGame     = '/game/wordle';
  static const semurgGame     = '/game/semurg';
  static const fortressGame   = '/game/fortress';
  static const donkeyGame     = '/game/donkey';
  static const rustamMapGame  = '/game/rustam-map';
  static const carRaceGame    = '/game/car-race';
  static const geoGame        = '/game/geo';
  static const historyGame    = '/game/history';
  static const englishGame    = '/game/english';
  static const odobnoma       = '/game/odobnoma';
  static const uzbekGame      = '/game/uzbek';
  static const wordGame       = '/game/word';
  static const multiplayerGame = '/game/multiplayer';
  // ── Ertak o'yinlari ───────────────────────────────────────────────────────
  static const susambilMath    = '/game/susambil';
  static const zumradOnaTili   = '/game/zumrad';
  static const shiroqHistory   = '/game/shiroq';
  static const alpomishGeo     = '/game/alpomish-geo';
  static const tumarisxonEng   = '/game/tumarisxon';
  static const avazxonOdob     = '/game/avazxon';
  static const runnerGame      = '/game/runner';
  static const mathZuma        = '/game/mathzuma';
  static const mathBlocks      = '/game/math-blocks';
  static const bubblePop       = '/game/bubble';
  static const tomarisTower    = '/game/tower';

  // O'zbekiston Sayohati xaritasi
  static const uzbekistanMap   = '/uzbekistan-map';
  static const uzStageGame     = '/uzbekistan-map/stage';
}

// ── Extra yordamchi funksiyalar ───────────────────────────────────────────────
UserProfile _profile(GoRouterState s) {
  final extra = s.extra;
  if (extra is UserProfile) return extra;
  return (extra as Map<String, dynamic>)['profile'] as UserProfile;
}

void _persistProfileUpdate(UserProfile profile) {
  unawaited(ProfileStorageService.instance.updateProfile(profile));
}

Function(UserProfile) _onUpdate(GoRouterState s) {
  final extra = s.extra;
  if (extra is Map<String, dynamic>) {
    final callback = extra['onUpdate'];
    if (callback is Function(UserProfile)) return callback;
  }
  return _persistProfileUpdate;
}

// ── Router ────────────────────────────────────────────────────────────────────
class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSelect,
        builder: (_, __) => const ProfileSelectScreen(),
      ),

      // ── Asosiy ekranlar ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (_, s) => HomeScreen(
          profile: _profile(s),
          onUpdate: _onUpdate(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.city,
        builder: (_, s) => CityScreen(
          profile: _profile(s),
          onUpdate: _onUpdate(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.missions,
        builder: (_, s) => DailyMissionsScreen(
          profile: _profile(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (_, s) => StatsScreen(profile: _profile(s)),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, s) => SettingsScreen(
          profile: _profile(s),
          onUpdate: _onUpdate(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.soundSettings,
        builder: (_, __) => const SoundSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentalPanel,
        builder: (_, __) => const ParentalScreen(),
      ),
      GoRoute(
        path: AppRoutes.gameEditor,
        builder: (_, __) => const GameEditorScreen(),
      ),
      GoRoute(
        path: AppRoutes.shop,
        builder: (_, s) => ShopScreen(
          profile: _profile(s),
          onUpdate: _onUpdate(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (_, s) => AchievementsScreen(profile: _profile(s)),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (_, s) => LeaderboardScreen(profile: _profile(s)),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (_, s) => ProgressScreen(profile: _profile(s)),
      ),
      GoRoute(
        path: AppRoutes.ancestors,
        builder: (_, s) => GreatAncestorsScreen(profile: _profile(s)),
      ),
      GoRoute(
        path: AppRoutes.avatarCreator,
        builder: (_, s) {
          final extra = s.extra as Map<String, dynamic>;
          return AvatarCreatorScreen(
            profile: extra['profile'] as UserProfile,
            onSave: extra['onSave'] as Function(UserProfile),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.companionSelect,
        builder: (_, s) => CompanionSelectScreen(
          profile: _profile(s),
          onUpdate: _onUpdate(s),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.seasons,
        builder: (_, __) => const SeasonScreen(),
      ),

      // ── O'yinlar ──────────────────────────────────────────────────────
      ..._gameRoutes(),
    ],
  );

  static List<GoRoute> _gameRoutes() => [
    GoRoute(
      path: AppRoutes.archeryGame,
      builder: (_, s) => AlpomishArcheryScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.wordleGame,
      builder: (_, s) => ZumradWordleScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.semurgGame,
      builder: (_, s) => SemurgFlightScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.fortressGame,
      builder: (_, s) => SpitamenFortressScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.donkeyGame,
      builder: (_, s) => DonkeyRoadScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.rustamMapGame,
      builder: (_, s) => RustamMapScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.carRaceGame,
      builder: (_, s) => CarRaceScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.geoGame,
      builder: (_, s) => GeographyGameScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.historyGame,
      builder: (_, s) => HistoryGameScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.englishGame,
      builder: (_, s) => EnglishGameScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.odobnoma,
      builder: (_, s) => OdobnomaScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.uzbekGame,
      builder: (_, s) => UzbekGameScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.wordGame,
      builder: (_, s) => WordGameScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.multiplayerGame,
      builder: (_, __) => const MultiplayerScreen(),
    ),
    // ── Ertak o'yinlari ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.susambilMath,
      builder: (_, s) => SusambilMathScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.zumradOnaTili,
      builder: (_, s) => ZumradOnaTiliScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.shiroqHistory,
      builder: (_, s) => ShiroqHistoryScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.alpomishGeo,
      builder: (_, s) => AlpomishGeoScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.tumarisxonEng,
      builder: (_, s) => TumarisxonEnglishScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.avazxonOdob,
      builder: (_, s) => AvazxonOdobnomaScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.runnerGame,
      builder: (_, s) => AlpomishRunnerScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.mathZuma,
      builder: (_, s) => MathZumaScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.mathBlocks,
      builder: (_, s) => MathBlocksScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.bubblePop,
      builder: (_, s) => ManzilaPopScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),
    GoRoute(
      path: AppRoutes.tomarisTower,
      builder: (_, s) => TomarisTowerScreen(
        profile: _profile(s),
        onUpdate: _onUpdate(s),
      ),
    ),

    // ── O'ZBEKISTON SAYOHATI XARITASI ─────────────────────────────────────
    GoRoute(
      path: AppRoutes.uzbekistanMap,
      builder: (_, s) {
        final profile = _profile(s);
        return WorldMapScreen(
          progress: MapProgress(
            stageStars: const {},
            regionsUnlocked: {
              UzRegion.toshkentShahar: true,
              UzRegion.samarqand: true,
              UzRegion.buxoro: true,
              UzRegion.fargona: true,
              UzRegion.namangan: true,
              UzRegion.andijon: true,
            },
            totalStars: profile.totalStars,
          ),
          playerStars: profile.totalStars,
          onStageSelected: (region, cityIdx, stageIdx) {
            s.context.push(
              AppRoutes.uzStageGame,
              extra: {
                'region': region,
                'cityIdx': cityIdx,
                'stageIdx': stageIdx,
              },
            );
          },
        );
      },
    ),

    GoRoute(
      path: AppRoutes.uzStageGame,
      builder: (_, s) {
        final extra = s.extra as Map<String, dynamic>;
        return UzMixedStageScreen(
          region: extra['region'] as UzRegion,
          cityIdx: extra['cityIdx'] as int,
          stageIdx: extra['stageIdx'] as int,
          onComplete: (stars) {
            s.context.pop(); // Xaritaga qaytish
          },
        );
      },
    ),
  ];
}
