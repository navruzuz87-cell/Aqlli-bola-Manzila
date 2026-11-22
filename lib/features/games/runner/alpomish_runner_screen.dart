import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/services/game_config_service.dart';
import '../../../core/services/game_stats_service.dart';

// ════════════════════════════════════════════════════════════════════════════
// ALPOMISH RUNNER — Yugurish + So'z yig'ish o'yini
// Alpomish yuguradi, to'g'ri harflarni yig'ib so'z tuzadi
// Fon: O'zbekiston tarixiy joylari (Registon, Buxoro, Xiva...)
// ════════════════════════════════════════════════════════════════════════════

// ── O'yin so'zlari: (so'z, izoh, joy) ────────────────────────────────────────
const _levels = [
  _Level(word: 'IPAK', hint: 'Buyuk Ipak Yo\'li', place: 'Samarqand', placeEmoji: '🕌', color: Color(0xFF1565C0)),
  _Level(word: 'OLTIN', hint: 'Oltin zargarlari', place: 'Buxoro', placeEmoji: '🌙', color: Color(0xFF6A1B9A)),
  _Level(word: 'BURGUT', hint: 'O\'zbek milliy ramzi', place: 'Toshkent', placeEmoji: '🏙️', color: Color(0xFF1B5E20)),
  _Level(word: 'DARYO', hint: 'Amudaryo va Sirdaryo', place: 'Xorazm', placeEmoji: '🏺', color: Color(0xFF4A148C)),
  _Level(word: 'SHOH', hint: 'Amir Temur davlati', place: 'Shahrisabz', placeEmoji: '⭐', color: Color(0xFF880E4F)),
  _Level(word: 'NAVOIY', hint: 'Buyuk shoir Alisher Navoiy', place: 'Hirot', placeEmoji: '📚', color: Color(0xFF004D40)),
  _Level(word: 'MINORA', hint: 'Kalon minorasi', place: 'Buxoro', placeEmoji: '🌙', color: Color(0xFF37474F)),
  _Level(word: 'REGISTON', hint: 'Dunyoning eng go\'zal maydoni', place: 'Samarqand', placeEmoji: '🕌', color: Color(0xFF1A237E)),
];

class _Level {
  final String word;
  final String hint;
  final String place;
  final String placeEmoji;
  final Color color;
  const _Level({required this.word, required this.hint, required this.place, required this.placeEmoji, required this.color});
}

// ── Havoda uchib kelayotgan harf ──────────────────────────────────────────────
class _RunnerObstacle {
  final int lane;
  final String emoji;
  final bool requiresJump;
  double y;
  bool resolved = false;

  _RunnerObstacle({
    required this.lane,
    required this.emoji,
    required this.requiresJump,
    required this.y,
  });
}

class _FlyingLetter {
  final String letter;
  final bool isCorrect;
  double x; // 0.0 - 1.0 (ekran eni bo'yicha)
  double y; // pixel (yuqoridan)
  final double speed;
  final double lane; // 0,1,2 — yo'laklar
  bool collected = false;
  bool missed = false;
  final int id;

  _FlyingLetter({
    required this.letter,
    required this.isCorrect,
    required this.x,
    required this.y,
    required this.speed,
    required this.lane,
    required this.id,
  });
}

// ── Zarralar (particle) ───────────────────────────────────────────────────────
class _Particle {
  double x, y, vx, vy, life;
  final Color color;
  _Particle({required this.x, required this.y, required this.vx, required this.vy, required this.color}) : life = 1.0;
}

// ════════════════════════════════════════════════════════════════════════════
class AlpomishRunnerScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const AlpomishRunnerScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<AlpomishRunnerScreen> createState() => _AlpomishRunnerScreenState();
}

class _AlpomishRunnerScreenState extends State<AlpomishRunnerScreen>
    with TickerProviderStateMixin {

  // ── Animatsiya controllerlari ─────────────────────────────────────────────
  late AnimationController _gameLoop;   // asosiy o'yin loop
  late AnimationController _heroAnim;   // qahramon animatsiyasi
  late AnimationController _bgScroll;   // fon harakati
  late AnimationController _shakeCtrl;  // noto'g'ri javob silkinishi

  // ── O'yin holati ─────────────────────────────────────────────────────────
  int _levelIdx = 0;
  int _heroLane = 1;        // 0=chap, 1=o'rta, 2=o'ng
  double _heroY = 0;        // sakrash uchun (manfiy qiymat — yuqoriga)
  double _jumpElapsed = 0;
  bool _isJumping = false;
  int _lives = 3;
  int _score = 0;
  int _combo = 0;
  bool _gameOver = false;
  bool _levelComplete = false;
  bool _showPlaceInfo = false;

  // ── So'z holati ──────────────────────────────────────────────────────────
  List<String> _collectedLetters = [];
  late List<String> _targetWord;
  late List<String> _wrongLetters;

  // ── Harflar va zarralar ──────────────────────────────────────────────────
  final List<_FlyingLetter> _letters = [];
  final List<_RunnerObstacle> _obstacles = [];
  final List<_Particle> _particles = [];
  int _letterIdCounter = 0;
  double _spawnTimer = 0;
  double _spawnInterval = 1.8; // sekund
  double _obstacleTimer = 0;
  double _slideRemaining = 0;
  bool _isSliding = false;
  double _gameSpeed = 1.0;
  GameConfigData _config = GameConfigData.defaults('alpomish_runner');
  final Set<int> _rewardedLevels = <int>{};
  int _earnedStars = 0;
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  bool _ageRestricted = false;
  bool _statsRecorded = false;
  DateTime _runStartedAt = DateTime.now();
  double _bgOffset = 0;

  // ── Flash effekti ─────────────────────────────────────────────────────────
  Color? _flashColor;
  double _flashOpacity = 0;

  final _rand = Random();

  _Level get _currentLevel => _levels[_levelIdx % _levels.length];

  @override
  void initState() {
    super.initState();
    _initLevel();
    _loadGameConfig();

    _gameLoop = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_onTick)
      ..forward();

    _heroAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..repeat(reverse: true);

    _bgScroll = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  Future<void> _loadGameConfig() async {
    final loaded = await GameConfigService.instance.load('alpomish_runner');
    if (!mounted) return;
    setState(() {
      _config = loaded;
      _gameSpeed = loaded.speed;
      final difficultyFactor = loaded.difficulty == 'easy' ? 1.22 : loaded.difficulty == 'hard' ? 0.78 : 1.0;
      _spawnInterval = (1.8 / (loaded.speed * difficultyFactor)).clamp(0.55, 2.6).toDouble();
      _ageRestricted = !loaded.isSuitableForAge(widget.profile.age);
      _remainingSeconds = loaded.timeLimitSeconds;
      if (!loaded.enabled || _ageRestricted) {
        _gameOver = true;
        _gameLoop.stop();
      } else if (loaded.timerEnabled) {
        _startSessionTimer();
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameOver || _levelComplete) { timer.cancel(); return; }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() { _remainingSeconds = 0; _gameOver = true; });
        _gameLoop.stop();
        _recordRunResult();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _initLevel() {
    _collectedLetters = [];
    _letters.clear();
    _obstacles.clear();
    _targetWord = _currentLevel.word.split('');

    // Noto'g'ri harflar — o'zbek alifbosidan
    const allLetters = ['A','B','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','X','Y','Z'];
    final wrongSet = <String>{};
    while (wrongSet.length < 6) {
      final l = allLetters[_rand.nextInt(allLetters.length)];
      if (!_targetWord.contains(l)) wrongSet.add(l);
    }
    _wrongLetters = wrongSet.toList();
    final difficultyFactor = _config.difficulty == 'easy' ? 1.22 : _config.difficulty == 'hard' ? 0.78 : 1.0;
    _spawnInterval = (1.8 / (_config.speed * difficultyFactor)).clamp(0.55, 2.6).toDouble();
    _obstacleTimer = 1.2;
    _slideRemaining = 0;
    _isSliding = false;
    _gameSpeed = _config.speed;
  }

  double _lastTime = 0;

  void _onTick() {
    if (_gameOver || _levelComplete) return;
    final t = _gameLoop.value * (const Duration(days: 1).inMilliseconds / 1000.0);
    final dt = (_lastTime == 0) ? 0.016 : (t - _lastTime).clamp(0.0, 0.05);
    _lastTime = t;

    _bgOffset += dt * 80 * _gameSpeed;

    // Sakrash fizikasi: yuqoriga ko'tarilish va pastga tushish bitta siklda.
    // Avvalgi kodda _isJumping true holatida qolib, qahramon havoda osilib qolishi mumkin edi.
    if (_isJumping) {
      _jumpElapsed += dt;
      final progress = (_jumpElapsed / 0.78).clamp(0.0, 1.0);
      _heroY = -sin(progress * pi) * 126;
      if (progress >= 1.0) {
        _heroY = 0;
        _jumpElapsed = 0;
        _isJumping = false;
      }
    }

    // Harf spawning
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnLetter();
      _spawnInterval = (1.5 / _config.speed - _gameSpeed * 0.1).clamp(0.6, 1.8).toDouble();
    }

    // Sirpanish holati
    if (_isSliding) {
      _slideRemaining -= dt;
      if (_slideRemaining <= 0) _isSliding = false;
    }

    // To'siqlar: sakrash yoki sirpanish bilan o'tiladi.
    final screenH = MediaQuery.sizeOf(context).height;
    _obstacleTimer += dt;
    if (_obstacleTimer >= (2.9 - (_gameSpeed * 0.18)).clamp(1.7, 2.9)) {
      _obstacleTimer = 0;
      // To'siq kerakli harf bilan bir yo'lakda kelib, bolani adolatsiz holatga
      // solmasligi uchun yaqinlashayotgan to'g'ri harf yo'laklari vaqtincha band.
      final occupiedLanes = _letters
          .where((letter) => !letter.collected && !letter.missed && letter.isCorrect && letter.y < 240)
          .map((letter) => letter.lane.round())
          .toSet();
      final safeLanes = [0, 1, 2].where((lane) => !occupiedLanes.contains(lane)).toList();
      if (safeLanes.isNotEmpty) {
        final jumpObstacle = _rand.nextBool();
        _obstacles.add(_RunnerObstacle(
          lane: safeLanes[_rand.nextInt(safeLanes.length)],
          emoji: jumpObstacle ? '🪵' : '🌿',
          requiresJump: jumpObstacle,
          y: -70,
        ));
      }
    }
    final heroScreenY = screenH * 0.72 + _heroY;
    for (final obstacle in _obstacles) {
      if (obstacle.resolved) continue;
      obstacle.y += dt * (180 + _gameSpeed * 40);
      final sameLane = obstacle.lane == _heroLane;
      final nearHero = (obstacle.y - heroScreenY).abs() < 48;
      final avoided = obstacle.requiresJump ? _heroY < -65 : _isSliding;
      if (sameLane && nearHero && !avoided) {
        obstacle.resolved = true;
        _lives--;
        _combo = 0;
        _flashColor = Colors.redAccent;
        _flashOpacity = 0.42;
        _shakeCtrl.forward(from: 0);
        HapticFeedback.heavyImpact();
        if (_lives <= 0) {
          _gameOver = true;
          _gameLoop.stop();
          _recordRunResult();
        }
      } else if (obstacle.y > heroScreenY + 55) {
        obstacle.resolved = true;
        if (sameLane) _score += 5;
      }
    }
    _obstacles.removeWhere((o) => o.resolved || o.y > screenH + 100);

    // Harflarni yangilash
    for (final fl in _letters) {
      if (fl.collected || fl.missed) continue;
      fl.y += dt * (180 + _gameSpeed * 40) * fl.speed;

      // Qahramon bilan to'qnashuv tekshirish
      final heroX = _heroLane / 2.0;
      final heroScreenY = screenH * 0.72 + _heroY;
      final letterScreenY = fl.y;
      final letterScreenX = fl.lane / 2.0;

      final dx = (heroX - letterScreenX).abs();
      final dy = (heroScreenY - letterScreenY).abs();

      if (dx < 0.15 && dy < 60 && _heroY > -80) {
        _collectLetter(fl);
      }

      if (fl.y > screenH) {
        fl.missed = true;
        if (fl.isCorrect) {
          // Kerakli harf o'tib ketdi — jarimasi yo'q, lekin combo uziladi
          _combo = 0;
        }
      }
    }
    _letters.removeWhere((fl) => (fl.missed || fl.collected) && fl.y > screenH + 100);

    // Zarralarni yangilash
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += dt * 300;
      p.life -= dt * 1.5;
    }
    _particles.removeWhere((p) => p.life <= 0);

    // Flash so'nishi
    if (_flashOpacity > 0) {
      _flashOpacity -= dt * 4;
      if (_flashOpacity < 0) _flashOpacity = 0;
    }

    // Tezlik oshishi
    _gameSpeed = _config.speed + (_score / 100) * 0.3;

    if (mounted) setState(() {});
  }

  void _spawnLetter() {
    // So'z harflarini tartibsiz chiqaramiz
    final nextIdx = _collectedLetters.length;
    if (nextIdx >= _targetWord.length) return;

    // Qaysi lane'da chiqarish
    final lane = _rand.nextInt(3).toDouble();

    // To'g'ri harf
    _letters.add(_FlyingLetter(
      letter: _targetWord[nextIdx],
      isCorrect: true,
      x: lane / 2,
      y: -60,
      speed: 0.9 + _rand.nextDouble() * 0.3,
      lane: lane,
      id: _letterIdCounter++,
    ));

    // 1-2 ta noto'g'ri harf ham
    final wrongCount = _rand.nextInt(2) + 1;
    final usedLanes = <double>{lane};
    for (int i = 0; i < wrongCount; i++) {
      double wLane;
      int attempts = 0;
      do {
        wLane = _rand.nextInt(3).toDouble();
        attempts++;
      } while (usedLanes.contains(wLane) && attempts < 10);
      usedLanes.add(wLane);

      _letters.add(_FlyingLetter(
        letter: _wrongLetters[_rand.nextInt(_wrongLetters.length)],
        isCorrect: false,
        x: wLane / 2,
        y: -60 - _rand.nextDouble() * 80,
        speed: 0.8 + _rand.nextDouble() * 0.4,
        lane: wLane,
        id: _letterIdCounter++,
      ));
    }
  }

  void _collectLetter(_FlyingLetter fl) {
    fl.collected = true;
    HapticFeedback.lightImpact();

    if (fl.isCorrect) {
      _collectedLetters.add(fl.letter);
      _combo++;
      _score += 10 * (_combo > 2 ? 2 : 1);
      _flashColor = Colors.greenAccent;
      _flashOpacity = 0.3;
      _spawnParticles(fl.lane / 2, fl.y, Colors.amber, count: 12);

      // So'z tugadimi?
      if (_collectedLetters.length >= _targetWord.length) {
        _onLevelComplete();
      }
    } else {
      _combo = 0;
      _lives--;
      _flashColor = Colors.redAccent;
      _flashOpacity = 0.5;
      _shakeCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
      _spawnParticles(fl.lane / 2, fl.y, Colors.red, count: 8);

      if (_lives <= 0) {
        _gameOver = true;
        _gameLoop.stop();
        _recordRunResult();
      }
    }
  }

  void _onLevelComplete() {
    _sessionTimer?.cancel();
    _levelComplete = true;
    _gameLoop.stop();
    _showPlaceInfo = true;
    _score += 50 + (_lives * 20);
    _spawnParticles(0.5, 300, Colors.amber, count: 40);
    _spawnParticles(0.3, 300, Colors.pinkAccent, count: 20);
    _spawnParticles(0.7, 300, Colors.lightBlueAccent, count: 20);
    if (_rewardedLevels.add(_levelIdx)) {
      _earnedStars += _config.rewardStars;
      widget.onUpdate?.call(widget.profile.copyWith(stars: widget.profile.stars + _config.rewardStars));
    }
  }

  void _spawnParticles(double normX, double y, Color color, {int count = 15}) {
    final w = MediaQuery.sizeOf(context).width;
    final x = normX * w;
    for (int i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * pi * 2;
      final speed = 80 + _rand.nextDouble() * 200;
      _particles.add(_Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 100,
        color: color,
      ));
    }
  }

  void _onSwipeLeft() {
    if (_heroLane > 0) {
      setState(() => _heroLane--);
      HapticFeedback.selectionClick();
    }
  }

  void _onSwipeRight() {
    if (_heroLane < 2) {
      setState(() => _heroLane++);
      HapticFeedback.selectionClick();
    }
  }

  void _onJump() {
    if (_gameOver || _levelComplete) return;
    if (!_isJumping && _heroY >= -10) {
      setState(() { _isJumping = true; _jumpElapsed = 0; });
      HapticFeedback.mediumImpact();
    }
  }

  void _onSlide() {
    if (_isJumping || _gameOver || _levelComplete) return;
    setState(() {
      _isSliding = true;
      _slideRemaining = 0.65;
    });
    HapticFeedback.selectionClick();
  }

  void _recordRunResult() {
    if (_statsRecorded || _ageRestricted || !_config.enabled) return;
    _statsRecorded = true;
    final campaignLimit = min(_config.questionCount, _levels.length);
    final completedLevels = _rewardedLevels.length;
    final maxScore = max(1, campaignLimit * 200);
    final progress = (completedLevels / max(1, campaignLimit)).clamp(0.0, 1.0);
    final stars = progress >= 1.0 ? 3 : progress >= 0.67 ? 2 : progress >= 0.34 ? 1 : 0;
    GameStatsService.instance.record(widget.profile.id, GameResult(
      gameId: 'alpomish_runner',
      subject: 'Geografiya',
      stars: stars,
      score: _score,
      maxScore: maxScore,
      durationSeconds: DateTime.now().difference(_runStartedAt).inSeconds,
      playedAt: DateTime.now(),
    ), legacyProfileId: widget.profile.name);
  }

  void _continueAfterLevel() {
    final campaignLimit = min(_config.questionCount, _levels.length);
    if (_levelIdx + 1 >= campaignLimit) {
      _sessionTimer?.cancel();
      _recordRunResult();
      Navigator.pop(context);
      return;
    }
    _nextLevel();
  }

  void _nextLevel() {
    _sessionTimer?.cancel();
    setState(() {
      _levelIdx++;
      _levelComplete = false;
      _showPlaceInfo = false;
      _gameOver = false;
      _lives = 3;
      _combo = 0;
      _letters.clear();
      _obstacles.clear();
      _particles.clear();
      _spawnTimer = 0;
      _lastTime = 0;
      _heroY = 0;
      _jumpElapsed = 0;
      _isJumping = false;
      _isSliding = false;
      _slideRemaining = 0;
      _initLevel();
    });
    _gameLoop.forward(from: 0);
    if (_config.timerEnabled) { _remainingSeconds = _config.timeLimitSeconds; _startSessionTimer(); }
  }

  void _retry() {
    if (!_config.enabled || _ageRestricted) return;
    _sessionTimer?.cancel();
    setState(() {
      _gameOver = false;
      _statsRecorded = false;
      _runStartedAt = DateTime.now();
      _lives = 3;
      _combo = 0;
      _letters.clear();
      _obstacles.clear();
      _particles.clear();
      _spawnTimer = 0;
      _lastTime = 0;
      _heroY = 0;
      _jumpElapsed = 0;
      _isJumping = false;
      _isSliding = false;
      _slideRemaining = 0;
      _initLevel();
    });
    _gameLoop.forward(from: 0);
    if (_config.timerEnabled) { _remainingSeconds = _config.timeLimitSeconds; _startSessionTimer(); }
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _heroAnim.dispose();
    _bgScroll.dispose();
    _shakeCtrl.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final level = _currentLevel;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity == null) return;
          if (d.primaryVelocity! < -200) _onSwipeLeft();
          if (d.primaryVelocity! > 200) _onSwipeRight();
        },
        onTap: _onJump,
        child: Stack(
          children: [
            // ── 1. Fon ─────────────────────────────────────────────────
            _RunnerBackground(
              color: level.color,
              offset: _bgOffset,
              place: level.place,
              placeEmoji: level.placeEmoji,
            ),

            // ── 2. Flash effekt ────────────────────────────────────────
            if (_flashOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: (_flashColor ?? Colors.white).withOpacity(_flashOpacity),
                  ),
                ),
              ),

            // ── 3. Yo'laklar chizig'i ──────────────────────────────────
            Positioned.fill(child: _LaneLines(color: level.color)),

            // ── 4. To'siqlar ──────────────────────────────────────────
            ..._obstacles.where((o) => !o.resolved).map((o) => Positioned(
              left: size.width * (o.lane / 2) - 28,
              top: o.y - 28,
              child: _ObstacleTile(emoji: o.emoji, color: level.color),
            )),

            // ── 5. Harflar ─────────────────────────────────────────────
            ..._letters.where((fl) => !fl.collected).map((fl) =>
              _LetterTile(
                letter: fl.letter,
                isCorrect: fl.isCorrect,
                lane: fl.lane,
                y: fl.y,
                screenWidth: size.width,
                color: level.color,
              ),
            ),

            // ── 6. Qahramon ────────────────────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_heroAnim, _shakeCtrl]),
              builder: (_, __) {
                final shake = sin(_shakeCtrl.value * pi * 6) * 8 * (1 - _shakeCtrl.value);
                return Positioned(
                  left: size.width * (_heroLane / 2) - 28 + shake,
                  bottom: size.height * 0.18 - _heroY,
                  child: _HeroSprite(
                    lane: _heroLane,
                    isJumping: _isJumping,
                    isSliding: _isSliding,
                    runAnim: _heroAnim.value,
                    color: level.color,
                  ),
                );
              },
            ),

            // ── 7. Zarralar ────────────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ParticlePainter(_particles)),
              ),
            ),

            // ── 8. HUD (yuqori) ────────────────────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(child: _GameHUD(
                lives: _lives,
                score: _score,
                combo: _combo,
                timerSeconds: _config.timerEnabled ? _remainingSeconds : null,
                word: _currentLevel.word,
                collected: _collectedLetters,
                hint: _config.robotHints ? _currentLevel.hint : '',
                color: level.color,
                onBack: () => Navigator.pop(context),
              )),
            ),

            // ── 9. Pastki boshqaruv ────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                child: _Controls(
                  onLeft: _onSwipeLeft,
                  onRight: _onSwipeRight,
                  onJump: _onJump,
                  onSlide: _onSlide,
                  color: level.color,
                ),
              ),
            ),

            // ── 10. Level complete overlay ─────────────────────────────
            if (_levelComplete)
              _LevelCompleteOverlay(
                level: level,
                score: _score,
                onNext: _continueAfterLevel,
                isFinal: _levelIdx + 1 >= min(_config.questionCount, _levels.length),
              ),

            // ── 11. Game over overlay ──────────────────────────────────
            if (_gameOver)
              _GameOverOverlay(
                score: _score,
                word: _currentLevel.word,
                onRetry: (_ageRestricted || !_config.enabled) ? () {} : _retry,
                onHome: () => Navigator.pop(context),
                color: level.color,
                message: _ageRestricted ? 'Bu o‘yin ${_config.minAge}–${_config.maxAge} yosh uchun mo‘ljallangan.' : (!_config.enabled ? 'O‘yin ota-ona tomonidan vaqtincha yopilgan.' : null),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SUBWIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Fon ───────────────────────────────────────────────────────────────────────
class _RunnerBackground extends StatelessWidget {
  final Color color;
  final double offset;
  final String place, placeEmoji;

  const _RunnerBackground({required this.color, required this.offset, required this.place, required this.placeEmoji});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient osmon
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.4),
                const Color(0xFF1A1A2E),
              ],
            ),
          ),
        ),
        // Yulduzlar
        Positioned.fill(
          child: CustomPaint(painter: _StarsPainter(offset: offset, color: color)),
        ),
        // Joy nomi
        Positioned(
          top: 100,
          right: 20,
          child: Opacity(
            opacity: 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(placeEmoji, style: const TextStyle(fontSize: 32)),
                Text(place, style: GoogleFonts.nunito(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        // Yo'l
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.1),
                  Colors.brown.shade900.withOpacity(0.8),
                  Colors.brown.shade900,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Yulduzlar rassom ─────────────────────────────────────────────────────────
class _StarsPainter extends CustomPainter {
  final double offset;
  final Color color;
  _StarsPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 60; i++) {
      final x = rand.nextDouble() * size.width;
      final y = (rand.nextDouble() * size.height * 0.6 + offset * 0.3) % (size.height * 0.6);
      final r = rand.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    // Binolar silueti
    final buildingPaint = Paint()..color = color.withOpacity(0.4);
    final rand2 = Random(99);
    double bx = (-offset * 0.5) % (size.width * 2) - size.width;
    while (bx < size.width + 100) {
      final bw = 30.0 + rand2.nextDouble() * 60;
      final bh = 60.0 + rand2.nextDouble() * 120;
      canvas.drawRect(
        Rect.fromLTWH(bx, size.height * 0.55 - bh, bw, bh),
        buildingPaint,
      );
      // Gumbaz
      final path = Path()
        ..moveTo(bx + bw / 2 - 15, size.height * 0.55 - bh)
        ..quadraticBezierTo(bx + bw / 2, size.height * 0.55 - bh - 20, bx + bw / 2 + 15, size.height * 0.55 - bh);
      canvas.drawPath(path, buildingPaint);
      bx += bw + 10 + rand2.nextDouble() * 30;
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.offset != offset;
}

// ── Yo'laklar ─────────────────────────────────────────────────────────────────
class _LaneLines extends StatelessWidget {
  final Color color;
  const _LaneLines({required this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CustomPaint(
      size: size,
      painter: _LaneLinesPainter(color: color, screenH: size.height),
    );
  }
}

class _LaneLinesPainter extends CustomPainter {
  final Color color;
  final double screenH;
  const _LaneLinesPainter({required this.color, required this.screenH});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // 2 ta chiziq — 3 yo'lak hosil qiladi
    canvas.drawLine(
      Offset(size.width / 3, screenH * 0.1),
      Offset(size.width / 3, screenH * 0.82),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, screenH * 0.1),
      Offset(size.width * 2 / 3, screenH * 0.82),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LaneLinesPainter old) => false;
}

// ── Harflar ───────────────────────────────────────────────────────────────────
class _LetterTile extends StatelessWidget {
  final String letter;
  final bool isCorrect;
  final double lane, y, screenWidth;
  final Color color;

  const _LetterTile({
    required this.letter, required this.isCorrect,
    required this.lane, required this.y,
    required this.screenWidth, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final x = screenWidth * (lane / 2) - 24;
    return Positioned(
      left: x, top: y - 24,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: isCorrect
              ? Colors.amber.shade700.withOpacity(0.95)
              : Colors.grey.shade800.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCorrect ? Colors.amber.shade300 : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCorrect ? Colors.amber : Colors.grey).withOpacity(0.4),
              blurRadius: 12, spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: GoogleFonts.nunito(
              fontSize: 22, fontWeight: FontWeight.w900,
              color: isCorrect ? Colors.white : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Qahramon sprite ───────────────────────────────────────────────────────────
class _ObstacleTile extends StatelessWidget {
  final String emoji;
  final Color color;
  const _ObstacleTile({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFF17243A).withOpacity(0.92),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.85), width: 2),
      boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 14)],
    ),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 30)),
  );
}

class _HeroSprite extends StatelessWidget {
  final int lane;
  final bool isJumping;
  final bool isSliding;
  final double runAnim;
  final Color color;

  const _HeroSprite({required this.lane, required this.isJumping, required this.isSliding, required this.runAnim, required this.color});

  @override
  Widget build(BuildContext context) {
    final legAngle = isJumping ? 0.0 : sin(runAnim * pi * 2) * 0.4;
    return SizedBox(
      width: 56, height: 80,
      child: Transform.scale(
        alignment: Alignment.bottomCenter,
        scaleY: isSliding ? 0.58 : 1.0,
        child: CustomPaint(
          painter: _HeroPainter(legAngle: legAngle, isJumping: isJumping, color: color),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  final double legAngle;
  final bool isJumping;
  final Color color;
  const _HeroPainter({required this.legAngle, required this.isJumping, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Bosh
    final headPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawCircle(Offset(cx, 14), 14, headPaint);
    // Soch
    final hairPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, 14), radius: 14),
        pi, pi, false, hairPaint..style = PaintingStyle.fill);
    // Ko'z
    canvas.drawCircle(Offset(cx - 5, 11), 2.5, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + 5, 11), 2.5, Paint()..color = Colors.black87);
    // Tana (chapan)
    final bodyPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 12, 28, 24, 24), const Radius.circular(6)),
      bodyPaint,
    );
    // Qo'llar
    final armPaint = Paint()..color = color.withOpacity(0.8)..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 12, 32), Offset(cx - 22, 42), armPaint);
    canvas.drawLine(Offset(cx + 12, 32), Offset(cx + 22, 42), armPaint);
    // Oyoqlar
    final legPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 6..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    if (isJumping) {
      canvas.drawLine(Offset(cx - 7, 52), Offset(cx - 12, 68), legPaint);
      canvas.drawLine(Offset(cx + 7, 52), Offset(cx + 12, 68), legPaint);
    } else {
      canvas.drawLine(Offset(cx - 7, 52), Offset(cx - 7 - sin(legAngle) * 10, 68), legPaint);
      canvas.drawLine(Offset(cx + 7, 52), Offset(cx + 7 + sin(legAngle) * 10, 68), legPaint);
    }
    // Poyabzal
    final shoePaint = Paint()..color = Colors.brown.shade800;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 17, 66, 14, 8), const Radius.circular(4)), shoePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 3, 66, 14, 8), const Radius.circular(4)), shoePaint);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => old.legAngle != legAngle || old.isJumping != isJumping;
}

// ── Zarralar ──────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  const _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withOpacity(p.life.clamp(0, 1));
      canvas.drawCircle(Offset(p.x, p.y), 4 * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── HUD ───────────────────────────────────────────────────────────────────────
class _GameHUD extends StatelessWidget {
  final int lives, score, combo;
  final int? timerSeconds;
  final String word, hint;
  final List<String> collected;
  final Color color;
  final VoidCallback onBack;

  const _GameHUD({
    required this.lives, required this.score, required this.combo, required this.timerSeconds,
    required this.word, required this.collected, required this.hint,
    required this.color, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              // Jonlar
              Row(children: List.generate(3, (i) => Text(
                i < lives ? '❤️' : '🖤',
                style: const TextStyle(fontSize: 18),
              ))),
              const Spacer(),
              // Ball
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('⭐ $score', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              if (timerSeconds != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('⏱ $timerSeconds', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
              if (combo >= 2) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
                  child: Text('🔥 ×$combo', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // So'z to'ldirish
          Text(hint, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(word.length, (i) {
              final filled = i < collected.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: filled ? Colors.amber.shade700 : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: filled ? Colors.amber.shade300 : Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    filled ? collected[i] : '_',
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ).animate(target: filled ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
            }),
          ),
        ],
      ),
    );
  }
}

// ── Boshqaruv tugmalari ───────────────────────────────────────────────────────
class _Controls extends StatelessWidget {
  final VoidCallback onLeft, onRight, onJump, onSlide;
  final Color color;

  const _Controls({required this.onLeft, required this.onRight, required this.onJump, required this.onSlide, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CtrlBtn(icon: Icons.arrow_back_ios_rounded, onTap: onLeft, color: color),
          _CtrlBtn(icon: Icons.keyboard_double_arrow_up_rounded, onTap: onJump, color: color, big: true),
          _CtrlBtn(icon: Icons.keyboard_double_arrow_down_rounded, onTap: onSlide, color: color),
          _CtrlBtn(icon: Icons.arrow_forward_ios_rounded, onTap: onRight, color: color),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool big;

  const _CtrlBtn({required this.icon, required this.onTap, required this.color, this.big = false});

  @override
  Widget build(BuildContext context) {
    final size = big ? 72.0 : 56.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.6), width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: big ? 32 : 26),
      ),
    );
  }
}

// ── Level complete overlay ────────────────────────────────────────────────────
class _LevelCompleteOverlay extends StatelessWidget {
  final _Level level;
  final int score;
  final VoidCallback onNext;
  final bool isFinal;

  const _LevelCompleteOverlay({required this.level, required this.score, required this.onNext, this.isFinal = false});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [level.color, level.color.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: level.color.withOpacity(0.5), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎉', style: const TextStyle(fontSize: 56))
                    .animate().scale().shake(delay: 200.ms),
                const SizedBox(height: 10),
                Text(isFinal ? 'SAYOHAT YAKUNLANDI!' : 'AJOYIB!', style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                Text(level.word, style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.amber.shade300)),
                const SizedBox(height: 6),
                Text(level.hint, style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                // Joy haqida ma'lumot
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(level.placeEmoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(level.place, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('O\'zbekiston tarixiy shahri', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('⭐ $score ball', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.amber.shade300)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: level.color,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(isFinal ? 'Yakunlash' : 'Davom etish →', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
        ),
      ),
    );
  }
}

// ── Game over overlay ─────────────────────────────────────────────────────────
class _GameOverOverlay extends StatelessWidget {
  final int score;
  final String word;
  final VoidCallback onRetry, onHome;
  final Color color;
  final String? message;

  const _GameOverOverlay({required this.score, required this.word, required this.onRetry, required this.onHome, required this.color, this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😔', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(message ?? 'O\'yin tugadi', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('So\'z: $word', style: GoogleFonts.nunito(fontSize: 16, color: Colors.amber.shade300, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('⭐ $score ball', style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Chiqish', style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Qayta →', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
        ),
      ),
    );
  }
}
