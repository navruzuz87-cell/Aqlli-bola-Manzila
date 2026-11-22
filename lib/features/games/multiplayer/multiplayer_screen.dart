import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/audio_service.dart';

// 2 kishilik mahalliy ko'p o'yinchi — bir qurilmada navbatma-navbat
class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});
  @override State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen>
    with TickerProviderStateMixin {

  // O'yinchilar
  final _names = ['O\'yinchi 1', 'O\'yinchi 2'];
  final _scores = [0, 0];
  final _emojis = ['🔵', '🔴'];
  int _currentPlayer = 0;
  int _round = 1;
  static const int _totalRounds = 5;

  // Savol
  late List<_MpQuestion> _deck;
  int _qIdx = 0;
  int? _selected;
  bool _answered = false;
  bool _showingTurn = true;
  bool _gameOver = false;
  Timer? _timer;
  int _timeLeft = 15;

  late AnimationController _timerCtrl;

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(vsync: this, duration: 15.seconds);
    _deck = List.of(_mpQuestions)..shuffle(Random());
    _showTurnScreen();
  }

  @override void dispose() { _timer?.cancel(); _timerCtrl.dispose(); super.dispose(); }

  void _showTurnScreen() {
    setState(() => _showingTurn = true);
    Future.delayed(2.seconds, _startTurn);
  }

  void _startTurn() {
    setState(() { _showingTurn = false; _selected = null; _answered = false; _timeLeft = 15; });
    _timerCtrl.forward(from: 0);
    _timer = Timer.periodic(1.seconds, (t) {
      if (_timeLeft <= 1) { t.cancel(); _onTimeout(); return; }
      setState(() => _timeLeft--);
    });
  }

  void _onTimeout() {
    AudioService.instance.playSfx(SfxSound.wrong);
    setState(() => _answered = true);
    Future.delayed(1.5.seconds, _nextTurn);
  }

  void _answer(int i) {
    if (_answered) return;
    _timer?.cancel();
    _timerCtrl.stop();
    setState(() { _selected = i; _answered = true; });

    final q = _deck[_qIdx];
    if (i == q.correctIndex) {
      _scores[_currentPlayer] += 10 + _timeLeft; // bonus vaqt uchun
      AudioService.instance.playSfx(SfxSound.correct);
    } else {
      AudioService.instance.playSfx(SfxSound.wrong);
    }
    Future.delayed(1.5.seconds, _nextTurn);
  }

  void _nextTurn() {
    final nextPlayer = 1 - _currentPlayer;
    _qIdx++;
    if (_qIdx >= _deck.length) _deck = (List.of(_mpQuestions)..shuffle(Random()));

    if (nextPlayer == 0) {
      // Ikki o'yinchi ham o'ynadi — raund tugadi
      if (_round >= _totalRounds) { setState(() => _gameOver = true); return; }
      _round++;
    }
    setState(() => _currentPlayer = nextPlayer);
    _showTurnScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _resultScreen();
    if (_showingTurn) return _turnScreen();
    return _gameScreen();
  }

  Widget _turnScreen() => Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _currentPlayer == 0
            ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
            : [const Color(0xFFB71C1C), const Color(0xFF7F0000)],
        ),
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_emojis[_currentPlayer], style: const TextStyle(fontSize: 72))
              .animate().scale(begin: const Offset(0.5,0.5), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(_names[_currentPlayer], style: GoogleFonts.nunito(
              fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Sizning navbatingiz! 🎯', style: GoogleFonts.nunito(
              fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 20),
          Text('Raund $_round / $_totalRounds', style: GoogleFonts.nunito(
              fontSize: 13, color: Colors.white38)),
        ]),
      ),
    ),
  );

  Widget _gameScreen() {
    final q = _deck[_qIdx % _deck.length];
    final isP1 = _currentPlayer == 0;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: isP1
              ? [const Color(0xFF1565C0), const Color(0xFF283593)]
              : [const Color(0xFFB71C1C), const Color(0xFF7F0000)],
          ),
        ),
        child: SafeArea(child: Column(children: [
          // Skor paneli
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _scoreChip(0),
              Expanded(child: Column(children: [
                Text('Raund $_round', style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.white54)),
                // Timer
                AnimatedBuilder(
                  animation: _timerCtrl,
                  builder: (_, __) => Stack(alignment: Alignment.center, children: [
                    SizedBox(width: 50, height: 50,
                      child: CircularProgressIndicator(
                        value: 1 - _timerCtrl.value,
                        strokeWidth: 5,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                            _timeLeft <= 5 ? Colors.red : Colors.white),
                      ),
                    ),
                    Text('$_timeLeft', style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: _timeLeft <= 5 ? Colors.red : Colors.white)),
                  ]),
                ),
              ])),
              _scoreChip(1),
            ]),
          ),
          const SizedBox(height: 16),
          // Savol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(q.text, textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 20,
                      fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          // Javoblar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.5,
              children: List.generate(q.options.length, (i) {
                Color bg = Colors.white.withOpacity(0.1);
                Color border = Colors.white.withOpacity(0.2);
                if (_answered) {
                  if (i == q.correctIndex) { bg = Colors.green.withOpacity(0.4); border = Colors.green; }
                  else if (i == _selected) { bg = Colors.red.withOpacity(0.4); border = Colors.red; }
                }
                return GestureDetector(
                  onTap: () => _answer(i),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Center(child: Text(q.options[i],
                        style: GoogleFonts.nunito(fontSize: 15,
                            fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                );
              }),
            ),
          ),
        ])),
      ),
    );
  }

  Widget _scoreChip(int p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(_currentPlayer == p ? 0.2 : 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _currentPlayer == p ? Colors.white : Colors.transparent,
        width: 1.5,
      ),
    ),
    child: Column(children: [
      Text(_emojis[p], style: const TextStyle(fontSize: 20)),
      Text('${_scores[p]}', style: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
    ]),
  );

  Widget _resultScreen() {
    final p1Wins = _scores[0] > _scores[1];
    final draw = _scores[0] == _scores[1];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
          ),
        ),
        child: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(draw ? '🤝' : (p1Wins ? '🔵' : '🔴'),
                style: const TextStyle(fontSize: 72))
                .animate().scale(begin: const Offset(0.5,0.5), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(draw ? "Durrang!" : "${_names[p1Wins ? 0 : 1]} g'alaba qozondi!",
                style: GoogleFonts.nunito(fontSize: 22,
                    fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _resultCard(0), const SizedBox(width: 20), _resultCard(1),
            ]),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text("Chiqish", style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A237E))),
              ),
            ),
          ]),
        )),
      ),
    );
  }

  Widget _resultCard(int p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: [
      Text(_emojis[p], style: const TextStyle(fontSize: 32)),
      Text(_names[p], style: GoogleFonts.nunito(
          fontSize: 13, color: Colors.white70)),
      Text('${_scores[p]}', style: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w900,
          color: const Color(0xFFFFD54F))),
      Text('ball', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38)),
    ]),
  );
}

class _MpQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  const _MpQuestion(this.text, this.options, this.correctIndex);
}

const _mpQuestions = [
  _MpQuestion('9 × 9 = ?',              ['72','81','80','90'],          1),
  _MpQuestion('50 + 75 = ?',            ['115','125','130','120'],       1),
  _MpQuestion('"Dog" o\'zbekcha?',       ['Mushuk','It','Qush','Baliq'], 1),
  _MpQuestion('O\'zbekiston poytaxti?',  ['Samarqand','Buxoro','Toshkent','Namangan'], 2),
  _MpQuestion('Suv formulasi?',          ['CO2','H2O','NaCl','O2'],      1),
  _MpQuestion('100 ÷ 4 = ?',            ['20','25','30','40'],           1),
  _MpQuestion('"Katta" antonimi?',       ['Baland','Kichik','Yaxshi','Tez'], 1),
  _MpQuestion('Yil necha oy?',           ['10','11','12','13'],           2),
  _MpQuestion('Eng baland tog\'?',       ['K2','Everest','Elbrus','Fuji'], 1),
  _MpQuestion('3² + 4² = ?',            ['14','25','20','30'],           1),
];
