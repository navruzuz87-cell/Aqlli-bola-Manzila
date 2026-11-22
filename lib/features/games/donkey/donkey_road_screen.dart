import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

// ── Odobnoma sahnalari ────────────────────────────────────────────────────────
class _Scene {
  final String emoji;        // sahna rasmi
  final String situation;    // vaziyat matni
  final List<String> choices;
  final int correct;         // to'g'ri tanlov indeksi
  final String feedback;     // to'g'ri javobga izoh

  const _Scene({
    required this.emoji,
    required this.situation,
    required this.choices,
    required this.correct,
    required this.feedback,
  });
}

const _scenes = <_Scene>[
  _Scene(
    emoji: '🏫',
    situation: 'Do\'stingiz darsda yordam so\'ramoqda. Siz nima qilasiz?',
    choices: ['Javobni aytib beraman', 'O\'qituvchiga xabar qilaman'],
    correct: 0,
    feedback: 'Do\'stga yordam berish — ezgu xulq! Lekin o\'qituvchisiz ham bilishga o\'rgating.',
  ),
  _Scene(
    emoji: '🌳',
    situation: 'Ko\'chada axlat ko\'rdingiz. Atrofda hech kim yo\'q. Nima qilasiz?',
    choices: ['O\'tib ketaman', 'Axlatni yig\'ib tashlash joyiga qo\'yaman'],
    correct: 1,
    feedback: 'Muhitni saqlash — har birimizning vazifamiz! Ajoyib!',
  ),
  _Scene(
    emoji: '👴',
    situation: 'Avtobus to\'xtag\'ichida keksa odam turibdi, o\'rin yo\'q. Nima qilasiz?',
    choices: ['O\'rnimni beraman', 'Ko\'rmagan bo\'laman'],
    correct: 0,
    feedback: 'Kattalarni hurmat qilish — o\'zbek milliy qadriyati!',
  ),
  _Scene(
    emoji: '🍎',
    situation: 'Tanaffusda bir bola yolg\'iz o\'tiribdi, ovqati yo\'q. Siz nima qilasiz?',
    choices: ['Ovqatimni uning bilan bo\'lishaman', 'O\'zim yeyveraman'],
    correct: 0,
    feedback: 'Ulashish — do\'stlik va mehribonlik belgisi!',
  ),
  _Scene(
    emoji: '📱',
    situation: 'Dars paytida telefon jiringladi. Nima qilasiz?',
    choices: ['Javob beraman', 'Darhol o\'chiraman, keyin qaraman'],
    correct: 1,
    feedback: 'O\'qituvchini hurmat qilish — mas\'uliyatli o\'quvchi belgisi!',
  ),
  _Scene(
    emoji: '🤥',
    situation: 'Sinfdosh vazani sindirdi, lekin siz ko\'rdingiz. U yashirishga urindi. Siz nima qilasiz?',
    choices: ['Hech narsa demam', 'Sinfdoshni o\'qituvchiga tan olishga undayman'],
    correct: 1,
    feedback: 'Halollik eng qimmatli fazilatdir!',
  ),
  _Scene(
    emoji: '🌧️',
    situation: 'Yomg\'irda do\'stingizning kitoblari ho\'l bo\'lmoqchi. Sizda yagona soyabon bor.',
    choices: ['Birga kiramiz', 'Soyabonni o\'zim ushlayman'],
    correct: 0,
    feedback: 'Do\'stlik — qiyinchilikda yordam berish demak!',
  ),
  _Scene(
    emoji: '🎁',
    situation: 'Tug\'ilgan kuningizda hedya oldingiz, lekin do\'stingiz xafa ko\'rinyapti.',
    choices: ['Do\'stimni kuldirmoqqa harakat qilaman', 'Bayramimni o\'zim davom ettiraman'],
    correct: 0,
    feedback: 'Do\'stingizning his-tuyg\'ulariga e\'tibor berish — haqiqiy do\'stlik!',
  ),
  _Scene(
    emoji: '📚',
    situation: 'Kitobxonada boshqalar o\'qiyapti. Telefonda kulgili video ko\'rdingiz.',
    choices: ['Ovoz chiqarib kulaman', 'Quloqchin taqaman yoki chiqib ketaman'],
    correct: 1,
    feedback: 'Jamoat joylarida boshqalarga hurmat ko\'rsatish — madaniyat belgisi!',
  ),
  _Scene(
    emoji: '🐾',
    situation: 'Ko\'chada it yosh bolani qo\'rqitmoqda. Siz nima qilasiz?',
    choices: ['Itni quvib yuboraman, bolaga yordam beraman', 'Yuguraman'],
    correct: 0,
    feedback: 'Kuchsizlarga yordam — jasurlik va mehribonlik!',
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
class DonkeyRoadScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const DonkeyRoadScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<DonkeyRoadScreen> createState() => _DonkeyRoadScreenState();
}

class _DonkeyRoadScreenState extends State<DonkeyRoadScreen>
    with TickerProviderStateMixin {
  static const int _totalScenes = 10;

  final _rng = Random();
  late List<_Scene> _shuffled;
  int _sceneIdx = 0;
  int _score = 0;
  bool _answered = false;
  int? _selected;
  bool _showFeedback = false;
  bool _showVictory = false;

  // Eshak pozitsiyasi: 0.0 (start) → 1.0 (finish)
  double _donkeyPos = 0.0;
  bool _movingForward = false;
  bool _movingBack = false;
  String _donkeyMood = 'neutral'; // neutral | happy | sad

  late AnimationController _walkCtrl;   // eshak yurishi
  late AnimationController _bounceCtrl; // to'g'ri/noto'g'ri sakrash
  late AnimationController _starCtrl;   // yulduz effekti
  late AnimationController _cloudCtrl;  // bulutlar

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_scenes)..shuffle(_rng);

    _walkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _cloudCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _walkCtrl.dispose();
    _bounceCtrl.dispose();
    _starCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  _Scene get _current => _shuffled[_sceneIdx % _shuffled.length];

  void _choose(int idx) async {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selected = idx;
    });

    final isCorrect = idx == _current.correct;

    if (isCorrect) {
      _score++;
      setState(() {
        _movingForward = true;
        _donkeyMood = 'happy';
      });
      _bounceCtrl.forward(from: 0);
      _starCtrl.forward(from: 0);

      // Eshak oldinga yuradi
      final newPos = (_donkeyPos + (1.0 / _totalScenes)).clamp(0.0, 1.0);
      await Future.delayed(100.ms);
      setState(() => _donkeyPos = newPos);
      await Future.delayed(600.ms);

      setState(() {
        _showFeedback = true;
        _movingForward = false;
      });
    } else {
      setState(() {
        _movingBack = true;
        _donkeyMood = 'sad';
      });
      _bounceCtrl.forward(from: 0);

      // Eshak ozgina orqaga
      final newPos = (_donkeyPos - 0.03).clamp(0.0, 1.0);
      await Future.delayed(100.ms);
      setState(() => _donkeyPos = newPos);
      await Future.delayed(600.ms);

      setState(() {
        _showFeedback = true;
        _movingBack = false;
      });
    }

    // Feedback 1.5 soniyadan keyin keyingi sahnaga
    await Future.delayed(1500.ms);
    _nextScene();
  }

  void _nextScene() {
    if (_sceneIdx + 1 >= _totalScenes) {
      _finish();
      return;
    }
    setState(() {
      _sceneIdx++;
      _answered = false;
      _selected = null;
      _showFeedback = false;
      _donkeyMood = 'neutral';
    });
  }

  void _finish() {
    final starsEarned = _score >= 9 ? 3 : _score >= 7 ? 2 : _score >= 5 ? 1 : 0;
    final subStars = Map<String, int>.from(widget.profile.subjectStars);
    final prev = subStars['odobnoma'] ?? 0;
    if (starsEarned > prev) subStars['odobnoma'] = starsEarned;

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
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildRoadScene(),
                const SizedBox(height: 8),
                _buildSituationCard(),
                const SizedBox(height: 10),
                _buildChoiceButtons(),
                const SizedBox(height: 14),
              ],
            ),
          ),
          if (_showVictory)
            VictoryOverlay(
              score: _score,
              maxScore: _totalScenes,
              message: _score >= 9
                  ? 'Eshak Susambilga yetdi! 🎉'
                  : _score >= 6
                      ? 'Yaxshi yo\'l bosib o\'tdingiz! 🌟'
                      : 'Yana bir marta urinib ko\'ring! 💪',
              onContinue: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFF98D8C8),
            Color(0xFFB8E6B8),
            Color(0xFF8BC34A),
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
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
            icon: const Icon(Icons.close, color: Color(0xFF2E7D32)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              '🫏 Susambildagi Eshak',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: const Color(0xFF1B5E20),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_sceneIdx + 1}/$_totalScenes  ⭐$_score',
              style: GoogleFonts.nunito(
                color: const Color(0xFF1B5E20),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildRoadScene() {
    return SizedBox(
      height: 160,
      child: AnimatedBuilder(
        animation: Listenable.merge([_walkCtrl, _cloudCtrl, _starCtrl]),
        builder: (_, __) {
          return LayoutBuilder(builder: (ctx, box) {
            return CustomPaint(
              size: Size(box.maxWidth, 160),
              painter: _RoadPainter(
                donkeyPos: _donkeyPos,
                walkPhase: _walkCtrl.value,
                cloudOffset: _cloudCtrl.value,
                mood: _donkeyMood,
                starProgress: _starCtrl.value,
                score: _score,
                total: _totalScenes,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSituationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(_current.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _current.situation,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF1B5E20),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (_showFeedback) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selected == _current.correct
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selected == _current.correct
                      ? Colors.green.shade300
                      : Colors.orange.shade300,
                ),
              ),
              child: Text(
                (_selected == _current.correct ? '✅ ' : '💡 ') +
                    _current.feedback,
                style: GoogleFonts.nunito(
                  color: _selected == _current.correct
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _current.choices.asMap().entries.map((e) {
          final idx = e.key;
          final text = e.value;
          final isCorrect = idx == _current.correct;
          final isSelected = _selected == idx;

          Color bg;
          Color border;
          Color textColor;

          if (_answered && isSelected) {
            if (isCorrect) {
              bg = Colors.green.shade100;
              border = Colors.green.shade400;
              textColor = Colors.green.shade900;
            } else {
              bg = Colors.red.shade100;
              border = Colors.red.shade300;
              textColor = Colors.red.shade900;
            }
          } else if (_answered && isCorrect) {
            bg = Colors.green.shade50;
            border = Colors.green.shade300;
            textColor = Colors.green.shade800;
          } else {
            bg = Colors.white.withOpacity(0.9);
            border = Colors.green.shade200;
            textColor = const Color(0xFF1B5E20);
          }

          return GestureDetector(
            onTap: () => _choose(idx),
            child: AnimatedContainer(
              duration: 200.ms,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: border.withOpacity(0.2),
                      border: Border.all(color: border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _answered && isSelected
                          ? (isCorrect ? '✓' : '✗')
                          : String.fromCharCode(65 + idx), // A, B
                      style: GoogleFonts.nunito(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.nunito(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: (idx * 100).ms)
            .slideX(begin: 0.2, curve: Curves.easeOut, duration: 250.ms);
        }).toList(),
      ),
    );
  }
}

// ── Yo'l va Eshak CustomPainter ───────────────────────────────────────────────
class _RoadPainter extends CustomPainter {
  final double donkeyPos;   // 0.0 → 1.0
  final double walkPhase;
  final double cloudOffset;
  final String mood;
  final double starProgress;
  final int score;
  final int total;

  _RoadPainter({
    required this.donkeyPos,
    required this.walkPhase,
    required this.cloudOffset,
    required this.mood,
    required this.starProgress,
    required this.score,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Osmon ──
    final skyPaint = Paint()
      ..color = const Color(0xFF87CEEB).withOpacity(0.0);

    // ── Bulutlar ──
    _drawCloud(canvas, w * (0.1 + cloudOffset * 0.15), h * 0.12, 50, 22);
    _drawCloud(canvas, w * (0.6 - cloudOffset * 0.08), h * 0.08, 38, 16);
    _drawCloud(canvas, w * (0.82 + cloudOffset * 0.06), h * 0.18, 32, 14);

    // ── O'tlar va tog'lar ──
    _drawHills(canvas, w, h);

    // ── Yo'l ──
    _drawRoad(canvas, w, h);

    // ── Manzil (Susambil) — o'ng tomon ──
    _drawDestination(canvas, w * 0.88, h * 0.42);

    // ── Boshlang'ich joy — chap tomon ──
    _drawStart(canvas, w * 0.06, h * 0.55);

    // ── Eshak ──
    final donkeyX = w * (0.1 + donkeyPos * 0.72);
    final donkeyY = h * 0.57;
    _drawDonkey(canvas, donkeyX, donkeyY, walkPhase, mood);

    // ── Yulduz effekti ──
    if (starProgress > 0 && starProgress < 0.9) {
      _drawStars(canvas, donkeyX, donkeyY, starProgress);
    }

    // ── Progress chiziq ──
    _drawProgressBar(canvas, w, h);
  }

  void _drawCloud(Canvas canvas, double cx, double cy, double r1, double r2) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r2.toDouble(), p);
    canvas.drawCircle(Offset(cx + r2 * 0.9, cy + 2), r2 * 0.8, p);
    canvas.drawCircle(Offset(cx - r2 * 0.9, cy + 2), r2 * 0.7, p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: r1, height: r2 * 0.9), p);
  }

  void _drawHills(Canvas canvas, double w, double h) {
    final hillPaint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, h * 0.5)
      ..quadraticBezierTo(w * 0.2, h * 0.3, w * 0.4, h * 0.48)
      ..quadraticBezierTo(w * 0.6, h * 0.28, w * 0.8, h * 0.44)
      ..quadraticBezierTo(w * 0.9, h * 0.36, w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, hillPaint);
  }

  void _drawRoad(Canvas canvas, double w, double h) {
    // Yo'l
    final roadPaint = Paint()
      ..color = const Color(0xFFD2B48C)
      ..style = PaintingStyle.fill;
    final roadPath = Path()
      ..moveTo(w * 0.02, h * 0.72)
      ..lineTo(w * 0.98, h * 0.68)
      ..lineTo(w * 0.98, h * 0.80)
      ..lineTo(w * 0.02, h * 0.84)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Yo'l chiziqlari (punktir)
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;
    for (int i = 0; i < 7; i++) {
      final x = w * (0.1 + i * 0.12);
      canvas.drawLine(Offset(x, h * 0.76), Offset(x + w * 0.07, h * 0.76), dashPaint);
    }
  }

  void _drawDestination(Canvas canvas, double x, double y) {
    // Susambil uyi
    final housePaint = Paint()
      ..color = const Color(0xFFE8D5B7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x - 20, y - 10, 40, 32), housePaint);

    // Tom
    final roofPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;
    final roofPath = Path()
      ..moveTo(x - 24, y - 10)
      ..lineTo(x, y - 32)
      ..lineTo(x + 24, y - 10)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Eshik
    canvas.drawRect(
      Rect.fromLTWH(x - 7, y + 10, 14, 12),
      Paint()..color = const Color(0xFF795548),
    );

    // "Susambil" yozuvi
    final tp = TextPainter(
      text: const TextSpan(
        text: '🌟 Susambil',
        style: TextStyle(
          color: Color(0xFF1B5E20),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - 24, y + 25));
  }

  void _drawStart(Canvas canvas, double x, double y) {
    // Boshlang'ich belgisi
    final flagPath = Path()
      ..moveTo(x, y - 30)
      ..lineTo(x + 18, y - 22)
      ..lineTo(x, y - 14);
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = Colors.green.shade700
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(x, y - 30),
      Offset(x, y + 2),
      Paint()
        ..color = Colors.brown.shade700
        ..strokeWidth = 2,
    );
  }

  void _drawDonkey(Canvas canvas, double x, double y, double walk, String mood) {
    final legSwing = sin(walk * pi) * 6;
    final bodyBounce = sin(walk * pi * 2).abs() * 2;

    // ── Oyoqlar ──
    final legPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Old oyoqlar
    canvas.drawLine(
      Offset(x + 8, y - bodyBounce),
      Offset(x + 12 + legSwing, y + 20),
      legPaint,
    );
    canvas.drawLine(
      Offset(x + 8, y - bodyBounce),
      Offset(x + 4 - legSwing, y + 20),
      legPaint,
    );
    // Orqa oyoqlar
    canvas.drawLine(
      Offset(x - 8, y - bodyBounce),
      Offset(x - 4 + legSwing, y + 20),
      legPaint,
    );
    canvas.drawLine(
      Offset(x - 8, y - bodyBounce),
      Offset(x - 12 - legSwing, y + 20),
      legPaint,
    );

    // ── Gavda ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y - 5 - bodyBounce),
        width: 38,
        height: 24,
      ),
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.fill,
    );

    // ── Bo'yin ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 16, y - 14 - bodyBounce),
        width: 14,
        height: 18,
      ),
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.fill,
    );

    // ── Bosh ──
    canvas.drawCircle(
      Offset(x + 24, y - 20 - bodyBounce),
      12,
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.fill,
    );

    // ── Quloqlar ──
    final earPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;
    // Chap quloq
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 20, y - 32 - bodyBounce),
        width: 7,
        height: 12,
      ),
      earPaint,
    );
    // O'ng quloq
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 28, y - 32 - bodyBounce),
        width: 7,
        height: 12,
      ),
      earPaint,
    );
    // Quloq ichi
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 20, y - 32 - bodyBounce),
        width: 4,
        height: 8,
      ),
      Paint()..color = const Color(0xFFE0BBB0),
    );

    // ── Ko'z ──
    canvas.drawCircle(
      Offset(x + 27, y - 21 - bodyBounce),
      3,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(x + 28, y - 22 - bodyBounce),
      1,
      Paint()..color = Colors.white,
    );

    // ── Og'iz (kayfiyat) ──
    final mouthPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (mood == 'happy') {
      // Kulgu
      final mouthPath = Path()
        ..moveTo(x + 22, y - 17 - bodyBounce)
        ..quadraticBezierTo(x + 25, y - 14 - bodyBounce, x + 32, y - 17 - bodyBounce);
      canvas.drawPath(mouthPath, mouthPaint);
    } else if (mood == 'sad') {
      // Qayg'u
      final mouthPath = Path()
        ..moveTo(x + 22, y - 14 - bodyBounce)
        ..quadraticBezierTo(x + 25, y - 17 - bodyBounce, x + 32, y - 14 - bodyBounce);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Neytral
      canvas.drawLine(
        Offset(x + 22, y - 16 - bodyBounce),
        Offset(x + 32, y - 16 - bodyBounce),
        mouthPaint,
      );
    }

    // ── Dum ──
    final tailPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(x - 17, y - 8 - bodyBounce),
      Offset(x - 26, y - 18 - bodyBounce + legSwing),
      tailPaint,
    );

    // ── Yuk (savat) ──
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(x - 2, y - 12 - bodyBounce),
        width: 20,
        height: 10,
      ),
      Paint()
        ..color = const Color(0xFF8D6E63).withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawStars(Canvas canvas, double x, double y, double progress) {
    final count = 5;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final r = 28.0 * progress;
      final starPaint = Paint()
        ..color = Colors.amber.withOpacity((1 - progress).clamp(0, 1))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x + r * cos(angle), y - 15 + r * sin(angle) * 0.5),
        4 * (1 - progress * 0.8),
        starPaint,
      );
    }
    // "To'g'ri!" matni
    if (progress < 0.6) {
      final tp = TextPainter(
        text: TextSpan(
          text: '✅ To\'g\'ri!',
          style: TextStyle(
            color: Colors.green.shade700.withOpacity(1 - progress),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - 50 - progress * 20));
    }
  }

  void _drawProgressBar(Canvas canvas, double w, double h) {
    final barW = w * 0.6;
    final barX = w * 0.2;
    final barY = h * 0.04;

    // Fon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barW, 8),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
    // To'ldirilgan
    final filled = barW * donkeyPos;
    if (filled > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, filled, 8),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.green.shade600,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.donkeyPos != donkeyPos ||
      old.walkPhase != walkPhase ||
      old.cloudOffset != cloudOffset ||
      old.mood != mood ||
      old.starProgress != starProgress;
}
