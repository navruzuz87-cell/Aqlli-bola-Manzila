import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/app_router.dart';
import 'core/services/audio_service.dart';
import 'core/services/mission_service.dart';
import 'core/services/parental_service.dart';
import 'core/services/game_stats_service.dart';
import 'core/services/season_service.dart';
import 'core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Global dark mode notifier ─────────────────────────────────────────────
// Bu barcha ekranlarda dark/light rejimni boshqaradi
final darkModeNotifier = ValueNotifier<bool>(true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only — bolalar uchun
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar shaffof
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Barcha servicelarni parallel ishga tushirish
  await Future.wait([
    AudioService.instance.init(),
    MissionService.instance.init(),
    ParentalService.instance.init(),
    GameStatsService.instance.init(),
    SeasonService.instance.init(),
    NotificationService.instance.init(),
  ]);

  // Dark mode ni SharedPreferences dan yuklash
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool('dark_mode') ?? true;

  runApp(const ManzilApp());
}

class ManzilApp extends StatelessWidget {
  const ManzilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp.router(
          title: 'Manzila: Aqlli Bola',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // ── Dark Theme ──────────────────────────────────────────────────
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF1565C0),
              secondary: const Color(0xFF42A5F5),
              surface: const Color(0xFF0D1B2A),
              error: const Color(0xFFCF6679),
            ),
            scaffoldBackgroundColor: const Color(0xFF0A1628),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          // ── Light Theme ─────────────────────────────────────────────────
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1565C0),
              secondary: const Color(0xFF1976D2),
              surface: const Color(0xFFF5F9FF),
              error: const Color(0xFFB00020),
            ),
            scaffoldBackgroundColor: const Color(0xFFEEF4FF),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
