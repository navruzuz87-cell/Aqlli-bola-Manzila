import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/season_service.dart';

class SeasonScreen extends StatelessWidget {
  const SeasonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: SeasonService.instance,
            builder: (_, __) {
              final svc = SeasonService.instance;
              return Column(children: [
                _topBar(context),
                Expanded(
                  child: svc.allSeasons.isEmpty
                    ? _noSeason()
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (svc.activeSeasons.isNotEmpty) ...[
                            _sectionTitle('🔥 Faol Fasllar'),
                            const SizedBox(height: 8),
                            ...svc.activeSeasons.map((s) => _seasonCard(s, true)),
                          ],
                          const SizedBox(height: 16),
                          _sectionTitle('📅 Barcha Fasllar'),
                          const SizedBox(height: 8),
                          ...svc.allSeasons
                            .where((s) => !s.isActive)
                            .map((s) => _seasonCard(s, false)),
                        ],
                      ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Text('Fasllar', style: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
    ]),
  );

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700,
          color: Colors.white70));

  Widget _noSeason() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🗓️', style: TextStyle(fontSize: 60)),
      const SizedBox(height: 12),
      Text('Hozircha faol fasl yo\'q',
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.white60)),
    ]),
  );

  Widget _seasonCard(SeasonInfo s, bool active) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: active
        ? LinearGradient(colors: s.colors.map((c) => c.withOpacity(0.3)).toList())
        : null,
      color: active ? null : Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: active ? s.colors.first.withOpacity(0.5) : Colors.white12,
        width: active ? 1.5 : 1,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Text(s.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(s.name, style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w900,
                  color: active ? Colors.white : Colors.white54)),
              if (active) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: s.colors.first,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('FAOL',
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ),
              ],
            ]),
            Text(s.description,
                style: GoogleFonts.nunito(fontSize: 12,
                    color: active ? Colors.white70 : Colors.white38)),
          ])),
          if (active)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${s.daysLeft}', style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('kun qoldi', style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.white60)),
            ]),
        ]),
      ),
      // Progress bar (if active)
      if (active) Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: s.progress, minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(s.colors.first),
          ),
        ),
      ),
      // Missions
      if (active) ...[
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: s.missions.asMap().entries.map((e) =>
              _missionRow(e.value, e.key)).toList(),
          ),
        ),
      ],
    ]),
  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1);

  Widget _missionRow(SeasonMission m, int idx) {
    final svc = SeasonService.instance;
    final prog = svc.getProgress(m.id);
    final claimed = svc.isClaimed(m.id);
    final canClaim = svc.canClaim(m);
    final pct = (prog / m.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(claimed ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(m.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.title,
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
                  color: claimed ? Colors.white38 : Colors.white)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct, minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                  claimed ? Colors.white24 : const Color(0xFFFFD54F)),
            ),
          ),
          const SizedBox(height: 2),
          Text('$prog / ${m.target}',
              style: GoogleFonts.nunito(fontSize: 10, color: Colors.white38)),
        ])),
        const SizedBox(width: 10),
        if (claimed)
          const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 22)
        else if (canClaim)
          GestureDetector(
            onTap: () => svc.claimReward(m.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('⭐ ${m.reward}',
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A237E))),
            ),
          )
        else
          Text('⭐ ${m.reward}',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.white38)),
      ]),
    );
  }
}
