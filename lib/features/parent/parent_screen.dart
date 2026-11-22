import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/parental_service.dart';

class ParentalScreen extends StatefulWidget {
  const ParentalScreen({super.key});

  @override
  State<ParentalScreen> createState() => _ParentalScreenState();
}

class _ParentalScreenState extends State<ParentalScreen> {
  final _svc = ParentalService.instance;
  bool _unlocked = false;
  final _pinCtrl = TextEditingController();
  String _pinError = '';

  static const _subjectNames = {
    'matematika': '🔢 Matematika',
    'ona_tili':   '📖 Ona tili',
    'ingliz':     '🌍 Ingliz',
    'tarix':      '🏛️ Tarix',
    'odobnoma':   '🌸 Odobnoma',
    'geo':        '🗺️ Geografiya',
  };

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _tryUnlock() {
    if (_svc.verifyPin(_pinCtrl.text)) {
      setState(() { _unlocked = true; _pinError = ''; });
    } else {
      setState(() => _pinError = 'PIN noto\'g\'ri');
      _pinCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF004D40)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _svc,
            builder: (_, __) {
              if (!_svc.settings.isEnabled || _unlocked) {
                return _buildMain();
              }
              return _buildPinGate();
            },
          ),
        ),
      ),
    );
  }

  // ── PIN kirish ────────────────────────────────────────────────────────────
  Widget _buildPinGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 64))
                .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text('Ota-ona paneli',
                style: GoogleFonts.nunito(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text('Davom etish uchun PIN kiriting',
                style: GoogleFonts.nunito(
                    fontSize: 15, color: Colors.white60)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _pinError.isNotEmpty
                        ? Colors.red.withOpacity(0.6)
                        : Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 28, letterSpacing: 8, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '• • • •',
                  hintStyle: GoogleFonts.nunito(
                      color: Colors.white30, letterSpacing: 8),
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                ),
                cursorColor: const Color(0xFFFFD54F),
                onSubmitted: (_) => _tryUnlock(),
              ),
            ),
            if (_pinError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_pinError,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: Colors.red[300])),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _tryUnlock,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Kirish',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A237E))),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('← Orqaga',
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Asosiy panel ──────────────────────────────────────────────────────────
  Widget _buildMain() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _topBar(),
          const SizedBox(height: 20),
          _statsCards(),
          const SizedBox(height: 16),
          _weekChart(),
          const SizedBox(height: 16),
          _subjectBreakdown(),
          const SizedBox(height: 16),
          _settingsCard(),
          const SizedBox(height: 16),
          _gameEditorCard(),
          const SizedBox(height: 16),
          _pinCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
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
        Text('Ota-ona paneli',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: Colors.white)),
        const Spacer(),
        const Text('👨‍👩‍👦', style: TextStyle(fontSize: 28)),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  // ── Statistika kartochalari ────────────────────────────────────────────────
  Widget _statsCards() {
    final today = _svc.todayMinutes;
    final limit = _svc.settings.dailyLimitMinutes;
    final pct = limit > 0 ? (today / limit).clamp(0.0, 1.0) : 0.0;
    final color = pct >= 1.0
        ? Colors.red
        : pct >= 0.75 ? Colors.orange : const Color(0xFF66BB6A);

    final items = [
      ('⏱️', '${today}', 'Bugun (daq.)', color),
      ('📅', '${_svc.weekMinutes}', 'Hafta (daq.)', Colors.blue[300]!),
      ('⭐', '${_svc.weekStars}', 'Hafta yulduzi', const Color(0xFFFFD54F)),
    ];

    return Column(
      children: [
        Row(
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(item.$2,
                        style: GoogleFonts.nunito(
                            fontSize: 24, fontWeight: FontWeight.w900,
                            color: item.$4)),
                    Text(item.$3,
                        style: GoogleFonts.nunito(
                            fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.3, end: 0),
            );
          }).toList(),
        ),
        if (limit > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Kunlik limit: $limit daqiqa',
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: Colors.white70)),
                    const Spacer(),
                    Text(
                      pct >= 1.0 ? '🛑 Limit to\'ldi' : '⏳ ${_svc.remainingMinutes} daq. qoldi',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: color,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── 7 kunlik grafik ────────────────────────────────────────────────────────
  Widget _weekChart() {
    final days = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final key = '${d.year}-${d.month}-${d.day}';
      final sess = _svc.history.where(
          (s) => '${s.date.year}-${s.date.month}-${s.date.day}' == key);
      final mins = sess.fold(0, (sum, s) => sum + s.minutesPlayed);
      return (d, mins);
    });

    final maxMins = days.map((d) => d.$2).fold(1, (a, b) => a > b ? a : b);
    final dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    return _sectionCard(
      title: '📊 7 kunlik faollik',
      delay: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.asMap().entries.map((e) {
          final i = e.key;
          final day = e.value;
          final isToday = i == 6;
          final pct = day.$2 / maxMins;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
              child: Column(
                children: [
                  Text('${day.$2}m',
                      style: GoogleFonts.nunito(
                          fontSize: 9,
                          color: day.$2 > 0 ? Colors.white70 : Colors.transparent)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 80 * pct.clamp(0.05, 1.0),
                      color: isToday
                          ? const Color(0xFFFFD54F)
                          : day.$2 > 0
                              ? const Color(0xFF42A5F5).withOpacity(0.7)
                              : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNames[day.$1.weekday % 7],
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? const Color(0xFFFFD54F) : Colors.white54),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Fan bo'yicha taqsimot ─────────────────────────────────────────────────
  Widget _subjectBreakdown() {
    final data = _svc.weekSubjectMinutes;
    if (data.isEmpty) {
      return _sectionCard(
        title: '📚 Fanlar bo\'yicha',
        delay: 400,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Bu hafta hali o\'yin o\'ynalmadi',
                style: GoogleFonts.nunito(
                    fontSize: 14, color: Colors.white38)),
          ),
        ),
      );
    }

    final total = data.values.fold(0, (a, b) => a + b);
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _sectionCard(
      title: '📚 Fanlar bo\'yicha (hafta)',
      delay: 400,
      child: Column(
        children: sorted.map((e) {
          final pct = e.value / total;
          final name = _subjectNames[e.key] ?? e.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(name,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white80)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF42A5F5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${e.value}m',
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.white54)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Sozlamalar ────────────────────────────────────────────────────────────
  Widget _settingsCard() {
    final s = _svc.settings;
    return _sectionCard(
      title: '⚙️ Cheklashlar',
      delay: 500,
      child: Column(
        children: [
          // Panel yoqish
          _switchRow(
            '👁️ Ota-ona panelini yoqish',
            s.isEnabled,
            (v) => _svc.updateSettings(s.copyWith(isEnabled: v)),
          ),
          const Divider(color: Colors.white10, height: 20),
          // Kunlik limit
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kunlik limit',
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(
                      s.dailyLimitMinutes == 0
                          ? 'Cheksiz'
                          : '${s.dailyLimitMinutes} daqiqa',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _iconBtn(Icons.remove, () {
                    final cur = s.dailyLimitMinutes;
                    if (cur > 0) {
                      _svc.updateSettings(s.copyWith(
                          dailyLimitMinutes: (cur - 15).clamp(0, 300)));
                    }
                  }),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      s.dailyLimitMinutes == 0
                          ? '∞' : '${s.dailyLimitMinutes}',
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD54F)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _iconBtn(Icons.add, () {
                    _svc.updateSettings(s.copyWith(
                        dailyLimitMinutes:
                            (s.dailyLimitMinutes + 15).clamp(0, 300)));
                  }),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          _switchRow(
            '📊 Har kuni statistika ko\'rsatsin',
            s.showOnLaunch,
            (v) => _svc.updateSettings(s.copyWith(showOnLaunch: v)),
          ),
        ],
      ),
    );
  }

  // ── PIN sozlash ────────────────────────────────────────────────────────────
  Widget _gameEditorCard() {
    return GestureDetector(
      onTap: () => context.push('/settings/parental/game-editor'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(children: [
          const Text('🛠️', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Game Editor', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
            Text('O‘yin qoidalari, yosh, tezlik va hikoyalarni sozlash', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    );
  }

  Widget _pinCard() {
    return _sectionCard(
      title: '🔐 PIN kod',
      delay: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _svc.settings.pinHash.isEmpty
                ? 'PIN hali o\'rnatilmagan'
                : 'PIN o\'rnatilgan ✅',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showSetPinDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  _svc.settings.pinHash.isEmpty
                      ? '🔑  PIN o\'rnatish' : '🔑  PIN o\'zgartirish',
                  style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A5E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('PIN o\'rnatish',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: GoogleFonts.nunito(fontSize: 24, color: Colors.white,
              letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '• • • •',
            hintStyle: GoogleFonts.nunito(
                color: Colors.white30, letterSpacing: 8),
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFD54F)),
            ),
            fillColor: Colors.white.withOpacity(0.07),
            filled: true,
          ),
          cursorColor: const Color(0xFFFFD54F),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor',
                style: GoogleFonts.nunito(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.length >= 4) {
                _svc.setPin(ctrl.text);
                Navigator.pop(context);
              }
            },
            child: Text('Saqlash',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFFFD54F),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Yordamchi widgetlar ───────────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required Widget child,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _switchRow(String label, bool val, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.nunito(fontSize: 15, color: Colors.white80)),
        ),
        Switch(
          value: val,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFD54F),
          activeTrackColor: const Color(0xFFFFD54F).withOpacity(0.4),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

typedef ParentScreen = ParentalScreen;
