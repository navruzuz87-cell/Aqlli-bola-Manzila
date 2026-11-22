import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';

// ── Mission modeli ────────────────────────────────────────────────────────
class Mission {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final MissionType type;
  final int target;       // maqsad soni
  final int reward;       // yulduz mukofot
  final String? subject;  // null = istalgan fan

  const Mission({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
    this.subject,
  });
}

enum MissionType { daily, weekly, special }

// ── Barcha missiyalar ─────────────────────────────────────────────────────
class MissionData {
  static const daily = [
    Mission(id: 'd1', title: 'Birinchi qadam',    emoji: '👣',
        description: '1 ta o\'yin o\'yna',
        type: MissionType.daily, target: 1, reward: 5),
    Mission(id: 'd2', title: 'Faol o\'quvchi',    emoji: '📚',
        description: '3 ta o\'yin o\'yna',
        type: MissionType.daily, target: 3, reward: 10),
    Mission(id: 'd3', title: 'Matematika ustasi', emoji: '🔢',
        description: 'Matematikadan 5 ta to\'g\'ri javob',
        type: MissionType.daily, target: 5, reward: 8, subject: 'matematika'),
    Mission(id: 'd4', title: 'Til bilimdon',      emoji: '🌍',
        description: 'Inglizchadan 3 ta to\'g\'ri javob',
        type: MissionType.daily, target: 3, reward: 8, subject: 'ingliz'),
    Mission(id: 'd5', title: 'Shahar quruvchi',   emoji: '🏗️',
        description: 'Shaharchani bir marta ochish',
        type: MissionType.daily, target: 1, reward: 5),
  ];

  static const weekly = [
    Mission(id: 'w1', title: 'Haftalik qahramoN', emoji: '🏆',
        description: '20 ta o\'yin o\'yna',
        type: MissionType.weekly, target: 20, reward: 50),
    Mission(id: 'w2', title: 'Ko\'p qirrali',     emoji: '🌟',
        description: 'Barcha 6 fandan o\'yna',
        type: MissionType.weekly, target: 6, reward: 40),
    Mission(id: 'w3', title: 'Yulduz to\'plash',  emoji: '⭐',
        description: 'Jami 100 ta yulduz yig\'',
        type: MissionType.weekly, target: 100, reward: 60),
    Mission(id: 'w4', title: 'Shahar me\'mori',   emoji: '🏙️',
        description: '3 ta bino qur',
        type: MissionType.weekly, target: 3, reward: 45),
  ];

  static const special = [
    Mission(id: 's1', title: 'Birinchi g\'alaba', emoji: '🎉',
        description: 'Birinchi o\'yinda g\'alab qozon',
        type: MissionType.special, target: 1, reward: 20),
    Mission(id: 's2', title: 'Perfektsionist',    emoji: '💎',
        description: 'Bitta o\'yinda 3 yulduz ol',
        type: MissionType.special, target: 1, reward: 25),
    Mission(id: 's3', title: 'Sadoqatli o\'quvchi',emoji: '🔥',
        description: '7 kun ketma-ket kir',
        type: MissionType.special, target: 7, reward: 100),
    Mission(id: 's4', title: 'Bilim xazinasi',    emoji: '📖',
        description: 'Barcha o\'yinlarni kamida bir marta o\'yna',
        type: MissionType.special, target: 7, reward: 80),
  ];

  static List<Mission> get all => [...daily, ...weekly, ...special];
}

// ── MissionProgress ────────────────────────────────────────────────────────
class MissionProgress {
  final String missionId;
  final int current;
  final bool completed;
  final bool claimed;
  final DateTime? completedAt;

  const MissionProgress({
    required this.missionId,
    required this.current,
    required this.completed,
    required this.claimed,
    this.completedAt,
  });

  MissionProgress copyWith({
    int? current, bool? completed, bool? claimed, DateTime? completedAt,
  }) => MissionProgress(
    missionId: missionId,
    current: current ?? this.current,
    completed: completed ?? this.completed,
    claimed: claimed ?? this.claimed,
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, dynamic> toMap() => {
    'id': missionId, 'current': current,
    'completed': completed, 'claimed': claimed,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory MissionProgress.fromMap(Map<String, dynamic> m) => MissionProgress(
    missionId: m['id'],
    current: m['current'] ?? 0,
    completed: m['completed'] ?? false,
    claimed: m['claimed'] ?? false,
    completedAt: m['completedAt'] != null
        ? DateTime.tryParse(m['completedAt']) : null,
  );
}

// ── MissionService ────────────────────────────────────────────────────────
class MissionService extends ChangeNotifier {
  MissionService._();
  static final instance = MissionService._();

  Map<String, MissionProgress> _progress = {};
  int _streakDays = 0;
  DateTime? _lastLogin;
  DateTime? _dailyReset;

  int get streakDays => _streakDays;
  DateTime? get lastLogin => _lastLogin;

  Future<void> init() async {
    await _load();
    _checkDailyReset();
    await _updateStreak();
  }

  // ── Streak hisoblash ──────────────────────────────────────────────────────
  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastLogin == null) {
      _streakDays = 1;
    } else {
      final last = DateTime(
          _lastLogin!.year, _lastLogin!.month, _lastLogin!.day);
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // Bugun allaqachon kirilgan — streak o'zgarmaydi
      } else if (diff == 1) {
        _streakDays++;
      } else {
        _streakDays = 1; // uzildi
      }
    }
    _lastLogin = now;
    await _save();
    notifyListeners();
  }

  // ── Kunlik reset ──────────────────────────────────────────────────────────
  void _checkDailyReset() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    if (_dailyReset == null || _dailyReset!.isBefore(todayMidnight)) {
      // Kunlik missiyalarni reset
      for (final m in MissionData.daily) {
        if (_progress.containsKey(m.id)) {
          _progress[m.id] = MissionProgress(
            missionId: m.id, current: 0,
            completed: false, claimed: false,
          );
        }
      }
      _dailyReset = todayMidnight;
    }
  }

  // ── Progress yangilash ────────────────────────────────────────────────────
  Future<List<Mission>> recordEvent({
    required MissionEventType event,
    String? subject,
    int starsEarned = 0,
    int gamesPlayed = 1,
  }) async {
    final newly = <Mission>[];
    for (final m in MissionData.all) {
      final prog = _progress[m.id] ??
          MissionProgress(missionId: m.id, current: 0,
              completed: false, claimed: false);
      if (prog.completed) continue;

      int delta = 0;
      switch (event) {
        case MissionEventType.gamePlayed:
          if (m.id == 'd1' || m.id == 'd2' || m.id == 'w1') delta = 1;
          if (m.id == 's4') delta = 1;
          break;
        case MissionEventType.correctAnswer:
          if (m.subject == null || m.subject == subject) {
            if (m.id == 'd3' && subject == 'matematika') delta = 1;
            if (m.id == 'd4' && subject == 'ingliz') delta = 1;
          }
          break;
        case MissionEventType.starsEarned:
          if (m.id == 'w3') delta = starsEarned;
          if (m.id == 's2' && starsEarned >= 3) delta = 1;
          break;
        case MissionEventType.cityOpened:
          if (m.id == 'd5') delta = 1;
          break;
        case MissionEventType.buildingBuilt:
          if (m.id == 'w4') delta = 1;
          break;
        case MissionEventType.firstWin:
          if (m.id == 's1') delta = 1;
          break;
        case MissionEventType.subjectPlayed:
          if (m.id == 'w2') delta = 1;
          break;
        case MissionEventType.streakDay:
          if (m.id == 's3') delta = 1;
          break;
      }

      if (delta > 0) {
        final newCurrent = (prog.current + delta).clamp(0, m.target);
        final nowDone = newCurrent >= m.target;
        _progress[m.id] = prog.copyWith(
          current: newCurrent,
          completed: nowDone,
          completedAt: nowDone ? DateTime.now() : null,
        );
        if (nowDone) newly.add(m);
      }
    }
    await _save();
    notifyListeners();
    return newly;
  }

  // ── Mukofot olish ─────────────────────────────────────────────────────────
  Future<int> claimReward(String missionId) async {
    final prog = _progress[missionId];
    if (prog == null || !prog.completed || prog.claimed) return 0;
    _progress[missionId] = prog.copyWith(claimed: true);
    final mission = MissionData.all.firstWhere((m) => m.id == missionId);
    await _save();
    notifyListeners();
    return mission.reward;
  }

  // ── Getterlar ─────────────────────────────────────────────────────────────
  MissionProgress progressFor(String id) =>
      _progress[id] ??
      MissionProgress(missionId: id, current: 0,
          completed: false, claimed: false);

  List<Mission> get claimable => MissionData.all
      .where((m) {
        final p = progressFor(m.id);
        return p.completed && !p.claimed;
      })
      .toList();

  int get totalUnclaimedStars =>
      claimable.fold(0, (sum, m) => sum + m.reward);

  // ── Persist ────────────────────────────────────────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('missions_progress');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      for (final item in list) {
        final p = MissionProgress.fromMap(item);
        _progress[p.missionId] = p;
      }
    }
    _streakDays = prefs.getInt('streak_days') ?? 0;
    final lastStr = prefs.getString('last_login');
    _lastLogin = lastStr != null ? DateTime.tryParse(lastStr) : null;
    final resetStr = prefs.getString('daily_reset');
    _dailyReset = resetStr != null ? DateTime.tryParse(resetStr) : null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _progress.values.map((p) => p.toMap()).toList();
    await prefs.setString('missions_progress', jsonEncode(list));
    await prefs.setInt('streak_days', _streakDays);
    if (_lastLogin != null) {
      await prefs.setString('last_login', _lastLogin!.toIso8601String());
    }
    if (_dailyReset != null) {
      await prefs.setString('daily_reset', _dailyReset!.toIso8601String());
    }
  }
}

enum MissionEventType {
  gamePlayed, correctAnswer, starsEarned,
  cityOpened, buildingBuilt, firstWin,
  subjectPlayed, streakDay,
}
