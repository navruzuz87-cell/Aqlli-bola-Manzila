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
// Shiroq Tarix O'yini
// Cho'pon Shiroq dushmanlarni chalg'itadi — to'g'ri tarix = g'alaba
// ════════════════════════════════════════════════════════════════════════════

class ShiroqHistoryScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const ShiroqHistoryScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<ShiroqHistoryScreen> createState() => _ShiroqHistoryScreenState();
}

class _ShiroqHistoryScreenState extends State<ShiroqHistoryScreen>
    with SingleTickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.intro;
  late final StoryGameState _story;

  late _HistoryQuestion _question;
  int? _selectedIndex;
  bool _answered = false;
  bool _correct = false;
  int _questionNumber = 0;

  late AnimationController _battleController;

  static const int _totalQuestions = 10;
  final _random = Random();
  final _questions = _buildHistoryQuestions();

  int _shiroqMorale = 5; // 0-5 jangdagi ruh

  @override
  void initState() {
    super.initState();
    _story = StoryGameState(
      subject: StorySubject.tarix,
      totalSteps: _totalQuestions,
    );
    _battleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _story.dispose();
    _battleController.dispose();
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
      'Bu voqea "${_question.era}" davrida bo\'lgan.',
      'Javob: "${_question.hint}"',
      'Tariximizni o\'rgan — Shiroqqa kuch ber!',
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
        _shiroqMorale = (_shiroqMorale + 1).clamp(0, 5);
      } else {
        _shiroqMorale = (_shiroqMorale - 1).clamp(0, 5);
      }
    });

    if (_correct) {
      AudioService.instance.playCorrect();
      _battleController.forward(from: 0);
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
        'tarix': (widget.profile.subjectProgress['tarix'] ?? 0) +
            _story.correctAnswers,
      },
    );
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GamePhase.intro => StoryIntroScreen(
          subject: StorySubject.tarix,
          onStart: () => setState(() => _phase = _GamePhase.game),
        ),
      _GamePhase.game => _buildGameScreen(),
      _GamePhase.outro => StoryOutroScreen(
          subject: StorySubject.tarix,
          score: _story.correctAnswers,
          totalQuestions: _totalQuestions,
          onReplay: () {
            _story.resetGame();
            _questionNumber = 0;
            _shiroqMorale = 5;
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
                  subject: StorySubject.tarix,
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
          _buildBattleScene(),
          const SizedBox(height: 16),
          _buildEraTag(),
          const SizedBox(height: 10),
          _buildQuestionCard(),
          const SizedBox(height: 14),
          Expanded(child: _buildAnswers()),
        ],
      ),
    );
  }

  Widget _buildBattleScene() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shiroq
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _battleController,
                builder: (_, child) {
                  final x = 4.0 * sin(_battleController.value * pi * 4);
                  return Transform.translate(
                    offset: Offset(x, 0),
                    child: child,
                  );
                },
                child: const Text('🧑‍🌾', style: TextStyle(fontSize: 36)),
              ),
              Row(
                children: List.generate(5, (i) => Text(
                  i < _shiroqMorale ? '🔥' : '💀',
                  style: const TextStyle(fontSize: 10),
                )),
              ),
            ],
          ),
          // O'rtada ⚔️
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 32)),
              Text(
                'Savol ${_questionNumber + 1}/$_totalQuestions',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          // Dushman
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _story.companionHappy ? 0.4 : 0.9,
                duration: const Duration(milliseconds: 500),
                child: const Text('⚔️🏇', style: TextStyle(fontSize: 32)),
              ),
              Text(
                _story.companionHappy ? 'Chalg\'idi' : 'Hujumda',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: _story.companionHappy ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEraTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white20),
      ),
      child: Text(
        '🏛️ Davr: ${_question.era}',
        style: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.white70,
          fontWeight: FontWeight.w700,
        ),
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
          Text(
            _question.question,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.4,
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
                    ? '✅ To\'g\'ri! Shiroq dushmanni chalg\'itdi!'
                    : '❌ Xato! To\'g\'ri: "${_question.options[_question.correctIndex]}"',
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_question.explanation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '📖 ${_question.explanation}',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnswers() {
    return ListView.builder(
      itemCount: _question.options.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final opt = _question.options[i];
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
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(['A', 'B', 'C', 'D'][i],
                  style: GoogleFonts.nunito(fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC62828)))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(opt, style: GoogleFonts.nunito(
                fontSize: 14, color: textColor, fontWeight: FontWeight.w700))),
              if (_answered && isCorrect)
                const Text('✅', style: TextStyle(fontSize: 18)),
              if (_answered && isSelected && !isCorrect)
                const Text('❌', style: TextStyle(fontSize: 18)),
            ]),
          ).animate(delay: Duration(milliseconds: 60 * i))
              .fadeIn(duration: 300.ms).slideX(begin: -0.2),
        );
      },
    );
  }
}

enum _GamePhase { intro, game, outro }

class _HistoryQuestion {
  final String question;
  final String era;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;

  const _HistoryQuestion({
    required this.question,
    required this.era,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
  });
}

List<_HistoryQuestion> _buildHistoryQuestions() => [
  const _HistoryQuestion(
    question: 'Qadim Yunon podshohi Kim bo\'lgan?',
    era: 'Mil. avv. IV asr',
    options: ['Iskandar Zulqarnayn', 'Qaysar', 'Davriy', 'Doro'],
    correctIndex: 0,
    explanation: 'Iskandar Zulqarnayn (Aleksandr Makedonskiy) yunon qo\'shinlarini boshqargan.',
    hint: 'Iskandar nomi bilan ham tanilgan',
  ),
  const _HistoryQuestion(
    question: 'Shiroq qaysi qavmning vakili bo\'lgan?',
    era: 'Mil. avv. VI-V asr',
    options: ['Saklar', 'Yunon', 'Fors', 'Massagetlar'],
    correctIndex: 0,
    explanation: 'Shiroq — sak qavmidan jasur cho\'pon.',
    hint: 'O\'rta Osiyo ko\'chmanchi qavmi',
  ),
  const _HistoryQuestion(
    question: 'Tumarisxon kim bo\'lgan?',
    era: 'Mil. avv. VI asr',
    options: [
      'Massagetlar malikasi',
      'Yunon shohzodasi',
      'Fors shohzodasi',
      'Sak qo\'mondoni',
    ],
    correctIndex: 0,
    explanation: 'Tumarisxon — massagetlar malikasi, Kir II ni mag\'lub qildi.',
    hint: 'Ayol hukmdor — massagetlar',
  ),
  const _HistoryQuestion(
    question: 'Ipak yo\'li qachon paydo bo\'lgan?',
    era: 'Mil. avv. II asr',
    options: [
      'Mil. avv. II asrda',
      'Mil. avv. V asrda',
      'Mil. 1-asrda',
      'Mil. III asrda',
    ],
    correctIndex: 0,
    explanation: 'Xitoy imperatori Vudi davrida ipak yo\'li tashkil etildi.',
    hint: 'Xitoydan G\'arbga savdo yo\'li',
  ),
  const _HistoryQuestion(
    question: 'Samarqand qachon asos solingan?',
    era: 'Qadimgi tarix',
    options: [
      'Mil. avv. VIII-VII asrlarda',
      'Mil. 1-asrda',
      'Mil. 500-yili',
      'Mil. 1000-yili',
    ],
    correctIndex: 0,
    explanation: 'Samarqand dunyoning eng qadimgi shaharlaridan biri — 2700+ yillik tarix.',
    hint: 'O\'zbekistonning qadimiy markazi',
  ),
  const _HistoryQuestion(
    question: 'Temur kim edi?',
    era: 'XIV-XV asrlar',
    options: [
      'Amir Temur — sohibqiron',
      'Yunon shohi',
      'Mo\'g\'ul xoni',
      'Rus podshosi',
    ],
    correctIndex: 0,
    explanation: 'Amir Temur — 1370-1405 yillarda Movarounnahrni idora etgan buyuk sarkarda.',
    hint: 'Sohibqiron — kuchli hukmdor',
  ),
  const _HistoryQuestion(
    question: 'Ulug\'bek kim bo\'lgan?',
    era: 'XV asr',
    options: [
      'Olim va hukmdor',
      'Sarkarda',
      'Savdogar',
      'Cho\'pon',
    ],
    correctIndex: 0,
    explanation: 'Muhammad Tarag\'ay Ulug\'bek — astronom olim va Samarqand hukmdori.',
    hint: 'Rasadxona qurdirgan',
  ),
  const _HistoryQuestion(
    question: 'Navoiy qaysi asrda yashagan?',
    era: 'XV asr',
    options: ['XV asr', 'XIV asr', 'XVI asr', 'XIII asr'],
    correctIndex: 0,
    explanation: 'Alisher Navoiy (1441-1501) — o\'zbek adabiyotining otasi.',
    hint: 'O\'zbek klassik shoiri',
  ),
  const _HistoryQuestion(
    question: 'O\'zbekiston qachon mustaqil bo\'ldi?',
    era: 'XX asr',
    options: ['1991-yil', '1990-yil', '1992-yil', '1989-yil'],
    correctIndex: 0,
    explanation: 'O\'zbekiston 1991-yil 1-sentyabrda mustaqillikka erishdi.',
    hint: 'Mustaqillik kuni — 1-sentyabr',
  ),
  const _HistoryQuestion(
    question: 'Xorazm qadim davlatida qaysi alfavit ishlatilgan?',
    era: 'Mil. avv. IV-III asr',
    options: [
      'Xorazm yozuvi',
      'Lotin yozuvi',
      'Arab yozuvi',
      'Kirill yozuvi',
    ],
    correctIndex: 0,
    explanation: 'Qadim Xorazmda o\'ziga xos Xorazm yozuvi mavjud bo\'lgan.',
    hint: 'Mahalliy qadimiy yozuv',
  ),
];
