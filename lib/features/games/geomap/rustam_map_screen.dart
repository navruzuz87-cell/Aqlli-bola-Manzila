import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

// ── Xaritadagi joylar (nisbiy koordinatalar 0.0–1.0) ────────────────────────
// O'zbekiston va Markaziy Osiyo soddalashtirilgan xaritasi
class _MapPlace {
  final String id;
  final String name;
  final String hint;      // Rustam beradi
  final double x;         // xarita kengligi bo'yicha
  final double y;         // xarita balandligi bo'yicha
  final double radius;    // teginish radiusi (nisbiy)

  const _MapPlace({
    required this.id,
    required this.name,
    required this.hint,
    required this.x,
    required this.y,
    this.radius = 0.07,
  });
}

const _places = <_MapPlace>[
  _MapPlace(id: 'tashkent',    name: 'Toshkent',    hint: 'O\'zbekiston poytaxti',           x: 0.62, y: 0.30),
  _MapPlace(id: 'samarkand',   name: 'Samarqand',   hint: 'Ipak yo\'li markaziy shahri',      x: 0.48, y: 0.52),
  _MapPlace(id: 'bukhara',     name: 'Buxoro',      hint: 'Olimlar shahri — Ibn Sino vatani', x: 0.32, y: 0.55),
  _MapPlace(id: 'khiva',       name: 'Xiva',        hint: 'Xorazm vohasidagi qadimiy shahar', x: 0.14, y: 0.48),
  _MapPlace(id: 'ferghana',    name: 'Farg\'ona',   hint: 'Vodiydagi eng katta shahar',       x: 0.76, y: 0.42),
  _MapPlace(id: 'shahrisabz',  name: 'Shahrisabz',  hint: 'Amir Temur tug\'ilgan joy',        x: 0.50, y: 0.62),
  _MapPlace(id: 'nukus',       name: 'Nukus',       hint: 'Qoraqalpog\'iston poytaxti',       x: 0.16, y: 0.28),
  _MapPlace(id: 'namangan',    name: 'Namangan',    hint: 'Farg\'ona vodiysidagi katta shahar',x: 0.74, y: 0.32),
  _MapPlace(id: 'andijan',     name: 'Andijon',     hint: 'Bobur tug\'ilgan shahar',          x: 0.82, y: 0.40),
  _MapPlace(id: 'termez',      name: 'Termiz',      hint: 'Janubdagi eng qadimiy shahar',     x: 0.54, y: 0.82),
  _MapPlace(id: 'aral',        name: 'Orol dengizi', hint: 'Qurib qolayotgan ko\'l',          x: 0.22, y: 0.14),
  _MapPlace(id: 'fergana_val', name: 'Farg\'ona vodiysi', hint: 'O\'zbekistonning eng hosildor o\'lkasi', x: 0.76, y: 0.37),
];

// ── O'yin savoli ──────────────────────────────────────────────────────────────
class _GeoQuestion {
  final _MapPlace target;
  final List<_MapPlace> decoys; // 3 ta chalg'ituvchi

  _GeoQuestion({required this.target, required this.decoys});
}

// ═════════════════════════════════════════════════════════════════════════════
class RustamMapScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const RustamMapScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<RustamMapScreen> createState() => _RustamMapScreenState();
}

class _RustamMapScreenState extends State<RustamMapScreen>
    with TickerProviderStateMixin {
  static const int _totalRounds = 10;

  final _rng = Random();
  int _round = 0;
  int _score = 0;
  bool _answered = false;
  String? _tappedId;
  bool _correct = false;
  bool _showVictory = false;
  late _GeoQuestion _question;

  // Rustam holati
  String _rustamSpeech = '';
  bool _rustamHappy = false;

  late AnimationController _pinCtrl;    // pin bouncing
  late AnimationController _glowCtrl;   // to'g'ri joy parqiroqi
  late AnimationController _rustamCtrl; // Rustam animatsiyasi
  late AnimationController _wrongCtrl;  // noto'g'ri silkitish

  // Barcha ko'rinadigan pinlar (joriy savol uchun)
  late List<_MapPlace> _visiblePlaces;

  @override
  void initState() {
    super.initState();
    _pinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rustamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _wrongCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadQuestion();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _glowCtrl.dispose();
    _rustamCtrl.dispose();
    _wrongCtrl.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    final shuffled = List<_MapPlace>.from(_places)..shuffle(_rng);
    final target = shuffled[_round % shuffled.length];
    final decoys = shuffled.where((p) => p.id != target.id).take(3).toList();

    _question = _GeoQuestion(target: target, decoys: decoys);
    _visiblePlaces = [target, ...decoys]..shuffle(_rng);

    _rustamSpeech = '📍 ${target.hint} — qayer?';
    _answered = false;
    _tappedId = null;
    _correct = false;
    _rustamHappy = false;
  }

  void _onMapTap(BuildContext context, Offset localPos, Size mapSize) {
    if (_answered) return;

    // Qaysi joyi bosildi?
    for (final place in _visiblePlaces) {
      final px = place.x * mapSize.width;
      final py = place.y * mapSize.height;
      final dist = (localPos - Offset(px, py)).distance;
      final hitRadius = place.radius * mapSize.width;

      if (dist <= hitRadius) {
        _handleAnswer(place.id);
        return;
      }
    }
  }

  void _handleAnswer(String placeId) async {
    if (_answered) return;
    setState(() {
      _answered = true;
      _tappedId = placeId;
      _correct = placeId == _question.target.id;
    });

    if (_correct) {
      _score++;
      _glowCtrl.forward(from: 0);
      setState(() {
        _rustamHappy = true;
        _rustamSpeech = '🎉 To\'g\'ri! ${_question.target.name} — ${_question.target.hint}';
      });
    } else {
      _wrongCtrl.forward(from: 0);
      setState(() {
        _rustamHappy = false;
        _rustamSpeech = '❌ To\'g\'ri joy: ${_question.target.name}';
      });
    }

    await Future.delayed(1800.ms);

    if (_round + 1 >= _totalRounds) {
      _finish();
    } else {
      setState(() {
        _round++;
        _loadQuestion();
      });
      _glowCtrl.reset();
    }
  }

  void _finish() {
    final starsEarned = _score >= 9 ? 3 : _score >= 7 ? 2 : _score >= 5 ? 1 : 0;
    final subStars = Map<String, int>.from(widget.profile.subjectStars);
    final prev = subStars['geo'] ?? 0;
    if (starsEarned > prev) subStars['geo'] = starsEarned;

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
                _buildRustamBar(),
                Expanded(child: _buildMap()),
                _buildBottomHint(),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (_showVictory)
            VictoryOverlay(
              score: _score,
              maxScore: _totalRounds,
              message: _score >= 9
                  ? 'Rustam kabi geograf! 🏆'
                  : _score >= 6
                      ? 'Xaritani yaxshi bilasiz! 🗺️'
                      : 'Geografiyani o\'rganing! 📚',
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
          colors: [Color(0xFF0D1B2A), Color(0xFF1B3A4B), Color(0xFF0F3460)],
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
              '🗺️ Rustam Maydon',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Text(
              '⭐ $_score  •  ${_round + 1}/$_totalRounds',
              style: GoogleFonts.nunito(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildRustamBar() {
    return AnimatedBuilder(
      animation: _rustamCtrl,
      builder: (_, __) {
        final bounce = sin(_rustamCtrl.value * pi) * 3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Transform.translate(
                offset: Offset(0, -bounce),
                child: Text(
                  _rustamHappy ? '🦸' : '🗺️',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rustam',
                      style: GoogleFonts.nunito(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _rustamSpeech,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pinCtrl, _glowCtrl, _wrongCtrl]),
        builder: (_, __) {
          return GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              // Map widget'ning local pozitsiyasini hisoblash
              // LayoutBuilder dan o'tgan o'lchamni ishlatamiz
            },
            child: LayoutBuilder(builder: (ctx, box) {
              final mapSize = Size(box.maxWidth, box.maxHeight);
              return GestureDetector(
                onTapDown: (d) => _onMapTap(ctx, d.localPosition, mapSize),
                child: AnimatedBuilder(
                  animation: _wrongCtrl,
                  builder: (_, child) {
                    final shake = sin(_wrongCtrl.value * pi * 5) *
                        4 *
                        (1 - _wrongCtrl.value);
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: mapSize,
                    painter: _MapPainter(
                      places: _visiblePlaces,
                      targetId: _question.target.id,
                      tappedId: _tappedId,
                      answered: _answered,
                      pinBounce: _pinCtrl.value,
                      glowProgress: _glowCtrl.value,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildBottomHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👆', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            _answered
                ? (_correct ? '✅ Ajoyib!' : '❌ ${_question.target.name} ni toping!')
                : '📍 Xaritadan "${_question.target.name}" ni toping',
            style: GoogleFonts.nunito(
              color: _answered
                  ? (_correct ? Colors.greenAccent : Colors.redAccent)
                  : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Xarita CustomPainter ──────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  final List<_MapPlace> places;
  final String targetId;
  final String? tappedId;
  final bool answered;
  final double pinBounce;
  final double glowProgress;

  _MapPainter({
    required this.places,
    required this.targetId,
    required this.tappedId,
    required this.answered,
    required this.pinBounce,
    required this.glowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Xarita foni ──
    _drawMapBackground(canvas, w, h);

    // ── O'zbekiston chegarasi (soddalashtirilgan ko'pburchak) ──
    _drawUzbekistanBorder(canvas, w, h);

    // ── Daryolar ──
    _drawRivers(canvas, w, h);

    // ── Grid chiziqlari ──
    _drawGrid(canvas, w, h);

    // ── Pinlar ──
    for (final place in places) {
      _drawPin(canvas, place, w, h);
    }
  }

  void _drawMapBackground(Canvas canvas, double w, double h) {
    // Dengiz/ko'l rangi
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF1565C0).withOpacity(0.15),
    );

    // Quruqlik
    final landPaint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), landPaint);

    // Cho'l hududlari
    final desertPaint = Paint()
      ..color = const Color(0xFFD4A849).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.25, h * 0.55), width: w * 0.4, height: h * 0.5),
      desertPaint,
    );

    // Tog'lar (janub-sharq)
    final mountainPaint = Paint()
      ..color = const Color(0xFF795548).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final mPath = Path()
      ..moveTo(w * 0.55, h * 0.6)
      ..lineTo(w * 0.65, h * 0.4)
      ..lineTo(w * 0.75, h * 0.6)
      ..lineTo(w * 0.85, h * 0.45)
      ..lineTo(w * 0.95, h * 0.65)
      ..lineTo(w * 0.55, h * 0.95)
      ..close();
    canvas.drawPath(mPath, mountainPaint);

    // Farg'ona vodiysi (yashilroq)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.37), width: w * 0.22, height: h * 0.18),
      Paint()..color = const Color(0xFF4CAF50).withOpacity(0.25),
    );
  }

  void _drawUzbekistanBorder(Canvas canvas, double w, double h) {
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // O'zbekiston taxminiy chegarasi
    final path = Path()
      ..moveTo(w * 0.08, h * 0.20)
      ..lineTo(w * 0.30, h * 0.08)
      ..lineTo(w * 0.52, h * 0.12)
      ..lineTo(w * 0.70, h * 0.18)
      ..lineTo(w * 0.90, h * 0.28)
      ..lineTo(w * 0.95, h * 0.50)
      ..lineTo(w * 0.88, h * 0.72)
      ..lineTo(w * 0.70, h * 0.90)
      ..lineTo(w * 0.45, h * 0.95)
      ..lineTo(w * 0.25, h * 0.88)
      ..lineTo(w * 0.08, h * 0.72)
      ..lineTo(w * 0.04, h * 0.50)
      ..close();
    canvas.drawPath(path, borderPaint);

    // "O'zbekiston" yozuvi
    final tp = TextPainter(
      text: const TextSpan(
        text: "O'ZBEKISTON",
        style: TextStyle(
          color: Colors.white24,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.5));
  }

  void _drawRivers(Canvas canvas, double w, double h) {
    final riverPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Amudaryo
    final amu = Path()
      ..moveTo(w * 0.52, h * 0.88)
      ..quadraticBezierTo(w * 0.30, h * 0.75, w * 0.14, h * 0.52)
      ..quadraticBezierTo(w * 0.10, h * 0.38, w * 0.20, h * 0.18);
    canvas.drawPath(amu, riverPaint);

    // Sirdaryo
    final syr = Path()
      ..moveTo(w * 0.80, h * 0.38)
      ..quadraticBezierTo(w * 0.65, h * 0.28, w * 0.50, h * 0.22)
      ..quadraticBezierTo(w * 0.30, h * 0.16, w * 0.20, h * 0.18);
    canvas.drawPath(syr, riverPaint);

    // Daryo yozuvlari
    _drawLabel(canvas, 'Amudaryo', w * 0.26, h * 0.72,
        const Color(0xFF42A5F5), 8);
    _drawLabel(canvas, 'Sirdaryo', w * 0.52, h * 0.20,
        const Color(0xFF42A5F5), 8);
  }

  void _drawGrid(Canvas canvas, double w, double h) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.8;
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(w * i / 5, 0), Offset(w * i / 5, h), gridPaint);
      canvas.drawLine(Offset(0, h * i / 5), Offset(w, h * i / 5), gridPaint);
    }
  }

  void _drawPin(Canvas canvas, _MapPlace place, double w, double h) {
    final px = place.x * w;
    final py = place.y * h;
    final isTarget = place.id == targetId;
    final isTapped = tappedId == place.id;
    final isCorrectTap = isTapped && place.id == targetId;
    final isWrongTap = isTapped && place.id != targetId;

    // Teginish maydoni (debug uchun shaffof)
    // canvas.drawCircle(Offset(px, py), place.radius * w, Paint()..color = Colors.white10);

    // Pin bounce (faqat target, javob berilmagan paytda)
    final bounce = (!answered && isTarget) ? sin(pinBounce * pi) * 5 : 0.0;

    // Pin rangi
    Color pinColor;
    if (answered) {
      if (isTarget) {
        pinColor = Colors.greenAccent;
      } else if (isWrongTap) {
        pinColor = Colors.redAccent;
      } else {
        pinColor = Colors.white38;
      }
    } else {
      pinColor = isTarget
          ? Colors.amber        // faqat target uchun sariq (javobi ko'rinmaydi chunki boshqa pinlar ham bor)
          : Colors.lightBlueAccent;
      // Aslida barcha pinlar bir xil ko'rinishi kerak (topish qiyinroq bo'lsin)
      pinColor = Colors.lightBlueAccent.withOpacity(0.9);
    }

    // Glow (to'g'ri bosilsa)
    if (isCorrectTap && glowProgress > 0) {
      final glowPaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.3 * (1 - glowProgress * 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(Offset(px, py - 12 - bounce), 24, glowPaint);
    }

    // Pin soya
    canvas.drawCircle(
      Offset(px + 1, py + 1),
      8,
      Paint()..color = Colors.black26,
    );

    // Pin shakli (drop)
    final pinPath = Path()
      ..moveTo(px, py - bounce)
      ..addOval(Rect.fromCenter(
          center: Offset(px, py - 18 - bounce), width: 18, height: 18))
      ..lineTo(px, py - bounce);
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill,
    );
    // Pin uchki
    canvas.drawCircle(
      Offset(px, py - 18 - bounce),
      7,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    // Pin markazidagi nuqta
    canvas.drawCircle(
      Offset(px, py - 18 - bounce),
      3,
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Shahar nomi (faqat javob berilgandan keyin yoki doimo)
    if (answered || isTarget) {
      _drawLabel(canvas, place.name, px, py - 32 - bounce, Colors.white, 10);
    }
  }

  void _drawLabel(Canvas canvas, String text, double x, double y,
      Color color, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.tappedId != tappedId ||
      old.answered != answered ||
      old.pinBounce != pinBounce ||
      old.glowProgress != glowProgress;
}
