import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Fasl ma'lumotlari ─────────────────────────────────────────────────────
class SeasonInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final DateTime start;
  final DateTime end;
  final List<Color> colors;
  final List<SeasonMission> missions;

  const SeasonInfo({
    required this.id, required this.name, required this.emoji,
    required this.description, required this.start, required this.end,
    required this.colors, required this.missions,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  double get progress {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0;
    if (now.isAfter(end)) return 1;
    return now.difference(start).inSeconds / end.difference(start).inSeconds;
  }

  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(end)) return 0;
    return end.difference(now).inDays + 1;
  }
}

class SeasonMission {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final int reward;

  const SeasonMission({
    required this.id, required this.title, required this.description,
    required this.emoji, required this.target, required this.reward,
  });
}

// ── Faslar ────────────────────────────────────────────────────────────────
class Seasons {
  static SeasonInfo navrozSeason(int year) => SeasonInfo(
    id: 'navroz_$year', name: "Navro'z",
    emoji: '🌸', description: "Bahor va yangi yil!",
    start: DateTime(year, 3, 21), end: DateTime(year, 4, 4),
    colors: [const Color(0xFFE91E63), const Color(0xFFFF9800)],
    missions: const [
      SeasonMission(id: 'navroz_1', title: "Navro'z salomlashuvi",    emoji: '🌸', description: '7 kun ketma-ket o\'yin o\'yna',           target: 7,  reward: 50),
      SeasonMission(id: 'navroz_2', title: "Sumalak pishirish",       emoji: '🫕', description: '21 ta to\'g\'ri javob ber',               target: 21, reward: 30),
      SeasonMission(id: 'navroz_3', title: "Ko'klam yulduzi",        emoji: '⭐', description: '100 ta yulduz yig\'',                     target: 100, reward: 70),
      SeasonMission(id: 'navroz_4', title: "Gullar ochilmoqda",       emoji: '🌺', description: '5 xil fandan o\'yin o\'yna',               target: 5,  reward: 40),
    ],
  );

  static SeasonInfo ramazonSeason(int year) => SeasonInfo(
    id: 'ramazon_$year', name: "Ramazon",
    emoji: '🌙', description: "Muborak oy!",
    start: DateTime(year, 3, 10), end: DateTime(year, 4, 9), // approx
    colors: [const Color(0xFF1565C0), const Color(0xFF7B1FA2)],
    missions: const [
      SeasonMission(id: 'ramazon_1', title: "Sahur qo'ng'irog'i",    emoji: '🌙', description: '30 kun o\'yin o\'yna',                    target: 30, reward: 100),
      SeasonMission(id: 'ramazon_2', title: "Ilm va iymon",          emoji: '📿', description: '50 ta to\'g\'ri javob ber',               target: 50, reward: 60),
      SeasonMission(id: 'ramazon_3', title: "Iftor sovg\'asi",       emoji: '🎁', description: '200 yulduz yig\'',                        target: 200, reward: 80),
    ],
  );

  static SeasonInfo navbahorSeason(int year) => SeasonInfo(
    id: 'navbahor_$year', name: "Navbahor",
    emoji: '🌱', description: "Yoz fasli!",
    start: DateTime(year, 6, 1), end: DateTime(year, 6, 30),
    colors: [const Color(0xFF388E3C), const Color(0xFF1976D2)],
    missions: const [
      SeasonMission(id: 'navbahor_1', title: "Yoz sarguzashtlari",   emoji: '🏖️', description: '15 kun o\'yin o\'yna',                    target: 15, reward: 60),
      SeasonMission(id: 'navbahor_2', title: "Matematik qahramonlik",emoji: '➕', description: 'Matematikadan 30 ta to\'g\'ri',             target: 30, reward: 40),
    ],
  );

  static List<SeasonInfo> getActive() {
    final year = DateTime.now().year;
    return [
      navrozSeason(year),
      ramazonSeason(year),
      navbahorSeason(year),
    ].where((s) => s.isActive).toList();
  }

  static List<SeasonInfo> getAll() {
    final year = DateTime.now().year;
    return [navrozSeason(year), ramazonSeason(year), navbahorSeason(year)];
  }
}

// ── SeasonService ──────────────────────────────────────────────────────────
class SeasonService extends ChangeNotifier {
  SeasonService._();
  static final instance = SeasonService._();

  static const _key = 'season_progress';
  Map<String, int> _progress = {};
  Map<String, bool> _claimed = {};

  List<SeasonInfo> get activeSeasons => Seasons.getActive();
  List<SeasonInfo> get allSeasons => Seasons.getAll();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _progress = Map<String, int>.from(m['progress'] ?? {});
      _claimed = Map<String, bool>.from(m['claimed'] ?? {});
    }
    notifyListeners();
  }

  int getProgress(String missionId) => _progress[missionId] ?? 0;
  bool isClaimed(String missionId) => _claimed[missionId] ?? false;

  bool canClaim(SeasonMission m) =>
      getProgress(m.id) >= m.target && !isClaimed(m.id);

  Future<void> recordProgress(String missionId, int amount) async {
    _progress[missionId] = (_progress[missionId] ?? 0) + amount;
    await _save();
    notifyListeners();
  }

  Future<int> claimReward(String missionId) async {
    // find mission
    for (final s in allSeasons) {
      final m = s.missions.where((m) => m.id == missionId).firstOrNull;
      if (m != null && canClaim(m)) {
        _claimed[missionId] = true;
        await _save();
        notifyListeners();
        return m.reward;
      }
    }
    return 0;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'progress': _progress,
      'claimed': _claimed,
    }));
  }
}
