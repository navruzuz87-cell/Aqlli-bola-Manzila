import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Notification model ────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final DateTime scheduledAt;
  bool isRead;

  AppNotification({
    required this.id, required this.title, required this.body,
    required this.type, required this.scheduledAt, this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'type': type.name, 'scheduledAt': scheduledAt.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'], title: j['title'], body: j['body'],
    type: NotifType.values.firstWhere((e) => e.name == j['type']),
    scheduledAt: DateTime.parse(j['scheduledAt']),
    isRead: j['isRead'] ?? false,
  );
}

enum NotifType { dailyReminder, missionComplete, streakWarning, levelUp, achievementUnlocked }

// ── NotificationService ───────────────────────────────────────────────────
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final instance = NotificationService._();

  static const _key = 'app_notifications';
  List<AppNotification> _notifications = [];
  List<AppNotification> get all => List.unmodifiable(_notifications);
  List<AppNotification> get unread => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unread.length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _notifications = raw.map((s) => AppNotification.fromJson(jsonDecode(s))).toList();
    // Check scheduled notifications
    await _checkScheduled();
    notifyListeners();
  }

  Future<void> _checkScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Daily reminder — 09:00
    final lastDaily = prefs.getString('last_daily_notif');
    final todayKey = '${now.year}-${now.month}-${now.day}';
    if (lastDaily != todayKey && now.hour >= 9) {
      await _add(AppNotification(
        id: 'daily_${now.millisecondsSinceEpoch}',
        title: "🌅 O'rganish vaqti!",
        body: "Bugun ham mashqlaringizni bajaring va yulduzlar yig'ing!",
        type: NotifType.dailyReminder,
        scheduledAt: now,
      ));
      await prefs.setString('last_daily_notif', todayKey);
    }

    // Streak warning — if streak >= 3 and no game today
    final lastGame = prefs.getString('last_game_date');
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    if (lastGame == yesterdayKey && now.hour >= 18) {
      final lastStreakWarn = prefs.getString('last_streak_warn');
      if (lastStreakWarn != todayKey) {
        await _add(AppNotification(
          id: 'streak_${now.millisecondsSinceEpoch}',
          title: '🔥 Ketma-ketligingiz xavf ostida!',
          body: "Bugun o'yin o'ynamasangiz seriyangiz tugaydi!",
          type: NotifType.streakWarning,
          scheduledAt: now,
        ));
        await prefs.setString('last_streak_warn', todayKey);
      }
    }
  }

  Future<void> addMissionComplete(String missionName, int stars) async {
    await _add(AppNotification(
      id: 'mission_${DateTime.now().millisecondsSinceEpoch}',
      title: '🎉 Missiya bajarildi!',
      body: '$missionName — $stars yulduz oldingiz!',
      type: NotifType.missionComplete,
      scheduledAt: DateTime.now(),
    ));
  }

  Future<void> addLevelUp(String profileName, int newLevel) async {
    await _add(AppNotification(
      id: 'level_${DateTime.now().millisecondsSinceEpoch}',
      title: '⬆️ Daraja ko\'tarildi!',
      body: '$profileName — endi ${newLevel}-darajaga yetdingiz!',
      type: NotifType.levelUp,
      scheduledAt: DateTime.now(),
    ));
  }

  Future<void> addAchievement(String title, String desc) async {
    await _add(AppNotification(
      id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
      title: '🏆 Yutuq: $title',
      body: desc,
      type: NotifType.achievementUnlocked,
      scheduledAt: DateTime.now(),
    ));
  }

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    _notifications[idx].isRead = true;
    await _save();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) n.isRead = true;
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _add(AppNotification n) async {
    _notifications.insert(0, n);
    if (_notifications.length > 50) _notifications = _notifications.take(50).toList();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key,
        _notifications.map((n) => jsonEncode(n.toJson())).toList());
  }
}
