import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/story_model.dart';
import 'manzila_bot_widget.dart';

// ════════════════════════════════════════════════════════════════════════════
// StoryGameWrapper — Har qanday o'yinni ertak qahramonlari bilan o'rash
// Har bir to'g'ri/xato javobda kahramon holati o'zgaradi
// ════════════════════════════════════════════════════════════════════════════

class StoryGameState extends ChangeNotifier {
  final StorySubject subject;
  final int totalSteps;

  StoryGameState({
    required this.subject,
    required this.totalSteps,
  });

  int _heroHealth = 5;
  int _currentStep = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _consecutiveWrong = 0;
  bool _showBotHint = false;
  String _botHint = '';
  String _botMood = 'thinking';
  bool _isGameOver = false;
  bool _showStepAnim = false;
  bool _heroMovingForward = false;
  bool _heroMovingBack = false;

  int get heroHealth => _heroHealth;
  int get currentStep => _currentStep;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  bool get showBotHint => _showBotHint;
  String get botHint => _botHint;
  String get botMood => _botMood;
  bool get isGameOver => _isGameOver;
  bool get showStepAnim => _showStepAnim;
  bool get heroMovingForward => _heroMovingForward;
  bool get heroMovingBack => _heroMovingBack;

  double get progressPct =>
      totalSteps > 0 ? _currentStep / totalSteps : 0.0;

  bool get companionHappy => _heroHealth >= 3;

  void onCorrectAnswer({String? hint}) {
    _correctAnswers++;
    _consecutiveWrong = 0;

    // Kahramon oldinga boradi
    _currentStep = (_currentStep + 1).clamp(0, totalSteps);

    // Sog'liq +1 (maks 5)
    if (_heroHealth < 5) _heroHealth++;

    // Harakat animatsiyasi
    _heroMovingForward = true;
    _showStepAnim = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () {
      _heroMovingForward = false;
      _showStepAnim = false;

      // O'yin tugadimi?
      if (_currentStep >= totalSteps) {
        _isGameOver = true;
      }
      notifyListeners();
    });
  }

  void onWrongAnswer({String? hint}) {
    _wrongAnswers++;
    _consecutiveWrong++;

    // Sog'liq -1 (min 0)
    if (_heroHealth > 0) _heroHealth--;

    // Kahramon orqaga ketadi
    _heroMovingBack = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 600), () {
      _heroMovingBack = false;
      notifyListeners();
    });

    // 3 ketma-ket xatoda Manzila bot chiqadi
    if (_consecutiveWrong >= 3 && hint != null) {
      Future.delayed(const Duration(milliseconds: 700), () {
        showBotWithHint(hint, mood: 'helping');
      });
    }

    // Sog'liq 0 ga tushsa o'yin tugaydi
    if (_heroHealth <= 0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isGameOver = true;
        notifyListeners();
      });
    }
  }

  void showBotWithHint(String hint, {String mood = 'thinking'}) {
    _botHint = hint;
    _botMood = mood;
    _showBotHint = true;
    notifyListeners();
  }

  void dismissBot() {
    _showBotHint = false;
    _consecutiveWrong = 0; // Reset consecutive wrong after hint
    notifyListeners();
  }

  void resetGame() {
    _heroHealth = 5;
    _currentStep = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _consecutiveWrong = 0;
    _showBotHint = false;
    _isGameOver = false;
    _heroMovingForward = false;
    _heroMovingBack = false;
    notifyListeners();
  }
}

// ── Story HUD (Heads-Up Display) — O'yin ustida ko'rsatiladi ─────────────────
class StoryHUD extends StatelessWidget {
  final StoryGameState gameState;
  final StorySubject subject;
  final VoidCallback? onHelpTap;

  const StoryHUD({
    super.key,
    required this.gameState,
    required this.subject,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    final hero = StoryData.getHero(subject);
    final c1 = hero.storyColors[0];
    final c2 = hero.storyColors.length > 1 ? hero.storyColors[1] : c1;

    return ListenableBuilder(
      listenable: gameState,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [c1, c2],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: c1.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(children: [
            Row(children: [
              // Kahramon
              _AnimatedHero(
                emoji: hero.heroEmoji,
                movingForward: gameState.heroMovingForward,
                movingBack: gameState.heroMovingBack,
              ),
              const SizedBox(width: 10),
              // Progress bar
              Expanded(
                child: _JourneyBar(
                  progress: gameState.progressPct,
                  companionEmoji: hero.companionEmoji,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // Companion
              Opacity(
                opacity: gameState.companionHappy ? 1.0 : 0.4,
                child: Text(hero.companionEmoji,
                  style: const TextStyle(fontSize: 28)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _HealthHearts(health: gameState.heroHealth),
              const Spacer(),
              // Yordam tugmasi
              if (onHelpTap != null)
                GestureDetector(
                  onTap: onHelpTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🤖', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('Yordam', style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.white,
                        fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          ]),
        );
      },
    );
  }
}

// ── Kahramon harakat animatsiyasi ─────────────────────────────────────────────
class _AnimatedHero extends StatelessWidget {
  final String emoji;
  final bool movingForward;
  final bool movingBack;

  const _AnimatedHero({
    required this.emoji,
    required this.movingForward,
    required this.movingBack,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      emoji,
      style: const TextStyle(fontSize: 32),
    );

    if (movingForward) {
      child = child
          .animate()
          .moveX(begin: 0, end: 8, duration: 200.ms)
          .then()
          .moveX(begin: 8, end: 0, duration: 200.ms)
          .then()
          .scale(begin: const Offset(1.3, 1.3), end: const Offset(1.0, 1.0),
              duration: 200.ms);
    } else if (movingBack) {
      child = child
          .animate()
          .shake(hz: 4, duration: 500.ms);
    }

    return child;
  }
}

// ── Yo'l chizig'i ─────────────────────────────────────────────────────────────
class _JourneyBar extends StatelessWidget {
  final double progress;
  final String companionEmoji;
  final Color color;

  const _JourneyBar({
    required this.progress,
    required this.companionEmoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            backgroundColor: Colors.white20,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        // Manzil belgisi (oxirida)
        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              '🏁',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Yurak sog'liq ko'rsatkichi ────────────────────────────────────────────────
class _HealthHearts extends StatelessWidget {
  final int health;

  const _HealthHearts({required this.health});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < health;
        return Text(
          filled ? '❤️' : '🖤',
          style: const TextStyle(fontSize: 16),
        ).animate(key: ValueKey('$i-$filled'))
            .scale(duration: 300.ms, curve: Curves.elasticOut);
      }),
    );
  }
}
