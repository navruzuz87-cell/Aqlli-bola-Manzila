import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/user_profile.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_stats_service.dart';
import '../../../core/services/mission_service.dart';

// ── Savol modeli ──────────────────────────────────────────────────────────
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String subject;
  final int difficulty; // 1=oson, 2=o'rta, 3=qiyin

  const Question({required this.text, required this.options,
    required this.correctIndex, required this.subject, this.difficulty = 1});
}

// ── Savollar banki ────────────────────────────────────────────────────────
const _questions = [
  // Matematika
  Question(text: '7 × 8 = ?',       options: ['54','56','58','64'], correctIndex: 1, subject: 'Matematika', difficulty: 1),
  Question(text: '144 ÷ 12 = ?',    options: ['10','11','12','13'], correctIndex: 2, subject: 'Matematika', difficulty: 2),
  Question(text: '15² = ?',         options: ['175','200','225','250'], correctIndex: 2, subject: 'Matematika', difficulty: 3),
  Question(text: '3 + 4 × 2 = ?',   options: ['14','11','10','9'],  correctIndex: 1, subject: 'Matematika', difficulty: 2),
  Question(text: '1000 - 237 = ?',  options: ['763','773','753','783'],correctIndex:0, subject: 'Matematika', difficulty: 2),
  // O'zbek tili
  Question(text: '"Kitob" so\'zining ko\'pligi?', options: ['Kitoblar','Kitobi','Kitobning','Kitobga'], correctIndex: 0, subject: "O'zbek tili", difficulty: 1),
  Question(text: 'Qaysi so\'z ot?', options: ['Chiroyli','Yugurmoq','Bog\'','Tez'], correctIndex: 2, subject: "O'zbek tili", difficulty: 1),
  Question(text: '"Baxt" antonimi?', options: ['Quvonch','Shodlik','Baxtsizlik','Zavq'], correctIndex: 2, subject: "O'zbek tili", difficulty: 2),
  // Ingliz tili
  Question(text: '"Apple" o\'zbekcha?', options: ['Nok','Olma','Limon','Uzum'], correctIndex: 1, subject: 'Ingliz tili', difficulty: 1),
  Question(text: 'I ___ a student.', options: ['am','is','are','be'], correctIndex: 0, subject: 'Ingliz tili', difficulty: 1),
  Question(text: '"Yesterday" qaysi zamon?', options: ['Present','Future','Past','Modal'], correctIndex: 2, subject: 'Ingliz tili', difficulty: 2),
  // Tabiat
  Question(text: 'Quyoshdan eng yaqin sayyora?', options: ['Venera','Yer','Mars','Merkuriy'], correctIndex: 3, subject: 'Tabiat', difficulty: 2),
  Question(text: 'Fotosintez uchun nima kerak?', options: ['Kislorod','Suv+Yorug\'lik','Azot','Karbonat'], correctIndex: 1, subject: 'Tabiat', difficulty: 2),
  Question(text: 'Qon aylanish tizimini qaysi organ boshqaradi?', options: ['Jigar','O\'pka','Yurak','Buyrak'], correctIndex: 2, subject: 'Tabiat', difficulty: 1),
  // Tarix
  Question(text: 'Amir Temur qachon tug\'ilgan?', options: ['1336','1356','1300','1375'], correctIndex: 0, subject: 'Tarix', difficulty: 2),
  Question(text: 'Ipak yo\'lining bosh shahri?', options: ['Buxoro','Samarqand','Xiva','Toshkent'], correctIndex: 1, subject: 'Tarix', difficulty: 2),
];

// ── O'yin ─────────────────────────────────────────────────────────────────
class ArcheryGameV2 extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdate;
  const ArcheryGameV2({super.key, required this.profile, required this.onUpdate});

  @override State<ArcheryGameV2> createState() => _ArcheryGameV2State();
}

class _ArcheryGameV2State extends State<ArcheryGameV2>
    with TickerProviderStateMixin {
  late List<Question> _deck;
  int _idx = 0;
  int _score = 0;
  int _stars = 0;
  int? _selected;
  bool _answered = false;
  bool _gameOver = false;
  final _start = DateTime.now();

  late AnimationController _arrowCtrl;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _deck = List.of(_questions)..shuffle(Random());
    _deck = _deck.take(10).toList();
    _arrowCtrl = AnimationController(vsync: this, duration: 500.ms);
    _shakeCtrl = AnimationController(vsync: this, duration: 400.ms);
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _answer(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
    });

    final correct = i == _deck[_idx].correctIndex;
    if (correct) {
      _score += 10 * _deck[_idx].difficulty;
      AudioService.instance.playSfx(SfxSound.correct);
      _arrowCtrl.forward(from: 0);
    } else {
      AudioService.instance.playSfx(SfxSound.wrong);
      _shakeCtrl.forward(from: 0);
    }

    Future.delayed(1200.ms, _next);
  }

  void _next() {
    if (_idx + 1 >= _deck.length) {
      _finish();
      return;
    }
    setState(() { _idx++; _selected = null; _answered = false; });
    _arrowCtrl.reset();
  }

  void _finish() {
    final maxScore = _deck.fold(0, (s, q) => s + 10 * q.difficulty);
    final pct = _score / maxScore;
    _stars = pct >= 0.85 ? 3 : pct >= 0.60 ? 2 : pct >= 0.30 ? 1 : 0;

    if (_stars >= 3) AudioService.instance.playSfx(SfxSound.victory);
    else if (_stars >= 1) AudioService.instance.playSfx(SfxSound.levelUp);

    final dur = DateTime.now().difference(_start).inSeconds;
    GameStatsService.instance.record(widget.profile.id, GameResult(
      gameId: 'archery', subject: 'mixed',
      stars: _stars, score: _score, maxScore: maxScore,
      durationSeconds: dur, playedAt: DateTime.now(),
    ), legacyProfileId: widget.profile.name);
    MissionService.instance.recordEvent(
        event: MissionEventType.gamePlayed, starsEarned: _score ~/ 10);

    setState(() => _gameOver = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(child: _gameOver ? _resultScreen() : _gameScreen()),
      ),
    );
  }

  Widget _gameScreen() {
    final q = _deck[_idx];
    return Column(children: [
      _topBar(),
      const SizedBox(height: 8),
      // Maqsad (nishon)
      _target(),
      const SizedBox(height: 20),
      // Savol
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(q.subject,
                    style: GoogleFonts.nunito(fontSize: 10, color: const Color(0xFFFFD54F))),
              ),
              const SizedBox(width: 6),
              Row(children: List.generate(q.difficulty, (_) =>
                  const Icon(Icons.star, color: Color(0xFFFFD54F), size: 12))),
            ]),
            const SizedBox(height: 10),
            Text(q.text, style: GoogleFonts.nunito(
                fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      // Javoblar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          mainAxisSpacing: 10, crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: List.generate(q.options.length, (i) => _optionBtn(i, q)),
        ),
      ),
    ]);
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: (_idx + 1) / _deck.length, minHeight: 8,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
        ),
      )),
      const SizedBox(width: 10),
      Text('$_score', style: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFFFFD54F))),
    ]),
  );

  Widget _target() => SizedBox(
    height: 100,
    child: Stack(alignment: Alignment.center, children: [
      // Nishon halqalari
      for (final r in [50.0, 38.0, 26.0, 14.0])
        Container(
          width: r*2, height: r*2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: r == 14 ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
      // O'q (to'g'ri javobda)
      AnimatedBuilder(
        animation: _arrowCtrl,
        builder: (_, __) => _arrowCtrl.value > 0
          ? Transform.scale(
              scale: _arrowCtrl.value,
              child: const Text('🏹', style: TextStyle(fontSize: 24)),
            )
          : const Text('🎯', style: TextStyle(fontSize: 28)),
      ),
    ]),
  );

  Widget _optionBtn(int i, Question q) {
    Color bg = Colors.white.withOpacity(0.1);
    Color border = Colors.white.withOpacity(0.2);
    if (_answered) {
      if (i == q.correctIndex) { bg = const Color(0xFF388E3C).withOpacity(0.4); border = const Color(0xFF66BB6A); }
      else if (i == _selected)  { bg = const Color(0xFFB71C1C).withOpacity(0.4); border = const Color(0xFFEF5350); }
    }

    return GestureDetector(
      onTap: () => _answer(i),
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Center(
          child: Text(q.options[i], style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _resultScreen() {
    final stars = ['','⭐','⭐⭐','⭐⭐⭐'][_stars];
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_stars >= 3 ? '🏆' : _stars >= 2 ? '🥈' : _stars >= 1 ? '🥉' : '😔',
            style: const TextStyle(fontSize: 72))
            .animate().scale(begin: const Offset(0.5,0.5), duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(stars.isNotEmpty ? stars : '0 yulduz',
            style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text('$_score ball', style: GoogleFonts.nunito(
            fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFFFFD54F))),
        const SizedBox(height: 6),
        Text('${_deck.length} ta savoldan', style: GoogleFonts.nunito(
            fontSize: 14, color: Colors.white60)),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text("Chiqish", textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white70)),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => setState(() {
              _deck = List.of(_questions)..shuffle(Random());
              _deck = _deck.take(10).toList();
              _idx = 0; _score = 0; _stars = 0;
              _selected = null; _answered = false; _gameOver = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text("🔄 Qayta", textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A237E))),
            ),
          )),
        ]),
      ]),
    ));
  }
}

typedef AlpomishArcheryScreen = ArcheryGameV2;
