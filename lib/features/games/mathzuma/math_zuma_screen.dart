import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/user_profile.dart';

// ════════════════════════════════════════════════════════════════════════════
// MATEMATIK ZUMA — Al-Xorazmiy laboratoriyasida
// Sharlar keladi, to'g'ri javobni olib portlatish kerak
// Zuma + matematik amallar = o'rgan o'ynab!
// ════════════════════════════════════════════════════════════════════════════

// ── Mavzular ─────────────────────────────────────────────────────────────────
const _topics = [
  _MathTopic(name: 'Qo\'shish', emoji: '➕', color: Color(0xFF1565C0), minNum: 1, maxNum: 10, op: '+'),
  _MathTopic(name: 'Ayirish',  emoji: '➖', color: Color(0xFF6A1B9A), minNum: 1, maxNum: 10, op: '-'),
  _MathTopic(name: 'Ko\'paytirish', emoji: '✖️', color: Color(0xFF1B5E20), minNum: 1, maxNum: 9,  op: '×'),
  _MathTopic(name: 'Bo\'lish',  emoji: '➗', color: Color(0xFF880E4F), minNum: 1, maxNum: 9,  op: '÷'),
];

class _MathTopic {
  final String name, emoji, op;
  final Color color;
  final int minNum, maxNum;
  const _MathTopic({required this.name, required this.emoji, required this.op, required this.color, required this.minNum, required this.maxNum});
}

// ── Shar (ball) ────────────────────────────────────────────────────────────
class _MathBall {
  final int id;
  final String expression; // "3 + 4 ="
  final int answer;        // 7
  double x;               // 0..1
  double y;               // pixels (yuqoridan)
  double speed;
  bool popped = false;
  bool wrong = false;     // noto'g'ri ataganida qizarish
  double wrongAnim = 0;

  _MathBall({
    required this.id,
    required this.expression,
    required this.answer,
    required this.x,
    required this.y,
    required this.speed,
  });
}

// ── Zarralar ─────────────────────────────────────────────────────────────────
class _Particle {
  double x, y, vx, vy, life, size;
  final Color color;
  _Particle({required this.x, required this.y, required this.vx, required this.vy, required this.color, this.size = 5}) : life = 1.0;
}

// ════════════════════════════════════════════════════════════════════════════
class MathZumaScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const MathZumaScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<MathZumaScreen> createState() => _MathZumaScreenState();
}

class _MathZumaScreenState extends State<MathZumaScreen> with TickerProviderStateMixin {

  late AnimationController _loop;
  late AnimationController _shootAnim;    // otish animatsiyasi
  late AnimationController _comboAnim;

  final _rand = Random();
  int _topicIdx = 0;
  int _level = 1;
  int _score = 0;
  int _combo = 0;
  int _lives = 3;
  bool _gameOver = false;
  bool _levelComplete = false;

  final List<_MathBall> _balls = [];
  final List<_Particle> _particles = [];
  int _ballIdCtr = 0;
  double _spawnTimer = 0;
  double _spawnInterval = 2.2;

  // Chiqaradigan shar (otuvchi)
  late _MathBall _shooterBall;
  late _MathBall _nextBall;
  double _shooterX = 0.5;
  bool _isShooting = false;
  double _shootY = 0;
  double _shootTargetY = 0;
  double _shootBallX = 0.5;

  // Flash
  Color? _flashColor;
  double _flashOpacity = 0;
  double _lastTime = 0;

  _MathTopic get _topic => _topics[_topicIdx % _topics.length];

  @override
  void initState() {
    super.initState();
    _shooterBall = _genBall(x: 0.5, y: 0);
    _nextBall = _genBall(x: 0.5, y: 0);

    _loop = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_onTick)
      ..forward();

    _shootAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _comboAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  _MathBall _genBall({required double x, required double y}) {
    final t = _topic;
    int a, b, ans;
    String expr;

    switch (t.op) {
      case '+':
        a = t.minNum + _rand.nextInt(t.maxNum);
        b = t.minNum + _rand.nextInt(t.maxNum);
        ans = a + b;
        expr = '$a + $b =';
        break;
      case '-':
        b = t.minNum + _rand.nextInt(t.maxNum);
        ans = t.minNum + _rand.nextInt(t.maxNum);
        a = ans + b;
        expr = '$a − $b =';
        break;
      case '×':
        a = t.minNum + _rand.nextInt(t.maxNum - t.minNum);
        b = t.minNum + _rand.nextInt(t.maxNum - t.minNum);
        ans = a * b;
        expr = '$a × $b =';
        break;
      default: // ÷
        b = 1 + _rand.nextInt(t.maxNum);
        ans = 1 + _rand.nextInt(t.maxNum);
        a = ans * b;
        expr = '$a ÷ $b =';
        break;
    }

    return _MathBall(
      id: _ballIdCtr++,
      expression: expr,
      answer: ans,
      x: x,
      y: y,
      speed: 0.7 + _rand.nextDouble() * 0.5 + _level * 0.08,
    );
  }

  void _onTick() {
    if (_gameOver || _levelComplete) return;
    final t = _loop.value * (const Duration(days: 1).inMilliseconds / 1000.0);
    final dt = (_lastTime == 0) ? 0.016 : (t - _lastTime).clamp(0.0, 0.05);
    _lastTime = t;

    // Sharlarni pastga tushirish
    final screenH = MediaQuery.sizeOf(context).height;
    for (final b in _balls) {
      if (b.popped) continue;
      b.y += dt * (90 + _level * 15) * b.speed;
      if (b.wrong) {
        b.wrongAnim -= dt * 3;
        if (b.wrongAnim < 0) b.wrongAnim = 0;
      }
      if (b.y > screenH * 0.78) {
        // Pastga tushdi — jon kamayadi
        b.popped = true;
        _lives--;
        _combo = 0;
        _flashColor = Colors.red;
        _flashOpacity = 0.4;
        HapticFeedback.heavyImpact();
        if (_lives <= 0) {
          _gameOver = true;
          _loop.stop();
        }
      }
    }
    _balls.removeWhere((b) => b.popped && b.y > screenH + 100);

    // Otilgan shar harakati
    if (_isShooting) {
      _shootY -= dt * 600;
      // Nishon bilan to'qnashuv
      for (final b in _balls) {
        if (b.popped) continue;
        final bScreenX = b.x;
        final bScreenY = b.y;
        final dx = (_shootBallX - bScreenX).abs();
        // Otilgan shar ekranning pastki qismidan boshlanadi;
        // to'qnashuv ham chizilayotgan haqiqiy Y koordinatasi bilan tekshiriladi.
        final shotScreenY = screenH * 0.8 + _shootY;
        final dy = (shotScreenY - bScreenY).abs();
        if (dx < 0.09 && dy < 50) {
          _checkAnswer(b);
          _isShooting = false;
          _loadNext();
          break;
        }
      }
      if (_shootY < -100) {
        _isShooting = false;
        _loadNext();
      }
    }

    // Spawn
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      final x = 0.1 + _rand.nextDouble() * 0.8;
      _balls.add(_genBall(x: x, y: -60));
      _spawnInterval = (2.2 - _level * 0.1).clamp(0.8, 2.2);
    }

    // Zarralar
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += dt * 400;
      p.life -= dt * 1.8;
    }
    _particles.removeWhere((p) => p.life <= 0);

    // Flash
    if (_flashOpacity > 0) {
      _flashOpacity -= dt * 3;
      if (_flashOpacity < 0) _flashOpacity = 0;
    }

    // Level tugashi
    if (_score >= 20 + _level * 15 && !_levelComplete) {
      _levelComplete = true;
      _loop.stop();
      _spawnStars();
    }

    if (mounted) setState(() {});
  }

  void _checkAnswer(_MathBall target) {
    if (_shooterBall.answer == target.answer) {
      // To'g'ri! Ikkalasini portlatamiz
      target.popped = true;
      _combo++;
      final pts = 10 * (_combo > 2 ? 2 : 1);
      _score += pts;
      _flashColor = Colors.greenAccent;
      _flashOpacity = 0.25;
      HapticFeedback.lightImpact();
      _spawnParticles(target.x, target.y, Colors.amber, count: 15);
      _spawnParticles(target.x, target.y, _topic.color.withOpacity(0.8), count: 8);
      if (_combo >= 3) {
        _comboAnim.forward(from: 0);
        _spawnParticles(target.x, target.y, Colors.pinkAccent, count: 10);
      }
    } else {
      // Noto'g'ri
      target.wrong = true;
      target.wrongAnim = 1.0;
      _combo = 0;
      _flashColor = Colors.redAccent;
      _flashOpacity = 0.3;
      HapticFeedback.mediumImpact();
    }
  }

  void _loadNext() {
    _shooterBall = _nextBall;
    _nextBall = _genBall(x: 0.5, y: 0);
  }

  void _shoot(double targetX) {
    if (_isShooting || _balls.isEmpty) return;
    _isShooting = true;
    _shootY = 0; // pastdan yuqoriga
    _shootBallX = targetX;
    _shooterX = targetX;
    HapticFeedback.mediumImpact();
  }

  void _spawnParticles(double normX, double y, Color color, {int count = 12}) {
    final w = MediaQuery.sizeOf(context).width;
    final x = normX * w;
    for (int i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * pi * 2;
      final speed = 60 + _rand.nextDouble() * 180;
      _particles.add(_Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 80,
        color: color,
        size: 3 + _rand.nextDouble() * 5,
      ));
    }
  }

  void _spawnStars() {
    _spawnParticles(0.5, 300, Colors.amber, count: 50);
    _spawnParticles(0.3, 300, Colors.pinkAccent, count: 25);
    _spawnParticles(0.7, 300, Colors.lightBlueAccent, count: 25);
  }

  void _nextLevel() {
    setState(() {
      _levelComplete = false;
      _level++;
      _topicIdx++;
      _balls.clear();
      _particles.clear();
      _spawnTimer = 0;
      _lastTime = 0;
      _isShooting = false;
      _combo = 0;
      _shooterBall = _genBall(x: 0.5, y: 0);
      _nextBall = _genBall(x: 0.5, y: 0);
    });
    _loop.forward(from: 0);
  }

  void _retry() {
    setState(() {
      _gameOver = false;
      _lives = 3;
      _score = 0;
      _combo = 0;
      _balls.clear();
      _particles.clear();
      _spawnTimer = 0;
      _lastTime = 0;
      _isShooting = false;
      _shooterBall = _genBall(x: 0.5, y: 0);
      _nextBall = _genBall(x: 0.5, y: 0);
    });
    _loop.forward(from: 0);
  }

  @override
  void dispose() {
    _loop.dispose();
    _shootAnim.dispose();
    _comboAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topic = _topic;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final normX = d.localPosition.dx / size.width;
          _shoot(normX.clamp(0.1, 0.9));
        },
        child: Stack(
          children: [
            // 1. Fon — Al-Xorazmiy laboratoriyasi
            _LabBackground(color: topic.color, offset: _lastTime * 20),

            // 2. Flash
            if (_flashOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: (_flashColor ?? Colors.white).withOpacity(_flashOpacity)),
                ),
              ),

            // 3. Sharlar
            ..._balls.where((b) => !b.popped).map((b) => _BallWidget(
              ball: b, color: topic.color, screenWidth: size.width,
            )),

            // 4. Otilgan shar
            if (_isShooting)
              Positioned(
                left: _shootBallX * size.width - 36,
                top: size.height * 0.8 + _shootY,
                child: _BallContent(
                  expression: _shooterBall.expression,
                  answer: _shooterBall.answer,
                  color: topic.color,
                  size: 72,
                  isShooter: true,
                ),
              ),

            // 5. Zarralar
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ParticlePainter(_particles)),
              ),
            ),

            // 6. HUD
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(child: _Hud(
                topic: topic, score: _score, lives: _lives, level: _level,
                combo: _combo, comboAnim: _comboAnim,
                onBack: () => Navigator.pop(context),
              )),
            ),

            // 7. Pastki — otuvchi + keyingi shar
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(child: _Shooter(
                current: _shooterBall,
                next: _nextBall,
                shooterX: _shooterX,
                color: topic.color,
                isShooting: _isShooting,
              )),
            ),

            // 8. Nishon chizig'i
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _AimPainter(color: topic.color, screenH: size.height)),
              ),
            ),

            // 9. Level complete
            if (_levelComplete)
              _LevelCompleteOverlay(
                topic: topic, score: _score, level: _level, onNext: _nextLevel,
              ),

            // 10. Game over
            if (_gameOver)
              _GameOverOverlay(
                score: _score, topic: topic,
                onRetry: _retry, onHome: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SUBWIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _LabBackground extends StatelessWidget {
  final Color color;
  final double offset;
  const _LabBackground({required this.color, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0D0D1A),
                color.withOpacity(0.3),
                const Color(0xFF0D0D1A),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(color: color, offset: offset)),
        ),
        // Laboratoriya davri yozuvi
        Positioned(
          top: 100, left: 20,
          child: Opacity(
            opacity: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔬', style: const TextStyle(fontSize: 40)),
                Text('Al-Xorazmiy\nLaboratoriyasi\nIX asr · Buxoro',
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        // Pastki zona
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, color.withOpacity(0.15), color.withOpacity(0.3)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double offset;
  const _GridPainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.07)
      ..strokeWidth = 1;
    final step = 40.0;
    final off = offset % step;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -off; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Formulalar
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final formulas = ['∑', 'π', '∞', 'x²', 'αβ', '∫', 'Δ', '√'];
    final rand = Random(7);
    for (int i = 0; i < 12; i++) {
      tp.text = TextSpan(
        text: formulas[rand.nextInt(formulas.length)],
        style: TextStyle(color: color.withOpacity(0.12), fontSize: 18),
      );
      tp.layout();
      tp.paint(canvas, Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height * 0.7));
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.offset != offset;
}

class _BallWidget extends StatelessWidget {
  final _MathBall ball;
  final Color color;
  final double screenWidth;

  const _BallWidget({required this.ball, required this.color, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final x = ball.x * screenWidth - 36;
    final wobble = sin(ball.wrongAnim * pi * 4) * 8 * ball.wrongAnim;
    return Positioned(
      left: x + wobble, top: ball.y - 36,
      child: _BallContent(
        expression: ball.expression,
        answer: ball.answer,
        color: ball.wrong ? Colors.red.shade700 : color,
        size: 72,
        isShooter: false,
      ),
    );
  }
}

class _BallContent extends StatelessWidget {
  final String expression;
  final int answer;
  final Color color;
  final double size;
  final bool isShooter;

  const _BallContent({
    required this.expression, required this.answer,
    required this.color, required this.size, required this.isShooter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            color.withOpacity(0.9),
            color,
            color.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: isShooter ? Colors.amber.shade300 : Colors.white.withOpacity(0.3),
          width: isShooter ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
          if (isShooter) BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            expression,
            style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9)),
            textAlign: TextAlign.center,
          ),
          Text(
            '?',
            style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AimPainter extends CustomPainter {
  final Color color;
  final double screenH;
  const _AimPainter({required this.color, required this.screenH});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Gorizontal nishon chizig'i
    final dashPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, screenH * 0.78), Offset(x + 6, screenH * 0.78), dashPaint);
    }
  }

  @override
  bool shouldRepaint(_AimPainter old) => false;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withOpacity(p.life.clamp(0, 1));
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _Hud extends StatelessWidget {
  final _MathTopic topic;
  final int score, lives, level, combo;
  final AnimationController comboAnim;
  final VoidCallback onBack;

  const _Hud({required this.topic, required this.score, required this.lives, required this.level, required this.combo, required this.comboAnim, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
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
              Text(topic.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(topic.name, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              const Spacer(),
              Row(children: List.generate(3, (i) => Text(i < lives ? '❤️' : '🖤', style: const TextStyle(fontSize: 16)))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('⭐ $score', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
          if (combo >= 3)
            AnimatedBuilder(
              animation: comboAnim,
              builder: (_, __) => Transform.scale(
                scale: 1 + sin(comboAnim.value * pi * 2) * 0.2,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 COMBO ×$combo! +${10 * 2} ball',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Shooter extends StatelessWidget {
  final _MathBall current, next;
  final double shooterX;
  final Color color;
  final bool isShooting;

  const _Shooter({required this.current, required this.next, required this.shooterX, required this.color, required this.isShooting});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Keyingi shar
          Column(
            children: [
              Text('Keyingi:', style: GoogleFonts.nunito(fontSize: 10, color: Colors.white38)),
              const SizedBox(height: 4),
              _BallContent(expression: next.expression, answer: next.answer, color: color.withOpacity(0.6), size: 52, isShooter: false),
            ],
          ),
          // Hozirgi shar (otuvchi)
          Opacity(
            opacity: isShooting ? 0 : 1,
            child: Column(
              children: [
                Text('Ot!', style: GoogleFonts.nunito(fontSize: 11, color: Colors.amber.shade300, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                _BallContent(expression: current.expression, answer: current.answer, color: color, size: 72, isShooter: true),
                const SizedBox(height: 4),
                Text('Nishonga teg!', style: GoogleFonts.nunito(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ),
          // Izoh
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('🔬', style: const TextStyle(fontSize: 24)),
              Text('Al-Xorazmiy', style: GoogleFonts.nunito(fontSize: 10, color: Colors.white38)),
              Text('IX asr', style: GoogleFonts.nunito(fontSize: 9, color: Colors.white24)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelCompleteOverlay extends StatelessWidget {
  final _MathTopic topic;
  final int score, level;
  final VoidCallback onNext;

  const _LevelCompleteOverlay({required this.topic, required this.score, required this.level, required this.onNext});

  static const _facts = [
    'Al-Xorazmiy "Kitob al-muxtasar" asarini IX asrda yozgan — algebra faniga asos solgan!',
    '"Algoritm" so\'zi Al-Xorazmiyning lotincha ismidan kelib chiqqan.',
    'Al-Xorazmiy hindlardan nol (0) raqamini dunyoga tarqatgan.',
    'Buyuk Buxoro — IX asrda dunyo ilmiy markazlaridan biri bo\'lgan.',
  ];

  @override
  Widget build(BuildContext context) {
    final fact = _facts[(level - 1) % _facts.length];
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [topic.color, topic.color.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: topic.color.withOpacity(0.5), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎊', style: const TextStyle(fontSize: 56)).animate().scale().shake(delay: 200.ms),
                const SizedBox(height: 10),
                Text('DARAJADAN O\'TDINGIZ!', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('${topic.emoji} ${topic.name}', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Text('🔬', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(fact, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white, height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('⭐ $score ball', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.amber.shade300)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: topic.color,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Keyingi daraja →', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85)).fadeIn(),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final _MathTopic topic;
  final VoidCallback onRetry, onHome;

  const _GameOverOverlay({required this.score, required this.topic, required this.onRetry, required this.onHome});

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
              color: const Color(0xFF0D0D1A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: topic.color.withOpacity(0.4), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😔', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text('O\'yin tugadi', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('${topic.emoji} ${topic.name}', style: GoogleFonts.nunito(fontSize: 15, color: Colors.white54)),
                const SizedBox(height: 8),
                Text('⭐ $score ball', style: GoogleFonts.nunito(fontSize: 18, color: Colors.amber.shade300)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: topic.color.withOpacity(0.5)),
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
                          backgroundColor: topic.color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Qayta →', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
        ),
      ),
    );
  }
}
