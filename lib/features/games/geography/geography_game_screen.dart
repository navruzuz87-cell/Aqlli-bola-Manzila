import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/geography_questions.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/widgets/victory_overlay.dart';

class GeographyGameScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const GeographyGameScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<GeographyGameScreen> createState() => _GeographyGameScreenState();
}

class _GeographyGameScreenState extends State<GeographyGameScreen>
    with TickerProviderStateMixin {
  late List<GeoQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  int _exploredTiles = 0; // 0–10: qancha "hudud" kashf qilindi
  static const int _maxTiles = 10;

  int? _selectedAnswer;
  bool _answered = false;
  bool _showCombo = false;
  bool _gameOver = false;
  GeoTopic? _filterTopic; // null = barchasi

  late AnimationController _globeController;
  late AnimationController _comboController;
  late AnimationController _tileController;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _tileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _loadQuestions() {
    final grade = widget.profile.grade ?? 3;
    List<GeoQuestion> pool;
    if (_filterTopic != null) {
      pool = GeoQuestions.getByTopic(_filterTopic!);
    } else {
      pool = GeoQuestions.getByGrade(grade);
    }
    _questions = (pool..shuffle(Random())).take(10).toList();
  }

  @override
  void dispose() {
    _globeController.dispose();
    _comboController.dispose();
    _tileController.dispose();
    super.dispose();
  }

  GeoQuestion get _current => _questions[_currentIndex];

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
        _exploredTiles = min(_exploredTiles + 1, _maxTiles);
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
      _tileController.forward(from: 0);
    } else {
      HapticUtils.wrong(); SoundUtils.wrong();
      setState(() {
        _wrongCount++;
        _comboCount = 0;
      });
    }

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() => _showCombo = false);
      if (_currentIndex + 1 >= _questions.length) {
        final _upd = widget.profile.copyWith(
          stars: widget.profile.stars + _starsEarned,
          subjectStars: {...widget.profile.subjectStars, 'geo': (widget.profile.subjectStars['geo'] ?? 0) + _starsEarned},
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
    });
  }

  void _restartGame() {
    setState(() {
      _loadQuestions();
      _currentIndex = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _starsEarned = 0;
      _comboCount = 0;
      _exploredTiles = 0;
      _selectedAnswer = null;
      _answered = false;
      _showCombo = false;
      _gameOver = false;
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
            colors: [
              Color(0xFF01579B),
              Color(0xFF0288D1),
              Color(0xFF004D40),
            ],
          ),
        ),
        child: SafeArea(
          child: _gameOver ? _buildResultScreen() : _buildGameBody(),
        ),
      ),
    );
  }

  // ── Game body ─────────────────────────────────────────────
  Widget _buildGameBody() {
    return Column(
      children: [
        _buildTopBar(),
        _buildMapExplorer(),
        const SizedBox(height: 8),
        _buildTopicFilter(),
        const SizedBox(height: 6),
        Expanded(child: _buildQuestionCard()),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 10),
      ],
    );
  }

  // ── Top bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    final pct = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌍 Geografiya',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF80DEEA)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _Chip('⭐', _starsEarned),
        const SizedBox(width: 6),
        _Chip('🧭', _comboCount),
      ]),
    );
  }

  // ── Map explorer (xarita kashfiyot paneli) ────────────────
  Widget _buildMapExplorer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Globe + explored label
          Row(children: [
            AnimatedBuilder(
              animation: _globeController,
              builder: (ctx, child) {
                return Transform.rotate(
                  angle: _globeController.value * 2 * pi * 0.08,
                  child: child,
                );
              },
              child: const Text('🌍', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kashf qilindi: $_exploredTiles/$_maxTiles hudud',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _exploredTiles / _maxTiles,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF69F0AE)),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),
          // Tile row — kashf qilingan hududlar
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _maxTiles,
              itemBuilder: (ctx, i) {
                final explored = i < _exploredTiles;
                final emojis = ['🏙️','🗺️','🏔️','🌊','🌍','🏯','🗼','🌋','🏜️','🌐'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: explored
                        ? const Color(0xFF004D40).withOpacity(0.7)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: explored ? const Color(0xFF80DEEA) : Colors.white24,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    explored ? emojis[i] : '❓',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Topic filter chips ────────────────────────────────────
  Widget _buildTopicFilter() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _TopicChip(
            label: '🌐 Hammasi',
            selected: _filterTopic == null,
            onTap: () {
              setState(() => _filterTopic = null);
              _restartGame();
            },
          ),
          ...GeoTopic.values.map((t) => _TopicChip(
                label: '${t.emoji} ${t.label}',
                selected: _filterTopic == t,
                onTap: () {
                  setState(() => _filterTopic = t);
                  _restartGame();
                },
              )),
        ],
      ),
    );
  }

  // ── Question card ─────────────────────────────────────────
  Widget _buildQuestionCard() {
    final q = _current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Topic badge + number
          Row(children: [
            _TopicBadge(topic: q.topic),
            const Spacer(),
            Text(
              '${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ]),
          const SizedBox(height: 8),

          // Question box with optional image emoji
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                if (q.imageEmoji != null) ...[
                  Text(q.imageEmoji!,
                      style: const TextStyle(fontSize: 44))
                      .animate(key: ValueKey(q.id))
                      .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 8),
                ],
                Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate(key: ValueKey(_currentIndex)).fadeIn().slideY(begin: -0.1),

          // Hint
          if (q.hint != null) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(q.hint!,
                  style: const TextStyle(
                      color: Color(0xFFFFD54F), fontSize: 12)),
            ]),
          ],

          const SizedBox(height: 10),

          // Answers
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: q.options.length,
              itemBuilder: (_, i) => _buildAnswerButton(i, q.options[i]),
            ),
          ),

          // Explanation after answer
          if (_answered && q.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF80DEEA).withOpacity(0.4)),
              ),
              child: Row(children: [
                const Text('🗺️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(q.explanation!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.4)),
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int index, String text) {
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

    final btn = GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isSelected && _answered
                ? (isCorrect
                    ? const Color(0xFF69F0AE)
                    : const Color(0xFFEF5350))
                : Colors.white24,
            child: Text(labels[index],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? Colors.black : Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          if (_answered && isCorrect) const Text('✅', style: TextStyle(fontSize: 16)),
          if (_answered && isSelected && !isCorrect)
            const Text('❌', style: TextStyle(fontSize: 16)),
        ]),
      ),
    );

    if (_answered && isCorrect) {
      return btn
          .animate(key: ValueKey('c_$index'))
          .scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.elasticOut);
    }
    if (_answered && isSelected && !isCorrect) {
      return btn.animate(key: ValueKey('w_$index')).shakeX(hz: 4, amount: 6, duration: 400.ms);
    }
    return btn
        .animate(key: ValueKey('opt_${_currentIndex}_$index'))
        .fadeIn(delay: (index * 70).ms)
        .slideX(begin: 0.2);
  }

  // ── Combo popup ───────────────────────────────────────────
  Widget _buildComboPopup() {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF006064)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.cyan.withOpacity(0.6),
                  blurRadius: 24,
                  spreadRadius: 4),
            ],
          ),
          child: const Text('🧭 x2 Kashfiyot!',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        )
            .animate()
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 500.ms)
            .then()
            .fadeOut(delay: 400.ms, duration: 400.ms),
      ),
    );
  }

  // ── Result screen ─────────────────────────────────────────
  Widget _buildResultScreen() {
    return VictoryOverlay(
      correctCount: _correctCount,
      totalCount: _questions.length,
      starsEarned: _starsEarned,
      maxCombo: _comboCount,
      subjectEmoji: '🌍',
      subjectName: 'Geografiya',
      onReplay: _restartGame,
      onHome: () => Navigator.pop(context),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────

class _TopicBadge extends StatelessWidget {
  final GeoTopic topic;
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
      child: Text('${topic.emoji} ${topic.label}',
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TopicChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00BCD4).withOpacity(0.4) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? const Color(0xFF80DEEA) : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
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
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}
