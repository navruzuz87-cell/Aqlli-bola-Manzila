import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/odobnoma_questions.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/widgets/victory_overlay.dart';

class OdobnomaScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const OdobnomaScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<OdobnomaScreen> createState() => _OdobnomaScreenState();
}

class _OdobnomaScreenState extends State<OdobnomaScreen>
    with TickerProviderStateMixin {
  late List<OdobnomaQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  bool _stage1 = true; // true = hikoya, false = savol
  int? _selectedAnswer;
  bool _answered = false;
  bool _showCombo = false;
  bool _gameOver = false;

  late AnimationController _afandiController;
  late AnimationController _comboController;

  @override
  void initState() {
    super.initState();
    final all = OdobnomaQuestions.getAll();
    _questions = (all..shuffle(Random())).take(7).toList();

    _afandiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _afandiController.dispose();
    _comboController.dispose();
    super.dispose();
  }

  OdobnomaQuestion get _current => _questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    final isCorrect = index == _current.correctIndex;
    if (isCorrect) {
      setState(() {
        _correctCount++;
        _comboCount++;
        final stars = _current.starsReward * (_comboCount >= 2 ? 2 : 1);
        _starsEarned += stars;
        if (_comboCount >= 2) {
          _showCombo = true;
          _comboController.forward(from: 0);
          HapticUtils.combo(); SoundUtils.combo();
        } else {
          HapticUtils.correct(); SoundUtils.correct();
        }
      });
    } else {
      HapticUtils.wrong(); SoundUtils.wrong();
      setState(() => _comboCount = 0);
    }

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showCombo = false);
      _next();
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      final _upd = widget.profile.copyWith(
        stars: widget.profile.stars + _starsEarned,
        subjectStars: {...widget.profile.subjectStars, 'odobnoma': (widget.profile.subjectStars['odobnoma'] ?? 0) + _starsEarned},
      );
      widget.onUpdate?.call(_upd);
      HapticUtils.gameComplete(); SoundUtils.win();
      setState(() => _gameOver = true);
    } else {
      setState(() {
        _currentIndex++;
        _stage1 = true;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(_current.theme.color);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withOpacity(0.9),
              themeColor.withOpacity(0.5),
              const Color(0xFF0D1117),
            ],
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
        const SizedBox(height: 8),
        _ThemeBadge(theme: _current.theme),
        const SizedBox(height: 12),
        Expanded(
          child: _stage1 ? _buildHikoyaCard() : _buildQuestionCard(),
        ),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTopBar() {
    final pct = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Odobnoma',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ChipStat('⭐', _starsEarned),
          const SizedBox(width: 6),
          _ChipStat('🔥', _comboCount),
        ],
      ),
    );
  }

  Widget _buildHikoyaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Afandi emoji with bounce
          AnimatedBuilder(
            animation: _afandiController,
            builder: (context, child) {
              final bounce = sin(_afandiController.value * pi) * 8;
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: child,
              );
            },
            child: const Text('🧓', style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 4),
          // Speech bubble
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _current.companionQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          // Hikoya card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _current.hikoya,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _GlowButton(
            label: 'Savolni bilaman! 👉',
            onTap: () => setState(() => _stage1 = false),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn()
        .slideX(begin: -0.3, curve: Curves.easeOut);
  }

  Widget _buildQuestionCard() {
    final q = _current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              q.question,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          // Answer buttons
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: q.options.length,
              itemBuilder: (_, i) => _buildAnswerBtn(i, q.options[i]),
            ),
          ),
          // Explanation after answer
          if (_answered)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '📖 ${q.moral}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3),
        ],
      ),
    )
        .animate()
        .fadeIn()
        .slideX(begin: 0.3, curve: Curves.easeOut);
  }

  Widget _buildAnswerBtn(int index, String text) {
    final labels = ['A', 'B', 'C', 'D'];
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == _current.correctIndex;

    Color bg = Colors.white10;
    Color border = Colors.white24;

    if (_answered) {
      if (isCorrect) {
        bg = const Color(0xFF1B5E20).withOpacity(0.7);
        border = const Color(0xFF69F0AE);
      } else if (isSelected) {
        bg = const Color(0xFFB71C1C).withOpacity(0.7);
        border = const Color(0xFFEF5350);
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected && _answered
                  ? (isCorrect ? const Color(0xFF69F0AE) : const Color(0xFFEF5350))
                  : Colors.white24,
              child: Text(labels[index],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.black : Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            if (_answered && isCorrect) const Text('✅'),
            if (_answered && isSelected && !isCorrect) const Text('❌'),
          ],
        ),
      ),
    )
        .animate(key: ValueKey('ans_${_currentIndex}_$index'))
        .fadeIn(delay: (index * 70).ms)
        .slideX(begin: 0.2);
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
          child: const Text('🌟 x2 Yulduz!',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        )
            .animate()
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 500.ms)
            .then()
            .fadeOut(delay: 400.ms, duration: 400.ms),
      ),
    );
  }

  Widget _buildResult() {
    return VictoryOverlay(
      correctCount: _correctCount,
      totalCount: _questions.length,
      starsEarned: _starsEarned,
      maxCombo: _comboCount,
      subjectEmoji: '🤝',
      subjectName: 'Odobnoma',
      onReplay: () {
        final all = OdobnomaQuestions.getAll();
        setState(() {
          _questions = (all..shuffle(Random())).take(7).toList();
          _currentIndex = 0;
          _correctCount = 0;
          _starsEarned = 0;
          _comboCount = 0;
          _stage1 = true;
          _selectedAnswer = null;
          _answered = false;
          _gameOver = false;
        });
      },
      onHome: () => Navigator.pop(context),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────

class _ThemeBadge extends StatelessWidget {
  final OdobnomaTheme theme;
  const _ThemeBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white20,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        '${theme.icon} ${theme.label}',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD600), Color(0xFFFF9800)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String emoji;
  final int value;
  const _ChipStat(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text('$emoji $value',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
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
      Text(emoji, style: const TextStyle(fontSize: 24)),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}
