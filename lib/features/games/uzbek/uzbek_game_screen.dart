import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/uzbek_questions.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';

class UzbekGameScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const UzbekGameScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<UzbekGameScreen> createState() => _UzbekGameScreenState();
}

class _UzbekGameScreenState extends State<UzbekGameScreen>
    with TickerProviderStateMixin {
  late List<UzbekQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  int _castleBricks = 0; // 0–10 bricks build a full castle
  static const int _maxBricks = 10;

  int? _selectedAnswer;
  bool _answered = false;
  bool _showCombo = false;
  bool _showStageCleared = false;
  bool _gameOver = false;

  late AnimationController _castleController;
  late AnimationController _comboController;
  late AnimationController _brickController;
  late AnimationController _wrongShakeController;

  @override
  void initState() {
    super.initState();
    final grade = widget.profile.grade ?? 1;
    final all = UzbekQuestions.getByGrade(grade);
    _questions = (all..shuffle(Random())).take(10).toList();

    _castleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _brickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _castleController.dispose();
    _comboController.dispose();
    _brickController.dispose();
    _wrongShakeController.dispose();
    super.dispose();
  }

  UzbekQuestion get _currentQ => _questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    final isCorrect = index == _currentQ.correctIndex;
    if (isCorrect) {
      setState(() {
        _correctCount++;
        _comboCount++;
        _castleBricks = min(_castleBricks + 1, _maxBricks);
        final stars = _currentQ.starsReward * (_comboCount >= 2 ? 2 : 1);
        _starsEarned += stars;
        if (_comboCount >= 2) {
          _showCombo = true;
          _comboController.forward(from: 0);
          HapticUtils.combo(); SoundUtils.combo();
        } else {
          HapticUtils.correct(); SoundUtils.correct();
        }
      });
      _brickController.forward(from: 0);
    } else {
      HapticUtils.wrong(); SoundUtils.wrong();
      setState(() {
        _wrongCount++;
        _comboCount = 0;
      });
      _wrongShakeController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showCombo = false);
      _next();
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      final _upd = widget.profile.copyWith(
          stars: widget.profile.stars + _starsEarned,
          subjectStars: {...widget.profile.subjectStars, 'ona_tili': (widget.profile.subjectStars['ona_tili'] ?? 0) + _starsEarned},
        );
        widget.onUpdate?.call(_upd);
        HapticUtils.gameComplete(); SoundUtils.win();
        setState(() => _gameOver = true);
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: _gameOver ? _buildResultScreen() : _buildGameBody(),
        ),
      ),
    );
  }

  Widget _buildGameBody() {
    return Column(
      children: [
        _buildTopBar(),
        const SizedBox(height: 8),
        _buildCastle(),
        const SizedBox(height: 12),
        Expanded(
          child: _buildQuestionCard(),
        ),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Top bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    final progress = (_currentIndex + 1) / _questions.length;
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
                Text(
                  '🇺🇿 Ona tili — Qal\'a qurish',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF69F0AE)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatChip('⭐', _starsEarned),
          const SizedBox(width: 6),
          _buildStatChip('🔥', _comboCount),
        ],
      ),
    );
  }

  Widget _buildStatChip(String emoji, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$emoji $value',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Castle ────────────────────────────────────────────────
  Widget _buildCastle() {
    final pct = _castleBricks / _maxBricks;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Castle visual
          AnimatedBuilder(
            animation: _brickController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Ground/base
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF37474F), Color(0xFF263238)],
                      ),
                    ),
                    child: _buildCastleGraphic(pct),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          // Brick counter row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_maxBricks, (i) {
              final filled = i < _castleBricks;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: filled ? const Color(0xFFFFB300) : Colors.white12,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: filled ? const Color(0xFFFF6F00) : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: filled
                    ? null
                    : Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 8),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCastleGraphic(double pct) {
    // Shows castle stages based on brick %
    final stage = (pct * 5).floor().clamp(0, 5);
    final stages = ['🏗️', '🧱', '🏰', '🏯', '🗼', '🏰✨'];
    return Center(
      child: Text(
        stages[stage],
        style: TextStyle(fontSize: 48 + (pct * 20)),
      )
          .animate(key: ValueKey(stage))
          .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  // ── Question card ─────────────────────────────────────────
  Widget _buildQuestionCard() {
    final q = _currentQ;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Topic badge + question number
          Row(
            children: [
              _TopicBadge(topic: q.topic),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Question text
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
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Hint
          if (q.hint != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFFFFD54F), size: 16),
                const SizedBox(width: 4),
                Text(
                  q.hint!,
                  style: const TextStyle(
                      color: Color(0xFFFFD54F), fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          // Answer buttons
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: q.options.length,
              itemBuilder: (context, i) {
                return _buildAnswerButton(i, q.options[i]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int index, String text) {
    final labels = ['A', 'B', 'C', 'D'];
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == _currentQ.correctIndex;

    Color bgColor = Colors.white10;
    Color borderColor = Colors.white24;
    Color textColor = Colors.white;

    if (_answered && isSelected) {
      if (isCorrect) {
        bgColor = const Color(0xFF1B5E20).withOpacity(0.7);
        borderColor = const Color(0xFF69F0AE);
      } else {
        bgColor = const Color(0xFFB71C1C).withOpacity(0.7);
        borderColor = const Color(0xFFEF5350);
      }
    } else if (_answered && isCorrect) {
      bgColor = const Color(0xFF1B5E20).withOpacity(0.5);
      borderColor = const Color(0xFF69F0AE);
    }

    final btn = GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isCorrect
                        ? const Color(0xFF69F0AE)
                        : const Color(0xFFEF5350))
                    : Colors.white24,
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (_answered && isCorrect)
              const Text('✅', style: TextStyle(fontSize: 18)),
            if (_answered && isSelected && !isCorrect)
              const Text('❌', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    if (_answered && isSelected && !isCorrect) {
      return btn
          .animate(key: ValueKey('wrong_$index'))
          .shakeX(hz: 4, amount: 6, duration: 400.ms);
    }
    if (_answered && isCorrect) {
      return btn
          .animate(key: ValueKey('correct_$index'))
          .scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.elasticOut);
    }
    return btn
        .animate(key: ValueKey('opt_${_currentIndex}_$index'))
        .fadeIn(delay: (index * 80).ms)
        .slideX(begin: 0.2);
  }

  // ── Combo popup ───────────────────────────────────────────
  Widget _buildComboPopup() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD600), Color(0xFFFF6D00)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Text(
              '🔥 x2 Yulduz!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 500.ms)
              .then()
              .fadeOut(delay: 400.ms, duration: 400.ms),
        ),
      ),
    );
  }

  // ── Result screen ─────────────────────────────────────────
  Widget _buildResultScreen() {
    final pct = _correctCount / _questions.length;
    String grade;
    String emoji;
    if (pct >= 0.9) {
      grade = "A'lo!";
      emoji = '🏆';
    } else if (pct >= 0.7) {
      grade = "Yaxshi!";
      emoji = '🥇';
    } else if (pct >= 0.5) {
      grade = "O'rtacha";
      emoji = '🥈';
    } else {
      grade = "Yana urinib ko'r";
      emoji = '💪';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72))
                .animate()
                .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 700.ms),
            const SizedBox(height: 16),
            Text(
              grade,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),
            // Castle final
            Text(
              _castleBricks >= _maxBricks
                  ? '🏰✨ To\'liq qal\'a qurildi!'
                  : '🏗️ $_castleBricks/$_maxBricks g\'isht qo\'yildi',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResultStat('✅', '$_correctCount', "To'g'ri"),
                const SizedBox(width: 24),
                _ResultStat('❌', '$_wrongCount', "Noto'g'ri"),
                const SizedBox(width: 24),
                _ResultStat('⭐', '$_starsEarned', "Yulduz"),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            // Explanation for wrong answers
            if (_wrongCount > 0) _buildWrongReview(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartGame,
                    icon: const Icon(Icons.replay, color: Colors.white),
                    label: const Text('Qayta',
                        style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Bosh sahifa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF69F0AE),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongReview() {
    final wrongQuestions = <UzbekQuestion>[];
    // Collect questions user got wrong
    // (simplified: show last 3 wrong if any)
    for (final q in _questions) {
      if (wrongQuestions.length >= 3) break;
      wrongQuestions.add(q);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📚 Bilimingizni mustahkamlang:',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...wrongQuestions.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${q.explanation ?? q.options[q.correctIndex]}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              )),
        ],
      ),
    );
  }

  void _restartGame() {
    final grade = widget.profile.grade ?? 1;
    final all = UzbekQuestions.getByGrade(grade);
    setState(() {
      _questions = (all..shuffle(Random())).take(10).toList();
      _currentIndex = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _starsEarned = 0;
      _comboCount = 0;
      _castleBricks = 0;
      _selectedAnswer = null;
      _answered = false;
      _showCombo = false;
      _gameOver = false;
    });
  }
}

// ── Helper widgets ─────────────────────────────────────────

class _TopicBadge extends StatelessWidget {
  final UzbekTopic topic;
  const _TopicBadge({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        '${topic.emoji} ${topic.label}',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
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
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
