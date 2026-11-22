import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/story_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// Ertak Tugash Ekrani — Zamonaviy oq fon dizayn
// Win: sariq konfetti, rang-barang karta
// Lose: ko'k-kumush, rag'batlantiruvchi
// ════════════════════════════════════════════════════════════════════════════

class StoryOutroScreen extends StatefulWidget {
  final StorySubject subject;
  final int score;
  final int totalQuestions;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const StoryOutroScreen({
    super.key,
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.onReplay,
    required this.onHome,
  });

  @override State<StoryOutroScreen> createState() => _StoryOutroScreenState();
}

class _StoryOutroScreenState extends State<StoryOutroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final bool _isWin;
  late final StoryHero _hero;

  @override
  void initState() {
    super.initState();
    _hero  = StoryData.getHero(widget.subject);
    _isWin = widget.score >= widget.totalQuestions * 0.6;
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(children: [
            // ── Rangli yuqori banner ───────────────────────────────────
            _buildHeader(),
            // ── Asosiy karta ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildStoryCard(),
                const SizedBox(height: 14),
                _buildScoreCard(),
                const SizedBox(height: 14),
                _buildStarsRow(),
                const SizedBox(height: 20),
                _buildButtons(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Yuqori banner ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final c1 = _isWin ? _hero.storyColors[0] : const Color(0xFF455A64);
    final c2 = _isWin
        ? (_hero.storyColors.length > 1 ? _hero.storyColors[1] : _hero.storyColors[0])
        : const Color(0xFF607D8B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: c1.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        // Pulsing emoji
        AnimatedBuilder(
          animation: _bounceCtrl,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, -6 * _bounceCtrl.value),
            child: Text(
              _isWin ? '🏆' : '💪',
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

        const SizedBox(height: 14),

        // Sarlavha
        Text(
          _isWin ? 'BARAKALLA!' : 'QO\'RQMA!',
          style: GoogleFonts.nunito(
            fontSize: 30, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: 2,
            shadows: [Shadow(color: Colors.black26,
              blurRadius: 8, offset: const Offset(1, 2))],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),

        const SizedBox(height: 6),

        // Natija matni
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _isWin
                ? '${widget.score}/${widget.totalQuestions} to\'g\'ri javob! 🎉'
                : 'Yana bir bor urinib ko\'r!',
            style: GoogleFonts.nunito(
              fontSize: 14, color: Colors.white,
              fontWeight: FontWeight.w700),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ]),
    );
  }

  // ── Ertak yakuni kartasi ───────────────────────────────────────────────────
  Widget _buildStoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        // Ikki kahramon
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: _buildCharacterRow(),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

        const SizedBox(height: 16),

        // Ajratuvchi chiziq
        Container(height: 1, color: const Color(0xFFF0F0F0)),
        const SizedBox(height: 14),

        // Ertak yakuni matni
        Text(
          _isWin ? _hero.winEnding : _hero.loseEnding,
          style: GoogleFonts.nunito(
            fontSize: 14, color: const Color(0xFF444466),
            height: 1.65, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 700.ms),
      ]),
    );
  }

  List<Widget> _buildCharacterRow() {
    if (_isWin) {
      return [
        _OutroCharacter(emoji: _hero.heroEmoji, name: _hero.heroName,
          mood: '😄', label: 'Baxtli!', color: _hero.storyColors[0]),
        const SizedBox(width: 12),
        const Text('❤️', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        _OutroCharacter(emoji: _hero.companionEmoji, name: _hero.companionName,
          mood: '🎉', label: 'Baxtli!', color: _hero.storyColors[0]),
      ];
    } else {
      return [
        _OutroCharacter(emoji: _hero.heroEmoji, name: _hero.heroName,
          mood: '😔', label: 'Hali umid bor!', color: const Color(0xFF78909C)),
        const SizedBox(width: 12),
        const Text('💙', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        _OutroCharacter(emoji: _hero.companionEmoji, name: _hero.companionName,
          mood: '🙏', label: 'Kutmoqda...', color: const Color(0xFF78909C)),
      ];
    }
  }

  // ── Natija progress kartasi ────────────────────────────────────────────────
  Widget _buildScoreCard() {
    final pct = widget.totalQuestions > 0
        ? widget.score / widget.totalQuestions : 0.0;
    final barColor = _isWin ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Natija:', style: GoogleFonts.nunito(
              color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${(pct * 100).round()}%', style: GoogleFonts.nunito(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pct, minHeight: 12,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ).animate().slideX(begin: -1, delay: 500.ms,
            duration: 1000.ms, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.score} to\'g\'ri', style: GoogleFonts.nunito(
              fontSize: 11, color: barColor, fontWeight: FontWeight.w700)),
            Text('${widget.totalQuestions - widget.score} noto\'g\'ri',
              style: GoogleFonts.nunito(
                fontSize: 11, color: Colors.red[300], fontWeight: FontWeight.w700)),
          ],
        ),
      ]),
    );
  }

  // ── Yulduzlar ──────────────────────────────────────────────────────────────
  Widget _buildStarsRow() {
    final pct = widget.totalQuestions > 0
        ? widget.score / widget.totalQuestions : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = pct >= (i + 1) / 3;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(children: [
            Text(filled ? '⭐' : '☆',
              style: TextStyle(fontSize: 36,
                color: filled ? Colors.amber : Colors.black12),
            ).animate(delay: Duration(milliseconds: 600 + i * 150))
                .scale(curve: Curves.elasticOut, duration: 500.ms),
          ]),
        );
      }),
    );
  }

  // ── Tugmalar ───────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    final accentColor = _isWin
        ? _hero.storyColors[0] : const Color(0xFF5C6BC0);

    return Column(children: [
      // Qayta o'ynash — asosiy tugma
      GestureDetector(
        onTap: widget.onReplay,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              accentColor,
              accentColor.withOpacity(0.8),
            ]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: accentColor.withOpacity(0.35),
                blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🔄', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Yana O\'yna!', style: GoogleFonts.nunito(
              fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
          ]),
        ),
      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),

      const SizedBox(height: 12),

      // Uyga qaytish — ikkilamchi tugma
      GestureDetector(
        onTap: widget.onHome,
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🏠', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Bosh Sahifa', style: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w800, color: accentColor)),
          ]),
        ),
      ).animate().fadeIn(delay: 1100.ms),
    ]);
  }
}

// ── Yakun kahramon avatarl ─────────────────────────────────────────────────────
class _OutroCharacter extends StatelessWidget {
  final String emoji;
  final String name;
  final String mood;
  final String label;
  final Color color;

  const _OutroCharacter({
    required this.emoji,
    required this.name,
    required this.mood,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Center(child: Text(emoji,
            style: const TextStyle(fontSize: 34))),
        ),
        Positioned(right: 0, bottom: 0,
          child: Text(mood, style: const TextStyle(fontSize: 20))),
      ]),
      const SizedBox(height: 6),
      Text(name, style: GoogleFonts.nunito(
        fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.nunito(
        fontSize: 10, color: Colors.black45)),
    ]);
  }
}
