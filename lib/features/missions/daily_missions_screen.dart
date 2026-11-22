import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/mission_service.dart';
import '../../core/services/audio_service.dart';
import '../../data/models/user_profile.dart';

class MissionsScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(int starsEarned)? onStarsEarned;

  const MissionsScreen({super.key, required this.profile, this.onStarsEarned});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = MissionService.instance;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _claim(Mission m) async {
    final stars = await _service.claimReward(m.id);
    if (stars > 0) {
      AudioService.instance.playSfx(SfxSound.starEarn);
      widget.onStarsEarned?.call(stars);
      if (mounted) _showRewardPopup(m, stars);
    }
  }

  void _showRewardPopup(Mission m, int stars) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF311B92)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFFFD54F).withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.emoji, style: const TextStyle(fontSize: 56))
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text('Tabriklaymiz!',
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(m.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+$stars ⭐',
                  style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A237E)),
                ),
              ).animate().scale(delay: 300.ms, duration: 400.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('Davom etish →',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white60,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _service,
            builder: (_, __) => Column(
              children: [
                _buildTopBar(),
                _buildStreakBanner(),
                _buildClaimAllButton(),
                _buildTabBar(),
                Expanded(child: _buildTabView()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Text('Missiyalar',
              style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const Spacer(),
          if (_service.totalUnclaimedStars > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${_service.totalUnclaimedStars} ⭐',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A237E)),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildStreakBanner() {
    final streak = _service.streakDays;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak >= 7
              ? [const Color(0xFFE65100), const Color(0xFFFF6D00)]
              : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: streak >= 3
              ? Colors.orange.withOpacity(0.6)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Text(
            streak >= 7 ? '🔥' : streak >= 3 ? '⚡' : '📅',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak kun ketma-ket!',
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              Text(
                streak >= 7
                    ? 'Ajoyib! Maxsus mukofot kutmoqda!'
                    : '7 kunga yetish uchun ${7 - streak} kun qoldi',
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          // Mini streak dots
          Row(
            children: List.generate(7, (i) {
              final filled = i < streak.clamp(0, 7);
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? const Color(0xFFFFD54F)
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildClaimAllButton() {
    final claimable = _service.claimable;
    if (claimable.isEmpty) return const SizedBox(height: 8);
    return GestureDetector(
      onTap: () async {
        int total = 0;
        for (final m in claimable) {
          total += await _service.claimReward(m.id);
        }
        AudioService.instance.playSfx(SfxSound.levelUp);
        widget.onStarsEarned?.call(total);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            '🎁  Hammasini ol (+${_service.totalUnclaimedStars} ⭐)',
            style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A237E)),
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['🌅 Kunlik', '📆 Haftalik', '💎 Maxsus'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: const Color(0xFF1A237E),
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w800),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
          dividerColor: Colors.transparent,
          tabs: tabs.map((t) => Tab(text: t, height: 36)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tab,
      children: [
        _buildMissionList(MissionData.daily),
        _buildMissionList(MissionData.weekly),
        _buildMissionList(MissionData.special),
      ],
    );
  }

  Widget _buildMissionList(List<Mission> missions) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: missions.length,
      itemBuilder: (_, i) {
        final m = missions[i];
        final p = _service.progressFor(m.id);
        return _buildMissionCard(m, p, i);
      },
    );
  }

  Widget _buildMissionCard(Mission m, MissionProgress p, int index) {
    final pct = (p.current / m.target).clamp(0.0, 1.0);
    final canClaim = p.completed && !p.claimed;

    return GestureDetector(
      onTap: canClaim ? () => _claim(m) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.claimed
              ? Colors.white.withOpacity(0.05)
              : canClaim
                  ? const Color(0xFFFFD54F).withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: p.claimed
                ? Colors.white.withOpacity(0.1)
                : canClaim
                    ? const Color(0xFFFFD54F).withOpacity(0.6)
                    : Colors.white.withOpacity(0.15),
            width: canClaim ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(p.claimed ? '✅' : m.emoji,
                style: TextStyle(
                    fontSize: 36,
                    color: p.claimed ? null : null)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title,
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: p.claimed
                              ? Colors.white38
                              : Colors.white)),
                  const SizedBox(height: 2),
                  Text(m.description,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: p.claimed
                              ? Colors.white24
                              : Colors.white60)),
                  if (!p.claimed) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(
                                p.completed
                                    ? const Color(0xFFFFD54F)
                                    : const Color(0xFF42A5F5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${p.current}/${m.target}',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Text('+${m.reward}',
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: p.claimed
                            ? Colors.white24
                            : const Color(0xFFFFD54F))),
                Text('⭐',
                    style: TextStyle(
                        fontSize: 16,
                        color: p.claimed
                            ? Colors.white24
                            : null)),
                if (canClaim)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('OL!',
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A237E))),
                  ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1, end: 0),
    );
  }
}

typedef DailyMissionsScreen = MissionsScreen;
