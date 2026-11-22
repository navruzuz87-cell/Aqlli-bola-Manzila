import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/user_profile.dart';
import '../../core/services/audio_service.dart';

// ── Bino ma'lumotlari ─────────────────────────────────────────────────────
class BuildingInfo {
  final String id;
  final String name;
  final String emoji;
  final String resource;
  final String resourceEmoji;
  final int maxLevel;
  final List<int> levelCosts; // har darajaga resurs soni
  final Offset position;      // sahifada joylashuv (0-1)

  const BuildingInfo({
    required this.id, required this.name, required this.emoji,
    required this.resource, required this.resourceEmoji,
    required this.maxLevel, required this.levelCosts,
    required this.position,
  });
}

const kBuildings = [
  BuildingInfo(id: 'minora',    name: 'Minora',    emoji: '🗼', resource: 'tosh',   resourceEmoji: '🪨', maxLevel: 5, levelCosts: [10, 20, 35, 55, 80], position: Offset(0.15, 0.25)),
  BuildingInfo(id: 'kutubxona', name: 'Kutubxona', emoji: '📚', resource: 'yogoch', resourceEmoji: '🪵', maxLevel: 5, levelCosts: [10, 20, 35, 55, 80], position: Offset(0.75, 0.20)),
  BuildingInfo(id: 'bozor',     name: 'Bozor',     emoji: '🏪', resource: 'mis',    resourceEmoji: '🟤', maxLevel: 5, levelCosts: [15, 25, 40, 60, 85], position: Offset(0.50, 0.40)),
  BuildingInfo(id: 'sardoba',   name: 'Sardoba',   emoji: '⛲', resource: 'shisha', resourceEmoji: '🔷', maxLevel: 5, levelCosts: [10, 20, 35, 55, 80], position: Offset(0.20, 0.60)),
  BuildingInfo(id: 'bog',       name: "Bog'",      emoji: '🌳', resource: 'gul',    resourceEmoji: '🌸', maxLevel: 5, levelCosts: [8,  18, 30, 50, 75],  position: Offset(0.70, 0.55)),
  BuildingInfo(id: 'masjid',    name: 'Masjid',    emoji: '🕌', resource: 'tuproq', resourceEmoji: '🟫', maxLevel: 5, levelCosts: [12, 22, 38, 58, 82], position: Offset(0.40, 0.70)),
  BuildingInfo(id: 'maktab',    name: 'Maktab',    emoji: '🏫', resource: 'yogoch', resourceEmoji: '🪵', maxLevel: 3, levelCosts: [25, 50, 90],           position: Offset(0.80, 0.75)),
  BuildingInfo(id: 'hammom',    name: 'Hammom',    emoji: '🛁', resource: 'tosh',   resourceEmoji: '🪨', maxLevel: 3, levelCosts: [20, 45, 80],           position: Offset(0.10, 0.80)),
];

// ── Sky gradients per time of day ─────────────────────────────────────────
List<Color> _skyColors() {
  final h = DateTime.now().hour;
  if (h >= 6 && h < 10)  return [const Color(0xFFFF8A65), const Color(0xFF42A5F5)]; // tong
  if (h >= 10 && h < 17) return [const Color(0xFF42A5F5), const Color(0xFF1565C0)]; // kunduz
  if (h >= 17 && h < 20) return [const Color(0xFFFF7043), const Color(0xFF6A1B9A)]; // kech
  return [const Color(0xFF1A237E), const Color(0xFF0D0D2B)];                         // kecha
}

class CityScreenV2 extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdate;
  const CityScreenV2({super.key, required this.profile, required this.onUpdate});

  @override
  State<CityScreenV2> createState() => _CityScreenV2State();
}

class _CityScreenV2State extends State<CityScreenV2>
    with TickerProviderStateMixin {
  late UserProfile _p;
  late AnimationController _cloudCtrl;
  BuildingInfo? _selectedBuilding;

  @override
  void initState() {
    super.initState();
    _p = widget.profile;
    _cloudCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    AudioService.instance.playMusic(MusicTrack.city);
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    AudioService.instance.playMusic(MusicTrack.home);
    super.dispose();
  }

  int _level(String id) => _p.buildingLevels[id] ?? 0;
  int _resource(String res) => _p.cityResources[res] ?? 0;

  void _build(BuildingInfo b) {
    final lvl = _level(b.id);
    if (lvl >= b.maxLevel) return;
    final cost = b.levelCosts[lvl];
    final have = _resource(b.resource);
    if (have < cost) return;

    AudioService.instance.playSfx(SfxSound.coinEarn);
    final newResources = Map<String, int>.from(_p.cityResources);
    newResources[b.resource] = have - cost;
    final newLevels = Map<String, int>.from(_p.buildingLevels);
    newLevels[b.id] = lvl + 1;
    setState(() {
      _p = _p.copyWith(cityResources: newResources, buildingLevels: newLevels);
      _selectedBuilding = null;
    });
    widget.onUpdate(_p);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _selectedBuilding = null),
        child: Stack(children: [
          // Osmon
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _skyColors(),
              ),
            ),
          ),
          // Bulutlar
          _buildClouds(size),
          // Yer
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
              ),
            ),
          ),
          // Binolar
          ...kBuildings.map((b) => _buildingWidget(b, size)),
          // Top bar
          SafeArea(child: Column(children: [
            _topBar(),
            const SizedBox(height: 8),
            _resourcesBar(),
          ])),
          // Tanlangan bino paneli
          if (_selectedBuilding != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildPanel(_selectedBuilding!),
            ),
        ]),
      ),
    );
  }

  Widget _buildClouds(Size size) {
    return AnimatedBuilder(
      animation: _cloudCtrl,
      builder: (_, __) {
        final t = _cloudCtrl.value;
        return Stack(children: [
          _cloud(size.width * ((t + 0.0) % 1.0), size.height * 0.12, 70),
          _cloud(size.width * ((t + 0.4) % 1.0), size.height * 0.18, 50),
          _cloud(size.width * ((t + 0.7) % 1.0), size.height * 0.09, 90),
        ]);
      },
    );
  }

  Widget _cloud(double x, double y, double w) {
    return Positioned(
      left: x - w / 2, top: y,
      child: Container(
        width: w, height: w * 0.5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(w),
        ),
      ),
    );
  }

  Widget _buildingWidget(BuildingInfo b, Size size) {
    final lvl = _level(b.id);
    final x = size.width * b.position.dx;
    final y = size.height * b.position.dy;
    final scale = 0.8 + lvl * 0.1;
    final isSelected = _selectedBuilding?.id == b.id;

    return Positioned(
      left: x - 30, top: y - 30,
      child: GestureDetector(
        onTap: () {
          AudioService.instance.playSfx(SfxSound.buttonTap);
          setState(() => _selectedBuilding = b);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(scale * (isSelected ? 1.15 : 1.0)),
          transformAlignment: Alignment.center,
          child: Stack(alignment: Alignment.center, children: [
            if (isSelected)
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD54F).withOpacity(0.3),
                ),
              ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(lvl == 0 ? '🏗️' : b.emoji,
                  style: TextStyle(fontSize: 36 * scale)),
              if (lvl > 0)
                Row(mainAxisSize: MainAxisSize.min,
                    children: List.generate(lvl, (_) =>
                    const Text('★', style: TextStyle(fontSize: 8, color: Color(0xFFFFD54F))))),
            ]),
          ]),
        ),
      ).animate(
        onPlay: (c) => c.repeat(reverse: true),
      ).moveY(begin: 0, end: -4, duration: (1500 + b.id.hashCode % 500).ms,
          curve: Curves.easeInOut),
    );
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Text('Shaharchang',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
      const Spacer(),
      Text(widget.profile.avatarEmoji, style: const TextStyle(fontSize: 28)),
    ]),
  );

  Widget _resourcesBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final e in [
          ('🪨', 'tosh'), ('🪵', 'yogoch'), ('🟤', 'mis'),
          ('🔷', 'shisha'), ('🌸', 'gul'), ('🟫', 'tuproq'),
        ]) Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(children: [
            Text(e.$1, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 3),
            Text('${_resource(e.$2)}',
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ]),
        ),
      ]),
    ),
  );

  Widget _buildPanel(BuildingInfo b) {
    final lvl = _level(b.id);
    final isMax = lvl >= b.maxLevel;
    final cost = isMax ? 0 : b.levelCosts[lvl];
    final have = _resource(b.resource);
    final canBuild = !isMax && have >= cost;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white30,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Row(children: [
            Text(b.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.name, style: GoogleFonts.nunito(fontSize: 20,
                  fontWeight: FontWeight.w900, color: Colors.white)),
              Row(children: List.generate(b.maxLevel, (i) =>
                  Icon(i < lvl ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD54F), size: 18))),
              Text(isMax ? 'Maksimal daraja!' : 'Daraja $lvl → ${lvl + 1}',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60)),
            ])),
          ]),
          if (!isMax) ...[
            const SizedBox(height: 14),
            Row(children: [
              Text('${b.resourceEmoji} ${b.resource}: ',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
              Text('$have / $cost',
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800,
                      color: canBuild ? const Color(0xFFFFD54F) : Colors.red[300])),
            ]),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: canBuild ? () => _build(b) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: canBuild ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: canBuild ? [BoxShadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.5),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )] : [],
                ),
                child: Text(canBuild ? '🔨  Qur!' : '⚠️  Resurs yetarli emas',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900,
                        color: canBuild ? const Color(0xFF1A237E) : Colors.white38)),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ]),
      ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }
}

typedef CityScreen = CityScreenV2;
