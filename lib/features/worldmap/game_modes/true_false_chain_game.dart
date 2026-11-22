import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// TRUE / FALSE CHAIN O'YIN — Tezda ha/yo'q deyish
// Ketma-ket faktlar keladi, 2 soniya ichida ha yoki yo'q
// Combo tizimi: ketma-ket to'g'ri = x2, x3 ko'paytiruvchi!
// ════════════════════════════════════════════════════════════════════════════

class TrueFalseStatement {
  final String statement;
  final bool isTrue;
  final String emoji;
  final String explanation;

  const TrueFalseStatement({
    required this.statement,
    required this.isTrue,
    required this.emoji,
    required this.explanation,
  });
}

class TrueFalseChainGame extends StatefulWidget {
  final List<TrueFalseStatement> statements;
  final Color color;
  final VoidCallback onComplete;
  final Function(int score, int max) onScore;

  const TrueFalseChainGame({
    super.key,
    required this.statements,
    required this.color,
    required this.onComplete,
    required this.onScore,
  });

  @override
  State<TrueFalseChainGame> createState() => _TrueFalseChainGameState();
}

class _TrueFalseChainGameState extends State<TrueFalseChainGame>
    with TickerProviderStateMixin {
  int _currentIdx = 0;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  bool? _lastResult;
  bool _answered = false;
  int _timeLeft = 4;
  Timer? _timer;

  late AnimationController _slideCtrl;
  late AnimationController _comboCtrl;
  late AnimationController _flashCtrl;
  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _comboCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 4;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0 && !_answered) {
        _onAnswer(null); // Vaqt tugadi = xato
      }
    });
  }

  void _onAnswer(bool? answer) {
    if (_answered) return;
    _timer?.cancel();

    final stmt = widget.statements[_currentIdx];
    final isCorrect = answer == stmt.isTrue;

    setState(() {
      _answered = true;
      _lastResult = isCorrect;
      if (isCorrect) {
        _combo++;
        _score += 1 + (_combo > 2 ? _combo - 2 : 0); // combo bonus
        if (_combo > _maxCombo) _maxCombo = _combo;
        _flashColor = const Color(0xFF4CAF50);
      } else {
        _combo = 0;
        _flashColor = const Color(0xFFEF5350);
      }
    });

    _comboCtrl.forward(from: 0);
    _flashCtrl.forward(from: 0).then((_) => _flashCtrl.reverse());

    Future.delayed(const Duration(milliseconds: 1200), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_currentIdx >= widget.statements.length - 1) {
      widget.onScore(_score, widget.statements.length);
      widget.onComplete();
      return;
    }
    _slideCtrl.forward(from: 0);
    setState(() {
      _currentIdx++;
      _answered = false;
      _lastResult = null;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideCtrl.dispose();
    _comboCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stmt = widget.statements[_currentIdx];
    final progress = (_currentIdx + 1) / widget.statements.length;

    return AnimatedBuilder(
      animation: _flashCtrl,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _flashColor.withOpacity(_flashCtrl.value * 0.08),
        ),
        child: child,
      ),
      child: Column(
        children: [
          // Üst: progress + combo + timer
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(widget.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _timeLeft <= 1 ? Colors.red[50] : widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '⏱ $_timeLeft',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _timeLeft <= 1 ? Colors.red : widget.color,
                  ),
                ),
              ),
              if (_combo >= 2) ...[
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _comboCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: 1.0 + _comboCtrl.value * 0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🔥 x$_combo',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Asosiy kart
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _answered
                      ? (_lastResult! ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)).withOpacity(0.2)
                      : widget.color.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: _answered
                  ? Border.all(
                      color: _lastResult! ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              children: [
                Text(stmt.emoji, style: const TextStyle(fontSize: 44))
                    .animate(key: ValueKey(_currentIdx))
                    .fadeIn().slideY(begin: -0.3),
                const SizedBox(height: 14),
                Text(
                  stmt.statement,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate(key: ValueKey('t$_currentIdx')).fadeIn(),
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Text(
                    stmt.explanation,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _lastResult! ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ha / Yo'q tugmalar
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _answered ? null : () => _onAnswer(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _answered && widget.statements[_currentIdx].isTrue == false
                          ? (_lastResult! ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEF5350), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFFEF5350).withOpacity(0.2), blurRadius: 8, offset: const Offset(0,4))],
                    ),
                    child: Column(
                      children: [
                        const Text('❌', style: TextStyle(fontSize: 28)),
                        Text('YO\'Q', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFFC62828))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _answered ? null : () => _onAnswer(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _answered && widget.statements[_currentIdx].isTrue == true
                          ? (_lastResult! ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.2), blurRadius: 8, offset: const Offset(0,4))],
                    ),
                    child: Column(
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 28)),
                        Text('HA', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_currentIdx + 1}/${widget.statements.length} • Ball: $_score',
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
