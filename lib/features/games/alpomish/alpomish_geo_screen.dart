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
// Alpomish Geografiya O'yini
// Bahodir Alpomish O'zbekiston bo'ylab Barchinoyni qidiradi
// Har viloyat/joy to'g'ri topilsa — Alpomish bir qadam oldinga bosadi
// ════════════════════════════════════════════════════════════════════════════

class AlpomishGeoScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const AlpomishGeoScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<AlpomishGeoScreen> createState() => _AlpomishGeoScreenState();
}

class _AlpomishGeoScreenState extends State<AlpomishGeoScreen>
    with SingleTickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.intro;
  late final StoryGameState _story;

  late _GeoQuestion _question;
  int? _selectedIndex;
  bool _answered = false;
  bool _correct = false;
  int _questionNumber = 0;

  late AnimationController _mapController;

  static const int _totalQuestions = 10;
  final _random = Random();
  final _questions = _buildGeoQuestions();

  // Alpomish joylashgan viloyat indeksi (0-12 Uzbekiston viloyatlari)
  int _regionIndex = 0;
  final _regions = [
    'Toshkent', 'Farg\'ona', 'Andijon', 'Namangan',
    'Samarqand', 'Buxoro', 'Qashqadaryo', 'Surxondaryo',
    'Jizzax', 'Sirdaryo', 'Navoiy', 'Xorazm', 'Qoraqalpog\'iston',
  ];

  @override
  void initState() {
    super.initState();
    _story = StoryGameState(
      subject: StorySubject.geografiya,
      totalSteps: _totalQuestions,
    );
    _mapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _story.dispose();
    _mapController.dispose();
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
      'Bu joy O\'zbekistonning ${_question.region} qismida.',
      '"${_question.hint}"',
      'Geografiya xaritasini ko\'z oldingizga keltiring!',
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
        _regionIndex = (_regionIndex + 1) % _regions.length;
      }
    });

    if (_correct) {
      AudioService.instance.playCorrect();
      _mapController.forward(from: 0);
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
        'geo': (widget.profile.subjectProgress['geo'] ?? 0) + _story.correctAnswers,
      },
    );
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _GamePhase.intro => StoryIntroScreen(
          subject: StorySubject.geografiya,
          onStart: () => setState(() => _phase = _GamePhase.game),
        ),
      _GamePhase.game => _buildGameScreen(),
      _GamePhase.outro => StoryOutroScreen(
          subject: StorySubject.geografiya,
          score: _story.correctAnswers,
          totalQuestions: _totalQuestions,
          onReplay: () {
            _story.resetGame();
            _questionNumber = 0;
            _regionIndex = 0;
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
                  subject: StorySubject.geografiya,
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
          _buildMapScene(),
          const SizedBox(height: 14),
          _buildQuestionCard(),
          const SizedBox(height: 14),
          Expanded(child: _buildAnswerOptions()),
        ],
      ),
    );
  }

  Widget _buildMapScene() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Alpomish
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _mapController,
                builder: (_, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.15 * sin(_mapController.value * pi),
                    child: child,
                  );
                },
                child: const Text('🦸‍♂️', style: TextStyle(fontSize: 36)),
              ),
              Text(
                'Alpomish',
                style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Viloyatlar yo'li
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hozir: ${_regions[_regionIndex % _regions.length]}',
                  style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: _story.progressPct,
                  minHeight: 8,
                  backgroundColor: Colors.white20,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF81D4FA)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_story.currentStep}/$_totalQuestions viloyatdan o\'tdi',
                  style: GoogleFonts.nunito(
                    fontSize: 10, color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Barchinoy (manzil)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _story.companionHappy ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 500),
                child: const Text('👸', style: TextStyle(fontSize: 36)),
              ),
              Text(
                'Barchinoy',
                style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
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
              Text(
                _question.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 6),
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
          Text(
            _question.question,
            style: GoogleFonts.nunito(
              fontSize: 18, fontWeight: FontWeight.w900,
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
                    ? '✅ To\'g\'ri! Alpomish oldinga!'
                    : '❌ Xato! To\'g\'ri: "${_question.options[_question.correctIndex]}"',
                style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_question.funFact.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '🗺️ ${_question.funFact}',
                style: GoogleFonts.nunito(
                  fontSize: 11, color: Colors.white54,
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
            child: Center(child: Text(opt, style: GoogleFonts.nunito(
              fontSize: 14, color: textColor, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center)),
          ).animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        );
      }).toList(),
    );
  }
}

enum _GamePhase { intro, game, outro }

class _GeoQuestion {
  final String question;
  final String category;
  final String emoji;
  final String region;
  final List<String> options;
  final int correctIndex;
  final String funFact;
  final String hint;

  const _GeoQuestion({
    required this.question,
    required this.category,
    required this.emoji,
    required this.region,
    required this.options,
    required this.correctIndex,
    required this.funFact,
    required this.hint,
  });
}

List<_GeoQuestion> _buildGeoQuestions() => [
  const _GeoQuestion(
    question: 'O\'zbekistonning poytaxti qaysi shahar?',
    category: 'Poytaxt',
    emoji: '🏛️',
    region: 'markaziy',
    options: ['Toshkent', 'Samarqand', 'Namangan', 'Buxoro'],
    correctIndex: 0,
    funFact: 'Toshkent — 2000+ yillik tarixga ega.',
    hint: 'O\'zbekistonning eng katta shahri',
  ),
  const _GeoQuestion(
    question: 'O\'zbekiston qancha viloyatdan iborat?',
    category: 'Ma\'muriy bo\'linish',
    emoji: '🗺️',
    region: 'barcha',
    options: ['12 viloyat + 1 respublika', '14 viloyat', '10 viloyat', '15 viloyat'],
    correctIndex: 0,
    funFact: 'Qoraqalpog\'iston — avtonom respublika.',
    hint: '12 + Qoraqalpog\'iston',
  ),
  const _GeoQuestion(
    question: 'O\'rta Osiyo\'ning eng katta ko\'li qaysi?',
    category: 'Ko\'llar',
    emoji: '🏞️',
    region: 'shimoliy',
    options: ['Orol dengizi', 'Aydar ko\'li', 'Charvak suv ombori', 'Chimyon'],
    correctIndex: 0,
    funFact: 'Orol dengizi qurishdan oldin dunyoning 4-chi eng katta ko\'li edi.',
    hint: 'Ilgari juda katta bo\'lgan',
  ),
  const _GeoQuestion(
    question: 'O\'zbekistondagi eng baland tog\' qaysi?',
    category: 'Tog\'lar',
    emoji: '🏔️',
    region: 'sharqiy',
    options: [
      'Hazrat Sultan (4643m)',
      'Chimyon tog\'i',
      'Baysun',
      'Ko\'hitang',
    ],
    correctIndex: 0,
    funFact: 'Hazrat Sultan — Surxondaryo va Tojikiston chegarasida.',
    hint: 'O\'zbekistondagi eng baland nuqta',
  ),
  const _GeoQuestion(
    question: 'Sirdaryo va Amudaryo qaysi dengizga quyiladi?',
    category: 'Daryolar',
    emoji: '🌊',
    region: 'barcha',
    options: ['Orol dengiziga', 'Kaspiy dengiziga', 'Qora dengizga', 'Fors ko\'rfaziga'],
    correctIndex: 0,
    funFact: 'Bu ikki daryo tarixan O\'rta Osiyoning "hayot tomirlari" bo\'lgan.',
    hint: 'O\'zbekistondagi yirik daryolar',
  ),
  const _GeoQuestion(
    question: 'Qaysi shahar "Ko\'hna shahar" nomi bilan mashhur?',
    category: 'Shaharlar',
    emoji: '🏙️',
    region: 'g\'arbiy',
    options: ['Xiva', 'Samarqand', 'Termiz', 'Shahrisabz'],
    correctIndex: 0,
    funFact: 'Xiva — Ichon-qal\'a UNESCO Jahon merosi ro\'yxatida.',
    hint: 'Xorazm o\'lkasidagi qadimiy shahar',
  ),
  const _GeoQuestion(
    question: 'Farg\'ona vodiysi qaysi tog\'lar orasida?',
    category: 'Jug\'rofiy joy',
    emoji: '🏕️',
    region: 'sharqiy',
    options: ['Tyan-Shan va Pomir', 'Hindukush', 'Qoratog\'', 'Zarafshon'],
    correctIndex: 0,
    funFact: 'Farg\'ona vodiysi — O\'rta Osiyoning eng sernah o\'lkasi.',
    hint: 'Sharqiy O\'zbekiston vodiysi',
  ),
  const _GeoQuestion(
    question: 'O\'zbekistonning qaysi shahri "Yulduzlar shahri" deb ataladi?',
    category: 'Shaharlar',
    emoji: '⭐',
    region: 'markaziy',
    options: ['Samarqand', 'Toshkent', 'Buxoro', 'Namangan'],
    correctIndex: 0,
    funFact: 'Samarqand — Ulug\'bek rasadxonasi shahri.',
    hint: 'Ulug\'bek yulduzlarni o\'rgangan shahar',
  ),
  const _GeoQuestion(
    question: 'Amudaryo qaysi tog\'dan boshlanadi?',
    category: 'Daryolar',
    emoji: '🏔️',
    region: 'janubiy',
    options: ['Pomir tog\'laridan', 'Tyan-Shan\'dan', 'Hindukush\'dan', 'Zarafshon\'dan'],
    correctIndex: 0,
    funFact: 'Amudaryo Vaxsh va Panj daryolarining qo\'shilishidan hosil bo\'ladi.',
    hint: 'Eng baland tog\'lardan biridan',
  ),
  const _GeoQuestion(
    question: 'O\'zbekiston qaysi materikda joylashgan?',
    category: 'Materiklar',
    emoji: '🌍',
    region: 'barcha',
    options: ['Yevrosiyo', 'Afrika', 'Shimoliy Amerika', 'Janubiy Amerika'],
    correctIndex: 0,
    funFact: 'O\'zbekiston — ikki qit\'a chegarasida joylashgan.',
    hint: 'Yevropa va Osiyo birlashgan materik',
  ),
];
