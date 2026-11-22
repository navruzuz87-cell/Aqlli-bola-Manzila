import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Game Editor saqlaydigan konfiguratsiyalarni o'yinlar uchun o'qish xizmati.
/// v1 konfiguratsiyasi SharedPreferences'da saqlanadi; server CMS keyin qo'shiladi.
class GameConfigData {
  final String id;
  final String difficulty;
  final String heroName;
  final String companionName;
  final String missionTitle;
  final String missionDescription;
  final bool enabled;
  final bool robotHints;
  final bool timerEnabled;
  final double speed;
  final int questionCount;
  final int rewardStars;
  final int timeLimitSeconds;
  final int minAge;
  final int maxAge;

  const GameConfigData({
    required this.id,
    required this.difficulty,
    required this.heroName,
    required this.companionName,
    required this.missionTitle,
    required this.missionDescription,
    required this.enabled,
    required this.robotHints,
    required this.timerEnabled,
    required this.speed,
    required this.questionCount,
    required this.rewardStars,
    required this.timeLimitSeconds,
    required this.minAge,
    required this.maxAge,
  });

  factory GameConfigData.defaults(String id) {
    final names = <String, List<String>>{
      'alpomish_runner': ['Alpomish', 'Barchinoy', 'Yo‘qolgan so‘zlarni top!'],
      'math_blocks': ['Al-Xorazmiy', 'Shogird', 'Ilm bloklarini joylashtir!'],
      'susambil': ['Eshak', 'Susambil ahli', 'Susambilga yetib bor!'],
      'zumrad': ['Zumrad', 'Qimmat', 'Sehrli sandiqni och!'],
      'shiroq': ['Shiroq', 'Vatan', 'Elni himoya qil!'],
      'tomiris': ['Tomiris', 'Saklar', 'Yurtni himoya qil!'],
    }[id] ?? ['Manzila', 'Do‘st', 'Sarguzashtni boshlang!'];
    return GameConfigData(
      id: id, difficulty: 'normal', heroName: names[0], companionName: names[1],
      missionTitle: names[2], missionDescription: 'Bilim topshiriqlarini bajaring.',
      enabled: true, robotHints: true, timerEnabled: false, speed: 1,
      questionCount: 8, rewardStars: 3, timeLimitSeconds: 60, minAge: 5, maxAge: 12,
    );
  }

  factory GameConfigData.fromJson(Map<String, dynamic> j, String fallbackId) {
    final d = defaults(fallbackId);
    return GameConfigData(
      id: j['id'] as String? ?? d.id,
      difficulty: j['difficulty'] as String? ?? d.difficulty,
      heroName: j['heroName'] as String? ?? d.heroName,
      companionName: j['companionName'] as String? ?? d.companionName,
      missionTitle: j['missionTitle'] as String? ?? d.missionTitle,
      missionDescription: j['missionDescription'] as String? ?? d.missionDescription,
      enabled: j['enabled'] as bool? ?? d.enabled,
      robotHints: j['robotHints'] as bool? ?? d.robotHints,
      timerEnabled: j['timerEnabled'] as bool? ?? d.timerEnabled,
      speed: ((j['speed'] as num?)?.toDouble() ?? d.speed).clamp(0.5, 2.0).toDouble(),
      questionCount: ((j['questionCount'] as int?) ?? d.questionCount).clamp(3, 20).toInt(),
      rewardStars: ((j['rewardStars'] as int?) ?? d.rewardStars).clamp(1, 5).toInt(),
      timeLimitSeconds: ((j['timeLimitSeconds'] as int?) ?? d.timeLimitSeconds).clamp(20, 180).toInt(),
      minAge: ((j['minAge'] as int?) ?? d.minAge).clamp(5, 12).toInt(),
      maxAge: ((j['maxAge'] as int?) ?? d.maxAge).clamp(5, 12).toInt(),
    );
  }

  bool isSuitableForAge(int? age) => age == null || (age >= minAge && age <= maxAge);
}

class GameConfigService {
  GameConfigService._();
  static final instance = GameConfigService._();
  static const storageKey = 'manzila_game_editor_configs_v1';
  Map<String, dynamic>? _cache;

  Future<GameConfigData> load(String gameId, {bool forceRefresh = false}) async {
    if (_cache == null || forceRefresh) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) {
        _cache = <String, dynamic>{};
      } else {
        try {
          final decoded = jsonDecode(raw);
          _cache = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        } catch (_) {
          _cache = <String, dynamic>{};
        }
      }
    }
    final value = _cache![gameId];
    if (value is Map<String, dynamic>) return GameConfigData.fromJson(value, gameId);
    return GameConfigData.defaults(gameId);
  }

  void invalidate() => _cache = null;
}
