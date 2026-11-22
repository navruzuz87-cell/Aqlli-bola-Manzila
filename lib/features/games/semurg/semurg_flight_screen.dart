import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

// ── So'zlar lug'ati (inglizcha → o'zbekcha) ──────────────────────────────────
const _wordList = [
  ('SUN',    'QUYOSH'),
  ('MOON',   'OY'),
  ('STAR',   'YULDUZ'),
  ('BIRD',   'QUSH'),
  ('FISH',   'BALIQ'),
  ('TREE',   'DARAXT'),
  ('ROSE',   'ATIRGUL'),
  ('WIND',   'SHAMOL'),
  ('RAIN',   'YOMG'IR'),
  ('SNOW',   'QOR'),
  ('FIRE',   'OT'),
  ('LAKE',   'KOL'),
  ('HILL',   'TEPA'),
  ('FROG',   'BAQA'),
  ('WOLF',   'BORI'),
  ('BEAR',   'AYIQ'),
  ('LION',   'SHER'),
  ('DUCK',   'OT'),
  ('WORM',   'QO\'RT'),
  ('LEAF',   'BARG'),
  ('ROOT',   'ILDIZ'),
  ('SEED',   'URUGOCH'),
  ('GOLD',   'OLTIN'),
  ('SILK',   'IPAK'),
  ('KING',   'SHOH'),
  ('QUEEN',  'MALIKA'),
  ('BRAVE',  'JASUR'),
  ('SMART',  'AQLLI'),
  ('FAST',   'TEZKOR'),
  ('HIGH',   'BALAND'),
  ('APPLE',  'OLMA'),
  ('GRAPE',  'UZUM'),
  ('PEACH',  'SHAFTOLI'),
  ('HORSE',  'OT'),
  ('EAGLE',  'BURGUT'),
  ('CLOUD',  'BULUT'),
  ('RIVER',  'DARYO'),
  ('FIELD',  'DALA'),
  ('STONE',  'TOSH'),
  ('SWORD',  'QILICH'),
];

// ── O'yin holati ──────────────────────────────────────────────────────────────
class _Round {
  final String english;
  final String uzbek;
  final List<String> letters; // barcha o'zbek harflari aralash
  final Set<int> revealed;    // ochilgan indekslar

  _Round({
    required this.english,
    required this.uzbek,
    required this.letters,
  }) : revealed = {};

  bool get isComplete => revealed.length == uzbek.length;
}

// ═════════════════════════════════════════════════════════════════════════════
class SemurgFlightScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const SemurgFlightScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<SemurgFlightScreen> createState() => _SemurgFlightScreenState();
}

class _SemurgFlightScreenState extends State<SemurgFlightScreen>
    with TickerProviderStateMixin {
  static const int _totalRounds = 8;

  final _rng = Random();
  late List<(String, String)> _shuffled;
  int _roundIdx = 0;
  late _Round _current;
  int _score = 0;
  int _lives = 3;        // xato uchun
  bool _gameOver = false;
  bool _showVictory = false;
  int? _lastWrongIdx;

  // Semurg' balandligi: 0.0 = pastda, 1.0 = tepada
  double _height = 0.1;
  late AnimationController _flyCtrl;    // uchish animatsiyasi
  late AnimationController _wingCtrl;   // qanotlar
  late AnimationController _glowCtrl;   // parqiroq
  late AnimationController _wrongCtrl;  // xato silkitish

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_wordList)..shuffle(_rng);
    _flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _wingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _wrongCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadRound();
  }

  @override
  void dispose() {
    _flyCtrl.dispose();
    _wingCtrl.dispose();
    _glowCtrl.dispose();
    _wrongCtrl.dispose();
    super.dispose();
  }

  void _loadRound() {
    final pair = _shuffled[_roundIdx % _shuffled.length];
    final uzbek = pair.$2;

    // O'zbek harflari + yana 4-6 ta chalg'ituvchi harf
    final Set<String> extras = {};
    const pool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    while (extras.length < 5) {
      final ch = pool[_rng.nextInt(pool.length)];
      if (!uzbek.contains(ch)) extras.add(ch);
    }

    final letters = [...uzbek.split(''), ...extras]..shuffle(_rng);

    _current = _Round(english: pair.$1, uzbek: uzbek, letters: letters);
  }

  void _pickLetter(int idx) {
    if (_gameOver) return;
    final letter = _current.letters[idx];

    // Qolgan ochilmagan harflardan topamiz
    for (int i = 0; i < _current.uzbek.length; i++) {
      if (!_current.revealed.contains(i) && _current.uzbek[i] == letter) {
        setState(() {
          _current.revealed.add(i);
          _lastWrongIdx = null;
        });

        if (_current.isComplete) {
          _score++;
          _flyUp();
          Future.delayed(900.ms, _nextRound);
        }
        return;
      }
    }

    // Noto'g'ri harf
    setState(() {
      _lives--;
      _lastWrongIdx = idx;
    });
    _wrongCtrl.forward(from: 0);

    if (_lives <= 0) {
      Future.delayed(600.ms, _finish);
    }
  }

  void _flyUp() {
    final newH = (_height + 0.12).clamp(0.0, 0.92);
    setState(() => _height = newH);
  }

  void _nextRound() {
    if (_roundIdx + 1 >= _totalRounds) {
      _finish();
      return;
    }
    setState(() {
      _roundIdx++;
      _loadRound();
      _lastWrongIdx = null;
    });
  }

  void _finish() {
    final starsEarned = _score >= 7 ? 3 : _score >= 5 ? 2 : _score >= 3 ? 1 : 0;
    final subStars = Map<String, int>.from(widget.profile.subjectStars);
    final prev = subStars['ingliz'] ?? 0;
    if (starsEarned > prev) subStars['ingliz'] = starsEarned;

    final updated = widget.profile.copyWith(
      stars: widget.profile.stars + starsEarned,
      subjectStars: subStars,
    );
    widget.onUpdate?.call(updated);
    setState(() {
      _gameOver = true;
      _showVictory = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildSky(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildFlightArea()),
                _buildWordDisplay(),
                const SizedBox(height: 10),
                _buildLetterGrid(),
                const SizedBox(height: 14),
              ],
            ),
          ),
          if (_showVictory)
            VictoryOverlay(
              score: _score,
              maxScore: _totalRounds,
              message: _score >= 7
                  ? 'Semurg\' eng yuqoriga uchdi! 🦅'
                  : _score >= 4
                      ? 'Semurg\' baland uchdi! ✨'
                      : 'Semurg\' uchishni o\'rganmoqda! 💪',
              onContinue: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildSky() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFF0D1B2A),
              const Color(0xFF1565C0),
              _height,
            )!,
            Color.lerp(
              const Color(0xFF1B2838),
              const Color(0xFF42A5F5),
              _height,
            )!,
            Color.lerp(
              const Color(0xFF2C3E50),
              const Color(0xFF80DEEA),
              _height,
            )!,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              '🦅 Semurg\' Parvozi',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Jonlar
          Row(children: List.generate(3, (i) =>
            Text(
              i < _lives ? '❤️' : '🖤',
              style: const TextStyle(fontSize: 18),
            ),
          )),
          const SizedBox(width: 6),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Text(
              '⭐ $_score',
              style: GoogleFonts.nunito(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFlightArea() {
    return LayoutBuilder(builder: (ctx, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      final birdY = h * (1.0 - _height) - 50;

      return Stack(
        children: [
          // Bulutlar
          ..._buildClouds(w, h),

          // Balandlik ko'rsatkichi (chap taraf)
          Positioned(
            left: 14,
            top: 10,
            bottom: 10,
            width: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🏔️', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 1 - _height,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('🌿', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),

          // Semurg'
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            left: w * 0.38,
            top: birdY,
            child: AnimatedBuilder(
              animation: _wingCtrl,
              builder: (_, __) => CustomPaint(
                size: const Size(90, 70),
                painter: _SemurgPainter(
                  wingAngle: _wingCtrl.value,
                  glowValue: _glowCtrl.value,
                  isHigh: _height > 0.6,
                ),
              ),
            ),
          ),

          // Balandlik matni
          Positioned(
            right: 14,
            top: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(_height * 100).round()}%',
                  style: GoogleFonts.nunito(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                Text(
                  _height > 0.7
                      ? '🌟 Bulutlar ustida!'
                      : _height > 0.4
                          ? '⬆️ Baland uchmoqda'
                          : '🌱 Past uchmoqda',
                  style: GoogleFonts.nunito(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Round progress
          Positioned(
            bottom: 6,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalRounds, (i) => Container(
                width: 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _roundIdx
                      ? Colors.amber
                      : i == _roundIdx
                          ? Colors.white
                          : Colors.white24,
                ),
              )),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildClouds(double w, double h) {
    return [
      Positioned(
        left: w * 0.05,
        top: h * (0.1 + (1 - _height) * 0.1),
        child: AnimatedOpacity(
          duration: 500.ms,
          opacity: _height > 0.5 ? 1.0 : 0.3,
          child: const Text('☁️', style: TextStyle(fontSize: 36, color: Colors.white38)),
        ),
      ),
      Positioned(
        right: w * 0.08,
        top: h * (0.2 + (1 - _height) * 0.15),
        child: const Text('⛅', style: TextStyle(fontSize: 28, color: Colors.white24)),
      ),
      Positioned(
        left: w * 0.55,
        top: h * (0.05 + (1 - _height) * 0.05),
        child: AnimatedOpacity(
          duration: 500.ms,
          opacity: _height > 0.7 ? 1.0 : 0.2,
          child: const Text('☁️', style: TextStyle(fontSize: 24, color: Colors.white30)),
        ),
      ),
    ];
  }

  Widget _buildWordDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Ingliz so'z (sarlavha)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🇬🇧 ',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                _current.english,
                style: GoogleFonts.nunito(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '→ O\'zbekcha?',
                style: GoogleFonts.nunito(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // O'zbek so'z harflari (ochiluvchi)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_current.uzbek.length, (i) {
              final revealed = _current.revealed.contains(i);
              return AnimatedContainer(
                duration: 250.ms,
                width: 36,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: revealed
                      ? Colors.green.withOpacity(0.3)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: revealed ? Colors.greenAccent : Colors.white24,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: revealed
                    ? Text(
                        _current.uzbek[i],
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().scale(curve: Curves.elasticOut)
                    : Container(
                        width: 18,
                        height: 2,
                        color: Colors.white24,
                      ),
              );
            }),
          ),
          // Jarayon
          const SizedBox(height: 6),
          Text(
            '${_current.revealed.length} / ${_current.uzbek.length} harf  •  '
            '${_roundIdx + 1} / $_totalRounds so\'z',
            style: GoogleFonts.nunito(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterGrid() {
    return AnimatedBuilder(
      animation: _wrongCtrl,
      builder: (_, child) {
        final shake = sin(_wrongCtrl.value * pi * 5) * 6 * (1 - _wrongCtrl.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _current.letters.asMap().entries.map((e) {
            final idx = e.key;
            final letter = e.value;
            final isUsed = _current.revealed.length == _current.uzbek.length ||
                (_current.uzbek.contains(letter) &&
                    _countInString(_current.uzbek, letter) <=
                        _countRevealed(letter));
            final isWrong = idx == _lastWrongIdx;

            return GestureDetector(
              onTap: isUsed ? null : () => _pickLetter(idx),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUsed
                      ? Colors.white.withOpacity(0.04)
                      : isWrong
                          ? Colors.red.withOpacity(0.35)
                          : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isUsed
                        ? Colors.white12
                        : isWrong
                            ? Colors.redAccent
                            : Colors.white30,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: GoogleFonts.nunito(
                    color: isUsed ? Colors.white12 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _countInString(String s, String ch) =>
      s.split('').where((c) => c == ch).length;

  int _countRevealed(String ch) {
    int count = 0;
    for (final i in _current.revealed) {
      if (_current.uzbek[i] == ch) count++;
    }
    return count;
  }
}

// ── Semurg' qushi CustomPainter ───────────────────────────────────────────────
class _SemurgPainter extends CustomPainter {
  final double wingAngle;   // 0.0 → 1.0 (qanotlar harakati)
  final double glowValue;
  final bool isHigh;

  _SemurgPainter({
    required this.wingAngle,
    required this.glowValue,
    required this.isHigh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h * 0.55;

    // ── Parqiroq (baland bo'lsa oltin) ──
    if (isHigh) {
      final glowPaint = Paint()
        ..color = Colors.amber.withOpacity(0.15 + glowValue * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(cx, cy), 38, glowPaint);
    }

    // ── Qanotlar ──
    final wingLift = sin(wingAngle * pi) * 20;
    final wingColor = isHigh ? const Color(0xFFFFB300) : const Color(0xFF7E57C2);
    final wingPaint = Paint()
      ..color = wingColor
      ..style = PaintingStyle.fill;

    // Chap qanot
    final leftWing = Path()
      ..moveTo(cx - 4, cy)
      ..quadraticBezierTo(cx - 28, cy - 15 - wingLift, cx - 42, cy - 8 - wingLift)
      ..quadraticBezierTo(cx - 30, cy + 10, cx - 4, cy + 6)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    // O'ng qanot
    final rightWing = Path()
      ..moveTo(cx + 4, cy)
      ..quadraticBezierTo(cx + 28, cy - 15 - wingLift, cx + 42, cy - 8 - wingLift)
      ..quadraticBezierTo(cx + 30, cy + 10, cx + 4, cy + 6)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // ── Qanot qirralari ──
    final edgePaint = Paint()
      ..color = isHigh
          ? const Color(0xFFFFECB3)
          : Colors.purple.shade100.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(leftWing, edgePaint);
    canvas.drawPath(rightWing, edgePaint);

    // ── Tanasi ──
    final bodyPaint = Paint()
      ..color = isHigh ? const Color(0xFFFF8F00) : const Color(0xFF5E35B1)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 14),
      bodyPaint,
    );

    // ── Boshi ──
    final headPaint = Paint()
      ..color = isHigh ? const Color(0xFFFFB300) : const Color(0xFF7E57C2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 12), 8, headPaint);

    // ── Tumshug'i ──
    final beakPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.fill;
    final beakPath = Path()
      ..moveTo(cx + 7, cy - 13)
      ..lineTo(cx + 16, cy - 10)
      ..lineTo(cx + 7, cy - 8)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // ── Ko'zi ──
    canvas.drawCircle(Offset(cx + 3, cy - 13), 2,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 3, cy - 13), 1,
        Paint()..color = Colors.black);

    // ── Dumi ──
    final tailPaint = Paint()
      ..color = isHigh ? const Color(0xFFFFF176) : Colors.purple.shade200
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx - 3 + i * 1.5, cy + 7),
        Offset(cx - 5 + i * 3, cy + 20 + wingLift * 0.3),
        tailPaint,
      );
    }

    // ── Baland bo'lsa yulduzlar ──
    if (isHigh) {
      final sparkPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.7 + glowValue * 0.3)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 4; i++) {
        final angle = (i / 4) * 2 * pi + glowValue * pi;
        final r = 32.0 + sin(glowValue * pi + i) * 6;
        canvas.drawCircle(
          Offset(cx + r * cos(angle), cy + r * sin(angle)),
          2,
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SemurgPainter old) =>
      old.wingAngle != wingAngle ||
      old.glowValue != glowValue ||
      old.isHigh != isHigh;
}
