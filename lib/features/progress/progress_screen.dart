import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/user_profile.dart';

// ── Fan ma'lumotlari ──────────────────────────────────────────────────────────
class _SubjectInfo {
  final String key;
  final String name;
  final String emoji;
  final Color color;
  const _SubjectInfo(this.key, this.name, this.emoji, this.color);
}

const _subjects = [
  _SubjectInfo('matematika', 'Matematika',  '🔢', Color(0xFF1565C0)),
  _SubjectInfo('ona_tili',   'Ona tili',    '🏰', Color(0xFF6A1B9A)),
  _SubjectInfo('geo',        'Geografiya',  '🗺️', Color(0xFF2E7D32)),
  _SubjectInfo('tarix',      'Tarix',       '⏰', Color(0xFFB71C1C)),
  _SubjectInfo('ingliz',     'Ingliz tili', '🇬🇧', Color(0xFF00695C)),
  _SubjectInfo('odobnoma',   'Odobnoma',    '🤝', Color(0xFFE65100)),
];

// ── CustomPainter: Radar diagramma ───────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final List<double> values; // 0.0 – 1.0, 6 ta
  final List<Color> colors;

  const _RadarPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    const sides = 6;
    final angleStep = (2 * pi) / sides;
    const startAngle = -pi / 2;

    // Fon to'r chiziqlari
    for (int ring = 1; ring <= 5; ring++) {
      final r = radius * ring / 5;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // O'q chiziqlari
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + i * angleStep;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1;
      canvas.drawLine(center,
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        paint);
    }

    // Ma'lumot sohasi
    final dataPath = Path();
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * values[i].clamp(0.0, 1.0);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) dataPath.moveTo(x, y); else dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(dataPath, Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.25)
      ..style = PaintingStyle.fill);
    canvas.drawPath(dataPath, Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);

    // Nuqtalar
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * values[i].clamp(0.0, 1.0);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 5,
        Paint()..color = colors[i]..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 5,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.values != values;
}

// ── Ekran ─────────────────────────────────────────────────────────────────────
class ProgressScreen extends StatelessWidget {
  final UserProfile profile;
  const ProgressScreen({super.key, required this.profile});

  int get _totalStars => profile.stars;
  int get _streak     => profile.dailyStreakDays;
  int get _minutes    => profile.totalPlayMinutes;

  List<double> get _radarValues {
    final vals = _subjects.map((s) =>
        (profile.subjectStars[s.key] ?? 0).toDouble()).toList();
    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final m = maxVal < 1 ? 1.0 : maxVal;
    return vals.map((v) => (v / m).clamp(0.05, 1.0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _buildHeroStats(),
                  const SizedBox(height: 20),
                  _buildRadarChart(),
                  const SizedBox(height: 20),
                  _buildSubjectBars(),
                  const SizedBox(height: 20),
                  _buildStreakCard(),
                  const SizedBox(height: 20),
                  _buildLevelCard(),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            '📊 Mening Progressim',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF8F00), Color(0xFFFFCA28)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Daraja ${profile.playerLevel}',
            style: GoogleFonts.nunito(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeroStats() {
    final entries = [
      ('⭐', _totalStars.toString(), 'Jami yulduz'),
      ('🔥', _streak.toString(), 'Kun streak'),
      ('⏱️', _minutes > 60
          ? '${(_minutes / 60).toStringAsFixed(1)}s'
          : '${_minutes}d', "O'ynalgan"),
    ];
    return Row(
      children: List.generate(entries.length, (i) {
        final s = entries[i];
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(children: [
              Text(s.$1, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(s.$2,
                style: GoogleFonts.nunito(
                  color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w900)),
              Text(s.$3,
                style: GoogleFonts.nunito(
                  color: Colors.white54, fontSize: 11)),
            ]),
          ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.3),
        );
      }),
    );
  }

  Widget _buildRadarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: [
        Text('🕸️ Fan Balansi',
          style: GoogleFonts.nunito(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 8),
        // Radar + emoji labellar LayoutBuilder bilan
        LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          const h = 240.0;
          const sides = 6;
          final angleStep = (2 * pi) / sides;
          const startAngle = -pi / 2;
          final radius = min(w, h) / 2 - 20;
          final cx = w / 2;
          const cy = h / 2;

          return SizedBox(
            height: h,
            child: Stack(children: [
              // Radar painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _RadarPainter(
                    values: _radarValues,
                    colors: _subjects.map((s) => s.color).toList(),
                  ),
                ),
              ),
              // Emoji + yulduz labellar
              ...List.generate(sides, (i) {
                final angle = startAngle + i * angleStep;
                // Label radiusi — doira tashqarisida
                final lr = radius + 22;
                final x = cx + lr * cos(angle);
                final y = cy + lr * sin(angle);
                final stars = profile.subjectStars[_subjects[i].key] ?? 0;
                return Positioned(
                  left: x - 22,
                  top:  y - 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_subjects[i].emoji,
                        style: const TextStyle(fontSize: 14)),
                      Text('$stars⭐',
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                );
              }),
            ]),
          );
        }),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: _subjects.map((s) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8,
                decoration: BoxDecoration(
                  color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 3),
              Text(s.name,
                style: GoogleFonts.nunito(
                  color: Colors.white60, fontSize: 10)),
            ],
          )).toList(),
        ),
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSubjectBars() {
    final vals = _subjects.map((s) =>
        profile.subjectStars[s.key] ?? 0).toList();
    final maxVal = vals.isEmpty ? 1 : vals.reduce((a, b) => a > b ? a : b);
    final m = maxVal < 1 ? 1 : maxVal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📚 Fanlar bo'yicha yulduzlar",
            style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          ...List.generate(_subjects.length, (i) {
            final s = _subjects[i];
            final stars = vals[i];
            final pct = stars / m;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Text(s.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.name,
                            style: GoogleFonts.nunito(
                              color: Colors.white70, fontSize: 12)),
                          Text('$stars ⭐',
                            style: GoogleFonts.nunito(
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct.toDouble(),
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(s.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ]).animate().fadeIn(delay: (i * 60).ms).slideX(begin: -0.2),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildStreakCard() {
    final streakPct = (_streak / 30).clamp(0.0, 1.0);
    final streakEmoji = _streak == 0 ? '😴'
        : _streak < 3  ? '🌱'
        : _streak < 7  ? '🔥'
        : _streak < 14 ? '⚡'
        : _streak < 30 ? '🏆'
        : '👑';
    final streakMsg = _streak == 0
        ? "Bugun o'yna va streakni boshlа!"
        : _streak < 7
            ? "7 kunga yetish uchun ${7 - _streak} kun qoldi"
            : _streak < 30
                ? "30 kunga yetish uchun ${30 - _streak} kun qoldi"
                : 'Ajoyib! Oylik rekord!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade900.withOpacity(0.6),
            Colors.deepOrange.shade900.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(children: [
        Text(streakEmoji, style: const TextStyle(fontSize: 44)),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_streak kun streak!',
              style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 4),
            Text(streakMsg,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: streakPct,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          ],
        )),
      ]),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildLevelCard() {
    final level = profile.playerLevel;
    const levelEmojis = [
      '', '🌱', '📖', '✏️', '🧪', '🔬', '🎓', '🏅', '🥈', '🥇', '👑'
    ];
    const levelTitles = [
      '', "Yangi boshlovchi", 'Qiziquvchi', 'Bilimli', 'Faol',
      'Aqlli', "Iste'dodli", 'Muvaffaqiyatli', 'Usta', 'Ekspert', 'Champion'
    ];
    final emoji = level <= 10 ? levelEmojis[level] : '👑';
    final title = level <= 10 ? levelTitles[level] : 'Champion';
    final completedSubjects = _subjects
        .where((s) => (profile.subjectStars[s.key] ?? 0) >= level * 10)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withOpacity(0.8),
            const Color(0xFF311B92).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.4)),
      ),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7C4DFF).withOpacity(0.3),
            border: Border.all(color: const Color(0xFF7C4DFF), width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daraja $level — $title',
              style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 4),
            Text('$completedSubjects / 6 fan maqsadiga yetildi',
              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completedSubjects / 6,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7C4DFF)),
              ),
            ),
          ],
        )),
      ]),
    ).animate().fadeIn(delay: 500.ms);
  }
}
