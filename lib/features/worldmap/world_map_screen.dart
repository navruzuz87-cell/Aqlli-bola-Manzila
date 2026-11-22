import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/uzbekistan_map.dart';

// ════════════════════════════════════════════════════════════════════════════
// WORLD MAP SCREEN — O'zbekiston xaritasi bo'yicha sayohat
// Har viloyatni bosib, uning shaharlarini ko'rish va o'ynash
// ════════════════════════════════════════════════════════════════════════════

class WorldMapScreen extends StatefulWidget {
  final MapProgress progress;
  final int playerStars;
  final Function(UzRegion, int, int) onStageSelected; // region, cityIdx, stageIdx

  const WorldMapScreen({
    super.key,
    required this.progress,
    required this.playerStars,
    required this.onStageSelected,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  UzRegion? _selectedRegion;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _isUnlocked(UzRegionData r) {
    return !r.isLocked || widget.playerStars >= r.requiredStars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _selectedRegion != null
                  ? _buildRegionDetail(_selectedRegion!)
                  : _buildMapView(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Yuqori sarlavha ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x401565C0), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          if (_selectedRegion != null)
            GestureDetector(
              onTap: () => setState(() => _selectedRegion = null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            )
          else
            const SizedBox(width: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedRegion != null
                      ? UzbekistanMap.getRegion(_selectedRegion!).name
                      : '🗺️ O\'zbekiston Sayohati',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _selectedRegion != null
                      ? UzbekistanMap.getRegion(_selectedRegion!).description
                      : 'Barcha viloyatlarni zabt et!',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Yulduzlar soni
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.playerStars}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Xarita ko'rinishi ───────────────────────────────────────────────────
  Widget _buildMapView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // ── O'zbekiston xaritasi (vizual) ──────────────────────────────
          _buildMapVisualization(),
          const SizedBox(height: 20),
          // ── Viloyatlar ro'yxati ────────────────────────────────────────
          _buildRegionsList(),
        ],
      ),
    );
  }

  // ─── Vizual xarita ───────────────────────────────────────────────────────
  Widget _buildMapVisualization() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Fon — xarita
            Positioned.fill(
              child: CustomPaint(
                painter: _MapBackgroundPainter(),
              ),
            ),
            // Viloyat nuqtalari
            ...UzbekistanMap.regions.map((region) {
              final unlocked = _isUnlocked(region);
              return _buildMapPin(region, unlocked);
            }),
            // Sarlavha
            Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                'O\'zbekiston Respublikasi',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.black38,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(UzRegionData region, bool unlocked) {
    final size = MediaQuery.of(context).size.width - 32;
    final x = region.mapX * size - 16;
    final y = region.mapY * 260 - 16;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          if (unlocked) {
            setState(() => _selectedRegion = region.id);
          } else {
            _showLockedMessage(region);
          }
        },
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final scale = unlocked
                ? (1.0 + _pulseCtrl.value * 0.08)
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: unlocked ? region.color : Colors.grey[400],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: unlocked
                      ? [BoxShadow(
                          color: region.color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )]
                      : [],
                ),
                child: Center(
                  child: Text(
                    unlocked ? region.emoji : '🔒',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Viloyatlar ro'yxati ─────────────────────────────────────────────────
  Widget _buildRegionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 Barcha viloyatlar',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        ...UzbekistanMap.regions.asMap().entries.map((e) {
          final idx = e.key;
          final region = e.value;
          final unlocked = _isUnlocked(region);
          return _buildRegionCard(region, unlocked, idx);
        }),
      ],
    );
  }

  Widget _buildRegionCard(UzRegionData region, bool unlocked, int idx) {
    // Tugallangan bosqichlar sonini hisoblash
    int completed = 0;
    int total = 0;
    for (int ci = 0; ci < region.cities.length; ci++) {
      final city = region.cities[ci];
      for (int si = 0; si < city.stageCount; si++) {
        total++;
        if (widget.progress.isStageComplete(region.id, ci, si)) completed++;
      }
    }

    return GestureDetector(
      onTap: () {
        if (unlocked) {
          setState(() => _selectedRegion = region.id);
        } else {
          _showLockedMessage(region);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? region.color.withOpacity(0.3) : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: unlocked ? region.color.withOpacity(0.1) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rang chiziq + emoji
            Container(
              width: 70,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: unlocked
                      ? [region.color, region.colorDark]
                      : [Colors.grey[300]!, Colors.grey[400]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unlocked ? region.emoji : '🔒',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    '${idx + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Ma'lumotlar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.name,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: unlocked ? const Color(0xFF1A1A2E) : Colors.grey[500],
                      ),
                    ),
                    Text(
                      '🏛️ ${region.capital}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    if (unlocked) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0,
                          minHeight: 6,
                          backgroundColor: region.color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(region.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completed/$total bosqich',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${region.requiredStars} yulduz kerak',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // O'q
            if (unlocked)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: region.color,
                  size: 24,
                ),
              ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: idx * 60)).fadeIn().slideX(begin: 0.1),
    );
  }

  // ─── Viloyat batafsil ko'rinishi ─────────────────────────────────────────
  Widget _buildRegionDetail(UzRegion regionId) {
    final region = UzbekistanMap.getRegion(regionId);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Viloyat banner
          _buildRegionBanner(region),
          const SizedBox(height: 20),
          // Shaharlar
          Text(
            '🏘️ Shaharlar va Tumanlar',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...region.cities.asMap().entries.map((e) {
            return _buildCityCard(region, e.key, e.value);
          }),
        ],
      ),
    );
  }

  Widget _buildRegionBanner(UzRegionData region) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [region.color, region.colorDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: region.color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(region.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.name,
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  region.description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🏛️ Poytaxt: ${region.capital}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildCityCard(UzRegionData region, int cityIdx, UzCity city) {
    final starsEarned = List.generate(city.stageCount, (i) {
      return widget.progress.getStageStars(region.id, cityIdx, i);
    });
    final totalEarned = starsEarned.fold(0, (a, b) => a + b);
    final maxStars = city.stageCount * 3;

    final themeColors = {
      UzStageTheme.history: const Color(0xFFC62828),
      UzStageTheme.culture: const Color(0xFF7B1FA2),
      UzStageTheme.geography: const Color(0xFF1565C0),
      UzStageTheme.science: const Color(0xFF2E7D32),
      UzStageTheme.language: const Color(0xFFE65100),
    };
    final themeEmojis = {
      UzStageTheme.history: '⚔️',
      UzStageTheme.culture: '🎭',
      UzStageTheme.geography: '🌍',
      UzStageTheme.science: '🔬',
      UzStageTheme.language: '📝',
    };
    final tc = themeColors[city.theme]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tc.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Shahar sarlavhasi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tc.withOpacity(0.1), tc.withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(city.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            themeEmojis[city.theme]!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _themeLabel(city.theme),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: tc,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Yulduzlar
                Column(
                  children: [
                    Text(
                      '$totalEarned/$maxStars',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: totalEarned > 0 ? Colors.amber[700] : Colors.grey[400],
                      ),
                    ),
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          // Bosqichlar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(city.stageCount, (si) {
                final starsGot = widget.progress.getStageStars(region.id, cityIdx, si);
                final isComplete = starsGot > 0;
                final isNext = !isComplete &&
                    (si == 0 || widget.progress.isStageComplete(region.id, cityIdx, si - 1));

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isComplete || isNext) {
                        widget.onStageSelected(region.id, cityIdx, si);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? tc.withOpacity(0.1)
                            : isNext
                                ? Colors.amber.withOpacity(0.1)
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isComplete
                              ? tc
                              : isNext
                                  ? Colors.amber
                                  : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isComplete ? '✅' : isNext ? '▶️' : '🔒',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${si + 1}-bosqich',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isComplete
                                  ? tc
                                  : isNext
                                      ? Colors.amber[700]
                                      : Colors.grey[400],
                            ),
                          ),
                          if (isComplete)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) => Text(
                                i < starsGot ? '⭐' : '☆',
                                style: const TextStyle(fontSize: 10),
                              )),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Qiziqarli ma'lumot
          if (city.funFacts.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        city.funFacts[0],
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: cityIdx * 100)).fadeIn().slideY(begin: 0.1);
  }

  String _themeLabel(UzStageTheme t) {
    switch (t) {
      case UzStageTheme.history: return 'Tarix';
      case UzStageTheme.culture: return 'Madaniyat';
      case UzStageTheme.geography: return 'Geografiya';
      case UzStageTheme.science: return 'Fan';
      case UzStageTheme.language: return 'Til';
    }
  }

  void _showLockedMessage(UzRegionData region) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3F4FF), Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                '${region.name} yopiq!',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu viloyatni ochish uchun yana ${region.requiredStars - widget.playerStars} ta yulduz kerak',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Sizda: ${widget.playerStars}/${region.requiredStars}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (widget.playerStars / region.requiredStars).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.orange[100],
                  valueColor: const AlwaysStoppedAnimation(Colors.orange),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Davom etaman! 💪',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Xarita fon rasmi ─────────────────────────────────────────────────────────
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Fon
    paint.color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Oddiy chegaralar (simplashtirilgan O'zbekiston shakli)
    paint.color = const Color(0xFFCDDC39).withOpacity(0.5);
    paint.style = PaintingStyle.fill;

    final path = Path();
    // O'zbekiston shaklining oddiy chizmasi
    path.moveTo(size.width * 0.15, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.12);
    path.lineTo(size.width * 0.72, size.height * 0.18);
    path.lineTo(size.width * 0.95, size.height * 0.25);
    path.lineTo(size.width * 0.98, size.height * 0.4);
    path.lineTo(size.width * 0.9, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.8);
    path.lineTo(size.width * 0.55, size.height * 0.85);
    path.lineTo(size.width * 0.35, size.height * 0.75);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.08, size.height * 0.45);
    path.close();

    canvas.drawPath(path, paint);

    // Chegara chizig'i
    paint.color = const Color(0xFF8BC34A);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);

    // Daryo chiziqlari
    paint.color = const Color(0xFF64B5F6).withOpacity(0.6);
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;

    // Sirdaryo
    final river1 = Path();
    river1.moveTo(size.width * 0.9, size.height * 0.3);
    river1.quadraticBezierTo(
      size.width * 0.65, size.height * 0.3,
      size.width * 0.2, size.height * 0.4,
    );
    canvas.drawPath(river1, paint);

    // Amudaryo
    final river2 = Path();
    river2.moveTo(size.width * 0.65, size.height * 0.75);
    river2.quadraticBezierTo(
      size.width * 0.4, size.height * 0.6,
      size.width * 0.15, size.height * 0.4,
    );
    canvas.drawPath(river2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
