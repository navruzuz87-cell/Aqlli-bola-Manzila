import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/story_model.dart';

// ════════════════════════════════════════════════════════════════════════════
// Ertak Kirish Ekrani — 4-rasmdagi zamonaviy uslubda
// Oq fon, rangli header, kahramon rasmi yoki emoji, matn, boshlash tugmasi
// ════════════════════════════════════════════════════════════════════════════

class StoryIntroScreen extends StatefulWidget {
  final StorySubject subject;
  final VoidCallback onStart;

  const StoryIntroScreen({
    super.key,
    required this.subject,
    required this.onStart,
  });

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;
  int _textStep = 0;
  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    Future.delayed(600.ms,  () { if (mounted) setState(() => _textStep = 1); });
    Future.delayed(1200.ms, () { if (mounted) setState(() => _textStep = 2); });
    Future.delayed(2000.ms, () { if (mounted) setState(() => _canStart = true); });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = StoryData.getHero(widget.subject);
    final c1 = hero.storyColors[0];
    final c2 = hero.storyColors[1];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Rangli yuqori qism ──────────────────────────────────
            _buildHeader(hero, c1, c2),
            // ── Pastki oq qism ──────────────────────────────────────
            Expanded(child: _buildContent(hero, c1)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(StoryHero hero, Color c1, Color c2) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Bezak doiralar
          Positioned(top: -30, right: -30,
            child: Container(width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08)))),
          Positioned(bottom: 20, left: -20,
            child: Container(width: 90, height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08)))),

          // Orqaga qaytish
          Positioned(
            top: 12, left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
              ),
            ),
          ),

          // Fan badge yuqorida
          Positioned(
            top: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(hero.worldName,
                style: GoogleFonts.nunito(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Colors.white)),
            ),
          ),

          // Kahramon rasmi yoki emoji — markazda
          Center(
            child: AnimatedBuilder(
              animation: _heroController,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -6 * _heroController.value),
                child: child,
              ),
              child: _buildHeroImage(hero),
            ),
          ),

          // Sarlavha pastda
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hero.questTitle,
                  style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26,
                      blurRadius: 8, offset: const Offset(0, 2))],
                  )),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.1, duration: 600.ms, curve: Curves.easeOut)
        .fadeIn(duration: 500.ms);
  }

  Widget _buildHeroImage(StoryHero hero) {
    // Geografiya uchun milliy kiyimli qiz rasmi
    if (widget.subject == StorySubject.geografiya) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/characters/hero_girl_horse.jpg',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(hero.heroEmoji,
              style: const TextStyle(fontSize: 90)),
          ),
        ),
      );
    }
    // Boshqalar uchun katta emoji
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Center(
        child: Text(hero.heroEmoji,
          style: const TextStyle(fontSize: 62)),
      ),
    );
  }

  Widget _buildContent(StoryHero hero, Color c1) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Kahramon info kartasi
          if (_textStep >= 1)
            _buildInfoCard(hero, c1).animate()
                .fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 14),

          // Vazifa tavsifi
          if (_textStep >= 2)
            _buildStoryCard(hero, c1).animate()
                .fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 20),

          // Boshlash tugmasi
          if (_canStart)
            _buildStartButton(c1).animate()
                .fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(StoryHero hero, Color c1) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Kahramon avatar
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: c1.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: c1.withOpacity(0.3), width: 2),
            ),
            child: Center(child: Text(hero.heroEmoji,
              style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kahramon',
                  style: GoogleFonts.nunito(fontSize: 11,
                    color: Colors.black45, fontWeight: FontWeight.w700)),
                Text(hero.heroName,
                  style: GoogleFonts.nunito(fontSize: 18,
                    fontWeight: FontWeight.w900, color: Colors.black87)),
              ],
            ),
          ),
          // Hamroh
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Hamroh',
                style: GoogleFonts.nunito(fontSize: 11,
                  color: Colors.black45, fontWeight: FontWeight.w700)),
              Row(
                children: [
                  Text(hero.companionEmoji,
                    style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(hero.companionName,
                    style: GoogleFonts.nunito(fontSize: 12,
                      fontWeight: FontWeight.w700, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(StoryHero hero, Color c1) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c1.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c1.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(hero.worldEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Vazifa',
                style: GoogleFonts.nunito(fontSize: 13,
                  fontWeight: FontWeight.w900, color: c1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(hero.questDescription,
            style: GoogleFonts.nunito(fontSize: 14,
              color: Colors.black87, height: 1.6, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStartButton(Color c1) {
    return GestureDetector(
      onTap: widget.onStart,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c1.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: c1.withOpacity(0.4),
              blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text("O'yinni boshlash!",
              style: GoogleFonts.nunito(fontSize: 18,
                fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
