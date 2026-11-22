import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Confetti particle ─────────────────────────────────────────────────────────
class _Particle {
  double x, y, vx, vy, size, rotation, rotSpeed;
  Color color;
  int shape; // 0=circle, 1=rect, 2=star

  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.size, required this.rotation,
    required this.rotSpeed, required this.color,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  const _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);

      switch (p.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero,
                width: p.size, height: p.size * 0.6),
            paint);
          break;
        case 2:
          _drawStar(canvas, paint, p.size / 2);
          break;
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = -pi / 2 + i * 2 * pi / 5;
      final innerA = outerA + pi / 5;
      final ox = r * cos(outerA);
      final oy = r * sin(outerA);
      final ix = (r * 0.4) * cos(innerA);
      final iy = (r * 0.4) * sin(innerA);
      if (i == 0) path.moveTo(ox, oy); else path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

// ── Confetti controller ───────────────────────────────────────────────────────
class _ConfettiController {
  final List<_Particle> particles = [];
  static final _rng = Random();

  static const _colors = [
    Color(0xFFFFD700), Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFF45B7D1), Color(0xFF96CEB4), Color(0xFFFF9FF3),
    Color(0xFFFECA57), Color(0xFF54A0FF), Color(0xFF5F27CD),
  ];

  void burst(Size size) {
    for (int i = 0; i < 80; i++) {
      particles.add(_Particle(
        x: 0.3 + _rng.nextDouble() * 0.4, // top-center area
        y: -0.05,
        vx: (_rng.nextDouble() - 0.5) * 0.012,
        vy: 0.004 + _rng.nextDouble() * 0.008,
        size: 6 + _rng.nextDouble() * 10,
        rotation: _rng.nextDouble() * 2 * pi,
        rotSpeed: (_rng.nextDouble() - 0.5) * 0.15,
        color: _colors[_rng.nextInt(_colors.length)],
        shape: _rng.nextInt(3),
      ));
    }
  }

  void tick() {
    for (final p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.00015; // gravity
      p.rotation += p.rotSpeed;
    }
    particles.removeWhere((p) => p.y > 1.1);
  }
}

// ── Victory Overlay ───────────────────────────────────────────────────────────
/// Barcha o'yinlarda qo'llaniladigan natija overlay
class VictoryOverlay extends StatefulWidget {
  final int correctCount;
  final int totalCount;
  final int starsEarned;
  final int maxCombo;
  final String subjectEmoji;
  final String subjectName;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const VictoryOverlay({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.starsEarned,
    required this.maxCombo,
    required this.subjectEmoji,
    required this.subjectName,
    required this.onReplay,
    required this.onHome,
  });

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late final _ConfettiController _confetti;
  late final AnimationController _tickCtrl;

  @override
  void initState() {
    super.initState();
    _confetti = _ConfettiController();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Confetti burst
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confetti.burst(MediaQuery.of(context).size);
        setState(() {});
      }
    });

    _tickCtrl.addListener(() {
      if (mounted) {
        _confetti.tick();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    super.dispose();
  }

  String get _gradeEmoji {
    final pct = widget.correctCount / widget.totalCount;
    if (pct >= 0.9) return '🏆';
    if (pct >= 0.7) return '🎉';
    if (pct >= 0.5) return '👍';
    return '💪';
  }

  String get _gradeTitle {
    final pct = widget.correctCount / widget.totalCount;
    if (pct >= 0.9) return "A'lo!";
    if (pct >= 0.7) return 'Yaxshi!';
    if (pct >= 0.5) return "O'rtacha";
    return 'Davom eting!';
  }

  Color get _gradeColor {
    final pct = widget.correctCount / widget.totalCount;
    if (pct >= 0.9) return const Color(0xFFFFD700);
    if (pct >= 0.7) return const Color(0xFF66BB6A);
    if (pct >= 0.5) return const Color(0xFF42A5F5);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(children: [
        // Blur overlay
        Container(color: Colors.black87),

        // Confetti
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ConfettiPainter(_confetti.particles),
        ),

        // Kontent
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fan emoji
                  Text(widget.subjectEmoji,
                    style: const TextStyle(fontSize: 48))
                      .animate().scale(delay: 100.ms),

                  const SizedBox(height: 8),

                  // Grade emoji
                  Text(_gradeEmoji,
                    style: const TextStyle(fontSize: 72))
                      .animate().scale(
                        delay: 300.ms,
                        curve: Curves.elasticOut,
                        duration: 600.ms,
                      ),

                  const SizedBox(height: 12),

                  // Grade title
                  Text(_gradeTitle,
                    style: GoogleFonts.nunito(
                      color: _gradeColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    )).animate().fadeIn(delay: 400.ms),

                  Text(widget.subjectName,
                    style: GoogleFonts.nunito(
                      color: Colors.white54,
                      fontSize: 14,
                    )).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 28),

                  // Stat kartalar
                  Row(children: [
                    _statCard('✅',
                      '${widget.correctCount}/${widget.totalCount}',
                      "To'g'ri",
                      const Color(0xFF66BB6A), 0),
                    const SizedBox(width: 10),
                    _statCard('⭐',
                      '${widget.starsEarned}',
                      'Yulduz',
                      const Color(0xFFFFD700), 1),
                    const SizedBox(width: 10),
                    _statCard('🔥',
                      '×${widget.maxCombo}',
                      'Max Combo',
                      const Color(0xFFFF7043), 2),
                  ]),

                  const SizedBox(height: 32),

                  // Yulduzlar row
                  _buildStarRow(),

                  const SizedBox(height: 32),

                  // Tugmalar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: widget.onReplay,
                      child: Text("🔄 Qayta o'yna",
                        style: GoogleFonts.nunito(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: widget.onHome,
                      child: Text('🏠 Bosh menyu',
                        style: GoogleFonts.nunito(fontSize: 16)),
                    ),
                  ).animate().slideY(begin: 0.3, delay: 700.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStarRow() {
    // 1-3 yulduz vizual (10 savolga 30 max yulduz, 3 ta icon)
    final maxPossible = widget.totalCount * 3;
    final filled = ((widget.starsEarned / maxPossible) * 3).ceil().clamp(0, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            i < filled ? '⭐' : '☆',
            style: TextStyle(
              fontSize: 40,
              color: i < filled ? const Color(0xFFFFD700) : Colors.white24,
            ),
          ).animate(delay: (500 + i * 150).ms).scale(curve: Curves.elasticOut),
        );
      }),
    );
  }

  Widget _statCard(String emoji, String value, String label,
      Color color, int delayIndex) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            )),
          Text(label,
            style: GoogleFonts.nunito(
              color: Colors.white54, fontSize: 10)),
        ]),
      ).animate()
        .fadeIn(delay: (350 + delayIndex * 80).ms)
        .slideY(begin: 0.3),
    );
  }
}
