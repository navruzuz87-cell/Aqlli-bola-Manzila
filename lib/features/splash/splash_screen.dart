import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/mission_service.dart';
import '../../core/services/parental_service.dart';
import '../../core/services/profile_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _starCtrl;
  String _loadingText = 'Yuklanmoqda...';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _init();
  }

  Future<void> _init() async {
    // 1. Audio servis
    await _setProgress(0.2, 'Ovoz tayyorlanmoqda...');
    await AudioService.instance.init();

    // 2. Mission servis
    await _setProgress(0.5, 'Missiyalar yuklanmoqda...');
    await MissionService.instance.init();

    // 3. Parental servis
    await _setProgress(0.75, 'Sozlamalar yuklanmoqda...');
    await ParentalService.instance.init();

    // 4. Profil tekshiruv
    await _setProgress(0.95, 'Profil tekshirilmoqda...');
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final profile = await ProfileStorageService.instance.loadActiveProfile();

    await _setProgress(1.0, 'Tayyor!');
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    if (profile == null) {
      context.go(AppRoutes.onboarding);
    } else {
      if (!onboardingDone) await prefs.setBool('onboarding_done', true);

      // Ota-ona paneli: showOnLaunch yoqilgan bo'lsa statistika ko'rsat
      final pSvc = ParentalService.instance;
      if (pSvc.settings.isEnabled && pSvc.settings.showOnLaunch) {
        await _showDailySummary(profile);
      }

      // Limit tekshiruv
      if (pSvc.isLimitReached) {
        _showLimitDialog();
        return;
      }

      // Ruxsat etilgan soat tekshiruv
      if (!pSvc.isAllowedHour) {
        _showNotAllowedDialog();
        return;
      }

      AudioService.instance.playMusic(MusicTrack.home);
      context.go(AppRoutes.home, extra: profile);
    }
  }

  Future<void> _setProgress(double val, String text) async {
    setState(() { _progress = val; _loadingText = text; });
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _showDailySummary(UserProfile profile) async {
    final pSvc = ParentalService.instance;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📊', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text('Kechagi statistika',
                  style: GoogleFonts.nunito(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 16),
              _statRow('⏱️ O\'ynalgan vaqt',
                  '${pSvc.todayMinutes} daqiqa'),
              _statRow('⭐ Yig\'ilgan yulduz',
                  '${profile.stars}'),
              _statRow('🔥 Ketma-ket kunlar',
                  '${pSvc.streakDays} kun'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('O\'yinga kirish →',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 16, fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A237E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A5E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('⏰ Vaqt tugadi',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'Bugunlik o\'yin vaqti tugadi.\nErtaga yana o\'ynash mumkin! 🌙',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tushunarli',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFFFD54F),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showNotAllowedDialog() {
    final hours = ParentalService.instance.settings.allowedHours;
    final range = hours.isEmpty ? '' : '${hours.first}:00 – ${hours.last + 1}:00';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A5E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🕐 Hozir vaqti emas',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'O\'ynash vaqti: $range\nO\'sha vaqtda kiring! 😊',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFFFD54F),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
          const Spacer(),
          Text(val,
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFD54F))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D2B), Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: Stack(
          children: [
            _buildStars(),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const Spacer(flex: 3),
                  _buildProgressBar(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _starCtrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarsPainter(_starCtrl.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text('🏰', style: TextStyle(fontSize: 60)),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 2.seconds,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildTitle() {
    return Text(
      'Manzila',
      style: GoogleFonts.nunito(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: const Color(0xFFFFD54F).withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildSubtitle() {
    return Text(
      'Aqlli Bola',
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFD54F).withOpacity(0.8),
        letterSpacing: 4,
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 400),
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _loadingText,
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.white38),
          ).animate(key: ValueKey(_loadingText)).fadeIn(),
        ],
      ),
    );
  }
}

// ── Yulduzlar CustomPainter ────────────────────────────────────────────────
class _StarsPainter extends CustomPainter {
  final double t;
  _StarsPainter(this.t);

  static final _stars = List.generate(40, (i) => (
    x: (i * 73 % 100) / 100.0,
    y: (i * 37 % 100) / 100.0,
    r: 1.0 + (i % 3),
    phase: (i * 17 % 100) / 100.0,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final s in _stars) {
      final opacity = 0.2 + 0.6 * ((t + s.phase) % 1.0 < 0.5
          ? (t + s.phase) % 1.0 * 2
          : 2 - (t + s.phase) % 1.0 * 2);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}
