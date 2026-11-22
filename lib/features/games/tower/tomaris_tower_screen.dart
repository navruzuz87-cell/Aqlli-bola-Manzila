import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/user_profile.dart';

// ════════════════════════════════════════════════════════════════════════════
// TOMARIS MINORASI — Tosh qalash o'yini (Stack game)
// Toshlar chapdan-o'ngga harakatlanadi
// Vaqtida bosib tushirish kerak — aniq qalsang tosh kengayadi
// O'zbek tarixi va qahramonlari haqida ma'lumot
// ════════════════════════════════════════════════════════════════════════════

class _HistoryFact {
  final String emoji, title, text, person;
  const _HistoryFact({required this.emoji, required this.title, required this.text, required this.person});
}

const _facts = [
  _HistoryFact(emoji: '⚔️', title: 'Tomaris', person: 'Massaget malikasi',
    text: 'Tomaris — massaget qabilasining qahramonl malikasi (miloddan avvalgi 530-yil). Buyuk Kir Forsni yengdi va o\'z xalqini himoya qildi.'),
  _HistoryFact(emoji: '🌟', title: 'Spitamen', person: 'Yunon bosqiniga qarshi',
    text: 'Spitamen — So\'g\'diyona qahramoni (miloddan avvalgi IV asr). Iskandar Zulqarnayn qo\'shiniga qarshi mardona kurashdi.'),
  _HistoryFact(emoji: '📐', title: 'Ulug\'bek', person: 'Samarqand astronomu',
    text: 'Mirzo Ulug\'bek — astronomi olim va hukmdor (1394-1449). Samarqandda katta rasadxona qurdi, 1018 yulduzning aniq koordinatini o\'lchadi.'),
  _HistoryFact(emoji: '📚', title: 'Ibn Sino', person: 'Tibbiyot otasi',
    text: 'Abu Ali ibn Sino — Buxoro yaqinida tug\'ilgan buyuk tabib (980-1037). "Tib qonunlari" asari 600 yildan ko\'proq Yevropada o\'qitildi.'),
  _HistoryFact(emoji: '🗺️', title: 'Al-Xorazmiy', person: 'Algebra yaratuvchisi',
    text: 'Muhammad al-Xorazmiy — Xorazmdan chiqqan olim (783-850). Algebra fanini yaratdi, "algoritm" so\'zi uning nomidan olingan.'),
  _HistoryFact(emoji: '🏛️', title: 'Amir Temur', person: 'Sohibqiron',
    text: 'Amir Temur — Shahrisabzda tug\'ilgan buyuk sarkarda (1336-1405). Samarqandni jahonning eng go\'zal shahriga aylantirdi.'),
  _HistoryFact(emoji: '🌺', title: 'Nodira', person: 'Qo\'qon shoirasi',
    text: 'Nodira — Qo\'qon xonligi shoirasi (1792-1842). O\'zbek she\'riyatining eng yorqin vakili, ming-minglab she\'rlar muallifi.'),
  _HistoryFact(emoji: '🔭', title: 'Beruniy', person: 'Universal olim',
    text: 'Abu Rayhon Beruniy — Xorazmda tug\'ilgan (973-1048). Yer yumaloq shaklini hisobladi, Hindiston haqida birinchi ilmiy kitob yozdi.'),
];

// ── Blok modeli ───────────────────────────────────────────────────────────────
class _Block {
  double x;    // markazning x koordinatasi (pikselda)
  double y;    // pastki qirraning y koordinatasi
  double width;
  final double height = 48.0;
  final Color color;
  bool isMoving;
  double speed;

  _Block({
    required this.x, required this.y,
    required this.width, required this.color,
    this.isMoving = false, this.speed = 180,
  });
}

class TomarisTowerScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const TomarisTowerScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<TomarisTowerScreen> createState() => _TomarisTowerScreenState();
}

class _TomarisTowerScreenState extends State<TomarisTowerScreen> with TickerProviderStateMixin {
  late AnimationController _loop;
  final List<_Block> _placed = [];
  late _Block _moving;

  final _rand = Random();
  int _score = 0;
  int _combo = 0;
  int _level = 1;
  bool _gameOver = false;
  bool _showFact = false;
  late _HistoryFact _currentFact;
  double _lastTime = 0;
  int _direction = 1; // 1 = o'ngga, -1 = chapga

  // Flash
  Color? _flashColor;
  double _flashOpacity = 0;

  // Combo animatsiya
  late AnimationController _comboAnim;

  static const _blockColors = [
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF1B5E20),
    Color(0xFF880E4F), Color(0xFF004D40), Color(0xFFBF360C),
    Color(0xFF37474F), Color(0xFF4A148C),
  ];

  double get _gameWidth => MediaQuery.sizeOf(context).width;
  double get _gameHeight => MediaQuery.sizeOf(context).height;
  double get _groundY => _gameHeight - 100;

  @override
  void initState() {
    super.initState();
    _currentFact = _facts[0];

    _loop = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_onTick)
      ..forward();

    _comboAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    _placed.clear();

    // Zamin bloki (keng)
    _placed.add(_Block(
      x: _gameWidth / 2,
      y: _groundY,
      width: _gameWidth * 0.6,
      color: const Color(0xFF795548),
      isMoving: false,
    ));

    _spawnMoving();
  }

  void _spawnMoving() {
    final topBlock = _placed.last;
    final newWidth = (topBlock.width - (_level > 5 ? 4.0 : 2.0)).clamp(40.0, topBlock.width);
    final speed = 160.0 + _level * 20.0;

    _moving = _Block(
      x: _direction > 0 ? -50 : _gameWidth + 50,
      y: topBlock.y - topBlock.height,
      width: newWidth,
      color: _blockColors[(_placed.length - 1) % _blockColors.length],
      isMoving: true,
      speed: speed,
    );
  }

  void _onTick() {
    if (_gameOver || _showFact) return;

    final t = _loop.value * (const Duration(days: 1).inMilliseconds / 1000.0);
    final dt = (_lastTime == 0) ? 0.016 : (t - _lastTime).clamp(0.0, 0.05);
    _lastTime = t;

    // Harakatlanayotgan blok
    _moving.x += _direction * _moving.speed * dt;

    // Devorga yetdi — yo'nalishni o'zgartir
    final halfW = _moving.width / 2;
    if (_moving.x + halfW > _gameWidth + 10) {
      _direction = -1;
      _moving.x = _gameWidth + 10 - halfW;
    } else if (_moving.x - halfW < -10) {
      _direction = 1;
      _moving.x = -10 + halfW;
    }

    // Flash
    if (_flashOpacity > 0) _flashOpacity -= dt * 3;

    if (mounted) setState(() {});
  }

  void _onTap() {
    if (_gameOver || _showFact) return;
    HapticFeedback.lightImpact();

    final topBlock = _placed.last;

    // Kesishma hisoblash
    final movLeft = _moving.x - _moving.width / 2;
    final movRight = _moving.x + _moving.width / 2;
    final topLeft = topBlock.x - topBlock.width / 2;
    final topRight = topBlock.x + topBlock.width / 2;

    final overlapLeft = max(movLeft, topLeft);
    final overlapRight = min(movRight, topRight);
    final overlapWidth = overlapRight - overlapLeft;

    if (overlapWidth <= 10) {
      // Miss — blok tushib ketdi
      _combo = 0;
      _flashColor = Colors.orange;
      _flashOpacity = 0.3;
      HapticFeedback.heavyImpact();
      _gameOver = true;
      _loop.stop();
      setState(() {});
      return;
    }

    // "Perfect" tekshirish (±5px)
    final diff = (_moving.x - topBlock.x).abs();
    final isPerfect = diff < 6;

    double finalWidth;
    double finalX;

    if (isPerfect) {
      // Perfect — blok kengayadi!
      finalWidth = (_moving.width + 4).clamp(0, _gameWidth * 0.65);
      finalX = topBlock.x;
      _combo++;
      _score += 15 + _combo * 5;
      _flashColor = Colors.amber;
      _flashOpacity = 0.25;
      HapticFeedback.mediumImpact();
    } else {
      finalWidth = overlapWidth;
      finalX = (overlapLeft + overlapRight) / 2;
      _combo = 0;
      _score += 10;
      _flashColor = Colors.greenAccent;
      _flashOpacity = 0.15;
    }

    if (_combo >= 3) {
      _comboAnim.forward(from: 0);
      HapticFeedback.selectionClick();
    }

    // Blokni qo'y
    _placed.add(_Block(
      x: finalX,
      y: _moving.y,
      width: finalWidth,
      color: _moving.color,
      isMoving: false,
    ));

    _level++;

    // Har 5 blokda tarixiy ma'lumot ko'rsat
    if (_placed.length % 5 == 0) {
      _currentFact = _facts[(_placed.length ~/ 5 - 1) % _facts.length];
      _showFact = true;
      _loop.stop();
      setState(() {});
      return;
    }

    // Kamera: minorani yuqoriga siljit
    _spawnMoving();
    _direction = -_direction;
  }

  void _closeFact() {
    _showFact = false;
    _spawnMoving();
    _direction = -_direction;
    _lastTime = 0;
    _loop.forward(from: 0);
  }

  void _retry() {
    setState(() {
      _gameOver = false;
      _score = 0; _combo = 0; _level = 1;
      _lastTime = 0; _flashOpacity = 0;
    });
    _startGame();
    _loop.forward(from: 0);
  }

  @override
  void dispose() {
    _loop.dispose();
    _comboAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Camera offset: minora o'sgani sayin yuqoriga scroll
    final towerHeight = _placed.isNotEmpty
        ? (_groundY - _placed.last.y).clamp(0.0, size.height * 2)
        : 0.0;
    final camOffset = max(0.0, towerHeight - size.height * 0.5);

    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            // 1. Fon
            _TowerBg(camOffset: camOffset),

            // 2. Bloklar
            ..._placed.map((b) => _buildBlock(b, camOffset, size)),
            _buildBlock(_moving, camOffset, size),

            // 3. Flash
            if (_flashOpacity > 0)
              Positioned.fill(child: IgnorePointer(
                child: Container(color: (_flashColor ?? Colors.white).withOpacity(_flashOpacity.clamp(0, 1))),
              )),

            // 4. HUD
            Positioned(top: 0, left: 0, right: 0,
              child: SafeArea(child: _TowerHud(
                score: _score, level: _level - 1, combo: _combo,
                onBack: () => Navigator.pop(context),
              )),
            ),

            // 5. Combo
            if (_combo >= 3)
              Positioned(
                bottom: 160, left: 0, right: 0,
                child: AnimatedBuilder(
                  animation: _comboAnim,
                  builder: (_, __) => Transform.scale(
                    scale: 1 + sin(_comboAnim.value * pi) * 0.3,
                    child: Center(
                      child: Text(
                        '🔥 PERFECT ×$_combo!',
                        style: GoogleFonts.nunito(
                          fontSize: 24, fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          shadows: [Shadow(color: Colors.orange, blurRadius: 20)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Qo'l ko'rsatma (birinchi tap)
            if (_placed.length == 1 && !_gameOver)
              Positioned(
                bottom: 130, left: 0, right: 0,
                child: Center(
                  child: Text('👆 Bosing!',
                    style: GoogleFonts.nunito(fontSize: 20, color: Colors.white70, fontWeight: FontWeight.w700))
                      .animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
                ),
              ),

            // 7. Tarixiy ma'lumot
            if (_showFact)
              _FactCard(fact: _currentFact, onClose: _closeFact, score: _score),

            // 8. Game over
            if (_gameOver)
              _TowerEndOverlay(
                score: _score, level: _level - 1,
                onRetry: _retry, onHome: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(_Block b, double camOffset, Size size) {
    final left = b.x - b.width / 2;
    final top = b.y - b.height - camOffset;

    return Positioned(
      left: left,
      top: top,
      width: b.width,
      height: b.height,
      child: Container(
        decoration: BoxDecoration(
          color: b.color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: b.color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              b.color.withOpacity(0.9),
              b.color,
              b.color.withOpacity(0.7),
            ],
          ),
        ),
        child: b.isMoving
            ? Center(child: Text('▼', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18)))
            : null,
      ),
    );
  }
}

// ── Fon ───────────────────────────────────────────────────────────────────────
class _TowerBg extends StatelessWidget {
  final double camOffset;
  const _TowerBg({required this.camOffset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0030), Color(0xFF1A0A2E), Color(0xFF0A1020)],
        ),
      ),
      child: CustomPaint(
        painter: _NightCityPainter(offset: camOffset),
        size: MediaQuery.sizeOf(context),
      ),
    );
  }
}

class _NightCityPainter extends CustomPainter {
  final double offset;
  const _NightCityPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final p = Paint();

    // Yulduzlar
    p.color = Colors.white.withOpacity(0.4);
    for (int i = 0; i < 80; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 1.5, p,
      );
    }

    // Shahar silueti
    final buildingPaint = Paint()..color = const Color(0xFF0D0825);
    final heights = [60, 90, 50, 110, 70, 80, 95, 55, 100, 65, 85, 75];
    final bw = size.width / heights.length;
    for (int i = 0; i < heights.length; i++) {
      final h = heights[i].toDouble();
      final bRect = Rect.fromLTWH(i * bw, size.height - h, bw - 2, h);
      canvas.drawRect(bRect, buildingPaint);

      // Derazalar
      final winPaint = Paint()..color = Colors.amber.withOpacity(0.3);
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 2; k++) {
          canvas.drawRect(
            Rect.fromLTWH(i * bw + 4 + k * 10, size.height - h + 8 + j * 14, 6, 8),
            winPaint,
          );
        }
      }
    }

    // Pastki zamin
    p.color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 60, size.width, 60), p);
  }

  @override
  bool shouldRepaint(_NightCityPainter old) => old.offset != offset;
}

// ── HUD ───────────────────────────────────────────────────────────────────────
class _TowerHud extends StatelessWidget {
  final int score, level, combo;
  final VoidCallback onBack;
  const _TowerHud({required this.score, required this.level, required this.combo, required this.onBack});

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
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Text('🏰', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text('Tomaris Minorasi', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('🧱 $level', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text('⭐ $score', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.amber)),
          ),
        ],
      ),
    );
  }
}

// ── Tarixiy ma'lumot kartasi ──────────────────────────────────────────────────
class _FactCard extends StatelessWidget {
  final _HistoryFact fact;
  final VoidCallback onClose;
  final int score;
  const _FactCard({required this.fact, required this.onClose, required this.score});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A0A30), Color(0xFF0D0825)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(fact.emoji, style: const TextStyle(fontSize: 52)).animate().scale(),
                const SizedBox(height: 8),
                Text(fact.title, style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.amber)),
                Text(fact.person, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white38)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    fact.text,
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Davom et! ▶',
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85)).fadeIn(),
        ),
      ),
    );
  }
}

// ── Tugash overlay ────────────────────────────────────────────────────────────
class _TowerEndOverlay extends StatelessWidget {
  final int score, level;
  final VoidCallback onRetry, onHome;
  const _TowerEndOverlay({required this.score, required this.level, required this.onRetry, required this.onHome});

  String get _rank {
    if (level >= 20) return '🏆 Ustoz!';
    if (level >= 12) return '⭐ Yaxshi!';
    if (level >= 6) return '👍 Chiroyli!';
    return '💪 Davom et!';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.88),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D0825), Color(0xFF1A0A2E)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🏰', style: const TextStyle(fontSize: 56)).animate().shake(),
                const SizedBox(height: 10),
                Text(_rank, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('$level blok baland minora!',
                  style: GoogleFonts.nunito(fontSize: 15, color: Colors.white54)),
                const SizedBox(height: 10),
                Text('⭐ $score ball',
                  style: GoogleFonts.nunito(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Chiqish', style: GoogleFonts.nunito(fontSize: 15, color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Qayta ▶', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
        ),
      ),
    );
  }
}
