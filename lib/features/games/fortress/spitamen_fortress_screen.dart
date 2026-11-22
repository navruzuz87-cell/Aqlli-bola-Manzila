import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

// ── Tarix savollari ──────────────────────────────────────────────────────────
class _HistoryQ {
  final String question;
  final List<String> choices;
  final int correct; // indeks

  const _HistoryQ({
    required this.question,
    required this.choices,
    required this.correct,
  });
}

const _questions = <_HistoryQ>[
  _HistoryQ(
    question: 'Spitamen kimga qarshi kurashgan?',
    choices: ['Iskandar Zulqarnayn', 'Chingizxon', 'Temur', 'Doro'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Amir Temur qaysi shaharda tug\'ilgan?',
    choices: ['Shahrisabz', 'Samarqand', 'Buxoro', 'Xiva'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Ulug\'bek rasadxonasi qayerda qurilgan?',
    choices: ['Samarqand', 'Buxoro', 'Toshkent', 'Urganch'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Alpomish qaysi xalqning eposi?',
    choices: ['O\'zbek', 'Qozoq', 'Tojik', 'Qirg\'iz'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'O\'zbekiston mustaqilligini qachon e\'lon qildi?',
    choices: ['1991', '1990', '1992', '1989'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Ipak yo\'li qaysi davlatlarni bog\'lagan?',
    choices: ['Xitoy va Rim', 'Hindiston va Misr', 'Eron va Gretsiya', 'Arabiston va Yevropa'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Ibn Sino qaysi soha olimi edi?',
    choices: ['Tibbiyot va falsafa', 'Astronomiya', 'Matematika', 'Tarix'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Temuriylar davlatining poytaxti qayer edi?',
    choices: ['Samarqand', 'Buxoro', 'Hirot', 'Toshkent'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Al-Xorazmiy nimani ixtiro qilgan?',
    choices: ['Algebra', 'Teleskop', 'Kompas', 'Kitob bosish'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Qadimgi Xorazm davlati qayerda joylashgan?',
    choices: ['Amudaryo havzasi', 'Sirdaryo havzasi', 'Farg\'ona vodiysi', 'Zarafshon vodiysi'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Bibixonim masjidi kim tomonidan qurilgan?',
    choices: ['Amir Temur', 'Ulug\'bek', 'Baburiy', 'Shayboniy'],
    correct: 0,
  ),
  _HistoryQ(
    question: 'Navoiy qaysi tilda ijod qilgan?',
    choices: ['O\'zbek (Chig\'atoy)', 'Fors', 'Arab', 'Turkiy'],
    correct: 0,
  ),
];

// ── Dushman modeli ────────────────────────────────────────────────────────────
class _Enemy {
  double x;        // 0.0 → 1.0 (ekran eni bo'yicha)
  double speed;
  bool defeated;
  int wave;

  _Enemy({required this.x, required this.speed, required this.wave})
      : defeated = false;
}

// ═════════════════════════════════════════════════════════════════════════════
class SpitamenFortressScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const SpitamenFortressScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<SpitamenFortressScreen> createState() => _SpitamenFortressScreenState();
}

class _SpitamenFortressScreenState extends State<SpitamenFortressScreen>
    with TickerProviderStateMixin {
  static const int _totalWaves = 10;

  final _rng = Random();
  late List<_HistoryQ> _shuffled;
  int _waveIdx = 0;
  late _HistoryQ _question;
  int _score = 0;
  int _fortressHP = 3;   // qal'a hayoti
  bool _answered = false;
  int? _selectedChoice;
  bool _showVictory = false;
  bool _shieldActive = false;   // to'g'ri javobdan keyin himoya
  List<_Enemy> _enemies = [];

  late AnimationController _enemyCtrl;   // dushmanlar harakati
  late AnimationController _swordCtrl;   // Spitamen qilich zarbi
  late AnimationController _hitCtrl;     // zarb effekti
  late AnimationController _shakeCtrl;   // qal'a silkitish
  late AnimationController _flagCtrl;    // bayroq hilpirash

  double _swordX = 0.5;
  bool _striking = false;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_questions)..shuffle(_rng);
    _question = _shuffled[_waveIdx % _shuffled.length];
    _spawnEnemies();

    _enemyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_tickEnemies)..repeat();

    _swordCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _hitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _enemyCtrl.dispose();
    _swordCtrl.dispose();
    _hitCtrl.dispose();
    _shakeCtrl.dispose();
    _flagCtrl.dispose();
    super.dispose();
  }

  void _spawnEnemies() {
    final count = 2 + (_waveIdx ~/ 2).clamp(0, 4);
    _enemies = List.generate(count, (i) => _Enemy(
      x: 0.05 + i * (0.85 / count),
      speed: 0.0008 + _waveIdx * 0.00006,
      wave: _waveIdx,
    ));
  }

  void _tickEnemies() {
    if (_answered || _showVictory) return;
    bool reached = false;
    setState(() {
      for (final e in _enemies) {
        if (!e.defeated) {
          e.x -= e.speed;
          if (e.x < 0.08) {
            e.defeated = true;
            reached = true;
          }
        }
      }
    });
    if (reached) {
      _fortressHP--;
      _shakeCtrl.forward(from: 0);
      if (_fortressHP <= 0) {
        _enemyCtrl.stop();
        Future.delayed(300.ms, _finish);
      }
    }
  }

  void _answer(int idx) async {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedChoice = idx;
    });

    if (idx == _question.correct) {
      // To'g'ri — Spitamen barcha dushmanlarni urib tushuradi
      _score++;
      setState(() { _shieldActive = true; _striking = true; });
      _swordCtrl.forward(from: 0);
      _hitCtrl.forward(from: 0);
      await Future.delayed(600.ms);
      setState(() {
        for (final e in _enemies) e.defeated = true;
      });
      await Future.delayed(500.ms);
    } else {
      // Noto'g'ri — qal'a zaif bo'lib qoladi
      _fortressHP = (_fortressHP - 1).clamp(0, 3);
      _shakeCtrl.forward(from: 0);
      await Future.delayed(600.ms);
    }

    _nextWave();
  }

  void _nextWave() {
    if (_waveIdx + 1 >= _totalWaves || _fortressHP <= 0) {
      _finish();
      return;
    }
    setState(() {
      _waveIdx++;
      _answered = false;
      _selectedChoice = null;
      _shieldActive = false;
      _striking = false;
      _question = _shuffled[_waveIdx % _shuffled.length];
      _spawnEnemies();
    });
    _swordCtrl.reset();
    _hitCtrl.reset();
  }

  void _finish() {
    _enemyCtrl.stop();
    final starsEarned = _score >= 9 ? 3 : _score >= 6 ? 2 : _score >= 4 ? 1 : 0;
    final subStars = Map<String, int>.from(widget.profile.subjectStars);
    final prev = subStars['tarix'] ?? 0;
    if (starsEarned > prev) subStars['tarix'] = starsEarned;

    final updated = widget.profile.copyWith(
      stars: widget.profile.stars + starsEarned,
      subjectStars: subStars,
    );
    widget.onUpdate?.call(updated);
    setState(() => _showVictory = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBg(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBattleField()),
                _buildQuestion(),
                const SizedBox(height: 10),
                _buildChoices(),
                const SizedBox(height: 14),
              ],
            ),
          ),
          if (_showVictory)
            VictoryOverlay(
              score: _score,
              maxScore: _totalWaves,
              message: _fortressHP > 0
                  ? (_score >= 8
                      ? 'Spitamen g\'alaba qildi! 🏆'
                      : 'Qal\'a himoyalandi! 🛡️')
                  : 'Qal\'a qulab tushdi... 💪 Keyingi safar!',
              onContinue: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0A00),
            Color(0xFF3E1F00),
            Color(0xFF5D3A00),
            Color(0xFF4E342E),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              '⚔️ Spitamen Qal\'asi',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Qal'a hayoti
          Row(
            children: List.generate(3, (i) => Text(
              i < _fortressHP ? '🏯' : '💔',
              style: const TextStyle(fontSize: 18),
            )),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Text(
              '⭐ $_score',
              style: GoogleFonts.nunito(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildBattleField() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _swordCtrl, _hitCtrl, _shakeCtrl, _flagCtrl, _enemyCtrl,
      ]),
      builder: (_, __) {
        final shake = _shakeCtrl.isAnimating
            ? sin(_shakeCtrl.value * pi * 6) * 5 * (1 - _shakeCtrl.value)
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: LayoutBuilder(builder: (ctx, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            return CustomPaint(
              size: Size(w, h),
              painter: _FortressPainter(
                enemies: _enemies,
                swordProgress: _swordCtrl.value,
                hitProgress: _hitCtrl.value,
                flagWave: _flagCtrl.value,
                fortressHP: _fortressHP,
                shieldActive: _shieldActive,
                striking: _striking,
                wave: _waveIdx,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildQuestion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('📜', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _question.question,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          Text(
            '${_waveIdx + 1}/$_totalWaves',
            style: GoogleFonts.nunito(
              color: Colors.amber.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.6,
        children: _question.choices.asMap().entries.map((e) {
          final idx = e.key;
          final text = e.value;
          final isCorrect = idx == _question.correct;
          final isSelected = _selectedChoice == idx;

          Color bg = Colors.white.withOpacity(0.08);
          Color border = Colors.white24;
          if (_answered && isSelected) {
            bg = isCorrect
                ? Colors.green.withOpacity(0.35)
                : Colors.red.withOpacity(0.3);
            border = isCorrect ? Colors.greenAccent : Colors.redAccent;
          } else if (_answered && isCorrect) {
            bg = Colors.green.withOpacity(0.18);
            border = Colors.greenAccent.withOpacity(0.4);
          }

          return GestureDetector(
            onTap: () => _answer(idx),
            child: AnimatedContainer(
              duration: 200.ms,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 1.5),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ).animate(delay: (idx * 60).ms)
            .slideY(begin: 0.3, curve: Curves.easeOut, duration: 250.ms);
        }).toList(),
      ),
    );
  }
}

// ── Maydon CustomPainter ──────────────────────────────────────────────────────
class _FortressPainter extends CustomPainter {
  final List<_Enemy> enemies;
  final double swordProgress;
  final double hitProgress;
  final double flagWave;
  final int fortressHP;
  final bool shieldActive;
  final bool striking;
  final int wave;

  _FortressPainter({
    required this.enemies,
    required this.swordProgress,
    required this.hitProgress,
    required this.flagWave,
    required this.fortressHP,
    required this.shieldActive,
    required this.striking,
    required this.wave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Yer ──
    final groundPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), groundPaint);

    // Yer chizig'i
    final linePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, h * 0.65), Offset(w, h * 0.65), linePaint);

    // ── Qal'a (o'ng tomon) ──
    _drawFortress(canvas, w, h);

    // ── Dushmanlar ──
    for (final e in enemies) {
      if (!e.defeated) {
        _drawEnemy(canvas, e.x * w, h * 0.58, wave);
      } else if (hitProgress > 0 && striking) {
        _drawDefeated(canvas, e.x * w, h * 0.55, hitProgress);
      }
    }

    // ── Spitamen ──
    _drawSpitamen(canvas, w * 0.14, h * 0.60, swordProgress, striking, shieldActive);

    // ── To'lqin ko'rsatkichi ──
    _drawWaveIndicator(canvas, w, h);
  }

  void _drawFortress(Canvas canvas, double w, double h) {
    final wallPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    final darkPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.fill;

    // Asosiy devor
    canvas.drawRect(
      Rect.fromLTWH(w * 0.75, h * 0.3, w * 0.25, h * 0.4),
      wallPaint,
    );

    // Minora
    canvas.drawRect(
      Rect.fromLTWH(w * 0.78, h * 0.15, w * 0.08, h * 0.25),
      darkPaint,
    );

    // Devor tishlari (krenellar)
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(w * (0.75 + i * 0.055), h * 0.26, w * 0.035, h * 0.06),
        darkPaint,
      );
    }

    // Minora tishlari
    for (int i = 0; i < 2; i++) {
      canvas.drawRect(
        Rect.fromLTWH(w * (0.785 + i * 0.03), h * 0.11, w * 0.02, h * 0.05),
        darkPaint,
      );
    }

    // Darcha
    final windowPaint = Paint()
      ..color = const Color(0xFFFFA000).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.80, h * 0.21, w * 0.025, h * 0.04),
      windowPaint,
    );

    // Bayroq
    final flagPole = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2;
    final poleTop = Offset(w * 0.826, h * 0.08);
    final poleBot = Offset(w * 0.826, h * 0.16);
    canvas.drawLine(poleTop, poleBot, flagPole);

    // Bayroq matosi
    final flagBend = sin(flagWave * pi) * 6;
    final flagPath = Path()
      ..moveTo(poleTop.dx, poleTop.dy)
      ..quadraticBezierTo(
        poleTop.dx + 16 + flagBend,
        poleTop.dy + 5,
        poleTop.dx + 20,
        poleTop.dy + 10,
      )
      ..lineTo(poleTop.dx, poleTop.dy + 10)
      ..close();
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = fortressHP > 1 ? const Color(0xFF1565C0) : Colors.red
        ..style = PaintingStyle.fill,
    );

    // Qal'a hayoti ko'rsatkichi
    for (int i = 0; i < 3; i++) {
      final hpPaint = Paint()
        ..color = i < fortressHP ? const Color(0xFF4CAF50) : const Color(0xFF37474F)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * (0.80 + i * 0.04), h * 0.52), 5, hpPaint);
    }

    // Himoya qalqoni
    if (shieldActive) {
      final shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.87, h * 0.42),
          width: w * 0.28,
          height: h * 0.4,
        ),
        shieldPaint,
      );
    }
  }

  void _drawEnemy(Canvas canvas, double x, double y, int wave) {
    final bodyColor = wave < 3
        ? const Color(0xFFE53935)
        : wave < 6
            ? const Color(0xFFB71C1C)
            : const Color(0xFF880E4F);

    // Gavda
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 22, height: 28),
      bodyPaint,
    );
    // Bosh
    canvas.drawCircle(
      Offset(x, y - 20),
      11,
      bodyPaint..color = bodyColor.withRed(255),
    );
    // Ko'z
    canvas.drawCircle(Offset(x - 3, y - 21), 2, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(x + 3, y - 21), 2, Paint()..color = Colors.black);
    // Qilich
    final swordPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x + 11, y - 10), Offset(x + 24, y - 24), swordPaint);
    // Qalqon
    if (wave >= 4) {
      final shPaint = Paint()
        ..color = Colors.brown.shade600
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 14, y - 8), width: 14, height: 18),
        shPaint,
      );
    }
  }

  void _drawDefeated(Canvas canvas, double x, double y, double progress) {
    if (progress > 0.6) return;
    final sparkPaint = Paint()
      ..color = Colors.orange.withOpacity(1 - progress * 1.5)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final r = 20.0 * progress;
      canvas.drawCircle(
        Offset(x + r * cos(angle), y + r * sin(angle)),
        3 * (1 - progress),
        sparkPaint,
      );
    }
  }

  void _drawSpitamen(
    Canvas canvas, double x, double y,
    double swordProg, bool strike, bool shield,
  ) {
    // Himoya qalqoni
    if (shield) {
      canvas.drawCircle(
        Offset(x, y - 15),
        30,
        Paint()
          ..color = Colors.amber.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // Kaftan (ko'k)
    final kaftanPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y - 12), width: 22, height: 34),
        const Radius.circular(5),
      ),
      kaftanPaint,
    );

    // Bosh
    canvas.drawCircle(
      Offset(x, y - 36),
      13,
      Paint()
        ..color = const Color(0xFFFFCC80)
        ..style = PaintingStyle.fill,
    );

    // Do'ppi
    final hatPath = Path()
      ..moveTo(x - 11, y - 46)
      ..lineTo(x, y - 60)
      ..lineTo(x + 11, y - 46)
      ..close();
    canvas.drawPath(
      hatPath,
      Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.fill,
    );

    // Mo'ylov
    canvas.drawLine(
      Offset(x - 7, y - 33),
      Offset(x + 7, y - 33),
      Paint()
        ..color = Colors.brown.shade800
        ..strokeWidth = 2,
    );

    // Qilich zarbi animatsiyasi
    final angle = strike
        ? -pi / 4 + swordProg * pi * 0.8
        : -pi / 6;
    canvas.save();
    canvas.translate(x + 10, y - 25);
    canvas.rotate(angle);
    // Qilich dastasi
    canvas.drawRect(
      const Rect.fromLTWH(-2, -4, 6, 10),
      Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.fill,
    );
    // Qilich tigi
    final bladePaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(1, 6),
      Offset(1 + (strike ? swordProg * 10 : 0), 36),
      bladePaint,
    );
    canvas.restore();

    // Spitamen yozuvi
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Spitamen',
        style: TextStyle(
          color: Color(0xFFFFE082),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - 24, y + 10));
  }

  void _drawWaveIndicator(Canvas canvas, double w, double h) {
    // Tepadagi "X. to'lqin" matni
    final tp = TextPainter(
      text: TextSpan(
        text: '⚔️ To\'lqin ${wave + 1}',
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.02));
  }

  @override
  bool shouldRepaint(_FortressPainter old) =>
      old.swordProgress != swordProgress ||
      old.hitProgress != hitProgress ||
      old.flagWave != flagWave ||
      old.fortressHP != fortressHP ||
      old.shieldActive != shieldActive ||
      old.striking != striking;
}
