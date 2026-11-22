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
// Zumrad va Qimmat — Ona Tili O'yini
// To'g'ri so'z → Sandiq ochiladi (Zumrad g'olib)
// Xato so'z    → Sandiq yopiladi (Qimmat g'olib)
// ════════════════════════════════════════════════════════════════════════════

class ZumradOnaTiliScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const ZumradOnaTiliScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<ZumradOnaTiliScreen> createState() => _ZumradOnaTiliScreenState();
}

class _ZumradOnaTiliScreenState extends State<ZumradOnaTiliScreen>
    with SingleTickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.intro;
  late final StoryGameState _story;

  late _WordQuestion _question;
  String? _selectedAnswer;
  bool _answered = false;
  bool _correct = false;
  int _questionNumber = 0;
  bool _sandiqOpen = false;

  late AnimationController _sandiqController;

  static const int _totalQuestions = 10;
  final _random = Random();
  final _questionPool = _buildQuestions();

  @override
  void initState() {
    super.initState();
    _story = StoryGameState(
      subject: StorySubject.onaTili,
      totalSteps: _totalQuestions,
    );
    _sandiqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _story.dispose();
    _sandiqController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final idx = _random.nextInt(_questionPool.length);
    _question = _questionPool[idx];
    _selectedAnswer = null;
    _answered = false;
    _correct = false;
  }

  String _getHint() {
    final hints = [
      '"${_question.questionText}" — savol so\'z manosini o\'ylab ko\'ring.',
      'Javoblarni birin-ketin o\'qing, qaysi biri to\'g\'ri tuyuladi?',
      '"${_question.answer}" so\'zi to\'g\'ri, chunki ${_question.explanation}',
    ];
    return hints[_random.nextInt(hints.length)];
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _correct = answer == _question.answer;
      _sandiqOpen = _correct;
    });

    if (_correct) {
      AudioService.instance.playCorrect();
      _sandiqController.forward(from: 0);
      _story.onCorrectAnswer();
    } else {
      AudioService.instance.playWrong();
      _sandiqController.reverse(from: 1);
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
        'ona_tili': (widget.profile.subjectProgress['ona_tili'] ?? 0) +
            _story.correctAnswers,
      },
    );
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GamePhase.intro => StoryIntroScreen(
          subject: StorySubject.onaTili,
          onStart: () => setState(() => _phase = _GamePhase.game),
        ),
      _GamePhase.game => _buildGameScreen(),
      _GamePhase.outro => StoryOutroScreen(
          subject: StorySubject.onaTili,
          score: _story.correctAnswers,
          totalQuestions: _totalQuestions,
          onReplay: () {
            _story.resetGame();
            _questionNumber = 0;
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
                  subject: StorySubject.onaTili,
                  onHelpTap: () {
                    showManzilaBotDialog(
                      context: context,
                      hint: _getHint(),
                      mood: 'helping',
                    );
                  },
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSandiqScene(),
          const SizedBox(height: 20),
          _buildQuestionCard(),
          const SizedBox(height: 16),
          Expanded(child: _buildAnswerGrid()),
        ],
      ),
    );
  }

  Widget _buildSandiqScene() {
    return AnimatedBuilder(
      animation: _sandiqController,
      builder: (_, __) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF7B1FA2).withOpacity(0.1),
              blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Zumrad
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _story.companionHappy ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 400),
                    child: const Text('👧', style: TextStyle(fontSize: 36)),
                  ),
                  Text(
                    'Zumrad',
                    style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Sandiq
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scaleY: 1.0 + 0.2 * _sandiqController.value,
                    child: Text(
                      _sandiqOpen ? '📦' : '🪄',
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                  Text(
                    _sandiqOpen ? 'OCHIQ!' : 'Yopiq',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: _sandiqOpen ? Colors.greenAccent : Colors.white38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              // Qimmat
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _story.companionHappy ? 0.4 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: const Text('😤', style: TextStyle(fontSize: 36)),
                  ),
                  Text(
                    'Qimmat',
                    style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF7B1FA2).withOpacity(0.1),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Text(_question.questionType, style: GoogleFonts.nunito(
          fontSize: 12, color: const Color(0xFF7B1FA2),
          fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(_question.questionText, style: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w900,
          color: Colors.black87, height: 1.4),
          textAlign: TextAlign.center),
        if (_answered) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _correct ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _correct
                ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)),
            ),
            child: Text(
              _correct ? '✅ To\'g\'ri! Sandiq ochilyapti!'
                : '❌ Xato! To\'g\'ri: "${_question.answer}"',
              style: GoogleFonts.nunito(fontSize: 13,
                color: _correct ? const Color(0xFF388E3C) : const Color(0xFFC62828),
                fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          ),
        ],
      ]),
    );
  }

  Widget _buildAnswerGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: _question.options.asMap().entries.map((e) {
        final opt = e.value;
        final isSelected = _selectedAnswer == opt;
        final isCorrect = opt == _question.answer;

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
          onTap: () => _selectAnswer(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Center(child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(opt, style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
                textAlign: TextAlign.center),
            )),
          ).animate(delay: Duration(milliseconds: 80 * e.key))
              .fadeIn(duration: 350.ms).slideY(begin: 0.2),
        );
      }).toList(),
    );
  }
}

// ── Bosqich ───────────────────────────────────────────────────────────────────
enum _GamePhase { intro, game, outro }

// ── So'z savoli ───────────────────────────────────────────────────────────────
class _WordQuestion {
  final String questionText;
  final String questionType;
  final String answer;
  final List<String> options;
  final String explanation;

  const _WordQuestion({
    required this.questionText,
    required this.questionType,
    required this.answer,
    required this.options,
    required this.explanation,
  });
}

List<_WordQuestion> _buildQuestions() => [
  const _WordQuestion(
    questionText: '"Kitob" so\'zining ko\'pligi qanday yoziladi?',
    questionType: 'Ko\'plik shakli',
    answer: 'Kitoblar',
    options: ['Kitoblar', 'Kitobni', 'Kitobda', 'Kitobga'],
    explanation: 'ko\'plik -lar qo\'shimchasi qo\'shiladi',
  ),
  const _WordQuestion(
    questionText: 'Qaysi so\'z to\'g\'ri yozilgan?',
    questionType: 'Imlo',
    answer: 'O\'qituvchi',
    options: ['O\'qituvchi', 'O\'qituwchi', 'Oqituvchi', 'O\'qitwchi'],
    explanation: 'o\' harfi apostrof bilan yoziladi',
  ),
  const _WordQuestion(
    questionText: '"Baxt" so\'zi qaysi turkumga kiradi?',
    questionType: 'So\'z turkumi',
    answer: 'Ot',
    options: ['Ot', 'Sifat', 'Fe\'l', 'Ravish'],
    explanation: 'ot — narsa-hodisani bildiradi',
  ),
  const _WordQuestion(
    questionText: 'Qaysi gapda vergul to\'g\'ri qo\'yilgan?',
    questionType: 'Tinish belgilari',
    answer: 'Meva, sabzavot va don ekildi.',
    options: [
      'Meva, sabzavot va don ekildi.',
      'Meva sabzavot, va don ekildi.',
      'Meva sabzavot va, don ekildi.',
      'Meva sabzavot va don, ekildi.',
    ],
    explanation: 'ro\'yxatdagi bir jinsli bo\'laklar vergul bilan ajratiladi',
  ),
  const _WordQuestion(
    questionText: '"Chiroyli" so\'zi qaysi so\'z turkumi?',
    questionType: 'So\'z turkumi',
    answer: 'Sifat',
    options: ['Sifat', 'Ot', 'Fe\'l', 'Son'],
    explanation: 'sifat — belgi-xususiyatni bildiradi',
  ),
  const _WordQuestion(
    questionText: 'O\'zbek alifbosida nechta harf bor?',
    questionType: 'Alifbo',
    answer: '29',
    options: ['29', '26', '31', '33'],
    explanation: 'o\'zbek lotin alifbosida 29 harf bor',
  ),
  const _WordQuestion(
    questionText: '"Men kutubxonada o\'qidim" — qaysi gap?',
    questionType: 'Gap turi',
    answer: 'Sodda gap',
    options: ['Sodda gap', 'Qo\'shma gap', 'Undov gap', 'Buyruq gap'],
    explanation: 'faqat bitta kesim bor — sodda gap',
  ),
  const _WordQuestion(
    questionText: 'Qaysi so\'z sinonimi — "Baland"?',
    questionType: 'Sinonim',
    answer: 'Uzun',
    options: ['Uzun', 'Kichik', 'Past', 'Tor'],
    explanation: 'baland va uzun ma\'nodosh so\'zlar',
  ),
  const _WordQuestion(
    questionText: '"Qalam" so\'zining antonimi?',
    questionType: 'Antonim',
    answer: 'Eraser (o\'chirg\'ich)',
    options: ['Eraser (o\'chirg\'ich)', 'Ruchka', 'Daftar', 'Kitob'],
    explanation: 'qalam yozadi, o\'chirg\'ich o\'chiradi — qarama-qarshi',
  ),
  const _WordQuestion(
    questionText: 'Qaysi gapda xato bor?',
    questionType: 'Xatoni top',
    answer: '"Men maktabga ketdim" to\'g\'ri.',
    options: [
      '"Men maktabga ketdim" to\'g\'ri.',
      '"Men maktabga ketdim" xato.',
      '"Men maktaba ketdim" to\'g\'ri.',
      '"Men maktabga ketdi" to\'g\'ri.',
    ],
    explanation: '"maktabga ketdim" to\'g\'ri shakldir',
  ),
];
