import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// FILL IN THE BLANK — Bo'sh joyni to'ldirish
// Harflarni tartibga solib so'z yasash
// Misol: "REGIS_ON" → T harfini toping
// ════════════════════════════════════════════════════════════════════════════

class FillBlankQuestion {
  final String instruction;
  final String hint;         // Izoh
  final String answer;       // To'g'ri so'z (katta harf)
  final String context;      // Gapda ishlatilishi
  final String emoji;
  final List<String> letterChoices; // Taklif qilingan harflar (1-3 to'g'ri + 5-6 xato)

  const FillBlankQuestion({
    required this.instruction,
    required this.hint,
    required this.answer,
    required this.context,
    required this.emoji,
    required this.letterChoices,
  });
}

class FillBlankGame extends StatefulWidget {
  final List<FillBlankQuestion> questions;
  final Color color;
  final VoidCallback onComplete;
  final Function(int score, int max) onScore;

  const FillBlankGame({
    super.key,
    required this.questions,
    required this.color,
    required this.onComplete,
    required this.onScore,
  });

  @override
  State<FillBlankGame> createState() => _FillBlankGameState();
}

class _FillBlankGameState extends State<FillBlankGame> {
  int _currentQ = 0;
  int _score = 0;
  String _typed = '';
  bool _answered = false;
  bool _correct = false;

  FillBlankQuestion get _q => widget.questions[_currentQ];

  // So'zdagi _ ni topib ko'rsatish
  String get _displayWord {
    final ans = _q.answer;
    // Har harfini ko'rsat yoki yashir
    return ans.split('').asMap().entries.map((e) {
      // 50-70% harflarni yashir (o'rtadagilarni)
      final hide = e.key > 0 && e.key < ans.length - 1 &&
          (ans.length <= 4 ? e.key == 1 : e.key % 2 == 1);
      return hide ? '_' : e.value;
    }).join(' ');
  }

  void _onLetterTap(String letter) {
    if (_answered) return;
    final blanks = _q.answer.split('').where((c) {
      final idx = _q.answer.indexOf(c);
      return idx > 0 && idx < _q.answer.length - 1 &&
          (_q.answer.length <= 4 ? idx == 1 : idx % 2 == 1);
    }).toList();

    if (_typed.length < blanks.length) {
      setState(() => _typed += letter);
      if (_typed.length == blanks.length) _checkAnswer();
    }
  }

  void _checkAnswer() {
    // Yashirilgan harflarni to'plash
    final ans = _q.answer;
    final hidden = <String>[];
    for (int i = 0; i < ans.length; i++) {
      final hide = i > 0 && i < ans.length - 1 &&
          (ans.length <= 4 ? i == 1 : i % 2 == 1);
      if (hide) hidden.add(ans[i]);
    }
    final correct = _typed.toUpperCase() == hidden.join().toUpperCase();

    setState(() {
      _answered = true;
      _correct = correct;
      if (correct) _score++;
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_currentQ >= widget.questions.length - 1) {
        widget.onScore(_score, widget.questions.length);
        widget.onComplete();
      } else {
        setState(() {
          _currentQ++;
          _typed = '';
          _answered = false;
          _correct = false;
        });
      }
    });
  }

  void _deleteLetter() {
    if (_answered || _typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress
        Row(
          children: List.generate(widget.questions.length, (i) => Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i < _currentQ
                    ? widget.color
                    : i == _currentQ
                        ? widget.color.withOpacity(0.4)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ),
        const SizedBox(height: 14),
        // Savol karti
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))],
          ),
          child: Column(
            children: [
              Text(_q.emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(
                _q.instruction,
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _q.hint,
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // So'z ko'rinishi
        _buildWordDisplay(),
        const SizedBox(height: 20),

        // Harflar klaviaturasi
        _buildLetterKeyboard(),

        // Natija xabari
        if (_answered) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _correct ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _correct ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              ),
            ),
            child: Text(
              _correct
                  ? '🎉 ${_q.answer} — To\'g\'ri!'
                  : '📚 Javob: ${_q.answer}\n${_q.context}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),
        ],
      ],
    );
  }

  Widget _buildWordDisplay() {
    final ans = _q.answer;
    final hiddenIdxs = <int>{};
    for (int i = 0; i < ans.length; i++) {
      final hide = i > 0 && i < ans.length - 1 &&
          (ans.length <= 4 ? i == 1 : i % 2 == 1);
      if (hide) hiddenIdxs.add(i);
    }

    int typedIdx = 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ans.split('').asMap().entries.map((e) {
        final i = e.key;
        final c = e.value;
        final isHidden = hiddenIdxs.contains(i);

        String display = c;
        Color bg = Colors.white;
        Color border = Colors.grey[300]!;
        Color textColor = const Color(0xFF1A1A2E);

        if (isHidden) {
          if (_answered) {
            display = c;
            bg = _correct ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
            border = _correct ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
            textColor = _correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
          } else if (typedIdx < _typed.length) {
            display = _typed[typedIdx];
            bg = widget.color.withOpacity(0.1);
            border = widget.color;
            textColor = widget.color;
            typedIdx++;
          } else {
            display = '_';
            bg = Colors.grey[100]!;
            border = Colors.grey[400]!;
            textColor = Colors.grey[400]!;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 36,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 2),
            boxShadow: isHidden ? [BoxShadow(color: border.withOpacity(0.2), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              display,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLetterKeyboard() {
    final letters = _q.letterChoices;
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: letters.map((l) => GestureDetector(
            onTap: () => _onLetterTap(l),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  l,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _deleteLetter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('⌫  O\'chirish', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
