import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/audio_service.dart';

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  final _audio = AudioService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _audio,
            builder: (_, __) => Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeroIcon(),
                        const SizedBox(height: 32),
                        _buildMusicCard(),
                        const SizedBox(height: 16),
                        _buildSfxCard(),
                        const SizedBox(height: 24),
                        _buildTestRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
          Text('Ovoz sozlamalari',
              style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
    );
  }

  Widget _buildHeroIcon() {
    return Text(
      _audio.musicEnabled || _audio.sfxEnabled ? '🔊' : '🔇',
      style: const TextStyle(fontSize: 72),
    )
        .animate(key: ValueKey(_audio.musicEnabled || _audio.sfxEnabled))
        .scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  // ── Musiqa kartochkasi ────────────────────────────────────────────────────
  Widget _buildMusicCard() {
    return _card(
      delay: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎵', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text('Fon musiqasi',
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const Spacer(),
              _toggle(
                value: _audio.musicEnabled,
                onChanged: (_) => _audio.toggleMusic(),
              ),
            ],
          ),
          if (_audio.musicEnabled) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.white54, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: _sliderTheme(),
                    child: Slider(
                      value: _audio.musicVolume,
                      onChanged: _audio.setMusicVolume,
                    ),
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.white54, size: 20),
              ],
            ),
            Center(
              child: Text(
                '${(_audio.musicVolume * 100).round()}%',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.white54),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── SFX kartochkasi ───────────────────────────────────────────────────────
  Widget _buildSfxCard() {
    return _card(
      delay: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔔', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text('O\'yin tovushlari',
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const Spacer(),
              _toggle(
                value: _audio.sfxEnabled,
                onChanged: (_) => _audio.toggleSfx(),
              ),
            ],
          ),
          if (_audio.sfxEnabled) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.white54, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: _sliderTheme(),
                    child: Slider(
                      value: _audio.sfxVolume,
                      onChanged: _audio.setSfxVolume,
                    ),
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.white54, size: 20),
              ],
            ),
            Center(
              child: Text(
                '${(_audio.sfxVolume * 100).round()}%',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.white54),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Test tugmalari ────────────────────────────────────────────────────────
  Widget _buildTestRow() {
    final tests = [
      ('✅', 'To\'g\'ri', SfxSound.correct),
      ('❌', 'Noto\'g\'ri', SfxSound.wrong),
      ('⭐', 'Yulduz', SfxSound.starEarn),
      ('🏆', 'G\'alaba', SfxSound.victory),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('  Tovushlarni sinab ko\'ring',
            style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.white54,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: tests.map((t) {
            return Expanded(
              child: GestureDetector(
                onTap: () => AudioService.instance.playSfx(t.$3),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(t.$1,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(t.$2,
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  // ── Yordamchi widgetlar ───────────────────────────────────────────────────
  Widget _card({required Widget child, required int delay}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: child,
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _toggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFFD54F),
      activeTrackColor: const Color(0xFFFFD54F).withOpacity(0.4),
      inactiveThumbColor: Colors.white38,
      inactiveTrackColor: Colors.white12,
    );
  }

  SliderThemeData _sliderTheme() {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: const Color(0xFFFFD54F),
      inactiveTrackColor: Colors.white.withOpacity(0.2),
      thumbColor: const Color(0xFFFFD54F),
      overlayColor: const Color(0xFFFFD54F).withOpacity(0.2),
      trackHeight: 4,
    );
  }
}
