import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/history_questions.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

class HistoryGameScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const HistoryGameScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<HistoryGameScreen> createState() => _HistoryGameScreenState();
}

class _HistoryGameScreenState extends State<HistoryGameScreen>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  late List<HistoryQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  bool _answered = false;
  int? _selectedOption;
  bool _gameOver = false;

  // Time-machine progress: each correct answer moves 1 era forward (0-4)
  int _eraProgress = 0; // 0 = ancient, 4 = contemporary
  static const int _maxEra = 4;

  HistoryEra? _filterEra;

  // Animations
  late AnimationController _machineController;
  late AnimationController _clockController;
  late AnimationController _eraTransController;
  bool _showCombo = false;
  String _comboText = '';

  // Era color map
  static const Map<HistoryEra, Color> _eraColors = {
    HistoryEra.ancient:      Color(0xFF795548),
    HistoryEra.medieval:     Color(0xFF455A64),
    HistoryEra.modern:       Color(0xFF4A148C),
    HistoryEra.contemporary: Color(0xFF006064),
    HistoryEra.uzbekistan:   Color(0xFF1B5E20),
  };

  static const List<String> _eraBgEmojis = ['🏺', '⚔️', '🔭', '🚀', '🇺🇿'];

  @override
  void initState() {
    super.initState();
    _machineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _clockController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _eraTransController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadQuestions();
  }

  void _loadQuestions() {
    final all = _filterEra != null
        ? HistoryQuestions.getByEra(_filterEra!)
        : HistoryQuestions.getByGrade(widget.profile.grade);
    final shuffled = List<HistoryQuestion>.from(all)..shuffle(Random());
    setState(() {
      _questions = shuffled.take(10).toList();
      _currentIndex = 0;
      _score = 0;
      _starsEarned = 0;
      _comboCount = 0;
      _answered = false;
      _selectedOption = null;
      _gameOver = false;
      _eraProgress = 0;
    });
  }

  HistoryQuestion get _current => _questions[_currentIndex];

  Color get _currentBg =>
      _eraColors[_current.era] ?? const Color(0xFF37474F);

  void _selectOption(int idx) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = idx;
    });

    if (idx == _current.correctIndex) {
      // Correct
      _comboCount++;
      final stars = _comboCount >= 2
          ? (_current.starsReward * 2)
          : _current.starsReward;
      setState(() {
        _starsEarned += stars;
        _score++;
        // Advance time machine 1 step every 2 correct answers
        if (_score % 2 == 0 && _eraProgress < _maxEra) {
          _eraProgress++;
          _eraTransController.forward(from: 0);
        }
      });
      if (_comboCount >= 2) {
        HapticUtils.combo(); SoundUtils.combo();
        setState(() {
          _showCombo = true;
          _comboText = '⏰ x2 Vaqt mashinasi!';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showCombo = false);
        });
      } else {
        HapticUtils.correct(); SoundUtils.correct();
      }
    } else {
      HapticUtils.wrong(); SoundUtils.wrong();
      _comboCount = 0;
    }

    Future.delayed(const Duration(milliseconds: 1600), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      final _upd = widget.profile.copyWith(
        stars: widget.profile.stars + _starsEarned,
        subjectStars: {...widget.profile.subjectStars, 'tarix': (widget.profile.subjectStars['tarix'] ?? 0) + _starsEarned},
      );
      widget.onUpdate?.call(_upd);
      HapticUtils.gameComplete(); SoundUtils.win();
      setState(() => _gameOver = true);
    } else {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _currentBg.withOpacity(0.95),
              _currentBg.withOpacity(0.6),
              const Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: _gameOver ? _buildResults() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        _buildTopBar(),
        _buildTimeMachine(),
        _buildEraFilter(),
        Expanded(child: _buildQuestion()),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🕰️ Vaqt Mashinasi',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          // Stars
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$_starsEarned',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMachine() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar + machine emoji
          Row(
            children: [
              AnimatedBuilder(
                animation: _machineController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _machineController.value * 4),
                  child: const Text('🕰️', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Davr: ${_eraProgress + 1}/$_maxEra',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1}/${_questions.length}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Time machine track
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Fill
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 500),
                            widthFactor: _eraProgress / _maxEra,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                                ),
                              ),
                            ),
                          ),
                          // Era emoji markers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(_maxEra, (i) {
                              final reached = i < _eraProgress;
                              return Text(
                                _eraBgEmojis[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: reached
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEraFilter() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip(null, 'Barchasi', '📚'),
          ...HistoryEra.values.map(
            (e) => _filterChip(e, e.label, e.emoji),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(HistoryEra? era, String label, String emoji) {
    final selected = _filterEra == era;
    return GestureDetector(
      onTap: () {
        setState(() => _filterEra = era);
        _loadQuestions();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Colors.amber.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.amber : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.amber : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _current;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Era badge + year
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '${q.era.emoji} ${q.era.label}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (q.year != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '📅 ${q.year}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Image emoji
          if (q.imageEmoji != null)
            Text(q.imageEmoji!, style: const TextStyle(fontSize: 48))
                .animate()
                .fadeIn()
                .scale(),

          const SizedBox(height: 8),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              q.question,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 14),

          // Options
          ...List.generate(q.options.length, (i) => _buildOption(i)),

          // Explanation after answer
          if (_answered && q.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.explanation!,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildOption(int idx) {
    Color bg = Colors.white.withOpacity(0.12);
    Color border = Colors.white.withOpacity(0.2);
    IconData? icon;

    if (_answered) {
      if (idx == _current.correctIndex) {
        bg = Colors.green.withOpacity(0.3);
        border = Colors.green;
        icon = Icons.check_circle;
      } else if (idx == _selectedOption) {
        bg = Colors.red.withOpacity(0.3);
        border = Colors.red;
        icon = Icons.cancel;
      }
    }

    return GestureDetector(
      onTap: () => _selectOption(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx), // A, B, C, D
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _current.options[idx],
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: idx == _current.correctIndex
                    ? Colors.greenAccent
                    : Colors.redAccent,
                size: 20,
              ),
            ],
          ],
        ),
      ).animate(key: ValueKey('opt_${_currentIndex}_$idx'))
          .fadeIn(delay: (idx * 80).ms)
          .slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildComboPopup() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Text(
          _comboText,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      )
          .animate()
          .fadeIn()
          .scale(begin: const Offset(0.7, 0.7))
          .then()
          .fadeOut(delay: 1500.ms),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _buildResults() {
    return VictoryOverlay(
      correctCount: _score,
      totalCount: _questions.length,
      starsEarned: _starsEarned,
      maxCombo: _comboCount,
      subjectEmoji: '🏺',
      subjectName: 'Tarix',
      onReplay: _loadQuestions,
      onHome: () => context.pop(),
    );
  }

  Widget _statRow(String label, String value, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$emoji  $label',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  @override
  void dispose() {
    _machineController.dispose();
    _clockController.dispose();
    _eraTransController.dispose();
    super.dispose();
  }
}
