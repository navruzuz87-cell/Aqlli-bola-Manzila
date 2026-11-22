import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/user_profile.dart';
import '../../core/services/game_stats_service.dart';

class StatsScreen extends StatefulWidget {
  final UserProfile profile;
  const StatsScreen({super.key, required this.profile});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _svc = GameStatsService.instance;
  String get _pid => widget.profile.id; // barqaror va yagona profil identifikatori

  static const _games = [
    ('archery',  '🏹', 'Alpomish Kamoni'),
    ('wordle',   '📦', 'Zumrad Sandiq'),
    ('semurg',   '🦅', "Semurg' Parvozi"),
    ('fortress', '🏰', "Spitamen Qal'asi"),
    ('donkey',   '🫏', 'Susambildagi Eshak'),
    ('susambil', '💧', 'Susambil: Yo‘qolgan buloq'),
    ('geomap',   '🗺️', 'Rustam Maydon'),
    ('math_blocks', '🔢', 'Matematik bloklar'),
    ('alpomish_runner', '🏃', 'Alpomish Runner'),
  ];

  static const _subjects = {
    'matematika': ('Matematika', '🔢', Color(0xFF1565C0)),
    'ona_tili':   ('Ona tili',   '📖', Color(0xFF2E7D32)),
    'ingliz':     ('Ingliz',     '🌍', Color(0xFF6A1B9A)),
    'tarix':      ('Tarix',      '🏛️', Color(0xFF4E342E)),
    'odobnoma':   ('Odobnoma',   '🌸', Color(0xFFAD1457)),
    'geo':        ('Geografiya', '🗺️', Color(0xFF00695C)),
    'Aralash fanlar': ('Aralash fanlar', '💧', Color(0xFF0288D1)),
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _svc.init(_pid, legacyProfileId: widget.profile.name);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _svc,
            builder: (_, __) => Column(
              children: [
                _topBar(),
                _summaryRow(),
                _weekChart(),
                _tabBar(),
                Expanded(child: _tabView()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 12),
      Text('📊 Statistika',
          style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
      const Spacer(),
      Text(widget.profile.avatarEmoji, style: const TextStyle(fontSize: 28)),
    ]).animate().fadeIn().slideX(begin: -0.2, end: 0),
  );

  Widget _summaryRow() {
    final all = _svc.resultsFor(_pid);
    final totalGames = all.length;
    final totalStars = all.fold(0, (s, r) => s + r.stars);
    final totalMins = all.fold(0, (s, r) => s + r.durationSeconds) ~/ 60;
    final avg3 = all.where((r) => r.stars == 3).length;

    final items = [
      ('🎮', '$totalGames', "O'yin"),
      ('⭐', '$totalStars', 'Yulduz'),
      ('⏱️', '${totalMins}m', 'Vaqt'),
      ('💎', '$avg3', 'Mukammal'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: items.asMap().entries.map((e) {
          final i = e.key; final item = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(children: [
                Text(item.$1, style: const TextStyle(fontSize: 20)),
                Text(item.$2, style: GoogleFonts.nunito(fontSize: 18,
                    fontWeight: FontWeight.w900, color: const Color(0xFFFFD54F))),
                Text(item.$3, style: GoogleFonts.nunito(fontSize: 10, color: Colors.white54)),
              ]),
            ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.3, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _weekChart() {
    final weekly = _svc.weeklyGames(_pid);
    final maxVal = weekly.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7 kunlik faollik',
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white70)),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final d = now.subtract(Duration(days: 6 - i));
                  final isToday = i == 6;
                  final pct = weekly[i] / maxVal;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (weekly[i] > 0)
                            Text('${weekly[i]}',
                                style: GoogleFonts.nunito(fontSize: 9,
                                    color: Colors.white60)),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              height: (50 * pct).clamp(4.0, 50.0),
                              color: isToday
                                  ? const Color(0xFFFFD54F)
                                  : weekly[i] > 0
                                      ? const Color(0xFF42A5F5).withOpacity(0.7)
                                      : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(days[d.weekday % 7],
                              style: GoogleFonts.nunito(fontSize: 10,
                                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                  color: isToday ? const Color(0xFFFFD54F) : Colors.white38)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _tabBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: const Color(0xFFFFD54F),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: const Color(0xFF1A237E),
        unselectedLabelColor: Colors.white70,
        labelStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "🎮  O'yinlar", height: 36),
          Tab(text: '📚  Fanlar', height: 36),
        ],
      ),
    ),
  );

  Widget _tabView() => TabBarView(
    controller: _tab,
    children: [_gamesTab(), _subjectsTab()],
  );

  // ── O'yinlar bo'yicha ─────────────────────────────────────────────────────
  Widget _gamesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: _games.asMap().entries.map((e) {
        final i = e.key;
        final g = e.value;
        final count = _svc.playCount(_pid, g.$1);
        final best = _svc.bestScore(_pid, g.$1);
        final avg = _svc.avgStars(_pid, g.$1);
        final recent = _svc.resultsFor(_pid, gameId: g.$1).take(3).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(count > 0 ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(g.$2, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g.$3, style: GoogleFonts.nunito(fontSize: 15,
                      fontWeight: FontWeight.w800, color: Colors.white)),
                  Row(children: [
                    Text('$count marta', style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.white54)),
                    if (best > 0) ...[
                      Text('  •  ', style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.white30)),
                      Text('Eng yuqori: $best', style: GoogleFonts.nunito(
                          fontSize: 11, color: const Color(0xFFFFD54F))),
                    ],
                  ]),
                ]),
              ),
              // Yulduz rating
              Row(children: List.generate(3, (si) => Icon(
                si < avg.round() ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFD54F), size: 18,
              ))),
            ]),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text("So'nggi natijalar:",
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 4),
              Row(children: recent.map((r) => Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r.stars == 3
                      ? const Color(0xFFFFD54F).withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${'⭐' * r.stars}${r.stars == 0 ? '—' : ''}  ${r.score}/${r.maxScore}',
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70),
                ),
              )).toList()),
            ],
          ]),
        ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  // ── Fanlar bo'yicha ───────────────────────────────────────────────────────
  Widget _subjectsTab() {
    final starMap = _svc.subjectStarMap(_pid);
    final maxStars = starMap.values.fold(1, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: _subjects.entries.toList().asMap().entries.map((e) {
        final i = e.key;
        final key = e.value.key;
        final (name, emoji, color) = e.value.value;
        final stars = starMap[key] ?? 0;
        final pct = stars / maxStars;
        final results = _svc.resultsFor(_pid, subject: key);
        final plays = results.length;
        final bestStars = plays > 0
            ? results.map((r) => r.stars).reduce((a, b) => a > b ? a : b)
            : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(plays > 0 ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.nunito(fontSize: 15,
                    fontWeight: FontWeight.w800, color: Colors.white)),
                Text(plays > 0
                    ? '$plays o\'yin  •  Eng yuqori: $bestStars ⭐'
                    : 'Hali o\'ynalmadi',
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.white54)),
              ])),
              Text('$stars ⭐', style: GoogleFonts.nunito(fontSize: 15,
                  fontWeight: FontWeight.w800, color: const Color(0xFFFFD54F))),
            ]),
            if (plays > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 7,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ]),
        ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}
