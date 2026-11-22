import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// DRAG & DROP O'YIN — Juftlashtirish
// So'z yoki rasm → to'g'ri joyga tashlash
// Misol: Viloyat → Poytaxt, Kashfiyot → Olim, Raqam → Natija
// ════════════════════════════════════════════════════════════════════════════

class DragDropQuestion {
  final String title;
  final String emoji;
  final List<DragPair> pairs;

  const DragDropQuestion({
    required this.title,
    required this.emoji,
    required this.pairs,
  });
}

class DragPair {
  final String left;   // sudrab olinadigan
  final String right;  // tashlash joyi
  final String emoji;

  const DragPair({required this.left, required this.right, this.emoji = ''});
}

class DragDropGame extends StatefulWidget {
  final DragDropQuestion question;
  final Color color;
  final VoidCallback onComplete;
  final Function(int score, int max) onScore;

  const DragDropGame({
    super.key,
    required this.question,
    required this.color,
    required this.onComplete,
    required this.onScore,
  });

  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

class _DragDropGameState extends State<DragDropGame> with TickerProviderStateMixin {
  late List<DragPair> _shuffledLeft;
  late List<DragPair?> _slots;        // har slot: null yoki tashlanganPair
  late List<bool> _slotCorrect;
  late List<bool> _used;
  int _score = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _shuffledLeft = [...widget.question.pairs]..shuffle(Random());
    _slots = List.filled(widget.question.pairs.length, null);
    _slotCorrect = List.filled(widget.question.pairs.length, false);
    _used = List.filled(widget.question.pairs.length, false);
  }

  void _onDrop(DragPair dragged, int slotIdx) {
    final correctPair = widget.question.pairs[slotIdx];
    final isCorrect = dragged.left == correctPair.left;

    setState(() {
      _slots[slotIdx] = dragged;
      _slotCorrect[slotIdx] = isCorrect;
      final leftIdx = _shuffledLeft.indexOf(dragged);
      if (leftIdx >= 0) _used[leftIdx] = true;
      if (isCorrect) _score++;
    });

    // Hammasi to'ldirilganmi?
    final filled = _slots.where((s) => s != null).length;
    if (filled == widget.question.pairs.length) {
      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onScore(_score, widget.question.pairs.length);
        setState(() => _done = true);
        Future.delayed(const Duration(milliseconds: 1200), widget.onComplete);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sarlavha
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,4))],
          ),
          child: Row(
            children: [
              Text(widget.question.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question.title,
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // O'yin maydoni
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chap: sudrab olinadi
            Expanded(
              child: Column(
                children: [
                  Text('🤚 Tortib oling', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...widget.question.pairs.asMap().entries.map((e) {
                    final pair = _shuffledLeft[e.key];
                    final used = _used[e.key];
                    return _buildDraggable(pair, used);
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // O'q
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: List.generate(widget.question.pairs.length, (i) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('→', style: TextStyle(fontSize: 20, color: widget.color)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // O'ng: slot
            Expanded(
              child: Column(
                children: [
                  Text('📌 Tashlang', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...widget.question.pairs.asMap().entries.map((e) {
                    return _buildDropTarget(e.key, e.value);
                  }),
                ],
              ),
            ),
          ],
        ),
        if (_done) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              _score == widget.question.pairs.length ? '🎉 Ajoyib! Hammasi to\'g\'ri!' : '✅ $_score/${widget.question.pairs.length} to\'g\'ri',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: widget.color),
            ),
          ).animate().scale(),
        ],
      ],
    );
  }

  Widget _buildDraggable(DragPair pair, bool used) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Draggable<DragPair>(
        data: pair,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${pair.emoji} ${pair.left}',
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
        childWhenDragging: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1.5, style: BorderStyle.solid),
          ),
        ),
        child: AnimatedOpacity(
          opacity: used ? 0.3 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: used ? Colors.grey[100] : widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: used ? Colors.grey[300]! : widget.color.withOpacity(0.4)),
            ),
            child: Text(
              '${pair.emoji} ${pair.left}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: used ? Colors.grey[400] : widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropTarget(int idx, DragPair correctPair) {
    final filled = _slots[idx];
    final correct = _slotCorrect[idx];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<DragPair>(
        onAcceptWithDetails: (details) => _onDrop(details.data, idx),
        builder: (_, candidateData, __) {
          final hovering = candidateData.isNotEmpty;
          Color bg = filled != null
              ? (correct ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
              : hovering
                  ? widget.color.withOpacity(0.15)
                  : const Color(0xFFF3F4FF);
          Color border = filled != null
              ? (correct ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))
              : hovering
                  ? widget.color
                  : Colors.grey[300]!;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    filled != null ? '${filled.emoji} ${filled.left}' : correctPair.right,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: filled != null
                          ? (correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                          : Colors.grey[500],
                    ),
                  ),
                ),
                if (filled != null)
                  Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
