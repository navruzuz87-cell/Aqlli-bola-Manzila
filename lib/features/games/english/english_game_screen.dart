import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/english_questions.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

class EnglishGameScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const EnglishGameScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<EnglishGameScreen> createState() => _EnglishGameScreenState();
}

class _EnglishGameScreenState extends State<EnglishGameScreen>
    with TickerProviderStateMixin {

  late List<EnglishQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _starsEarned = 0;
  int _comboCount = 0;
  bool _answered = false;
  int? _selectedOption;
  bool _gameOver = false;
  bool _showCombo = false;

  EnglishCategory? _filterCat;

  late AnimationController _bounceController;
  late AnimationController _starController;

  // Pastel rang paleti (bolalar uchun yorqin)
  static const List<Color> _cardColors = [
    Color(0xFF42A5F5), // ko'k
    Color(0xFF66BB6A), // yashil
    Color(0xFFFF7043), // to'q sariq
    Color(0xFFAB47BC), // binafsha
    Color(0xFF26C6DA), // zangori
    Color(0xFFFFCA28), // sariq
    Color(0xFFEC407A), // pushti
    Color(0xFF8D6E63), // jigarrang
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadQuestions();
  }

  void _loadQuestions() {
    final all = _filterCat != null
        ? EnglishQuestions.getByCategory(_filterCat!)
        : EnglishQuestions.getByGrade(widget.profile.grade);
    final shuffled = List<EnglishQuestion>.from(all)..shuffle(Random());
    setState(() {
      _questions = shuffled.take(10).toList();
      _currentIndex = 0;
      _score = 0;
      _starsEarned = 0;
      _comboCount = 0;
      _answered = false;
      _selectedOption = null;
      _gameOver = false;
    });
  }

  EnglishQuestion get _current => _questions[_currentIndex];

  Color get _bgColor =>
      _cardColors[_currentIndex % _cardColors.length];

  void _selectOption(int idx) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = idx;
    });

    if (idx == _current.correctIndex) {
      _comboCount++;
      final stars = _comboCount >= 2
          ? (_current.starsReward * 2)
          : _current.starsReward;
      _starController.forward(from: 0);
      setState(() {
        _starsEarned += stars;
        _score++;
        if (_comboCount >= 2) _showCombo = true;
      });
      if (_comboCount >= 2) {
        HapticUtils.combo(); SoundUtils.combo();
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

    Future.delayed(const Duration(milliseconds: 1800), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      final _upd = widget.profile.copyWith(
        stars: widget.profile.stars + _starsEarned,
        subjectStars: {...widget.profile.subjectStars, 'ingliz': (widget.profile.subjectStars['ingliz'] ?? 0) + _starsEarned},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _bgColor,
              _bgColor.withOpacity(0.7),
              const Color(0xFF1A1A2E),
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
        _buildProgressBar(),
        _buildCategoryFilter(),
        Expanded(child: _buildQuestion()),
        if (_showCombo) _buildComboPopup(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🇬🇧 English Fun!',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          // Stars counter
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => Transform.scale(
              scale: 1.0 + _starController.value * 0.3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '$_starsEarned',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final pct = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: List.generate(
                  _questions.length,
                  (i) => Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _currentIndex
                          ? Colors.white
                          : i == _currentIndex
                              ? Colors.yellow
                              : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        children: [
          _chip(null, 'Barchasi', '📚'),
          ...EnglishCategory.values
              .map((c) => _chip(c, c.label, c.emoji)),
        ],
      ),
    );
  }

  Widget _chip(EnglishCategory? cat, String label, String emoji) {
    final selected = _filterCat == cat;
    return GestureDetector(
      onTap: () {
        setState(() => _filterCat = cat);
        _loadQuestions();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.25),
          ),
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
          // ── Rasm / Emoji ───────────────────────────────
          AnimatedBuilder(
            animation: _bounceController,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _answered ? 0 : _bounceController.value * 6),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    q.imageEmoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                ),
              ),
            ),
          )
              .animate(key: ValueKey('img_$_currentIndex'))
              .scale(begin: const Offset(0.5, 0.5))
              .fadeIn(),

          const SizedBox(height: 14),

          // ── O'zbekcha so'z ─────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              q.uzbekWord,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 6),

          // Savol
          Text(
            'Inglizcha nomi nima?',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 14),

          // ── Javob variantlari ──────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: List.generate(
              q.options.length,
              (i) => _buildOption(i),
            ),
          ),

          // ── Fun fact / To'g'ri javobdan keyin ─────────
          if (_answered && _selectedOption == q.correctIndex)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    q.pronunciation,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.funSentence,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),

          if (_answered && _selectedOption != q.correctIndex)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✅ To\'g\'ri javob: ${q.englishWord} ${q.pronunciation}',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.greenAccent,
                ),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _buildOption(int idx) {
    final q = _current;
    Color bg = Colors.white.withOpacity(0.18);
    Color border = Colors.white.withOpacity(0.3);
    Color textColor = Colors.white;
    bool isCorrect = idx == q.correctIndex;
    bool isSelected = idx == _selectedOption;

    if (_answered) {
      if (isCorrect) {
        bg = Colors.green.withOpacity(0.4);
        border = Colors.greenAccent;
        textColor = Colors.white;
      } else if (isSelected) {
        bg = Colors.red.withOpacity(0.35);
        border = Colors.redAccent;
        textColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () => _selectOption(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_answered && isCorrect)
                const Text('✅ ', style: TextStyle(fontSize: 16)),
              if (_answered && isSelected && !isCorrect)
                const Text('❌ ', style: TextStyle(fontSize: 16)),
              Text(
                q.options[idx],
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      )
          .animate(key: ValueKey('opt_${_currentIndex}_$idx'))
          .fadeIn(delay: (idx * 100).ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            delay: (idx * 100).ms,
          ),
    );
  }

  Widget _buildComboPopup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.yellowAccent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Text(
        '🎉 x2 Super Combo!',
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0.6, 0.6))
        .then()
        .fadeOut(delay: 1500.ms);
  }

  // ── Natijalar ekrani ──────────────────────────────────────────────────────

  Widget _buildResults() {
    return VictoryOverlay(
      correctCount: _score,
      totalCount: _questions.length,
      starsEarned: _starsEarned,
      maxCombo: _comboCount,
      subjectEmoji: '🇬🇧',
      subjectName: 'Ingliz tili',
      onReplay: _loadQuestions,
      onHome: () => context.pop(),
    );
  }

  Widget _resultStat(String label, String value, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$emoji  $label',
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70)),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _starController.dispose();
    super.dispose();
  }
}
