import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// Manzila AI Robot — real rasm bilan, 4-rasmdagi uslubda
// ════════════════════════════════════════════════════════════════════════════

class ManzilaBotWidget extends StatefulWidget {
  final String hint;
  final String mood;
  final VoidCallback onDismiss;

  const ManzilaBotWidget({
    super.key,
    required this.hint,
    required this.mood,
    required this.onDismiss,
  });

  @override
  State<ManzilaBotWidget> createState() => _ManzilaBotWidgetState();
}

class _ManzilaBotWidgetState extends State<ManzilaBotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.mood) {
      case 'celebrating': return const Color(0xFFF57F17);
      case 'sad':         return const Color(0xFF7B1FA2);
      default:            return const Color(0xFF1565C0);
    }
  }

  String get _moodLabel {
    switch (widget.mood) {
      case 'helping':     return 'Yordam beraman!';
      case 'celebrating': return 'Ajoyib!';
      case 'sad':         return 'Xafa bo\'lma...';
      default:            return 'O\'ylab ko\'raylik...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: _buildCard(context),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.25),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Yuqori qism: ko'k gradient + robot rasmi ──────────────
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1565C0),
                  const Color(0xFF1E88E5),
                  const Color(0xFF42A5F5),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Bezak doiralar ──────────────────────────────────
                Positioned(top: -20, right: -20,
                  child: Container(width: 100, height: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07)))),
                Positioned(bottom: -10, left: -15,
                  child: Container(width: 70, height: 70,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07)))),
                // ── Robot rasmi ─────────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, -5 * _bounceController.value),
                      child: child,
                    ),
                    child: Image.asset(
                      'assets/images/characters/manzila_robot.png',
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('🤖',
                        style: TextStyle(fontSize: 80)),
                    ),
                  ),
                ),
                // ── Ism badge ───────────────────────────────────────
                Positioned(
                  bottom: 10, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 7, height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF69F0AE),
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                              .fadeIn(duration: 700.ms),
                          const SizedBox(width: 6),
                          Text('Manzila AI',
                            style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w900,
                              color: Colors.white, letterSpacing: 1,
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Maslahat qismi ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Mood label
                Text(_moodLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: _accentColor,
                  )),
                const SizedBox(height: 10),
                // Hint bubble
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBCCFF)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(widget.hint,
                          style: GoogleFonts.nunito(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A237E), height: 1.5,
                          )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tugma
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFF1565C0),
                        const Color(0xFF42A5F5),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.35),
                          blurRadius: 12, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👍', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text('Tushundim, rahmat!',
                          style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w900,
                            color: Colors.white,
                          )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
        .scale(begin: const Offset(0.75, 0.75), duration: 450.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
  }
}

// ── Helper: dialog sifatida chiqarish ────────────────────────────────────────
Future<void> showManzilaBotDialog({
  required BuildContext context,
  required String hint,
  String mood = 'helping',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (ctx) => ManzilaBotWidget(
      hint: hint,
      mood: mood,
      onDismiss: () => Navigator.of(ctx).pop(),
    ),
  );
}

// ── Stack ichida overlay sifatida ─────────────────────────────────────────────
class ManzilaBotOverlay extends StatelessWidget {
  final String hint;
  final String mood;
  final VoidCallback onDismiss;

  const ManzilaBotOverlay({
    super.key,
    required this.hint,
    required this.mood,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ManzilaBotWidget(
        hint: hint,
        mood: mood,
        onDismiss: onDismiss,
      ),
    );
  }
}
