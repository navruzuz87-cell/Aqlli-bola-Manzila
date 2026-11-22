import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/user_profile.dart';

class AvatarCreatorScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onSave;
  const AvatarCreatorScreen(
      {super.key, required this.profile, required this.onSave});

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen>
    with TickerProviderStateMixin {
  late bool _isGirl;
  late int _skinIndex;
  late int _hairIndex;
  late int _hairColorIndex;
  late int _clothesIndex;
  late int _clothesColorIndex;

  late AnimationController _previewController;

  final List<String> _boySkins = ['🧑', '👦🏻', '👦🏽', '👦🏿'];
  final List<String> _girlSkins = ['👧', '👧🏻', '👧🏽', '👧🏿'];
  final List<String> _boyHairs = ['💇', '💇‍♂️', '🧑‍🦱', '🧑‍🦲'];
  final List<String> _girlHairs = ['💇‍♀️', '👱‍♀️', '🧑‍🦱', '👰'];
  final List<String> _boyClothes = ['👕', '👔', '🥋', '🎽'];
  final List<String> _girlClothes = ['👗', '🌸', '👚', '🎀'];
  final List<Color> _clothesColors = [
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
    const Color(0xFFB71C1C),
    const Color(0xFF6A1B9A),
    const Color(0xFFE65100),
    const Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _isGirl = p.isGirl;
    _skinIndex = p.avatarSkin.clamp(0, 3);
    _hairIndex = p.avatarHair.clamp(0, 3);
    _hairColorIndex = 0;
    _clothesIndex = p.avatarClothes.clamp(0, 3);
    _clothesColorIndex = 0;

    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  String get _faceEmoji =>
      _isGirl ? _girlSkins[_skinIndex] : _boySkins[_skinIndex];
  String get _clothesEmoji =>
      _isGirl ? _girlClothes[_clothesIndex] : _boyClothes[_clothesIndex];

  void _save() {
    final updated = widget.profile.copyWith(
      gender: _isGirl ? 'girl' : 'boy',
      avatarSkin: _skinIndex,
      avatarHair: _hairIndex,
      avatarClothes: _clothesIndex,
    );
    widget.onSave(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Avatar saqlandi! ✅'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('🎨 Avatar Creator',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ]),
              ),

              // Preview
              _buildPreview(),

              const SizedBox(height: 16),

              // Options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Gender
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GenderChip(
                            label: '👦 O\'g\'il bola',
                            selected: !_isGirl,
                            onTap: () => setState(() => _isGirl = false),
                          ),
                          const SizedBox(width: 12),
                          _GenderChip(
                            label: '👧 Qiz bola',
                            selected: _isGirl,
                            onTap: () => setState(() => _isGirl = true),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _OptionRow(
                        label: '🎨 Teri rangi',
                        items: _isGirl ? _girlSkins : _boySkins,
                        selected: _skinIndex,
                        onSelect: (i) => setState(() => _skinIndex = i),
                      ),

                      _OptionRow(
                        label: '💇 Soch uslubi',
                        items: _isGirl ? _girlHairs : _boyHairs,
                        selected: _hairIndex,
                        onSelect: (i) => setState(() => _hairIndex = i),
                      ),

                      _OptionRow(
                        label: '👕 Kiyim',
                        items: _isGirl ? _girlClothes : _boyClothes,
                        selected: _clothesIndex,
                        onSelect: (i) => setState(() => _clothesIndex = i),
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('🎨 Kiyim rangi',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _clothesColors
                            .asMap()
                            .entries
                            .map((e) => GestureDetector(
                                  onTap: () =>
                                      setState(() => _clothesColorIndex = e.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: e.value,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _clothesColorIndex == e.key
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('💾 Saqlash',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return AnimatedBuilder(
      animation: _previewController,
      builder: (context, child) {
        final bounce = _previewController.value * 8;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _clothesColors[_clothesColorIndex].withOpacity(0.3),
          border: Border.all(
            color: _clothesColors[_clothesColorIndex],
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_faceEmoji, style: const TextStyle(fontSize: 48)),
            Text(_clothesEmoji, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final int selected;
  final Function(int) onSelect;
  const _OptionRow({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items
                .asMap()
                .entries
                .map((e) => GestureDetector(
                      onTap: () => onSelect(e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: selected == e.key
                              ? const Color(0xFF1565C0)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected == e.key
                                ? Colors.white
                                : Colors.white24,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(e.value,
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.white10,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? Colors.white54 : Colors.white24, width: 2),
        ),
        child: Text(label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }
}
