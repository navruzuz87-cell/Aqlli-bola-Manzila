import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../data/models/user_profile.dart';

// Math question model
class MathQuestion {
  final String question;
  final List<int> options;
  final int answer;
  final int stars;

  MathQuestion({
    required this.question,
    required this.options,
    required this.answer,
    this.stars = 10,
  });

  static MathQuestion generate(int level) {
    final r = Random();
    int a, b, op;

    if (level <= 2) {
      a = r.nextInt(10) + 1;
      b = r.nextInt(10) + 1;
      op = r.nextInt(2); // + or -
    } else if (level <= 5) {
      a = r.nextInt(20) + 5;
      b = r.nextInt(10) + 2;
      op = r.nextInt(3);
    } else {
      a = r.nextInt(50) + 10;
      b = r.nextInt(20) + 5;
      op = r.nextInt(4);
    }

    int answer;
    String question;

    switch (op) {
      case 0:
        answer = a + b;
        question = '$a + $b = ?';
      case 1:
        if (a < b) { final tmp = a; a = b; b = tmp; }
        answer = a - b;
        question = '$a - $b = ?';
      case 2:
        answer = a * b ~/ 10 + 1;
        a = answer;
        b = r.nextInt(5) + 2;
        answer = a * b;
        question = '$a × $b = ?';
      default:
        b = r.nextInt(8) + 2;
        answer = b * (r.nextInt(10) + 1);
        a = answer;
        question = '$a ÷ $b = ?';
        answer = a ~/ b;
    }

    // Generate wrong options
    final Set<int> opts = {answer};
    while (opts.length < 4) {
      final delta = r.nextInt(10) + 1;
      opts.add(answer + (r.nextBool() ? delta : -delta));
    }
    final optList = opts.toList()..shuffle();

    return MathQuestion(
      question: question,
      options: optList,
      answer: answer,
      stars: 10 + level * 2,
    );
  }
}

class CarRaceScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const CarRaceScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<CarRaceScreen> createState() => _CarRaceScreenState();
}

class _CarRaceScreenState extends State<CarRaceScreen>
    with TickerProviderStateMixin {
  int _level = 1;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  int _carPosition = 0; // 0–100%
  static const int _questionsPerRound = 10;
  int _answered = 0;

  late MathQuestion _currentQ;
  int? _selectedAnswer;
  bool _isAnswered = false;
  bool _showCombo = false;
  bool _gameOver = false;

  late AnimationController _carController;
  late AnimationController _comboController;
  late AnimationController _roadController;

  late Timer _roadTimer;

  @override
  void initState() {
    super.initState();
    _level = widget.profile.subjectProgress['matematika'] ?? 1;
    _currentQ = MathQuestion.generate(_level);

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _carController.dispose();
    _comboController.dispose();
    _roadController.dispose();
    super.dispose();
  }

  void _selectAnswer(int value) {
    if (_isAnswered) return;
    final isCorrect = value == _currentQ.answer;

    setState(() {
      _selectedAnswer = value;
      _isAnswered = true;
      _answered++;

      if (isCorrect) {
        _correctCount++;
        _comboCount++;
        final stars = _currentQ.stars * (_comboCount >= 2 ? 2 : 1);
        _starsEarned += stars;
        _carPosition = min(100, _carPosition + 10);
        if (_comboCount >= 2) {
          _showCombo = true;
          _comboController.forward(from: 0);
          HapticUtils.combo(); SoundUtils.combo();
        }
        // Adaptive difficulty
        if (_correctCount % 3 == 0) _level = min(10, _level + 1);
        HapticUtils.correct(); SoundUtils.correct();
      } else {
        _wrongCount++;
        _comboCount = 0;
        if (_wrongCount % 2 == 0 && _level > 1) _level = max(1, _level - 1);
        HapticUtils.wrong(); SoundUtils.wrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _showCombo = false);
      if (_answered >= _questionsPerRound) {
        // Profil yangilash
        final updated = widget.profile.copyWith(
          stars: widget.profile.stars + _starsEarned,
          subjectStars: {
            ...widget.profile.subjectStars,
            'matematika': (widget.profile.subjectStars['matematika'] ?? 0) + _starsEarned,
          },
        );
        widget.onUpdate?.call(updated);
        setState(() => _gameOver = true);
      } else {
        setState(() {
          _currentQ = MathQuestion.generate(_level);
          _selectedAnswer = null;
          _isAnswered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: _gameOver ? _buildResult() : _buildGameBody(),
        ),
      ),
    );
  }

  Widget _buildGameBody() {
    return Column(
      children: [
        _buildTopBar(),
        _buildRoadTrack(),
        const SizedBox(height: 8),
        _buildQuestion(),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Text('🏎️ Matematika Poyga',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const Spacer(),
        _Chip('⭐', _starsEarned),
        const SizedBox(width: 6),
        _Chip('🔥', _comboCount),
        const SizedBox(width: 6),
        _Chip('📊', _level),
      ]),
    );
  }

  Widget _buildRoadTrack() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Road lines
          AnimatedBuilder(
            animation: _roadController,
            builder: (context, child) {
              return CustomPaint(
                painter: _RoadPainter(_roadController.value),
                size: Size.infinite,
              );
            },
          ),
          // Car
          Positioned(
            left: MediaQuery.of(context).size.width * 0.08 +
                (_carPosition / 100) *
                    (MediaQuery.of(context).size.width - 100),
            top: 32,
            child: const Text('🏎️', style: TextStyle(fontSize: 44))
                .animate(key: ValueKey(_carPosition))
                .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 300.ms,
                    curve: Curves.elasticOut),
          ),
          // Progress
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: Row(children: [
              const Text('🚦', style: TextStyle(fontSize: 16)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _carPosition / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD600)),
                    minHeight: 8,
                  ),
                ),
              ),
              const Text('🏁', style: TextStyle(fontSize: 16)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _currentQ.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate(key: ValueKey(_currentQ.question))
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut),
            const SizedBox(height: 16),
            // Options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: _currentQ.options
                    .map((opt) => _buildOption(opt))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int value) {
    final isSelected = _selectedAnswer == value;
    final isCorrect = value == _currentQ.answer;
    final labels = ['A', 'B', 'C', 'D'];
    final idx = _currentQ.options.indexOf(value);

    Color bg = Colors.white12;
    Color border = Colors.white24;

    if (_isAnswered) {
      if (isCorrect) {
        bg = const Color(0xFF1B5E20).withOpacity(0.7);
        border = const Color(0xFF69F0AE);
      } else if (isSelected) {
        bg = const Color(0xFFB71C1C).withOpacity(0.7);
        border = const Color(0xFFEF5350);
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isSelected && _isAnswered
                  ? (isCorrect ? const Color(0xFF69F0AE) : const Color(0xFFEF5350))
                  : Colors.white24,
              child: Text(labels[idx],
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isAnswered && isCorrect) const Text('✅'),
          ],
        ),
      ),
    )
        .animate(key: ValueKey('opt_${_currentQ.question}_$idx'))
        .fadeIn(delay: (idx * 60).ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }

  Widget _buildComboPopup() {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD600), Color(0xFFFF6D00)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 24,
                  spreadRadius: 4),
            ],
          ),
          child: const Text('🏎️ x2 Tez!',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        )
            .animate()
            .scale(
                begin: const Offset(0.5, 0.5),
                curve: Curves.elasticOut,
                duration: 500.ms)
            .then()
            .fadeOut(delay: 400.ms, duration: 400.ms),
      ),
    );
  }

  Widget _buildResult() {
    final pct = _correctCount / _questionsPerRound;
    final emoji = pct >= 0.9 ? '🏆' : pct >= 0.7 ? '🥇' : '🏎️';
    final msg = pct >= 0.9 ? 'Champion!' : pct >= 0.7 ? 'Yaxshi!' : 'Yana ur!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72))
                .animate()
                .scale(
                    begin: const Offset(0, 0),
                    curve: Curves.elasticOut,
                    duration: 700.ms),
            const SizedBox(height: 12),
            Text(msg,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ResultStat('✅', '$_correctCount', "To'g'ri"),
              const SizedBox(width: 20),
              _ResultStat('❌', '$_wrongCount', "Xato"),
              const SizedBox(width: 20),
              _ResultStat('⭐', '$_starsEarned', 'Yulduz'),
            ]).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('🏠 Bosh sahifa',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _level = widget.profile.subjectProgress['matematika'] ?? 1;
                      _correctCount = 0;
                      _wrongCount = 0;
                      _starsEarned = 0;
                      _comboCount = 0;
                      _carPosition = 0;
                      _answered = 0;
                      _currentQ = MathQuestion.generate(_level);
                      _selectedAnswer = null;
                      _isAnswered = false;
                      _showCombo = false;
                      _gameOver = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('🔄 Qayta'),
                ),
              ),
            ]).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji;
  final int value;
  const _Chip(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$emoji $value',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _ResultStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}

class _RoadPainter extends CustomPainter {
  final double offset;
  _RoadPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final dashW = 30.0;
    final gap = 20.0;
    final step = dashW + gap;
    final total = size.width + step;
    final off = offset * step;

    for (double x = -step + off % step; x < total; x += step) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height / 2 - 2, dashW, 4),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) => oldDelegate.offset != offset;
}
