import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// SPEED TAP O'YIN — Tezlik bilan topish
// Ekranda 9 ta katak, faqat to'g'rilarini tez bos!
// Misol: "Viloyatlarni toping" — 9 katak ichida viloyat + xato nomlar
// ════════════════════════════════════════════════════════════════════════════

class SpeedTapQuestion {
  final String instruction;   // "O'zbekiston viloyatlarini toping!"
  final String emoji;
  final List<String> correct; // To'g'ri javoblar
  final List<String> wrong;   // Chalg'ituvchilar
  final int timeSeconds;

  const SpeedTapQuestion({
    required this.instruction,
    required this.emoji,
    required this.correct,
    required this.wrong,
    this.timeSeconds = 20,
  });
}

class SpeedTapGame extends StatefulWidget {
  final SpeedTapQuestion question;
  final Color color;
  final VoidCallback onComplete;
  final Function(int score, int max) onScore;

  const SpeedTapGame({
    super.key,
    required this.question,
    required this.color,
    required this.onComplete,
    required this.onScore,
  });

  @override
  State<SpeedTapGame> createState() => _SpeedTapGameState();
}

class _SpeedTapGameState extends State<SpeedTapGame> with TickerProviderStateMixin {
  late List<_Tile> _tiles;
  int _timeLeft = 0;
  Timer? _timer;
  int _correctTapped = 0;
  int _wrongTapped = 0;
  bool _done = false;

  late AnimationController _timerCtrl;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.question.timeSeconds;
    _timerCtrl = AnimationController(vsync: this, duration: Duration(seconds: widget.question.timeSeconds));

    // Katak aralashmasini tayyorla
    final all = [
      ...widget.question.correct.map((s) => _Tile(text: s, isCorrect: true)),
      ...widget.question.wrong.map((s) => _Tile(text: s, isCorrect: false)),
    ];
    all.shuffle(Random());
    _tiles = all.take(9).toList();
    // Kamida 1 ta to'g'ri bo'lsin
    final hasCorrect = _tiles.any((t) => t.isCorrect);
    if (!hasCorrect && widget.question.correct.isNotEmpty) {
      _tiles[0] = _Tile(text: widget.question.correct[0], isCorrect: true);
      _tiles.shuffle(Random());
    }

    _startTimer();
  }

  void _startTimer() {
    _timerCtrl.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _finish();
    });
  }

  void _onTap(int idx) {
    if (_done || _tiles[idx].tapped) return;
    final tile = _tiles[idx];
    setState(() {
      _tiles[idx] = tile.copyWith(tapped: true);
      if (tile.isCorrect) {
        _correctTapped++;
      } else {
        _wrongTapped++;
        _timeLeft = max(0, _timeLeft - 3); // Xato = -3 soniya!
      }
    });

    // Hammasi topildimi?
    final totalCorrect = _tiles.where((t) => t.isCorrect).length;
    if (_correctTapped >= totalCorrect) _finish();
  }

  void _finish() {
    if (_done) return;
    _timer?.cancel();
    _timerCtrl.stop();
    final totalCorrect = _tiles.where((t) => t.isCorrect).length;
    widget.onScore(_correctTapped, totalCorrect);
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 1500), widget.onComplete);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCorrect = _tiles.where((t) => t.isCorrect).length;
    final remaining = totalCorrect - _correctTapped;
    final timerFraction = _timeLeft / widget.question.timeSeconds;

    return Column(
      children: [
        // Topshiriq + timer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,4))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(widget.question.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.question.instruction,
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                    ),
                  ),
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5 ? Colors.red[50] : widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_timeLeft <= 5 ? '⚠️' : '⏱️', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$_timeLeft s',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _timeLeft <= 5 ? Colors.red : widget.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Timer bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 6,
                  child: LinearProgressIndicator(
                    value: timerFraction.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      timerFraction > 0.4 ? widget.color : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$remaining ta qoldi • Xato = -3 soniya!',
                style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 3×3 kataklar
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _tiles.asMap().entries.map((e) => _buildTile(e.key, e.value)).toList(),
        ),
        if (_done) ...[
          const SizedBox(height: 14),
          Center(
            child: Text(
              _correctTapped >= totalCorrect
                  ? '🎉 Hammasi topildi!'
                  : '⏰ Vaqt tugadi! $_correctTapped/$totalCorrect',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: widget.color),
            ),
          ).animate().fadeIn().scale(),
        ],
      ],
    );
  }

  Widget _buildTile(int idx, _Tile tile) {
    Color bg = Colors.white;
    Color border = Colors.grey[200]!;
    Color textColor = const Color(0xFF1A1A2E);

    if (tile.tapped) {
      if (tile.isCorrect) {
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
      } else {
        bg = const Color(0xFFFFEBEE);
        border = const Color(0xFFEF5350);
        textColor = const Color(0xFFC62828);
      }
    } else if (_done && tile.isCorrect) {
      bg = Colors.orange[50]!;
      border = Colors.orange;
      textColor = Colors.orange[800]!;
    }

    return GestureDetector(
      onTap: () => _onTap(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,3))],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              tile.text,
              style: GoogleFonts.nunito(
                fontSize: tile.text.length > 10 ? 11 : 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ).animate(
        effects: tile.tapped && tile.isCorrect
            ? [const ScaleEffect(begin: Offset(1.1, 1.1), end: Offset(1.0, 1.0))]
            : tile.tapped && !tile.isCorrect
                ? [const ShakeEffect()]
                : [],
      ),
    );
  }
}

class _Tile {
  final String text;
  final bool isCorrect;
  final bool tapped;

  const _Tile({required this.text, required this.isCorrect, this.tapped = false});

  _Tile copyWith({bool? tapped}) => _Tile(
    text: text, isCorrect: isCorrect, tapped: tapped ?? this.tapped,
  );
}
