import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/story_model.dart';
import '../story/story_intro_screen.dart';
import '../story/story_outro_screen.dart';
import '../story/story_game_wrapper.dart';
import '../story/manzila_bot_widget.dart';

// ════════════════════════════════════════════════════════════════════════════
// Tumarisxon Ingliz Tili O'yini
// Malika Tumarisxon yunon elchilari bilan muzokaralar olib boradi
// Ingliz so'z bilimi = muzokaralar g'alabasi
// ════════════════════════════════════════════════════════════════════════════

class TumarisxonEnglishScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const TumarisxonEnglishScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<TumarisxonEnglishScreen> createState() =>
      _TumarisxonEnglishScreenState();
}

class _TumarisxonEnglishScreenState extends State<TumarisxonEnglishScreen>
    with SingleTickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.intro;
  late final StoryGameState _story;

  late _EnglishQuestion _question;
  int? _selectedIndex;
  bool _answered = false;
  bool _correct = false;
  int _questionNumber = 0;
  int _diplomaticScore = 0; // 0-5 diplomatiya bali

  late AnimationController _speechController;

  static const int _totalQuestions = 10;
  final _random = Random();
  final _questions = _buildEnglishQuestions();

  @override
  void initState() {
    super.initState();
    _story = StoryGameState(
      subject: StorySubject.inglizTili,
      totalSteps: _totalQuestions,
    );
    _speechController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _story.dispose();
    _speechController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final idx = _random.nextInt(_questions.length);
    _question = _questions[idx];
    _selectedIndex = null;
    _answered = false;
    _correct = false;
  }

  String _getHint() {
    final hints = [
      '"${_question.questionText}" — ${_question.hint}',
      'Bu so\'z "${_question.category}" turkumiga kiradi.',
      'Inglizcha o\'rgansang — Tumarisxon kuchli bo\'ladi!',
    ];
    return hints[_random.nextInt(hints.length)];
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _correct = index == _question.correctIndex;
      if (_correct) {
        _diplomaticScore = (_diplomaticScore + 1).clamp(0, 5);
      } else {
        _diplomaticScore = (_diplomaticScore - 1).clamp(0, 5);
      }
    });

    if (_correct) {
      AudioService.instance.playCorrect();
      _speechController.forward(from: 0);
      _story.onCorrectAnswer();
    } else {
      AudioService.instance.playWrong();
      _story.onWrongAnswer(hint: _getHint());
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _questionNumber++;
      if (_story.isGameOver || _questionNumber >= _totalQuestions) {
        setState(() => _phase = _GamePhase.outro);
        _saveProgress();
      } else {
        setState(() => _generateQuestion());
      }
    });
  }

  void _saveProgress() {
    final score = _story.correctAnswers;
    final stars = score >= 8 ? 3 : score >= 6 ? 2 : score >= 4 ? 1 : 0;
    final updated = widget.profile.copyWith(
      stars: widget.profile.stars + stars,
      subjectProgress: {
        ...widget.profile.subjectProgress,
        'ingliz': (widget.profile.subjectProgress['ingliz'] ?? 0) +
            _story.correctAnswers,
      },
    );
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GamePhase.intro => StoryIntroScreen(
          subject: StorySubject.inglizTili,
          onStart: () => setState(() => _phase = _GamePhase.game),
        ),
      _GamePhase.game => _buildGameScreen(),
      _GamePhase.outro => StoryOutroScreen(
          subject: StorySubject.inglizTili,
          score: _story.correctAnswers,
          totalQuestions: _totalQuestions,
          onReplay: () {
            _story.resetGame();
            _questionNumber = 0;
            _diplomaticScore = 0;
            setState(() {
              _phase = _GamePhase.intro;
              _generateQuestion();
            });
          },
          onHome: () => Navigator.of(context).pop(),
        ),
    };
  }

  Widget _buildGameScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _story,
          builder: (_, __) {
            return Stack(children: [
              Column(children: [
                StoryHUD(
                  gameState: _story,
                  subject: StorySubject.inglizTili,
                  onHelpTap: () => showManzilaBotDialog(
                    context: context,
                    hint: _getHint(),
                    mood: 'helping',
                  ),
                ),
                Expanded(child: _buildContent()),
              ]),
              if (_story.showBotHint)
                ManzilaBotOverlay(
                  hint: _story.botHint,
                  mood: _story.botMood,
                  onDismiss: _story.dismissBot,
                ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildDiplomacyScene(),
          const SizedBox(height: 14),
          _buildQuestionCard(),
          const SizedBox(height: 14),
          Expanded(child: _buildAnswerOptions()),
        ],
      ),
    );
  }

  Widget _buildDiplomacyScene() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tumarisxon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _speechController,
                builder: (_, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.1 * _speechController.value,
                    child: child,
                  );
                },
                child: const Text('👑', style: TextStyle(fontSize: 36)),
              ),
              Row(
                children: List.generate(5, (i) => Text(
                  i < _diplomaticScore ? '🌟' : '⭕',
                  style: const TextStyle(fontSize: 10),
                )),
              ),
            ],
          ),
          // O'rtada muzokaralar
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🤝', style: TextStyle(fontSize: 28)),
              Text(
                _diplomaticScore >= 3 ? 'Muzokara!' : 'Qiyin...',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: _diplomaticScore >= 3 ? Colors.greenAccent : Colors.orangeAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Yunon elchisi
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _story.companionHappy ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: const Text('🏛️', style: TextStyle(fontSize: 36)),
              ),
              Text(
                _story.companionHappy ? 'Tan berdi' : 'Muzokarada',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: _story.companionHappy ? Colors.greenAccent : Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🇬🇧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                _question.category,
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ingliz so'zi katta ko'rsatiladi
          if (_question.englishWord.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _question.englishWord,
                style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            _question.questionText,
            style: GoogleFonts.nunito(
              fontSize: 17, fontWeight: FontWeight.w900,
              color: Colors.white, height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (_answered) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _correct ? Colors.green.withOpacity(0.25) : Colors.red.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _correct
                    ? '✅ To\'g\'ri! Tumarisxon g\'olib!'
                    : '❌ Xato! To\'g\'ri: "${_question.options[_question.correctIndex]}"',
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: _question.options.asMap().entries.map((e) {
        final i = e.key;
        final opt = e.value;
        final isSelected = _selectedIndex == i;
        final isCorrect = i == _question.correctIndex;

        Color bgColor;
        Color borderColor;
        Color textColor;
        if (!_answered) {
          bgColor = Colors.white;
          borderColor = const Color(0xFFE0E0E0);
          textColor = Colors.black87;
        } else if (isCorrect) {
          bgColor = const Color(0xFFE8F5E9);
          borderColor = const Color(0xFF4CAF50);
          textColor = const Color(0xFF388E3C);
        } else if (isSelected) {
          bgColor = const Color(0xFFFFEBEE);
          borderColor = const Color(0xFFEF5350);
          textColor = const Color(0xFFC62828);
        } else {
          bgColor = const Color(0xFFF5F5F5);
          borderColor = const Color(0xFFEEEEEE);
          textColor = Colors.black38;
        }

        return GestureDetector(
          onTap: () => _selectAnswer(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Center(child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(opt, style: GoogleFonts.nunito(
                fontSize: 15, color: textColor, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            )),
          ).animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.85, 0.85)),
        );
      }).toList(),
    );
  }
}

enum _GamePhase { intro, game, outro }

class _EnglishQuestion {
  final String questionText;
  final String englishWord;
  final String category;
  final List<String> options;
  final int correctIndex;
  final String hint;

  const _EnglishQuestion({
    required this.questionText,
    required this.englishWord,
    required this.category,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });
}

List<_EnglishQuestion> _buildEnglishQuestions() => [
  const _EnglishQuestion(
    questionText: '"Apple" so\'zining o\'zbekchasi?',
    englishWord: 'Apple',
    category: 'Lug\'at',
    options: ['Olma', 'Nok', 'Uzum', 'Shaftoli'],
    correctIndex: 0,
    hint: 'Qizil yoki yashil meva',
  ),
  const _EnglishQuestion(
    questionText: '"School" so\'zi qanday tarjima qilinadi?',
    englishWord: 'School',
    category: 'Lug\'at',
    options: ['Maktab', 'Bog\'cha', 'Kutubxona', 'Kasalxona'],
    correctIndex: 0,
    hint: 'O\'quvchilar boriladigan joy',
  ),
  const _EnglishQuestion(
    questionText: '"I am happy" jumlasining tarjimasi?',
    englishWord: 'I am happy',
    category: 'Grammatika',
    options: ['Men xursandman', 'Men yaxshiman', 'U xursand', 'Biz xursandmiz'],
    correctIndex: 0,
    hint: '"I" = men, "happy" = xursand',
  ),
  const _EnglishQuestion(
    questionText: '"Book" so\'zining ko\'pligi qanday?',
    englishWord: 'Book',
    category: 'Grammatika',
    options: ['Books', 'Bookes', 'Bookies', 'Booksen'],
    correctIndex: 0,
    hint: 'Ko\'plik odatda -s qo\'shiladi',
  ),
  const _EnglishQuestion(
    questionText: '"Water" so\'zi qanday tarjima qilinadi?',
    englishWord: 'Water',
    category: 'Lug\'at',
    options: ['Suv', 'Non', 'Sut', 'Choy'],
    correctIndex: 0,
    hint: 'Ichimlik, H₂O',
  ),
  const _EnglishQuestion(
    questionText: '"Red" rangi o\'zbekchasi?',
    englishWord: 'Red',
    category: 'Ranglar',
    options: ['Qizil', 'Ko\'k', 'Yashil', 'Sariq'],
    correctIndex: 0,
    hint: 'Olma rangi',
  ),
  const _EnglishQuestion(
    questionText: '"She is my mother" tarjimasi?',
    englishWord: 'She is my mother',
    category: 'Grammatika',
    options: ['U mening onamdir', 'U mening otamdir', 'Men uning onamman', 'U mening do\'stimdir'],
    correctIndex: 0,
    hint: '"She" = u (ayol), "mother" = ona',
  ),
  const _EnglishQuestion(
    questionText: 'Qaysi so\'z "katta" ma\'nosini bildiradi?',
    englishWord: '',
    category: 'Lug\'at',
    options: ['Big', 'Small', 'Short', 'Thin'],
    correctIndex: 0,
    hint: '"Katta" = ___',
  ),
  const _EnglishQuestion(
    questionText: '"Monday" qaysi kun?',
    englishWord: 'Monday',
    category: 'Hafta kunlari',
    options: ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba'],
    correctIndex: 0,
    hint: 'Hafta boshidagi birinchi ish kuni',
  ),
  const _EnglishQuestion(
    questionText: '"How old are you?" — bu savol nimani so\'raydi?',
    englishWord: 'How old are you?',
    category: 'Muloqot',
    options: ['Yosh so\'raydi', 'Ism so\'raydi', 'Manzil so\'raydi', 'Kasb so\'raydi'],
    correctIndex: 0,
    hint: '"Old" = eski/katta (yosh ma\'nosida)',
  ),
];
