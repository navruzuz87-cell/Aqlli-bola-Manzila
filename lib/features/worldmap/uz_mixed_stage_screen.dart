import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/uzbekistan_map.dart';
import 'game_modes/drag_drop_game.dart';
import 'game_modes/speed_tap_game.dart';
import 'game_modes/fill_blank_game.dart';
import 'game_modes/order_sequence_game.dart';
import 'game_modes/true_false_chain_game.dart';

// ════════════════════════════════════════════════════════════════════════════
// UZ MIXED STAGE SCREEN — Aralash o'yin mexanikali bosqich
// Har bosqich = 3-4 ta turli o'yin turi ketma-ket
// Zerikarlilik yo'q — har daqiqa yangi mexanika!
// ════════════════════════════════════════════════════════════════════════════

enum GameModeType { multipleChoice, dragDrop, speedTap, fillBlank, orderSequence, trueFalse }

class MixedRound {
  final GameModeType mode;
  final String title;
  final String emoji;
  final dynamic data; // GameMode-specific data

  const MixedRound({
    required this.mode,
    required this.title,
    required this.emoji,
    required this.data,
  });
}

class UzMixedStageScreen extends StatefulWidget {
  final UzRegion region;
  final int cityIdx;
  final int stageIdx;
  final Function(int stars) onComplete;

  const UzMixedStageScreen({
    super.key,
    required this.region,
    required this.cityIdx,
    required this.stageIdx,
    required this.onComplete,
  });

  @override
  State<UzMixedStageScreen> createState() => _UzMixedStageScreenState();
}

class _UzMixedStageScreenState extends State<UzMixedStageScreen> {
  late UzRegionData _regionData;
  late List<MixedRound> _rounds;
  int _currentRound = 0;
  int _totalScore = 0;
  int _totalMax = 0;
  bool _showIntro = true;
  bool _showRoundComplete = false;
  int _lastScore = 0;
  int _lastMax = 1;

  @override
  void initState() {
    super.initState();
    _regionData = UzbekistanMap.getRegion(widget.region);
    _rounds = _buildRounds();
    // 2 soniya intro
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showIntro = false);
    });
  }

  List<MixedRound> _buildRounds() {
    // Viloyat va shahar bo'yicha turli raundlar
    // Haqiqiy ma'lumotlar bilan
    final regionName = _regionData.name;
    final cityName = _regionData.cities[widget.cityIdx].name;

    switch (widget.region) {
      case UzRegion.toshkentShahar:
        return _toshkentRounds(widget.cityIdx, widget.stageIdx);
      case UzRegion.samarqand:
        return _samarqandRounds(widget.cityIdx, widget.stageIdx);
      case UzRegion.buxoro:
        return _buxoroRounds(widget.cityIdx, widget.stageIdx);
      case UzRegion.xorazm:
        return _xorazmRounds(widget.cityIdx, widget.stageIdx);
      default:
        return _defaultRounds(regionName, cityName);
    }
  }

  // ─── TOSHKENT RAUNDLARI ───────────────────────────────────────────────────
  List<MixedRound> _toshkentRounds(int city, int stage) {
    if (city == 0 && stage == 0) return [
      // Raund 1: Ha/Yo'q — Toshkent faktlari
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Ha yoki Yo\'q?',
        emoji: '❓',
        data: const [
          TrueFalseStatement(statement: 'Toshkent O\'rta Osiyodagi eng katta shahar', isTrue: true, emoji: '🏙️', explanation: 'Ha! 2.5+ million aholi bilan eng yirik'),
          TrueFalseStatement(statement: 'Toshkent metrost 1960-yilda ochilgan', isTrue: false, emoji: '🚇', explanation: 'Yo\'q! 1977-yilda ochilgan'),
          TrueFalseStatement(statement: 'Chorsu bozori 2000 yillik tarixga ega', isTrue: true, emoji: '🛒', explanation: 'Ha! Juda qadimiy bozor'),
          TrueFalseStatement(statement: 'O\'zbekiston 1991-yilda mustaqil bo\'ldi', isTrue: true, emoji: '🇺🇿', explanation: 'Ha! 31 avgust 1991-yil'),
          TrueFalseStatement(statement: 'Toshkentda zilzila bo\'lmagan', isTrue: false, emoji: '🌍', explanation: 'Yo\'q! 1966-yili kuchli zilzila bo\'lgan'),
        ],
      ),
      // Raund 2: Juftlashtirish
      MixedRound(
        mode: GameModeType.dragDrop,
        title: 'Juftlashtir',
        emoji: '🔗',
        data: DragDropQuestion(
          title: 'Viloyat → Poytaxtni toping',
          emoji: '🗺️',
          pairs: const [
            DragPair(left: 'Samarqand', right: 'Samarqand', emoji: '🕌'),
            DragPair(left: 'Buxoro', right: 'Buxoro', emoji: '🌙'),
            DragPair(left: 'Namangan', right: 'Namangan', emoji: '🫐'),
            DragPair(left: 'Xorazm', right: 'Urganch', emoji: '🏺'),
          ],
        ),
      ),
      // Raund 3: Tezlik bilan topish
      MixedRound(
        mode: GameModeType.speedTap,
        title: 'Tez top!',
        emoji: '⚡',
        data: SpeedTapQuestion(
          instruction: 'O\'zbekiston viloyatlarini toping!',
          emoji: '🗺️',
          correct: ['Samarqand', 'Buxoro', 'Namangan', 'Xorazm'],
          wrong: ['Almaty', 'Dushanbe', 'Bishkek', 'Tehran', 'Kabul'],
          timeSeconds: 25,
        ),
      ),
    ];

    if (city == 1 && stage == 0) return [
      MixedRound(
        mode: GameModeType.orderSequence,
        title: 'Tartibga sol',
        emoji: '📅',
        data: OrderSequenceQuestion(
          instruction: 'Voqealarni tarixiy tartibda joylashtir',
          emoji: '⚔️',
          showYears: true,
          items: const [
            OrderItem(text: 'Alisher Navoiy tug\'ilgan', emoji: '📚', correctOrder: 0, yearOrHint: '1441-yil'),
            OrderItem(text: 'O\'zbekiston mustaqil bo\'ldi', emoji: '🇺🇿', correctOrder: 1, yearOrHint: '1991-yil'),
            OrderItem(text: 'Toshkent metrost ochildi', emoji: '🚇', correctOrder: 2, yearOrHint: '1977-yil'),
          ],
        ),
      ),
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Ha yoki Yo\'q?',
        emoji: '❓',
        data: const [
          TrueFalseStatement(statement: 'Mustaqillik maydoni 1991-yilda qurilgan', isTrue: true, emoji: '🏛️', explanation: 'Ha! Mustaqillik yili qurilgan'),
          TrueFalseStatement(statement: 'Bayroq ustunning balandligi 100 metr', isTrue: false, emoji: '🏳️', explanation: 'Yo\'q! 164 metr baland'),
          TrueFalseStatement(statement: 'Alisher Navoiy XV asrda yashagan', isTrue: true, emoji: '📖', explanation: '1441-1501 — XV-XVI asr boshida yashagan'),
          TrueFalseStatement(statement: 'O\'zbek tili fors yozuvida yoziladi', isTrue: false, emoji: '🔤', explanation: 'Yo\'q! Lotin alifbosida yoziladi'),
        ],
      ),
    ];

    return _defaultRounds(_regionData.name, _regionData.cities[city].name);
  }

  // ─── SAMARQAND RAUNDLARI ──────────────────────────────────────────────────
  List<MixedRound> _samarqandRounds(int city, int stage) {
    if (city == 0) return [ // Registon
      MixedRound(
        mode: GameModeType.fillBlank,
        title: 'Bo\'sh joy to\'ldiring',
        emoji: '✍️',
        data: const [
          FillBlankQuestion(
            instruction: 'Samarqandning mashhur maydoni?',
            hint: 'R harfi bilan boshlanadi',
            answer: 'REGISTON',
            context: 'REGISTON — dunyoning eng go\'zal maydoni',
            emoji: '🏯',
            letterChoices: ['R', 'E', 'G', 'I', 'S', 'T', 'O', 'N', 'A', 'U', 'M'],
          ),
          FillBlankQuestion(
            instruction: 'Ulug\'bek qaysi fanni o\'rgangan?',
            hint: 'Yulduzlar va sayyoralar',
            answer: 'ASTRONOMIYA',
            context: 'ASTRONOMIYA — yulduzlar fani',
            emoji: '🔭',
            letterChoices: ['A', 'T', 'R', 'O', 'N', 'I', 'Y', 'M', 'S', 'U', 'E'],
          ),
        ],
      ),
      MixedRound(
        mode: GameModeType.speedTap,
        title: 'Ipak yo\'li sheharlari',
        emoji: '🏯',
        data: SpeedTapQuestion(
          instruction: 'Ipak yo\'li shaharlarini toping!',
          emoji: '🛤️',
          correct: ['Samarqand', 'Buxoro', 'Xiva', 'Marv'],
          wrong: ['Paris', 'London', 'Tokyo', 'Berlin', 'Madrid'],
          timeSeconds: 20,
        ),
      ),
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Samarqand faktlari',
        emoji: '🕌',
        data: const [
          TrueFalseStatement(statement: 'Registon UNESCO merosi ro\'yxatida', isTrue: true, emoji: '🏛️', explanation: '1988-yildan UNESCO jahon merosi'),
          TrueFalseStatement(statement: 'Samarqandda 1000 yillik tarix bor', isTrue: false, emoji: '📅', explanation: 'Yo\'q! 2750+ yillik tarix bor'),
          TrueFalseStatement(statement: 'Ulug\'bek ham shoh ham olim bo\'lgan', isTrue: true, emoji: '👑', explanation: 'Ha! Samarqand hukmdori va buyuk olim'),
          TrueFalseStatement(statement: 'Shohi Zinda "O\'lik shoh" degan ma\'noda', isTrue: false, emoji: '⭐', explanation: 'Yo\'q! "Tirik shoh" degan ma\'noni anglatadi'),
        ],
      ),
    ];

    return _defaultRounds(_regionData.name, _regionData.cities[city].name);
  }

  // ─── BUXORO RAUNDLARI ─────────────────────────────────────────────────────
  List<MixedRound> _buxoroRounds(int city, int stage) {
    return [
      MixedRound(
        mode: GameModeType.orderSequence,
        title: 'Olimlarni vaqtda joylashtir',
        emoji: '🔬',
        data: OrderSequenceQuestion(
          instruction: 'Buyuk olimlarni yashagan davriga qarab tartibla',
          emoji: '👨‍🔬',
          showYears: true,
          items: const [
            OrderItem(text: 'Ibn Sino (Avitsenna)', emoji: '🏥', correctOrder: 0, yearOrHint: '980-1037'),
            OrderItem(text: 'Ulug\'bek', emoji: '🔭', correctOrder: 1, yearOrHint: '1394-1449'),
            OrderItem(text: 'Alisher Navoiy', emoji: '📚', correctOrder: 2, yearOrHint: '1441-1501'),
          ],
        ),
      ),
      MixedRound(
        mode: GameModeType.dragDrop,
        title: 'Olim va kashfiyot',
        emoji: '🔗',
        data: DragDropQuestion(
          title: 'Buyuk olim → Kashfiyotini toping',
          emoji: '🧪',
          pairs: const [
            DragPair(left: 'Ibn Sino', right: 'Tibbiyot', emoji: '🏥'),
            DragPair(left: 'Al-Xorazmiy', right: 'Algebra', emoji: '📐'),
            DragPair(left: 'Ulug\'bek', right: 'Astronomiya', emoji: '🔭'),
            DragPair(left: 'Beruniy', right: 'Geografiya', emoji: '🌍'),
          ],
        ),
      ),
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Buxoro faktlari',
        emoji: '🌙',
        data: const [
          TrueFalseStatement(statement: 'Ibn Sino 450 dan ortiq asar yozgan', isTrue: true, emoji: '📖', explanation: 'Ha! Juda ko\'p asar yozgan buyuk alloma'),
          TrueFalseStatement(statement: 'Kalon minorasi 100 metr baland', isTrue: false, emoji: '🗼', explanation: 'Yo\'q! 47 metr baland'),
          TrueFalseStatement(statement: 'Lyabi-xovuz 1620-yilda qurilgan', isTrue: true, emoji: '🏊', explanation: 'Ha! XVII asrda qurilgan go\'zal makon'),
          TrueFalseStatement(statement: 'Buxoro Ipak yo\'lida emas', isTrue: false, emoji: '🛤️', explanation: 'Yo\'q! Ipak yo\'lining muhim markazi'),
        ],
      ),
    ];
  }

  // ─── XORAZM RAUNDLARI ────────────────────────────────────────────────────
  List<MixedRound> _xorazmRounds(int city, int stage) {
    return [
      MixedRound(
        mode: GameModeType.fillBlank,
        title: 'Fan terminlari',
        emoji: '📐',
        data: const [
          FillBlankQuestion(
            instruction: 'Al-Xorazmiy kashf etgan fan?',
            hint: 'Al-jabr deb ham ataladi',
            answer: 'ALGEBRA',
            context: 'ALGEBRA so\'zi arabcha al-jabr dan kelib chiqqan',
            emoji: '📐',
            letterChoices: ['A', 'L', 'G', 'E', 'B', 'R', 'O', 'I', 'U', 'S', 'T'],
          ),
        ],
      ),
      MixedRound(
        mode: GameModeType.speedTap,
        title: 'Matematik belgilar',
        emoji: '🔢',
        data: SpeedTapQuestion(
          instruction: 'Matematik amalllarni toping!',
          emoji: '📐',
          correct: ['+', '-', '×', '÷', '='],
          wrong: ['A', 'B', 'C', '!', '@', '#', '\$'],
          timeSeconds: 20,
        ),
      ),
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Xorazm va Orol',
        emoji: '🏺',
        data: const [
          TrueFalseStatement(statement: 'Al-Xorazmiy "Algoritm" atamasiga asos bo\'lgan', isTrue: true, emoji: '💻', explanation: 'Ha! "Algorithm" uning latin ismidan kelib chiqqan'),
          TrueFalseStatement(statement: 'Orol dengizi hali ham to\'la', isTrue: false, emoji: '🌊', explanation: 'Yo\'q! 90% quriib ketgan — ekologik faloqat'),
          TrueFalseStatement(statement: 'Xiva UNESCO merosida', isTrue: true, emoji: '🏯', explanation: 'Ha! Ichon-Qal\'a UNESCO roʻyxatida'),
          TrueFalseStatement(statement: 'Al-Xorazmiy XV asrda yashagan', isTrue: false, emoji: '📅', explanation: 'Yo\'q! IX asrda 780-850 yillarda yashagan'),
        ],
      ),
    ];
  }

  // ─── UMUMIY (boshqa viloyatlar) ───────────────────────────────────────────
  List<MixedRound> _defaultRounds(String region, String city) {
    return [
      MixedRound(
        mode: GameModeType.trueFalse,
        title: 'Ha yoki Yo\'q?',
        emoji: '❓',
        data: [
          TrueFalseStatement(statement: '$region O\'zbekistondagi viloyat', isTrue: true, emoji: '🗺️', explanation: 'Ha! $region O\'zbekiston Respublikasining bir qismi'),
          TrueFalseStatement(statement: 'O\'zbekistonda 20 ta viloyat bor', isTrue: false, emoji: '📋', explanation: 'Yo\'q! 12 viloyat + Qoraqalpog\'iston + Toshkent shahri bor'),
          TrueFalseStatement(statement: 'O\'zbek tili turk tiliga yaqin', isTrue: true, emoji: '🗣️', explanation: 'Ha! Ikkalasi ham turkiy tillar oilasiga mansub'),
          TrueFalseStatement(statement: 'O\'zbekiston dengizga chiqadi', isTrue: false, emoji: '🌊', explanation: 'Yo\'q! O\'zbekiston quruqlik bilan o\'ralgan — ikki marta'),
        ],
      ),
      MixedRound(
        mode: GameModeType.speedTap,
        title: 'O\'zbek tarixchilar',
        emoji: '📚',
        data: SpeedTapQuestion(
          instruction: 'O\'zbekiston olimlarini toping!',
          emoji: '🧠',
          correct: ['Ibn Sino', 'Beruniy', 'Ulug\'bek', 'Navoiy'],
          wrong: ['Napoleon', 'Einstein', 'Newton', 'Darwin', 'Platon'],
          timeSeconds: 22,
        ),
      ),
    ];
  }

  void _onRoundComplete() {
    if (_currentRound >= _rounds.length - 1) {
      // Hamma raundlar tugadi
      final stars = _totalMax > 0
          ? (_totalScore / _totalMax >= 0.9 ? 3 : _totalScore / _totalMax >= 0.7 ? 2 : _totalScore / _totalMax >= 0.5 ? 1 : 0)
          : 0;
      widget.onComplete(stars);
      return;
    }
    setState(() {
      _showRoundComplete = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _currentRound++;
          _showRoundComplete = false;
        });
      }
    });
  }

  void _onScore(int score, int max) {
    setState(() {
      _totalScore += score;
      _totalMax += max;
      _lastScore = score;
      _lastMax = max;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) return _buildIntro();

    final round = _rounds[_currentRound];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHUD(round),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_showRoundComplete)
                      _buildRoundCompleteCard()
                    else
                      _buildRoundContent(round),
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

  Widget _buildIntro() {
    final city = _regionData.cities[widget.cityIdx];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_regionData.color, _regionData.colorDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(city.emoji, style: const TextStyle(fontSize: 72))
                    .animate().scale().shake(delay: 300.ms),
                const SizedBox(height: 20),
                Text(
                  city.name,
                  style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  _regionData.name,
                  style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 20),
                Text(
                  '${widget.stageIdx + 1}-bosqich',
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.white60),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_rounds.length} ta vazifa',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(MixedRound round) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_regionData.color, _regionData.colorDark],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(color: _regionData.color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,5))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${round.emoji} ${round.title}',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  '${_currentRound + 1}/${_rounds.length} vazifa',
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          // Ball
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⭐ $_totalScore',
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundContent(MixedRound round) {
    switch (round.mode) {
      case GameModeType.trueFalse:
        return TrueFalseChainGame(
          key: ValueKey('tf_$_currentRound'),
          statements: round.data is List ? List<TrueFalseStatement>.from(round.data) : [],
          color: _regionData.color,
          onComplete: _onRoundComplete,
          onScore: _onScore,
        );
      case GameModeType.dragDrop:
        return DragDropGame(
          key: ValueKey('dd_$_currentRound'),
          question: round.data as DragDropQuestion,
          color: _regionData.color,
          onComplete: _onRoundComplete,
          onScore: _onScore,
        );
      case GameModeType.speedTap:
        return SpeedTapGame(
          key: ValueKey('st_$_currentRound'),
          question: round.data as SpeedTapQuestion,
          color: _regionData.color,
          onComplete: _onRoundComplete,
          onScore: _onScore,
        );
      case GameModeType.fillBlank:
        return FillBlankGame(
          key: ValueKey('fb_$_currentRound'),
          questions: round.data is List ? List<FillBlankQuestion>.from(round.data) : [],
          color: _regionData.color,
          onComplete: _onRoundComplete,
          onScore: _onScore,
        );
      case GameModeType.orderSequence:
        return OrderSequenceGame(
          key: ValueKey('os_$_currentRound'),
          question: round.data as OrderSequenceQuestion,
          color: _regionData.color,
          onComplete: _onRoundComplete,
          onScore: _onScore,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildRoundCompleteCard() {
    final perfect = _lastScore == _lastMax;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _regionData.color.withOpacity(0.15), blurRadius: 16, offset: const Offset(0,6))],
      ),
      child: Column(
        children: [
          Text(perfect ? '🎉' : '👍', style: const TextStyle(fontSize: 56))
              .animate().scale().shake(),
          const SizedBox(height: 10),
          Text(
            perfect ? 'Mukammal!' : 'Yaxshi!',
            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: _regionData.color),
          ),
          Text(
            '$_lastScore/$_lastMax to\'g\'ri',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            'Keyingi vazifa boshlanmoqda...',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
