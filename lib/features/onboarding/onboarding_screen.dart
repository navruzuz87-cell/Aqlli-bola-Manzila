import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';
import '../../core/router/app_router.dart';
import '../../core/services/profile_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  int _currentPage = 0;
  int _selectedGrade = 0; // 0 = tanlanmagan
  int _selectedAge = 0;
  String _selectedAvatar = '';
  bool _isLoading = false;

  final List<String> _avatars = [
    '🦁', '🐯', '🦊', '🐺',
    '🦅', '🦉', '🐉', '🦄',
    '🐬', '🦋',
  ];

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().length >= 2;
      case 1:
        return _selectedGrade > 0;
      case 2:
        return _selectedAge >= 5 && _selectedAge <= 12;
      case 3:
        return _selectedAvatar.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextPage() {
    if (!_canProceed) return;
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    final profile = UserProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      avatarEmoji: _selectedAvatar,
      grade: _selectedGrade,
      age: _selectedAge,
      lastPlayDate: UserProfile.todayKey(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await ProfileStorageService.instance.selectProfile(profile);
    if (mounted) {
      context.go(AppRoutes.home, extra: profile);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildNamePage(),
                    _buildGradePage(),
                    _buildAgePage(),
                    _buildAvatarPage(),
                  ],
                ),
              ),
              _buildBottomButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == _currentPage;
        final done = i < _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: (active || done)
                ? const Color(0xFFFFD54F)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  // ── Sahifa 1: Ism ────────────────────────────────────────────────────────
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Assalomu alaykum!',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            'Ismingizni kiriting',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white70,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Masalan: Alibek',
                hintStyle: GoogleFonts.nunito(
                  color: Colors.white38,
                  fontSize: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18,
                ),
              ),
              cursorColor: const Color(0xFFFFD54F),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  // ── Sahifa 2: Sinf ────────────────────────────────────────────────────────
  Widget _buildGradePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏫', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'Qaysi sinfda o\'qiysiz?',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 36),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: List.generate(6, (i) {
              final grade = i + 1;
              final selected = _selectedGrade == grade;
              return GestureDetector(
                onTap: () => setState(() => _selectedGrade = grade),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFD54F)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFFD54F)
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$grade',
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? const Color(0xFF1A237E)
                              : Colors.white,
                        ),
                      ),
                      Text(
                        'sinf',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF1A237E).withOpacity(0.7)
                              : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ).animate(target: selected ? 1 : 0).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 150.ms,
                    ),
              );
            }),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  // ── Sahifa 3: Yosh ───────────────────────────────────────────────────────
  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎂', style: TextStyle(fontSize: 64))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('Yoshingiz nechida?', style: GoogleFonts.nunito(
            fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Yoshga mos o‘yin va topshiriqlarni tanlash uchun.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(8, (i) {
              final age = i + 5;
              final selected = _selectedAge == age;
              return GestureDetector(
                onTap: () => setState(() => _selectedAge = age),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFD54F) : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? const Color(0xFFFFD54F) : Colors.white24, width: 2),
                  ),
                  child: Center(child: Text('$age', style: GoogleFonts.nunito(
                    fontSize: 25, fontWeight: FontWeight.w900,
                    color: selected ? const Color(0xFF1A237E) : Colors.white))),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Sahifa 3: Avatar ──────────────────────────────────────────────────────
  Widget _buildAvatarPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _selectedAvatar.isEmpty ? '🎭' : _selectedAvatar,
              key: ValueKey(_selectedAvatar),
              style: const TextStyle(fontSize: 72),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'Qahramoningizni tanlang',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _avatars.map((emoji) {
              final selected = _selectedAvatar == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFD54F)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFFD54F)
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: selected ? 32 : 28),
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  // ── Pastki tugma ──────────────────────────────────────────────────────────
  Widget _buildBottomButton() {
    final labels = ['Davom etish →', 'Davom etish →', 'Davom etish →', 'Boshlash! 🚀'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _canProceed ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: _canProceed ? _nextPage : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _canProceed
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  )
                : Text(
                    labels[_currentPage],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
