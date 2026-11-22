import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/companions.dart';
import '../../data/models/user_profile.dart';

class CompanionSelectScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const CompanionSelectScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<CompanionSelectScreen> createState() => _CompanionSelectScreenState();
}

class _CompanionSelectScreenState extends State<CompanionSelectScreen>
    with TickerProviderStateMixin {
  late String _selectedId;
  late AnimationController _bounceController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.profile.selectedCompanion;

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  int get _playerLevel => widget.profile.playerLevel;

  void _selectCompanion(Companion c) {
    setState(() => _selectedId = c.id);
    // Darhol saqlash
    final updated = widget.profile.copyWith(selectedCompanion: c.id);
    widget.onUpdate?.call(updated);
    HapticFeedback.selectionClick();
  }

  void _showLockedDialog(Companion c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Text(c.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 10),
          Text(c.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          '${c.name} ${c.unlockLevel}-darajada ochiladi.\n\nHozirgi darajangiz: $_playerLevel',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tushunarli 💪'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = Companion.getUnlocked(_playerLevel);
    final locked = Companion.getLocked(_playerLevel);
    final selected = Companion.getById(_selectedId);

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
                  const Text('🎭 Hamroh tanlash',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ]),
              ),

              // Selected preview
              if (selected != null) _buildSelectedPreview(selected),

              // List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (unlocked.isNotEmpty) ...[
                      const Text('🔓 Ochilgan hamrohlar',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...unlocked.map((c) => _CompanionTile(
                            companion: c,
                            isSelected: c.id == _selectedId,
                            isLocked: false,
                            onTap: () => _selectCompanion(c),
                          )),
                    ],
                    if (locked.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('🔒 Qulflangan hamrohlar',
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...locked.map((c) => _CompanionTile(
                            companion: c,
                            isSelected: false,
                            isLocked: true,
                            onTap: () => _showLockedDialog(c),
                          )),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPreview(Companion c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          // Bouncing emoji
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              final bounce = sin(_bounceController.value * pi) * 8;
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: child,
              );
            },
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = _glowController.value;
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.3 + glow * 0.3),
                        blurRadius: 16 + glow * 8,
                        spreadRadius: 2 + glow * 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: Text(c.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text(c.greeting,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionTile extends StatelessWidget {
  final Companion companion;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;
  const _CompanionTile({
    required this.companion,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1565C0).withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(companion.emoji,
              style: TextStyle(
                  fontSize: 40, color: isLocked ? null : null)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companion.name,
                    style: TextStyle(
                      color: isLocked ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                const SizedBox(height: 2),
                Text(companion.story,
                    style: TextStyle(
                        color: isLocked ? Colors.white24 : Colors.white60,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: companion.subjectEmojis
                    .map((e) => Text(e, style: const TextStyle(fontSize: 16)))
                    .toList()),
              ],
            ),
          ),
          if (isLocked)
            Column(children: [
              const Icon(Icons.lock, color: Colors.white38, size: 20),
              Text(
                'Daraja\n${companion.unlockLevel}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ])
          else if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF69F0AE), size: 28),
        ]),
      ),
    );
  }
}
