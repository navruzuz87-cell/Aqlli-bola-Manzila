import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/user_profile.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/profile_storage_service.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  List<UserProfile> _profiles = [];
  bool _loading = true;

  static const _maxProfiles = 4;
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // ── Yuklash / saqlash ─────────────────────────────────────────────────────
  Future<void> _loadProfiles() async {
    _profiles = await ProfileStorageService.instance.loadProfiles();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfiles() async {
    await ProfileStorageService.instance.saveProfiles(_profiles);
  }

  // ── Profil tanlash ────────────────────────────────────────────────────────
  Future<void> _selectProfile(UserProfile profile) async {
    AudioService.instance.playSfx(SfxSound.buttonTap);
    await ProfileStorageService.instance.selectProfile(profile);
    if (!mounted) return;
    AudioService.instance.playMusic(MusicTrack.home);
    context.go(AppRoutes.home, extra: profile);
  }

  // ── Profil o'chirish ──────────────────────────────────────────────────────
  Future<void> _deleteProfile(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A5E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Profilni o\'chirish',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          '${_profiles[index].name} profilini o\'chirasizmi?\nBarcha ma\'lumotlar yo\'qoladi!',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Bekor',
                style: GoogleFonts.nunito(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('O\'chir',
                style: GoogleFonts.nunito(
                    color: Colors.red[300], fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _profiles.removeAt(index));
      await _saveProfiles();
    }
  }

  // ── Profil ma'lumotlarini tahrirlash ──────────────────────────────────────
  Future<void> _editProfile(int index) async {
    final current = _profiles[index];
    final result = await Navigator.push<UserProfile>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => _OnboardingForNew(
          initialProfile: current,
          onDone: (p) => Navigator.pop(context, p),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
    if (result != null) {
      setState(() => _profiles[index] = result);
      await _saveProfiles();
    }
  }

  // ── Yangi profil qo'shish → Onboarding ───────────────────────────────────
  Future<void> _addProfile() async {
    if (_profiles.length >= _maxProfiles) return;
    AudioService.instance.playSfx(SfxSound.buttonTap);

    final result = await Navigator.push<UserProfile>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => _OnboardingForNew(
          onDone: (p) => Navigator.pop(context, p),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    if (result != null) {
      setState(() => _profiles.add(result));
      await _saveProfiles();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D2B), Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD54F)))
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    Expanded(child: _buildGrid()),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text('👨‍👩‍👦‍👦', style: TextStyle(fontSize: 52))
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 12),
        Text('Kim o\'ynaydi?',
            style: GoogleFonts.nunito(
                fontSize: 30, fontWeight: FontWeight.w900,
                color: Colors.white))
            .animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        Text('Profilni tanlang',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.white54))
            .animate().fadeIn(delay: 350.ms),
      ],
    );
  }

  Widget _buildGrid() {
    final items = <Widget>[
      ..._profiles.asMap().entries.map((e) => _profileCard(e.value, e.key)),
      if (_profiles.length < _maxProfiles) _addCard(),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        shrinkWrap: true,
        children: items,
      ),
    );
  }

  // ── Profil kartochkasi ────────────────────────────────────────────────────
  Widget _profileCard(UserProfile p, int index) {
    final level = (p.stars ~/ 50) + 1;
    final pct = (p.stars % 50) / 50.0;
    final gradeLabel = p.grade == null ? '—' : '${p.grade}';
    final ageLabel = p.age == null ? 'Yosh kiritilmagan' : '${p.age} yosh';

    return GestureDetector(
      onTap: () => _selectProfile(p),
      onLongPress: () => _deleteProfile(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFFD54F), width: 2.5),
                    ),
                    child: Center(
                      child: Text(p.avatarEmoji,
                          style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 17, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  Text('$gradeLabel-sinf  •  $ageLabel',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.white60)),
                  const SizedBox(height: 10),
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('${p.stars}',
                          style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFD54F))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Lv.$level',
                            style: GoogleFonts.nunito(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFD54F))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Level progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 5,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFD54F)),
                    ),
                  ),
                ],
              ),
            ),
            // Tahrirlash va o'chirish tugmalari
            Positioned(
              top: 8, left: 8,
              child: GestureDetector(
                onTap: () => _editProfile(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => _deleteProfile(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 14),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 100).ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
              duration: 400.ms, curve: Curves.easeOut),
    );
  }

  // ── Yangi profil kartochkasi ───────────────────────────────────────────────
  Widget _addCard() {
    final remaining = _maxProfiles - _profiles.length;
    return GestureDetector(
      onTap: _addProfile,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFFFD54F).withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.add, color: Color(0xFFFFD54F), size: 32),
            ),
            const SizedBox(height: 10),
            Text('Yangi profil',
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white70)),
            Text('$remaining joy bor',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.white38)),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (_profiles.length * 100).ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
              duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yangi profil uchun mini-Onboarding (4 bosqich, modal)
// ═══════════════════════════════════════════════════════════════════════════
class _OnboardingForNew extends StatefulWidget {
  final void Function(UserProfile) onDone;
  final UserProfile? initialProfile;
  const _OnboardingForNew({required this.onDone, this.initialProfile});

  @override
  State<_OnboardingForNew> createState() => _OnboardingForNewState();
}

class _OnboardingForNewState extends State<_OnboardingForNew> {
  final _nameCtrl = TextEditingController();
  final _pageCtrl = PageController();
  int _page = 0;
  int _grade = 0;
  int _age = 0;
  String _avatar = '';

  final _avatars = ['🦁','🐯','🦊','🐺','🦅','🦉','🐉','🦄','🐬','🦋'];

  bool get _ok => _page == 0
      ? _nameCtrl.text.trim().length >= 2
      : _page == 1 ? _grade > 0
      : _page == 2 ? _age >= 5 && _age <= 12
      : _avatar.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    if (p != null) {
      _nameCtrl.text = p.name;
      _grade = p.grade ?? 0;
      _age = p.age ?? 0;
      _avatar = p.avatarEmoji;
    }
  }

  void _next() {
    if (!_ok) return;
    if (_page < 3) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic);
    } else {
      final existing = widget.initialProfile;
      widget.onDone(existing == null
          ? UserProfile(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: _nameCtrl.text.trim(),
              avatarEmoji: _avatar,
              grade: _grade,
              age: _age,
              lastPlayDate: UserProfile.todayKey(),
            )
          : existing.copyWith(
              name: _nameCtrl.text.trim(),
              avatarEmoji: _avatar,
              grade: _grade,
              age: _age,
            ));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Sarlavha
              Padding(
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
                    Text('Yangi profil',
                        style: GoogleFonts.nunito(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const Spacer(),
                    // Step dots
                    Row(
                      children: List.generate(4, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i <= _page
                              ? const Color(0xFFFFD54F)
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [_namePage(), _gradePage(), _agePage(), _avatarPage()],
                ),
              ),
              // Tugma
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _ok ? 1.0 : 0.4,
                  child: GestureDetector(
                    onTap: _ok ? _next : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _ok ? [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withOpacity(0.5),
                            blurRadius: 12, offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Text(
                        _page < 3 ? 'Davom →' : (widget.initialProfile == null ? 'Profil yaratish! 🎉' : 'Saqlash'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 18, fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A237E)),
                      ),
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

  Widget _namePage() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('👋', style: TextStyle(fontSize: 64))
          .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      const SizedBox(height: 20),
      Text("Ismini kiriting",
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800,
              color: Colors.white)).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 28),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _nameCtrl,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ism kiriting...',
            hintStyle: GoogleFonts.nunito(color: Colors.white38, fontSize: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
          ),
          cursorColor: const Color(0xFFFFD54F),
        ),
      ),
    ]),
  );

  Widget _gradePage() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🏫', style: TextStyle(fontSize: 56))
          .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      const SizedBox(height: 16),
      Text('Nechinchi sinfda?',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800,
              color: Colors.white)).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 28),
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: List.generate(6, (i) {
          final g = i + 1;
          final sel = _grade == g;
          return GestureDetector(
            onTap: () => setState(() => _grade = g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.2),
                    width: 2),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$g', style: GoogleFonts.nunito(fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: sel ? const Color(0xFF1A237E) : Colors.white)),
                Text('sinf', style: GoogleFonts.nunito(fontSize: 11,
                    color: sel ? const Color(0xFF1A237E).withOpacity(0.7) : Colors.white54)),
              ]),
            ),
          );
        }),
      ),
    ]),
  );

  Widget _agePage() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎂', style: TextStyle(fontSize: 56))
          .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      const SizedBox(height: 16),
      Text('Yoshingiz nechida?',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800,
              color: Colors.white)),
      const SizedBox(height: 8),
      Text('Bu ma’lumot o‘yinlarni yoshga mos tanlashga yordam beradi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
      const SizedBox(height: 24),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(8, (i) {
          final age = i + 5;
          final selected = _age == age;
          return GestureDetector(
            onTap: () => setState(() => _age = age),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? const Color(0xFFFFD54F) : Colors.white24, width: 2),
              ),
              child: Center(child: Text('$age', style: GoogleFonts.nunito(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: selected ? const Color(0xFF1A237E) : Colors.white))),
            ),
          );
        }),
      ),
    ]),
  );

  Widget _avatarPage() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(_avatar.isEmpty ? '🎭' : _avatar,
            key: ValueKey(_avatar),
            style: const TextStyle(fontSize: 64)),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
      const SizedBox(height: 14),
      Text('Qahramonni tanlang',
          style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800,
              color: Colors.white)).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 24),
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: _avatars.map((em) {
          final sel = _avatar == em;
          return GestureDetector(
            onTap: () => setState(() => _avatar = em),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.2),
                    width: 2),
              ),
              child: Center(
                child: Text(em,
                    style: TextStyle(fontSize: sel ? 30 : 26)),
              ),
            ),
          );
        }).toList(),
      ),
    ]),
  );
}
