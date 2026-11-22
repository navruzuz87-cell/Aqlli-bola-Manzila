import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// ════════════════════════════════════════════════════════════════════════════
// ORDER SEQUENCE O'YIN — Tartibga solish
// Voqealar, raqamlar, sanalarni to'g'ri tartibga sol
// Misol: Tarixiy voqealarni yil tartibida joylashtir
// ════════════════════════════════════════════════════════════════════════════

class OrderItem {
  final String text;
  final String emoji;
  final int correctOrder;    // 0, 1, 2, 3...
  final String yearOrHint;   // Ko'rsatmaslik mumkin

  const OrderItem({
    required this.text,
    required this.emoji,
    required this.correctOrder,
    this.yearOrHint = '',
  });
}

class OrderSequenceQuestion {
  final String instruction;
  final String emoji;
  final List<OrderItem> items;
  final bool showYears;

  const OrderSequenceQuestion({
    required this.instruction,
    required this.emoji,
    required this.items,
    this.showYears = false,
  });
}

class OrderSequenceGame extends StatefulWidget {
  final OrderSequenceQuestion question;
  final Color color;
  final VoidCallback onComplete;
  final Function(int score, int max) onScore;

  const OrderSequenceGame({
    super.key,
    required this.question,
    required this.color,
    required this.onComplete,
    required this.onScore,
  });

  @override
  State<OrderSequenceGame> createState() => _OrderSequenceGameState();
}

class _OrderSequenceGameState extends State<OrderSequenceGame> {
  late List<OrderItem> _shuffled;
  late List<OrderItem?> _placed;   // foydalanuvchi joylagan tartib
  int? _selected;                   // tanlangan element indeksi (_shuffled ichida)
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _shuffled = [...widget.question.items]..shuffle(Random());
    _placed = List.filled(widget.question.items.length, null);
  }

  void _onSelectItem(int idx) {
    if (_submitted) return;
    setState(() {
      if (_selected == idx) {
        _selected = null;
      } else {
        _selected = idx;
      }
    });
  }

  void _onPlaceInSlot(int slotIdx) {
    if (_submitted || _selected == null) return;
    final item = _shuffled[_selected!];

    // Agar slot band bo'lsa — almashtir
    final existing = _placed[slotIdx];
    setState(() {
      _placed[slotIdx] = item;
      if (existing != null) {
        // Eski narsani qaytarib qo'y
        final oldIdx = _shuffled.indexWhere((e) => e.text == existing.text);
        if (oldIdx < 0) _shuffled.add(existing);
      }
      _selected = null;
    });
  }

  void _removeFromSlot(int slotIdx) {
    if (_submitted || _placed[slotIdx] == null) return;
    setState(() {
      _placed[slotIdx] = null;
    });
  }

  void _submit() {
    if (_submitted) return;
    final filled = _placed.where((p) => p != null).length;
    if (filled < widget.question.items.length) return;

    int correct = 0;
    for (int i = 0; i < _placed.length; i++) {
      if (_placed[i]?.correctOrder == i) correct++;
    }
    _score = correct;
    widget.onScore(_score, widget.question.items.length);
    setState(() => _submitted = true);
    Future.delayed(const Duration(milliseconds: 2000), widget.onComplete);
  }

  List<OrderItem> get _unusedItems {
    final used = _placed.where((p) => p != null).map((p) => p!.text).toSet();
    return _shuffled.where((s) => !used.contains(s.text)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allFilled = _placed.every((p) => p != null);

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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.instruction,
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                    ),
                    Text(
                      '1-raqam = eng birinchi',
                      style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tartiblanadigan slotlar
        ...List.generate(widget.question.items.length, (i) => _buildSlot(i)),
        const SizedBox(height: 12),

        // Tanlanmagan elementlar
        if (_unusedItems.isNotEmpty) ...[
          Text(
            '👆 Birini tanlang:',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _unusedItems.asMap().entries.map((e) {
              final item = e.value;
              final origIdx = _shuffled.indexOf(item);
              final isSelected = _selected == origIdx;
              return GestureDetector(
                onTap: () => _onSelectItem(origIdx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.color : widget.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? widget.color : widget.color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 8)] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        item.text,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],

        // Tasdiqlash tugmasi
        if (!_submitted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: allFilled ? widget.color : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: allFilled ? _submit : null,
              child: Text(
                '✅ Tekshirish',
                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),

        if (_submitted) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _score == widget.question.items.length
                  ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _score == widget.question.items.length
                  ? '🏆 Mukammal tartib!'
                  : '📚 $_score/${widget.question.items.length} to\'g\'ri joylashtirildi',
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800,
                  color: _score == widget.question.items.length
                      ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),
        ],
      ],
    );
  }

  Widget _buildSlot(int slotIdx) {
    final item = _placed[slotIdx];
    final hasSelected = _selected != null;
    bool correct = false;
    bool wrong = false;
    if (_submitted && item != null) {
      correct = item.correctOrder == slotIdx;
      wrong = !correct;
    }

    return GestureDetector(
      onTap: item != null
          ? () => _removeFromSlot(slotIdx)
          : hasSelected
              ? () => _onPlaceInSlot(slotIdx)
              : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: item != null
              ? (correct ? const Color(0xFFE8F5E9) : wrong ? const Color(0xFFFFEBEE) : widget.color.withOpacity(0.07))
              : hasSelected
                  ? Colors.amber.withOpacity(0.1)
                  : const Color(0xFFF3F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item != null
                ? (correct ? const Color(0xFF4CAF50) : wrong ? const Color(0xFFEF5350) : widget.color.withOpacity(0.4))
                : hasSelected
                    ? Colors.amber
                    : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Raqam
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item != null
                    ? (correct ? const Color(0xFF4CAF50) : wrong ? const Color(0xFFEF5350) : widget.color)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${slotIdx + 1}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: item != null ? Colors.white : Colors.grey[500],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: item != null
                  ? Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.text,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: correct
                                      ? const Color(0xFF2E7D32)
                                      : wrong
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF1A1A2E),
                                ),
                              ),
                              if (widget.question.showYears && item.yearOrHint.isNotEmpty)
                                Text(item.yearOrHint,
                                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        if (_submitted)
                          Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
                        if (!_submitted)
                          const Text('✕', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : Text(
                      hasSelected ? '👆 Bu yerga qo\'ying' : 'Bo\'sh joy...',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: hasSelected ? Colors.amber[700] : Colors.grey[400],
                        fontWeight: hasSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
