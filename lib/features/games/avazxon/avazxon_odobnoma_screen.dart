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
// Avazxon Odobnoma O'yini
// Avazxon yangi mahallaga ko'chib keldi — to'yda yaxshi xulq ko'rsatishi kerak
// To'g'ri xulq = qo'shnilar sevadi, xato = ular xafa
// ════════════════════════════════════════════════════════════════════════════

class AvazxonOdobnomaScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const AvazxonOdobnomaScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<AvazxonOdobnomaScreen> createState() => _AvazxonOdobnomaScreenState();
}

class _AvazxonOdobnomaScreenState extends State<AvazxonOdobnomaScreen>
    with SingleTickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.intro;
  late final StoryGameState _story;

  late _OdobQuestion _question;
  int? _selectedIndex;
  bool _answered = false;
  bool _correct = false;
  int _questionNumber = 0;
  int _neighborHappiness = 3; // 0-5

  late AnimationController _cheerController;

  static const int _totalQuestions = 10;
  final _random = Random();
  final _questions = _buildOdobQuestions();

  @override
  void initState() {
    super.initState();
    _story = StoryGameState(
      subject: StorySubject.odobnoma,
      totalSteps: _totalQuestions,
    );
    _cheerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _story.dispose();
    _cheerController.dispose();
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
      'Yaxshi xulq — odobli, hurmatli, mehribon bo\'lishdir.',
      '${_question.hint}',
      'Avazxon o\'rnida bo\'lsang, nima qilarding?',
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
        _neighborHappiness = (_neighborHappiness + 1).clamp(0, 5);
      } else {
        _neighborHappiness = (_neighborHappiness - 1).clamp(0, 5);
      }
    });

    if (_correct) {
      AudioService.instance.playCorrect();
      _cheerController.forward(from: 0);
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
        'odobnoma': (widget.profile.subjectProgress['odobnoma'] ?? 0) +
            _story.correctAnswers,
      },
    );
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GamePhase.intro => StoryIntroScreen(
          subject: StorySubject.odobnoma,
          onStart: () => setState(() => _phase = _GamePhase.game),
        ),
      _GamePhase.game => _buildGameScreen(),
      _GamePhase.outro => StoryOutroScreen(
          subject: StorySubject.odobnoma,
          score: _story.correctAnswers,
          totalQuestions: _totalQuestions,
          onReplay: () {
            _story.resetGame();
            _questionNumber = 0;
            _neighborHappiness = 3;
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
                  subject: StorySubject.odobnoma,
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
          _buildMahallScene(),
          const SizedBox(height: 14),
          _buildScenarioCard(),
          const SizedBox(height: 14),
          Expanded(child: _buildChoices()),
        ],
      ),
    );
  }

  Widget _buildMahallScene() {
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
          // Avazxon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _cheerController,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, -4.0 * _cheerController.value),
                    child: child,
                  );
                },
                child: const Text('👦', style: TextStyle(fontSize: 36)),
              ),
              Text('Avazxon',
                style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Mahalla
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏡', style: TextStyle(fontSize: 28)),
              Text(
                _neighborHappiness >= 3 ? 'Do\'stlar!😊' : 'Xafa😔',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: _neighborHappiness >= 3
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Qo'shnilar
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: List.generate(5, (i) => Text(
                  i < _neighborHappiness ? '😊' : '😐',
                  style: const TextStyle(fontSize: 14),
                )),
              ),
              Text('Qo\'shnilar',
                style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard() {
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
              Text(_question.sceneEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                _question.scene,
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stsenariy matni
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _question.scenario,
              style: GoogleFonts.nunito(
                fontSize: 14, color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _question.questionText,
            style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w900,
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
                    ? '✅ Juda zo\'r! Qo\'shnilar seni yaxshi ko\'radi!'
                    : '❌ ${_question.wrongFeedback}',
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_correct && _question.correctFeedback.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '💡 ${_question.correctFeedback}',
                style: GoogleFonts.nunito(
                  fontSize: 11, color: Colors.white60,
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

  Widget _buildChoices() {
    return ListView.builder(
      itemCount: _question.choices.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final choice = _question.choices[i];
        final isSelected = _selectedIndex == i;
        final isCorrect = i == _question.correctIndex;

        Color bgColor;
        Color borderColor;
        Color textColor;
        IconData? trailingIcon;
        if (!_answered) {
          bgColor = Colors.white;
          borderColor = const Color(0xFFE0E0E0);
          textColor = Colors.black87;
        } else if (isCorrect) {
          bgColor = const Color(0xFFE8F5E9);
          borderColor = const Color(0xFF4CAF50);
          textColor = const Color(0xFF388E3C);
          trailingIcon = Icons.check_circle;
        } else if (isSelected) {
          bgColor = const Color(0xFFFFEBEE);
          borderColor = const Color(0xFFEF5350);
          textColor = const Color(0xFFC62828);
          trailingIcon = Icons.cancel;
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
              Text(choice.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(choice.text, style: GoogleFonts.nunito(
                fontSize: 14, color: textColor, fontWeight: FontWeight.w700))),
              if (trailingIcon != null)
                Icon(trailingIcon,
                  color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                  size: 20),
            ]),
          ).animate(delay: Duration(milliseconds: 60 * i))
              .fadeIn(duration: 300.ms).slideX(begin: -0.15),
        );
      },
    );
  }
}

enum _GamePhase { intro, game, outro }

class _OdobChoice {
  final String text;
  final String emoji;
  const _OdobChoice({required this.text, required this.emoji});
}

class _OdobQuestion {
  final String scenario;
  final String questionText;
  final String scene;
  final String sceneEmoji;
  final List<_OdobChoice> choices;
  final int correctIndex;
  final String correctFeedback;
  final String wrongFeedback;
  final String hint;

  const _OdobQuestion({
    required this.scenario,
    required this.questionText,
    required this.scene,
    required this.sceneEmoji,
    required this.choices,
    required this.correctIndex,
    required this.correctFeedback,
    required this.wrongFeedback,
    required this.hint,
  });
}

List<_OdobQuestion> _buildOdobQuestions() => [
  const _OdobQuestion(
    scenario: 'Avazxon to\'yga keldi. Dasturxon boshlandi. Kattalar hali ovqatlanmagan.',
    questionText: 'Avazxon nima qilishi kerak?',
    scene: 'To\'y dasturxoni',
    sceneEmoji: '🍽️',
    choices: [
      _OdobChoice(text: 'Kattalar boshlagach, o\'zi ham boshlaydi', emoji: '🙏'),
      _OdobChoice(text: 'Darhol ovqatlanib oladi', emoji: '😋'),
      _OdobChoice(text: 'Ovqatni oladi, lekin yemaydi', emoji: '🤔'),
      _OdobChoice(text: 'Ovqat yoqmasligini aytadi', emoji: '😒'),
    ],
    correctIndex: 0,
    correctFeedback: 'Kattalarni hurmat qilish — to\'yda asosiy qoida!',
    wrongFeedback: 'Kattalar boshlaguncha kutish kerak edi.',
    hint: 'Kattalarni hurmat qilish muhim',
  ),
  const _OdobQuestion(
    scenario: 'Qo\'shni keksa buvi Avazxonni ko\'rganda salom berdi.',
    questionText: 'Avazxon qanday javob qaytarishi kerak?',
    scene: 'Ko\'chada uchrashuv',
    sceneEmoji: '👋',
    choices: [
      _OdobChoice(text: 'Bosh egib, "Assalomu alaykum!" deydi', emoji: '😊'),
      _OdobChoice(text: 'Davom etib ketadi', emoji: '🚶'),
      _OdobChoice(text: 'Faqat qo\'l silkitadi', emoji: '👋'),
      _OdobChoice(text: '"Yaxshimisiz?" deydi, salom bermaydi', emoji: '😶'),
    ],
    correctIndex: 0,
    correctFeedback: 'Salom berish — hurmat belgisi, bu juda to\'g\'ri!',
    wrongFeedback: 'Kattalarning salomiga javob berish shart.',
    hint: 'O\'zbek an\'anasida salom',
  ),
  const _OdobQuestion(
    scenario: 'To\'yda bir bola boshqasining oldiga o\'tib, qolipni buzdi.',
    questionText: 'Bu harakat qanday?',
    scene: 'To\'y navbati',
    sceneEmoji: '🎉',
    choices: [
      _OdobChoice(text: 'Noto\'g\'ri — navbatni buzish odobsizlik', emoji: '❌'),
      _OdobChoice(text: 'To\'g\'ri — tez bo\'lgani yaxshi', emoji: '✅'),
      _OdobChoice(text: 'Farqi yo\'q', emoji: '😐'),
      _OdobChoice(text: 'Faqat kichiklar uchun to\'g\'ri', emoji: '👶'),
    ],
    correctIndex: 0,
    correctFeedback: 'Navbatni kutish — odobli insonning belgisi.',
    wrongFeedback: 'Navbatni buzish hech qachon to\'g\'ri emas.',
    hint: 'Navbat va sabr',
  ),
  const _OdobQuestion(
    scenario: 'Avazxon uxlab yotgan paytda telefon qo\'ng\'iroq qildi. Bu qo\'shni edi.',
    questionText: 'Avazxon ertalab nima qilishi kerak?',
    scene: 'Qo\'ng\'iroqqa javob',
    sceneEmoji: '📱',
    choices: [
      _OdobChoice(text: 'Ertalab qo\'ng\'iroq qilib, uzr so\'raydi', emoji: '🤝'),
      _OdobChoice(text: 'Hech narsa qilmaydi', emoji: '😶'),
      _OdobChoice(text: 'Qo\'shni yomon deydi', emoji: '😤'),
      _OdobChoice(text: 'Telefon raqamini o\'chiradi', emoji: '🚫'),
    ],
    correctIndex: 0,
    correctFeedback: 'Uzr so\'rash — ulug\'lik belgisi, bu juda to\'g\'ri!',
    wrongFeedback: 'Uzr so\'rash to\'g\'ri edi.',
    hint: 'Uzr so\'rash kattalikning belgisi',
  ),
  const _OdobQuestion(
    scenario: 'Maktabda o\'qituvchi savolga javob so\'radi. Avazxon biladi.',
    questionText: 'U nima qilishi kerak?',
    scene: 'Dars vaqtida',
    sceneEmoji: '🏫',
    choices: [
      _OdobChoice(text: 'Qo\'l ko\'tarib, ruxsat so\'raydi', emoji: '✋'),
      _OdobChoice(text: 'Darhol baqirib javob beradi', emoji: '📢'),
      _OdobChoice(text: 'Boshqasiga aytadi', emoji: '🤫'),
      _OdobChoice(text: 'Sukut saqlaydi', emoji: '😶'),
    ],
    correctIndex: 0,
    correctFeedback: 'Qo\'l ko\'tarish — tartibli, odobli muloqot!',
    wrongFeedback: 'Qo\'l ko\'tarib ruxsat so\'rash kerak edi.',
    hint: 'Darsda intizom',
  ),
  const _OdobQuestion(
    scenario: 'To\'yda katta dasturxon tugatildi. Avazxon ham to\'ydi.',
    questionText: 'Dasturxondan turish oldidan nima deydi?',
    scene: 'Ovqatdan keyin',
    sceneEmoji: '🙌',
    choices: [
      _OdobChoice(text: '"Rahmat, ovqat mazali edi!" deydi', emoji: '😊'),
      _OdobChoice(text: 'Hech narsa demay ketadi', emoji: '🚶'),
      _OdobChoice(text: '"Ko\'proq ber!" deydi', emoji: '😋'),
      _OdobChoice(text: 'Ovqatni tanqid qiladi', emoji: '😒'),
    ],
    correctIndex: 0,
    correctFeedback: 'Rahmat aytish — mehmon va mezbon munosabatining asosi!',
    wrongFeedback: 'Mezbonlarga rahmat aytish zarur edi.',
    hint: 'Rahmat aytish odob',
  ),
  const _OdobQuestion(
    scenario: 'Avazxon xato qildi va do\'stini xafa qildi.',
    questionText: 'U nima qilishi kerak?',
    scene: 'Do\'stlik',
    sceneEmoji: '🤝',
    choices: [
      _OdobChoice(text: 'Uzr so\'rab, to\'g\'rilaydi', emoji: '🙏'),
      _OdobChoice(text: 'Yashirinadi', emoji: '🙈'),
      _OdobChoice(text: 'Do\'stini gunohkor deydi', emoji: '👉'),
      _OdobChoice(text: 'E\'tibor bermaydi', emoji: '😐'),
    ],
    correctIndex: 0,
    correctFeedback: 'Uzr so\'rash mardlik! Avazxon katta inson.',
    wrongFeedback: 'Xatoni tan olib, uzr so\'rash eng to\'g\'ri yo\'l.',
    hint: 'Uzr so\'rash mardlik belgisi',
  ),
  const _OdobQuestion(
    scenario: 'Kichik uka yo\'lda yiqildi. Avazxon ko\'rdi.',
    questionText: 'Avazxon nima qiladi?',
    scene: 'Ko\'chada',
    sceneEmoji: '🤲',
    choices: [
      _OdobChoice(text: 'Qo\'lini uzatib, turgizadi', emoji: '🤝'),
      _OdobChoice(text: 'Davom etib ketadi', emoji: '🚶'),
      _OdobChoice(text: 'Kuladi', emoji: '😄'),
      _OdobChoice(text: 'Boshqasiga aytadi', emoji: '📢'),
    ],
    correctIndex: 0,
    correctFeedback: 'Yordamga shoshilish — insoniylikning belgisi!',
    wrongFeedback: 'Yiqilganga yordam berish zarur edi.',
    hint: 'Yordam berish fazilat',
  ),
  const _OdobQuestion(
    scenario: 'To\'yda qo\'shiq kuylandi. Avazxon qo\'shiqni yoqtirmadi.',
    questionText: 'U nima qilishi kerak?',
    scene: 'To\'y bazmi',
    sceneEmoji: '🎵',
    choices: [
      _OdobChoice(text: 'Sukut saqlaydi, boshqalarni bezovta qilmaydi', emoji: '🤐'),
      _OdobChoice(text: 'Baqirib tanqid qiladi', emoji: '📣'),
      _OdobChoice(text: 'Ketib qoladi', emoji: '🚪'),
      _OdobChoice(text: 'Yonidagilarga shikoyat qiladi', emoji: '😒'),
    ],
    correctIndex: 0,
    correctFeedback: 'Hamma narsani yoqtirishga majburiy emasmiz, lekin odob saqlanadi!',
    wrongFeedback: 'Sukut saqlash va to\'yni bezovta qilmaslik odob.',
    hint: 'O\'z fikrni odobli ifodalash',
  ),
  const _OdobQuestion(
    scenario: 'Katta amaki Avazxonga sovg\'a berdi.',
    questionText: 'Avazxon sovg\'ani olib nima qiladi?',
    scene: 'Sovg\'a',
    sceneEmoji: '🎁',
    choices: [
      _OdobChoice(text: 'Ikki qo\'llab olib, "Rahmat!" deydi', emoji: '🙏'),
      _OdobChoice(text: 'Bir qo\'l bilan tortib oladi', emoji: '✊'),
      _OdobChoice(text: 'Sovg\'ani ko\'rmaydi', emoji: '😶'),
      _OdobChoice(text: '"Bu menga kichik" deydi', emoji: '😒'),
    ],
    correctIndex: 0,
    correctFeedback: 'Ikki qo\'l bilan olish va rahmat aytish — o\'zbek odobining asosi!',
    wrongFeedback: 'Ikki qo\'l bilan olib, rahmat aytish kerak edi.',
    hint: 'Ikki qo\'l bilan olish odob',
  ),
];
