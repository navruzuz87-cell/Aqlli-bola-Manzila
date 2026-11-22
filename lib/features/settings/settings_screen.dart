import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/sound_utils.dart';
import '../../main.dart' show darkModeNotifier;
import '../../core/services/profile_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdate;

  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onUpdate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundOn;
  late bool _hapticOn;
  late bool _notificationsOn;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundOn         = prefs.getBool('sound_on') ?? true;
      _hapticOn        = prefs.getBool('haptic_on') ?? true;
      _notificationsOn = prefs.getBool('notifications_on') ?? true;
      _darkMode        = prefs.getBool('dark_mode') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _resetProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Progressni o\'chirish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Barcha yulduzlar va yutuqlar o\'chadi. Davom etasizmi?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final reset = widget.profile.copyWith(
        stars: 0,
        gems: 0,
        dailyStreakDays: 0,
        subjectStars: {},
        subjectProgress: {},
        ownedItems: '',
        totalPlayMinutes: 0,
      );
      widget.onUpdate(reset);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Progress o\'chirildi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🗑️ Profilni o\'chirish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '${widget.profile.name} profili butunlay o\'chadi!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ProfileStorageService.instance.deleteProfile(widget.profile.id);
      if (mounted) context.go('/profiles');
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
            colors: [Color(0xFF212121), Color(0xFF37474F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        '⚙️ Sozlamalar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Profil kartochkasi
                    _buildProfileCard(),
                    const SizedBox(height: 20),

                    // O'yin sozlamalari
                    _buildSection('🎮 O\'yin', [
                      _SettingTile(
                        icon: '🔊',
                        label: 'Ovoz',
                        subtitle: 'O\'yin tovushlari',
                        value: _soundOn,
                        onChanged: (v) {
                          setState(() => _soundOn = v);
                          _saveSetting('sound_on', v);
                          SoundUtils.invalidateCache();
                          if (v) { HapticFeedback.lightImpact(); SoundUtils.click(); }
                        },
                      ),
                      _SettingTile(
                        icon: '📳',
                        label: 'Tebranish',
                        subtitle: 'To\'g\'ri/xato javob tebranishi',
                        value: _hapticOn,
                        onChanged: (v) {
                          setState(() => _hapticOn = v);
                          _saveSetting('haptic_on', v);
                          HapticUtils.invalidateCache();
                          if (v) HapticFeedback.mediumImpact();
                        },
                      ),
                      _SettingTile(
                        icon: '🔔',
                        label: 'Bildirishnomalar',
                        subtitle: 'Kunlik eslatmalar',
                        value: _notificationsOn,
                        onChanged: (v) {
                          setState(() => _notificationsOn = v);
                          _saveSetting('notifications_on', v);
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Ko'rinish
                    _buildSection('🎨 Ko\'rinish', [
                      _SettingTile(
                        icon: '🌙',
                        label: 'Qorong\'u rejim',
                        subtitle: 'Kechasi ko\'z uchun qulay',
                        value: _darkMode,
                        onChanged: (v) {
                          setState(() => _darkMode = v);
                          _saveSetting('dark_mode', v);
                          darkModeNotifier.value = v; // global UI yangilash
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Ma'lumot
                    _buildSection('ℹ️ Ilova haqida', [
                      _InfoTile(icon: '📱', label: 'Versiya', value: '1.0.0'),
                      _InfoTile(icon: '👨‍💻', label: 'Dasturchi', value: 'Manzila Team'),
                      _InfoTile(icon: '🇺🇿', label: 'Til', value: 'O\'zbek'),
                    ]),

                    const SizedBox(height: 20),

                    // Xavfli amallar
                    _buildSection('⚠️ Xavfli zona', [
                      _ActionTile(
                        icon: '🔄',
                        label: 'Progressni o\'chirish',
                        subtitle: 'Yulduzlar va yutuqlar saqlanmaydi',
                        color: Colors.orange,
                        onTap: _resetProgress,
                      ),
                      _ActionTile(
                        icon: '🗑️',
                        label: 'Profilni o\'chirish',
                        subtitle: '${widget.profile.name} profili o\'chadi',
                        color: Colors.red,
                        onTap: _deleteProfile,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Text(
                        '🏠 Manzila: Aqlli Bola\nO\'ynab o\'rgan! 🌟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1565C0).withOpacity(0.5),
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: Center(
              child: Text(
                widget.profile.isGirl ? '👧' : '👦',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${widget.profile.grade}-sinf • ⭐ ${widget.profile.stars} • 🔥 ${widget.profile.dailyStreakDays} kun',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String icon, label, subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SettingTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String icon, label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon, label, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45), fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
