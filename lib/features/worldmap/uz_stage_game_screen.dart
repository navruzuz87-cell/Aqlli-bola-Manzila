import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/uzbekistan_map.dart';
import '../../data/models/uz_questions_data.dart';

// ════════════════════════════════════════════════════════════════════════════
// UZ STAGE GAME SCREEN — O'zbekiston sayohat o'yini bosqichi
// Haqiqiy ma'lumotlar bilan geografiya, tarix, fan, madaniyat
// ════════════════════════════════════════════════════════════════════════════

class UzStageGameScreen extends StatefulWidget {
  final UzRegion region;
  final int cityIdx;
  final int stageIdx;
  final Function(int stars) onComplete;

  const UzStageGameScreen({
    super.key,
    required this.region,
    required this.cityIdx,
    required this.stageIdx,
    required this.onComplete,
  });

  @override
  State<UzStageGameScreen> createState() => _UzStageGameScreenState();
}

class _UzStageGameScreenState extends State<UzStageGameScreen>
    with TickerProviderStateMixin {

  late UzRegionData _regionData;
  late UzCity _cityData;
  late List<UzQuestion> _questions;

  int _currentQ = 0;
  int _correctCount = 0;
  int _hearts = 3;
  int? _selectedAnswer;
  bool _answered = false;
  bool _showFunFact = false;
  bool _gameOver = false;
  bool _gameWon = false;

  late AnimationController _heartCtrl;
  late AnimationController _correctCtrl;
  late AnimationController _wrongCtrl;

  @override
  void initState() {
    super.initState();
    _regionData = UzbekistanMap.getRegion(widget.region);
    _cityData = _regionData.cities[widget.cityIdx];
    _questions = UzQuestionsData.getQuestions(widget.region, widget.cityIdx, widget.stageIdx);

    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _correctCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _wrongCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _correctCtrl.dispose();
    _wrongCtrl.dispose();
    super.dispose();
  }

  UzQuestion get _currentQuestion => _questions[_currentQ];

  int get _earnedStars {
    final ratio = _correctCount / _questions.length;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.7) return 2;
    if (ratio >= 0.5) return 1;
    return 0;
  }

  void _onAnswer(int idx) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = idx;
      _answered = true;
    });

    final isCorrect = idx == _currentQuestion.correctIndex;

    if (isCorrect) {
      _correctCount++;
      _correctCtrl.forward(from: 0);
    } else {
      _hearts--;
      _heartCtrl.forward(from: 0);
      _wrongCtrl.forward(from: 0);
    }

    // Fun fact ko'rsat
    if (_currentQuestion.funFact.isNotEmpty) {
      setState(() => _showFunFact = true);
    }

    // 1.8 soniyadan keyin keyingisiga o'tish
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_hearts <= 0) {
      setState(() { _gameOver = true; });
      return;
    }

    if (_currentQ >= _questions.length - 1) {
      setState(() { _gameWon = true; });
      return;
    }

    setState(() {
      _currentQ++;
      _answered = false;
      _selectedAnswer = null;
      _showFunFact = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _buildGameOverScreen();
    if (_gameWon) return _buildWinScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHUD(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildJourneyScene(),
                    const SizedBox(height: 16),
                    _buildQuestionCard(),
                    const SizedBox(height: 16),
                    _buildAnswers(),
                    if (_showFunFact && _answered) ...[
                      const SizedBox(height: 16),
                      _buildFunFact(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HUD ─────────────────────────────────────────────────────────────────
  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_regionData.color, _regionData.colorDark],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _regionData.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_regionData.emoji} ${_cityData.name}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.stageIdx + 1}-bosqich',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Yuraklar
          Row(
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _heartCtrl,
                builder: (_, __) {
                  final scale = i == _hearts
                      ? (1.0 - _heartCtrl.value * 0.3)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Text(
                      i < _hearts ? '❤️' : '🖤',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(width: 10),
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentQ + 1}/${_questions.length}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sayohat sahnasi ─────────────────────────────────────────────────────
  Widget _buildJourneyScene() {
    // Progress
    final progress = (_currentQ + 1) / _questions.length;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _regionData.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(_regionData.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_regionData.name} → ${_cityData.name}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      _cityData.description,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: _regionData.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: (MediaQuery.of(context).size.width - 64) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_regionData.color, _regionData.colorDark],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 64) * progress - 10,
                top: -4,
                child: const Text('🧒', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Savol kartasi ───────────────────────────────────────────────────────
  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _regionData.color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _regionData.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _themeEmoji(_cityData.theme),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _themeLabel(_cityData.theme),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _regionData.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _currentQuestion.question,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  // ─── Javoblar ────────────────────────────────────────────────────────────
  Widget _buildAnswers() {
    return Column(
      children: _currentQuestion.options.asMap().entries.map((e) {
        final idx = e.key;
        final text = e.value;
        return _buildAnswerCard(idx, text);
      }).toList(),
    );
  }

  Widget _buildAnswerCard(int idx, String text) {
    final letters = ['A', 'B', 'C', 'D'];

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey[200]!;
    Color textColor = const Color(0xFF1A1A2E);
    Color badgeColor = _regionData.color.withOpacity(0.1);
    Color badgeText = _regionData.color;
    Widget? trailingIcon;

    if (_answered) {
      if (idx == _currentQuestion.correctIndex) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
        badgeColor = const Color(0xFF4CAF50);
        badgeText = Colors.white;
        trailingIcon = const Text('✅', style: TextStyle(fontSize: 20));
      } else if (idx == _selectedAnswer) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFEF5350);
        textColor = const Color(0xFFC62828);
        badgeColor = const Color(0xFFEF5350);
        badgeText = Colors.white;
        trailingIcon = const Text('❌', style: TextStyle(fontSize: 20));
      } else {
        bgColor = Colors.grey[50]!;
        borderColor = Colors.grey[200]!;
        textColor = Colors.grey[400]!;
        badgeColor = Colors.grey[200]!;
        badgeText = Colors.grey[400]!;
      }
    }

    return GestureDetector(
      onTap: () => _onAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letters[idx],
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: badgeText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }

  // ─── Qiziqarli ma'lumot ──────────────────────────────────────────────────
  Widget _buildFunFact() {
    final isCorrect = _selectedAnswer == _currentQuestion.correctIndex;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFFF1F8E9)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFFA5D6A7)
              : const Color(0xFFFFCC80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '🎉 To\'g\'ri!' : '📚 Javob:',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isCorrect
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _currentQuestion.explanation,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFF1A1A2E),
              height: 1.4,
            ),
          ),
          if (_currentQuestion.funFact.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _currentQuestion.funFact,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  // ─── G'alaba ekrani ──────────────────────────────────────────────────────
  Widget _buildWinScreen() {
    final stars = _earnedStars;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Gradient header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_regionData.color, _regionData.colorDark],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _regionData.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text('🏆', style: const TextStyle(fontSize: 56))
                        .animate().scale(delay: 200.ms).shake(delay: 400.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Barakalla!',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_cityData.name}ni zabt etdingiz!',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Yulduzlar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            i < stars ? '⭐' : '☆',
                            style: TextStyle(
                              fontSize: i < stars ? 44 : 36,
                            ),
                          ).animate(delay: Duration(milliseconds: 200 + i * 200))
                              .scale(begin: const Offset(0.5, 0.5))
                              .fadeIn(),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_correctCount/${_questions.length} to\'g\'ri javob',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Qiziqarli ma'lumot
              if (_cityData.funFacts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _regionData.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _regionData.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '📚 Bilimingiz oshdi!',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _regionData.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._cityData.funFacts.take(2).map((fact) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: _regionData.color)),
                            Expanded(
                              child: Text(
                                fact,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Tugmalar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _regionData.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.onComplete(stars);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Davom etish →',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Xaritaga qaytish',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Yutilib bo'ldi ekrani ────────────────────────────────────────────────
  Widget _buildGameOverScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💔', style: TextStyle(fontSize: 72))
                  .animate().shake(),
              const SizedBox(height: 16),
              Text(
                'Yana urinib ko\'r!',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xato qilish yaxshi — shundan o\'rganamiz!',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _regionData.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentQ = 0;
                      _correctCount = 0;
                      _hearts = 3;
                      _selectedAnswer = null;
                      _answered = false;
                      _showFunFact = false;
                      _gameOver = false;
                    });
                  },
                  child: Text(
                    '🔄 Qayta urinish',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Xaritaga qaytish',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(UzStageTheme t) {
    switch (t) {
      case UzStageTheme.history: return 'Tarix';
      case UzStageTheme.culture: return 'Madaniyat';
      case UzStageTheme.geography: return 'Geografiya';
      case UzStageTheme.science: return 'Fan va kashfiyot';
      case UzStageTheme.language: return 'Til va adabiyot';
    }
  }

  String _themeEmoji(UzStageTheme t) {
    switch (t) {
      case UzStageTheme.history: return '⚔️';
      case UzStageTheme.culture: return '🎭';
      case UzStageTheme.geography: return '🌍';
      case UzStageTheme.science: return '🔬';
      case UzStageTheme.language: return '📝';
    }
  }
}
