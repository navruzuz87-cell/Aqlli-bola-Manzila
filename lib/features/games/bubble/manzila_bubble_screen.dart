import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/user_profile.dart';

// ════════════════════════════════════════════════════════════════════════════
// MANZILA BUBBLE POP — So'z tarjimasi o'yini
// Ko'k pufakchalar chiqadi — ichida so'zlar bor
// Savol beriladi (inglizcha), to'g'ri o'zbek so'zini portlatish kerak
// ════════════════════════════════════════════════════════════════════════════

const _wordPairs = [
  ('SUN', 'QUYOSH', '☀️'), ('MOON', 'OY', '🌙'), ('STAR', 'YULDUZ', '⭐'),
  ('WATER', 'SUV', '💧'), ('FIRE', 'OT', '🔥'), ('TREE', 'DARAXT', '🌳'),
  ('BIRD', 'QUSH', '🐦'), ('FISH', 'BALIQ', '🐟'), ('LION', 'SHER', '🦁'),
  ('HORSE', 'OT', '🐎'), ('EAGLE', 'BURGUT', '🦅'), ('ROSE', 'ATIRGUL', '🌹'),
  ('GOLD', 'OLTIN', '🥇'), ('SILK', 'IPAK', '🧵'), ('BREAD', 'NON', '🍞'),
  ('BOOK', 'KITOB', '📚'), ('SWORD', 'QILICH', '⚔️'), ('KING', 'SHOH', '👑'),
  ('BRAVE', 'JASUR', '💪'), ('SMART', 'AQLLI', '🧠'), ('FAST', 'TEZ', '⚡'),
  ('RIVER', 'DARYO', '🏞️'), ('MOUNTAIN', 'TOG\'', '⛰️'), ('FIELD', 'DALA', '🌾'),
  ('FLOWER', 'GUL', '🌸'), ('WIND', 'SHAMOL', '💨'), ('SNOW', 'QOR', '❄️'),
  ('HEART', 'YURAK', '❤️'), ('HAND', 'QO\'L', '🤝'), ('EYE', 'KO\'Z', '👁️'),
];

class _Bubble {
  final int id;
  final String word;
  final String emoji;
  final bool isCorrect;
  double x, y;      // 0..1 normalized
  double vx, vy;    // velocity
  double radius;
  double wobble;    // animatsiya faza
  bool popped = false;
  Color color;

  _Bubble({
    required this.id, required this.word, required this.emoji,
    required this.isCorrect, required this.x, required this.y,
    required this.vx, required this.vy, required this.radius,
    required this.wobble, required this.color,
  });
}

class _Particle {
  double x, y, vx, vy, life, size;
  final Color color;
  _Particle({required this.x, required this.y, required this.vx, required this.vy, required this.color, this.size = 5}) : life = 1.0;
}

// ════════════════════════════════════════════════════════════════════════════
class ManzilaPopScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const ManzilaPopScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<ManzilaPopScreen> createState() => _ManzilaPopScreenState();
}

class _ManzilaPopScreenState extends State<ManzilaPopScreen> with TickerProviderStateMixin {

  late AnimationController _loop;
  late AnimationController _questionPop;

  final _rand = Random();
  final List<_Bubble> _bubbles = [];
  final List<_Particle> _particles = [];

  int _score = 0;
  int _lives = 3;
  int _combo = 0;
  int _round = 0;
  bool _gameOver = false;
  bool _won = false;
  int _idCtr = 0;
  double _lastTime = 0;

  // Hozirgi savol
  late String _questionEng;
  late String _answerUzb;
  late String _questionEmoji;

  // Flash
  Color? _flashColor;
  double _flashOpacity = 0;

  // Wrong tap animatsiya
  String? _wrongWord;
  double _wrongOpacity = 0;

  @override
  void initState() {
    super.initState();
    _newQuestion();

    _loop = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_onTick)
      ..forward();

    _questionPop = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    // Dastlabki pufakchalar
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _spawnBubble();
      });
    }
  }

  void _newQuestion() {
    final pair = _wordPairs[_rand.nextInt(_wordPairs.length)];
    _questionEng = pair.$1;
    _answerUzb = pair.$2;
    _questionEmoji = pair.$3;
    _questionPop.forward(from: 0);
  }

  void _spawnBubble() {
    if (!mounted) return;
    final isCorrect = _rand.nextDouble() < 0.35; // 35% to'g'ri
    String word;

    if (isCorrect) {
      word = _answerUzb;
    } else {
      // Boshqa so'z
      String w;
      do {
        w = _wordPairs[_rand.nextInt(_wordPairs.length)].$2;
      } while (w == _answerUzb);
      word = w;
    }

    final colors = [
      const Color(0xFF1565C0), const Color(0xFF6A1B9A),
      const Color(0xFF1B5E20), const Color(0xFF880E4F),
      const Color(0xFF004D40), const Color(0xFF37474F),
    ];

    final r = 38.0 + _rand.nextDouble() * 18;
    final x = 0.1 + _rand.nextDouble() * 0.8;
    final vx = (_rand.nextDouble() - 0.5) * 0.08;
    final vy = -0.04 - _rand.nextDouble() * 0.04; // yuqoriga suzadi

    _bubbles.add(_Bubble(
      id: _idCtr++,
      word: word,
      emoji: isCorrect ? _questionEmoji : _wordPairs[_rand.nextInt(_wordPairs.length)].$3,
      isCorrect: isCorrect,
      x: x, y: 1.1,
      vx: vx, vy: vy,
      radius: r,
      wobble: _rand.nextDouble() * pi * 2,
      color: colors[_rand.nextInt(colors.length)],
    ));
  }

  void _onTick() {
    if (_gameOver || _won) return;
    final t = _loop.value * (const Duration(days: 1).inMilliseconds / 1000.0);
    final dt = (_lastTime == 0) ? 0.016 : (t - _lastTime).clamp(0.0, 0.05);
    _lastTime = t;

    // Pufakchalar harakati
    for (final b in _bubbles) {
      if (b.popped) continue;
      b.x += b.vx * dt;
      b.y += b.vy * dt;
      b.wobble += dt * 1.5;

      // Devor bilan to'qnashuv
      if (b.x < 0.05) { b.x = 0.05; b.vx = b.vx.abs(); }
      if (b.x > 0.95) { b.x = 0.95; b.vx = -b.vx.abs(); }

      // Yuqoridan chiqib ketdi — to'g'ri bo'lsa jon kamayadi
      if (b.y < -0.15) {
        b.popped = true;
        if (b.isCorrect) {
          _lives--;
          _combo = 0;
          _flashColor = Colors.orange;
          _flashOpacity = 0.3;
          if (_lives <= 0) {
            _gameOver = true;
            _loop.stop();
          }
          // Yangi savol + yangi to'g'ri pufakcha
          _newQuestion();
          _spawnBubble();
          _spawnBubble();
        }
      }
    }

    // Yangi pufakchalar spawn
    final activeBubbles = _bubbles.where((b) => !b.popped).length;
    if (activeBubbles < 7) {
      _spawnBubble();
    }
    _bubbles.removeWhere((b) => b.popped && b.y < -0.3);

    // Zarralar
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += dt * 200;
      p.life -= dt * 1.5;
    }
    _particles.removeWhere((p) => p.life <= 0);

    // Flash
    if (_flashOpacity > 0) { _flashOpacity -= dt * 2.5; }
    if (_wrongOpacity > 0) { _wrongOpacity -= dt * 2; }

    if (mounted) setState(() {});
  }

  void _onBubbleTap(_Bubble b) {
    if (b.popped) return;
    b.popped = true;
    HapticFeedback.lightImpact();

    final size = MediaQuery.sizeOf(context);
    final px = b.x * size.width;
    final py = b.y * size.height;

    if (b.isCorrect) {
      _combo++;
      _score += 10 + (_combo > 2 ? _combo * 2 : 0);
      _flashColor = Colors.greenAccent;
      _flashOpacity = 0.2;
      _spawnParticles(px, py, Colors.amber, count: 20);
      _spawnParticles(px, py, b.color, count: 10);
      _round++;
      if (_round >= 15) {
        _won = true;
        _loop.stop();
        _spawnParticles(size.width / 2, size.height / 2, Colors.amber, count: 60);
      } else {
        _newQuestion();
        _bubbles.removeWhere((bub) => bub.isCorrect && !bub.popped);
        for (int i = 0; i < 2; i++) _spawnBubble();
      }
    } else {
      _combo = 0;
      _wrongWord = b.word;
      _wrongOpacity = 1.0;
      _flashColor = Colors.redAccent;
      _flashOpacity = 0.25;
      _lives--;
      HapticFeedback.mediumImpact();
      _spawnParticles(px, py, Colors.red, count: 8);
      if (_lives <= 0) { _gameOver = true; _loop.stop(); }
    }
  }

  void _spawnParticles(double x, double y, Color color, {int count = 15}) {
    for (int i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * pi * 2;
      final speed = 50 + _rand.nextDouble() * 150;
      _particles.add(_Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 60,
        color: color,
        size: 3 + _rand.nextDouble() * 6,
      ));
    }
  }

  void _retry() {
    setState(() {
      _gameOver = false; _won = false;
      _lives = 3; _score = 0; _combo = 0; _round = 0;
      _bubbles.clear(); _particles.clear();
      _lastTime = 0; _flashOpacity = 0;
      _newQuestion();
    });
    _loop.forward(from: 0);
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () { if (mounted) _spawnBubble(); });
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _questionPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // 1. Fon
          _BubbleBg(),

          // 2. Flash
          if (_flashOpacity > 0)
            Positioned.fill(child: IgnorePointer(
              child: Container(color: (_flashColor ?? Colors.white).withOpacity(_flashOpacity.clamp(0, 1))),
            )),

          // 3. Pufakchalar
          ..._bubbles.where((b) => !b.popped).map((b) => Positioned(
            left: b.x * size.width - b.radius,
            top: b.y * size.height - b.radius,
            child: GestureDetector(
              onTap: () => _onBubbleTap(b),
              child: _BubbleWidget(bubble: b),
            ),
          )),

          // 4. Zarralar
          Positioned.fill(child: IgnorePointer(
            child: CustomPaint(painter: _ParticlePainter(_particles)),
          )),

          // 5. HUD
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(child: _BubbleHud(
              score: _score, lives: _lives, combo: _combo, round: _round,
              onBack: () => Navigator.pop(context),
            )),
          ),

          // 6. Savol
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 20,
            left: 20, right: 20,
            child: AnimatedBuilder(
              animation: _questionPop,
              builder: (_, __) => Transform.scale(
                scale: 1 + sin(_questionPop.value * pi) * 0.08,
                child: _QuestionCard(
                  eng: _questionEng, emoji: _questionEmoji, round: _round,
                ),
              ),
            ),
          ),

          // 7. Noto'g'ri so'z
          if (_wrongOpacity > 0 && _wrongWord != null)
            Positioned(
              top: size.height * 0.4,
              left: 0, right: 0,
              child: Center(
                child: Opacity(
                  opacity: _wrongOpacity.clamp(0, 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('❌ $_wrongWord — noto\'g\'ri!',
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ),

          // 8. Game over / win
          if (_gameOver)
            _EndOverlay(won: false, score: _score, onRetry: _retry, onHome: () => Navigator.pop(context)),
          if (_won)
            _EndOverlay(won: true, score: _score, onRetry: _retry, onHome: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ── Pufakcha widget ───────────────────────────────────────────────────────────
class _BubbleWidget extends StatelessWidget {
  final _Bubble bubble;
  const _BubbleWidget({required this.bubble});

  @override
  Widget build(BuildContext context) {
    final r = bubble.radius;
    final wobbleScale = 1 + sin(bubble.wobble) * 0.04;
    return Transform.scale(
      scale: wobbleScale,
      child: Container(
        width: r * 2, height: r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.2,
            colors: [
              bubble.color.withOpacity(0.7),
              bubble.color,
              bubble.color.withOpacity(0.5),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: bubble.color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            // Ichki yaltiroq
            Positioned(
              top: r * 0.15, left: r * 0.3,
              child: Container(
                width: r * 0.5, height: r * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(r),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(bubble.emoji, style: TextStyle(fontSize: r * 0.45)),
                  Text(
                    bubble.word,
                    style: GoogleFonts.nunito(
                      fontSize: r * 0.3, fontWeight: FontWeight.w900, color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fon ───────────────────────────────────────────────────────────────────────
class _BubbleBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A2E), Color(0xFF1A0A2E), Color(0xFF0A1A1A)],
        ),
      ),
      child: Opacity(
        opacity: 0.1,
        child: CustomPaint(
          painter: _StarBgPainter(),
          size: MediaQuery.sizeOf(context),
        ),
      ),
    );
  }
}

class _StarBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(13);
    final p = Paint()..color = Colors.white;
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 2 + 0.5, p,
      );
    }
  }
  @override
  bool shouldRepaint(_StarBgPainter old) => false;
}

// ── Zarralar ─────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x, p.y), p.size * p.life,
        Paint()..color = p.color.withOpacity(p.life.clamp(0, 1)),
      );
    }
  }
  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── HUD ───────────────────────────────────────────────────────────────────────
class _BubbleHud extends StatelessWidget {
  final int score, lives, combo, round;
  final VoidCallback onBack;
  const _BubbleHud({required this.score, required this.lives, required this.combo, required this.round, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text('🫧', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text('So\'z Pufagi', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          Row(children: List.generate(3, (i) => Text(i < lives ? '❤️' : '🖤', style: const TextStyle(fontSize: 15)))),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('⭐ $score', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Text('$round/15', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

// ── Savol kartasi ─────────────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final String eng, emoji;
  final int round;
  const _QuestionCard({required this.eng, required this.emoji, required this.round});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('O\'zbekcha tarjimasi?', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38)),
              Text(eng, style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('To\'g\'ri pufakni\nportlat! 💥',
              style: GoogleFonts.nunito(fontSize: 10, color: Colors.white60), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

// ── Tugash overlay ────────────────────────────────────────────────────────────
class _EndOverlay extends StatelessWidget {
  final bool won;
  final int score;
  final VoidCallback onRetry, onHome;
  const _EndOverlay({required this.won, required this.score, required this.onRetry, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: won
                    ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
                    : [const Color(0xFF1A0A2E), const Color(0xFF0A0A1A)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(won ? '🎊' : '😔', style: const TextStyle(fontSize: 56))
                    .animate().scale().shake(delay: 200.ms),
                const SizedBox(height: 10),
                Text(
                  won ? '15 so\'z o\'rgandingiz!' : 'O\'yin tugadi',
                  style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text('⭐ $score ball', style: GoogleFonts.nunito(fontSize: 20, color: Colors.amber.shade300, fontWeight: FontWeight.w700)),
                if (won) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(14)),
                    child: Text(
                      '🌸 Manzila bilimga oshiqadi!\nHar kuni yangi so\'zlar o\'rgan.',
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Chiqish', style: GoogleFonts.nunito(fontSize: 15, color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Qayta ▶', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85)).fadeIn(),
        ),
      ),
    );
  }
}
