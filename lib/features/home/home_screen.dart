import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/user_profile.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/mission_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/season_service.dart';
import '../../core/painters/game_card_painters.dart';
import '../../core/painters/game_screen_painters.dart';

// ════════════════════════════════════════════════════════════════════════════
// Home Screen — 4-rasmdagi zamonaviy bolalar app uslubi
// Oq fon, rangli kartalar, 3D emoji, yumshoq soyalar
// ════════════════════════════════════════════════════════════════════════════

class HomeScreenV2 extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdate;
  const HomeScreenV2({super.key, required this.profile, required this.onUpdate});

  @override State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  late UserProfile _p;

  @override
  void initState() {
    super.initState();
    _p = widget.profile;
    AudioService.instance.playMusic(MusicTrack.home);
  }

  @override
  Widget build(BuildContext context) {
    final activeSeason = SeasonService.instance.activeSeasons.firstOrNull;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Yuqori banner ─────────────────────────────────────────
            _buildTopBanner(activeSeason),
            const SizedBox(height: 20),
            // ── Tezkor statistika ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _quickStats(),
            ),
            const SizedBox(height: 20),
            // ── Kunlik maqsad ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _dailyGoalCard(),
            ),
            const SizedBox(height: 24),
            // ── O'zbekiston Sayohati (yangi katta banner) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _uzbekistanJourneyBanner(),
            ),
            const SizedBox(height: 12),
            // ── Alpomish Runner ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _runnerGameBanner(),
            ),
            const SizedBox(height: 8),
            // ── Math Zuma ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _mathZumaBanner(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _mathBlocksBanner(),
            ),
            const SizedBox(height: 8),
            // ── So'z Pufagi ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _bubblePopBanner(),
            ),
            const SizedBox(height: 8),
            // ── Tomaris Minorasi ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _towerBanner(),
            ),
            const SizedBox(height: 24),
            // ── Ertak o'yinlari ───────────────────────────────────────
            _sectionHeader('📖 Ertak O\'yinlari', 'Qahramonlarga yordam ber!'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _storyGamesGrid(),
            ),
            const SizedBox(height: 24),
            // ── Klassik o'yinlar ──────────────────────────────────────
            _sectionHeader('🎮 Klassik O\'yinlar', ''),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _classicGamesGrid(),
            ),
            const SizedBox(height: 24),
            // ── Pastki menyu ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _bottomMenu(),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Yuqori banner ──────────────────────────────────────────────────────────
  Widget _buildTopBanner(SeasonInfo? season) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: season != null
              ? season.colors
              : [const Color(0xFF5C6BC0), const Color(0xFF7986CB)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C6BC0).withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row: logo + notification + profile
        Row(children: [
          Text('⭐ Manzila', style: GoogleFonts.nunito(
            fontSize: 20, fontWeight: FontWeight.w900,
            color: Colors.white,
          )),
          const Spacer(),
          // Bildirishnomalar
          ListenableBuilder(
            listenable: NotificationService.instance,
            builder: (_, __) {
              final count = NotificationService.instance.unreadCount;
              return GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: Stack(children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                  ),
                  if (count > 0) Positioned(
                    top: 4, right: 4,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252), shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(child: Text('$count',
                        style: const TextStyle(fontSize: 8, color: Colors.white,
                          fontWeight: FontWeight.w900))),
                    ),
                  ),
                ]),
              );
            },
          ),
          const SizedBox(width: 10),
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSelect),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
              ),
              child: Center(child: Text(_p.avatarEmoji,
                style: const TextStyle(fontSize: 20))),
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // Salom + profil
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Salom, ${_p.name}! 👋',
                style: GoogleFonts.nunito(fontSize: 22,
                  fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 2),
              Text('Bugun nima o\'rganamiz?',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
            ]),
          ),
          // Yulduzlar
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSelect),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5)),
              ),
              child: Row(children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text('${_p.totalStars}', style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD54F))),
              ]),
            ),
          ),
        ]),

        const SizedBox(height: 14),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _p.levelProgress, minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
          ),
        ),
        const SizedBox(height: 6),
        Text('${_p.grade}-sinf  •  ${_p.level}-daraja',
          style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60)),
      ]),
    );
  }

  // ── Tezkor statistika kartalar ──────────────────────────────────────────────
  Widget _quickStats() => Row(children: [
    _statCard('🔥', '${MissionService.instance.streakDays}', 'Ketma-ket', const Color(0xFFFF6B35), 0),
    const SizedBox(width: 10),
    _statCard('✅', '${MissionService.instance.claimable.length}', 'Tayyor', const Color(0xFF4CAF50), 1),
    const SizedBox(width: 10),
    _statCard('🏆', '${_p.totalBuildings}', 'Binolar', const Color(0xFF9C27B0), 2),
  ]);

  Widget _statCard(String emoji, String val, String label, Color color, int idx) =>
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15),
              blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.nunito(fontSize: 20,
            fontWeight: FontWeight.w900, color: Colors.black87)),
          Text(label, style: GoogleFonts.nunito(fontSize: 10,
            color: Colors.black38, fontWeight: FontWeight.w700)),
        ]),
      ).animate(delay: (idx * 80).ms).fadeIn().slideY(begin: 0.2),
    );

  // ── Kunlik maqsad ───────────────────────────────────────────────────────────
  Widget _dailyGoalCard() {
    final done  = MissionService.instance.completedToday;
    final total = 5;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.missions, extra: _p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF5C6BC0).withOpacity(0.3),
              blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(children: [
          const Text('🌟', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kunlik maqsad', style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w700)),
              Text('Davom etavering! 💪', style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: done / total, minHeight: 7,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
                ),
              ),
              const SizedBox(height: 4),
              Text('$done / $total Dars', style: GoogleFonts.nunito(
                fontSize: 11, color: Colors.white60)),
            ]),
          ),
        ]),
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  // ── Ertak o'yinlari grid ────────────────────────────────────────────────────
  Widget _storyGamesGrid() => GridView.count(
    crossAxisCount: 2, shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 14, crossAxisSpacing: 14,
    childAspectRatio: 0.95,
    children: [
      _storyCard('🫏', 'Susambil',    'Matematika',  AppRoutes.susambilMath,  const Color(0xFF388E3C), 0),
      _storyCard('👧', 'Zumrad',      'Ona tili',    AppRoutes.zumradOnaTili, const Color(0xFF7B1FA2), 1),
      _storyCard('🧑‍🌾', 'Shiroq',    'Tarix',       AppRoutes.shiroqHistory, const Color(0xFFC62828), 2),
      _storyCard('🦸‍♂️', 'Alpomish',  'Geografiya',  AppRoutes.alpomishGeo,   const Color(0xFF0288D1), 3),
      _storyCard('👑', 'Tumarisxon',  'Ingliz tili', AppRoutes.tumarisxonEng, const Color(0xFF00695C), 4),
      _storyCard('👦', 'Avazxon',     'Odobnoma',    AppRoutes.avazxonOdob,   const Color(0xFFE64A19), 5),
    ],
  );

  // Har bir sarguzasht uchun CustomPainter
  static CustomPainter _storyPainter(String name) {
    switch (name) {
      case 'Susambil':   return const SusambilCardPainter();
      case 'Zumrad':     return const ZumradCardPainter();
      case 'Shiroq':     return const ShiroqCardPainter();
      case 'Alpomish':   return const AlpomishCardPainter();
      case 'Tumarisxon': return const TumarisxonCardPainter();
      case 'Avazxon':    return const AvazxonCardPainter();
      default:           return const SusambilCardPainter();
    }
  }

  Widget _storyCard(String emoji, String name, String subject,
      String route, Color color, int idx) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.playSfx(SfxSound.buttonTap);
        context.push(route, extra: {'profile': _p, 'onUpdate': (UserProfile up) {
          setState(() => _p = up); widget.onUpdate(up);
        }});
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35),
              blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // CustomPainter grafik fon
              Positioned.fill(
                child: CustomPaint(painter: _storyPainter(name)),
              ),
              // Quyida matn
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, color.withOpacity(0.92)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                      )),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(subject, style: GoogleFonts.nunito(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: (idx * 60).ms).fadeIn().scale(begin: const Offset(0.88, 0.88)),
    );
  }

  // ── Klassik o'yinlar grid ───────────────────────────────────────────────────
  Widget _classicGamesGrid() => GridView.count(
    crossAxisCount: 3, shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12, crossAxisSpacing: 12,
    childAspectRatio: 0.9,
    children: [
      _classicCard('🎯', 'Archery',  AppRoutes.archeryGame,  const Color(0xFF42A5F5), 0),
      _classicCard('🔤', 'Wordle',   AppRoutes.wordleGame,   const Color(0xFF66BB6A), 1),
      _classicCard('🦅', 'Semurg',   AppRoutes.semurgGame,   const Color(0xFFFF7043), 2),
      _classicCard('🏰', 'Qal\'a',   AppRoutes.fortressGame, const Color(0xFFAB47BC), 3),
      _classicCard('🫏', 'Yo\'l',    AppRoutes.donkeyGame,   const Color(0xFFFFB300), 4),
      _classicCard('🗺️', 'Xarita',   AppRoutes.rustamMapGame,const Color(0xFF26A69A), 5),
    ],
  );

  static CustomPainter _classicPainter(String name) {
    switch (name) {
      case 'Archery': return const ArcheryCardPainter();
      case 'Wordle':  return const WordleCardPainter();
      case 'Semurg':  return const SemurgCardPainter();
      case "Qal'a":   return const FortressCardPainter();
      case "Yo'l":    return const YolCardPainter();
      case 'Xarita':  return const XaritaCardPainter();
      default:        return const ArcheryCardPainter();
    }
  }

  Widget _classicCard(String emoji, String name, String route, Color color, int idx) {
    final hasPainter = ['Archery', 'Wordle', 'Semurg', "Qal'a", "Yo'l", 'Xarita'].contains(name);
    return GestureDetector(
      onTap: () {
        AudioService.instance.playSfx(SfxSound.buttonTap);
        context.push(route, extra: {'profile': _p, 'onUpdate': (UserProfile up) {
          setState(() => _p = up); widget.onUpdate(up);
        }});
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3),
              blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Grafik fon
              Positioned.fill(
                child: hasPainter
                    ? CustomPaint(painter: _classicPainter(name))
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color.withOpacity(0.85), color],
                          ),
                        ),
                        child: Center(child: Text(emoji,
                          style: const TextStyle(fontSize: 32))),
                      ),
              ),
              // Nom (pastda)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.85),
                  ),
                  child: Text(name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: (300 + idx * 50).ms).fadeIn().scale(begin: const Offset(0.88, 0.88)),
    );
  }

  // ── O'zbekiston Sayohati banner ───────────────────────────────────────────────
  Widget _runnerGameBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.runnerGame, extra: _p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Text('🏃', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alpomish Yuguradi!', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('So\'z yig\'ib tarixni o\'rgan', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('O\'ynash ▶', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mathZumaBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.mathZuma, extra: _p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Text('🔬', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Al-Xorazmiy Zuma', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Sharlarni otib matematika o\'rgan', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('O\'ynash ▶', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mathBlocksBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.mathBlocks, extra: _p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D7180), Color(0xFF173B76)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF0D7180).withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: const Text('🧮', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Al-Xorazmiy: Matematik bloklar', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('Misolni yech, javob blokini joyla', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text('O‘ynash ▶', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
        ]),
      ),
    );
  }

  Widget _bubblePopBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.bubblePop, extra: _p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00695C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Text('🫧', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('So\'z Pufagi', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Inglizcha-o\'zbekcha so\'zlarni o\'rgan', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('O\'ynash ▶', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _towerBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.tomarisTower, extra: _p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF311B92)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF4A148C).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Text('🏰', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tomaris Minorasi', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Tosh qal, tarix o\'rgan!', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('O\'ynash ▶', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uzbekistanJourneyBanner() {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.uzbekistanMap, extra: _p),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O\'zbekiston Sayohati',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Barcha viloyatlarni zabt et!\n14 viloyat • tarix • fan • madaniyat',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sayohatni boshlash →',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ── Section sarlavha ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(
            fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: GoogleFonts.nunito(
              fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w600)),
        ]),
      ),
      Text('Barchasi', style: GoogleFonts.nunito(
        fontSize: 12, color: const Color(0xFF5C6BC0),
        fontWeight: FontWeight.w700)),
    ]),
  );

  // ── Pastki menyu ────────────────────────────────────────────────────────────
  Widget _bottomMenu() => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, 4)),
      ],
    ),
    child: Row(children: [
      _menuBtn('🏙️', 'Shahar',     () => context.push(AppRoutes.city,
        extra: {'profile': _p, 'onUpdate': widget.onUpdate}), 0),
      _menuBtn('🎯', 'Missiyalar', () => context.push(AppRoutes.missions, extra: _p), 1),
      _menuBtn('📊', 'Statistika', () => context.push(AppRoutes.stats,
        extra: {'profile': _p}), 2),
      _menuBtn('⚙️', 'Sozlamalar', () => context.push(AppRoutes.settings,
        extra: {'profile': _p, 'onUpdate': widget.onUpdate}), 3),
    ]),
  );

  Widget _menuBtn(String emoji, String label, VoidCallback onTap, int idx) =>
    Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.nunito(
              fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w700)),
          ]),
        ).animate(delay: (500 + idx * 50).ms).fadeIn().slideY(begin: 0.3),
      ),
    );
}

typedef HomeScreen = HomeScreenV2;
