import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Kunlik sessiya yozuvi ─────────────────────────────────────────────────
class DaySession {
  final DateTime date;
  final int minutesPlayed;
  final int starsEarned;
  final Map<String, int> subjectMinutes; // fan → daqiqa

  const DaySession({
    required this.date,
    required this.minutesPlayed,
    required this.starsEarned,
    required this.subjectMinutes,
  });

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'minutes': minutesPlayed,
    'stars': starsEarned,
    'subjects': subjectMinutes,
  };

  factory DaySession.fromMap(Map<String, dynamic> m) => DaySession(
    date: DateTime.parse(m['date']),
    minutesPlayed: m['minutes'] ?? 0,
    starsEarned: m['stars'] ?? 0,
    subjectMinutes: Map<String, int>.from(m['subjects'] ?? {}),
  );
}

// ── Parental sozlamalar ───────────────────────────────────────────────────
class ParentalSettings {
  final bool isEnabled;
  final String pinHash;         // SHA-256 hash
  final int dailyLimitMinutes;  // 0 = cheksiz
  final bool showOnLaunch;      // har kuni statistika ko'rsatsin
  final List<int> allowedHours; // bo'sh = istalgan vaqt

  const ParentalSettings({
    this.isEnabled = false,
    this.pinHash = '',
    this.dailyLimitMinutes = 60,
    this.showOnLaunch = false,
    this.allowedHours = const [],
  });

  ParentalSettings copyWith({
    bool? isEnabled, String? pinHash,
    int? dailyLimitMinutes, bool? showOnLaunch,
    List<int>? allowedHours,
  }) => ParentalSettings(
    isEnabled: isEnabled ?? this.isEnabled,
    pinHash: pinHash ?? this.pinHash,
    dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
    showOnLaunch: showOnLaunch ?? this.showOnLaunch,
    allowedHours: allowedHours ?? this.allowedHours,
  );

  Map<String, dynamic> toMap() => {
    'enabled': isEnabled, 'pin': pinHash,
    'limit': dailyLimitMinutes, 'showOnLaunch': showOnLaunch,
    'hours': allowedHours,
  };

  factory ParentalSettings.fromMap(Map<String, dynamic> m) => ParentalSettings(
    isEnabled: m['enabled'] ?? false,
    pinHash: m['pin'] ?? '',
    dailyLimitMinutes: m['limit'] ?? 60,
    showOnLaunch: m['showOnLaunch'] ?? false,
    allowedHours: List<int>.from(m['hours'] ?? []),
  );
}

// ── ParentalService ────────────────────────────────────────────────────────
class ParentalService extends ChangeNotifier {
  ParentalService._();
  static final instance = ParentalService._();

  ParentalSettings _settings = const ParentalSettings();
  List<DaySession> _history = []; // so'nggi 30 kun
  DateTime? _sessionStart;
  int _todayMinutes = 0;
  String? _activeSubject;

  ParentalSettings get settings => _settings;
  int get todayMinutes => _todayMinutes;
  List<DaySession> get history => List.unmodifiable(_history);

  // ── Init / persist ────────────────────────────────────────────────────────
  Future<void> init() async {
    await _load();
    _recalcToday();
  }

  void _recalcToday() {
    final today = _todayKey();
    final sess = _history.where((s) => _keyOf(s.date) == today);
    _todayMinutes = sess.fold(0, (sum, s) => sum + s.minutesPlayed);
  }

  String _todayKey() => _keyOf(DateTime.now());
  String _keyOf(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // ── Sessiya boshqaruvi ────────────────────────────────────────────────────
  void sessionStart({String? subject}) {
    _sessionStart = DateTime.now();
    _activeSubject = subject;
  }

  Future<void> sessionEnd({int starsEarned = 0}) async {
    if (_sessionStart == null) return;
    final mins = DateTime.now().difference(_sessionStart!).inMinutes;
    _sessionStart = null;

    if (mins <= 0) return;

    final today = DateTime.now();
    final todayKey = _todayKey();
    final existing = _history.indexWhere((s) => _keyOf(s.date) == todayKey);

    final subMap = <String, int>{};
    if (_activeSubject != null) subMap[_activeSubject!] = mins;

    if (existing >= 0) {
      final old = _history[existing];
      final merged = Map<String, int>.from(old.subjectMinutes);
      subMap.forEach((k, v) => merged[k] = (merged[k] ?? 0) + v);
      _history[existing] = DaySession(
        date: old.date,
        minutesPlayed: old.minutesPlayed + mins,
        starsEarned: old.starsEarned + starsEarned,
        subjectMinutes: merged,
      );
    } else {
      _history.insert(0, DaySession(
        date: today,
        minutesPlayed: mins,
        starsEarned: starsEarned,
        subjectMinutes: subMap,
      ));
      if (_history.length > 30) _history.removeLast();
    }

    _todayMinutes += mins;
    _activeSubject = null;
    await _save();
    notifyListeners();
  }

  // ── Limit tekshiruv ───────────────────────────────────────────────────────
  bool get isLimitReached =>
      _settings.isEnabled &&
      _settings.dailyLimitMinutes > 0 &&
      _todayMinutes >= _settings.dailyLimitMinutes;

  int get remainingMinutes {
    if (!_settings.isEnabled || _settings.dailyLimitMinutes == 0) return 9999;
    return (_settings.dailyLimitMinutes - _todayMinutes).clamp(0, 9999);
  }

  bool get isAllowedHour {
    if (!_settings.isEnabled || _settings.allowedHours.isEmpty) return true;
    return _settings.allowedHours.contains(DateTime.now().hour);
  }

  // ── PIN ───────────────────────────────────────────────────────────────────
  bool verifyPin(String pin) {
    if (_settings.pinHash.isEmpty) return true;
    return _simpleHash(pin) == _settings.pinHash;
  }

  String _simpleHash(String s) {
    // Sodda hash — production da dart:crypto ishlatish tavsiya etiladi
    int h = 0;
    for (final c in s.codeUnits) h = (h * 31 + c) & 0xFFFFFFFF;
    return h.toRadixString(16);
  }

  // ── Settings yangilash ────────────────────────────────────────────────────
  Future<void> updateSettings(ParentalSettings newSettings) async {
    _settings = newSettings;
    await _save();
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _settings = _settings.copyWith(pinHash: _simpleHash(pin));
    await _save();
    notifyListeners();
  }

  // ── Statistika ────────────────────────────────────────────────────────────
  int get weekMinutes {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _history
        .where((s) => s.date.isAfter(cutoff))
        .fold(0, (sum, s) => sum + s.minutesPlayed);
  }

  int get weekStars {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _history
        .where((s) => s.date.isAfter(cutoff))
        .fold(0, (sum, s) => sum + s.starsEarned);
  }

  Map<String, int> get weekSubjectMinutes {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final result = <String, int>{};
    for (final s in _history.where((s) => s.date.isAfter(cutoff))) {
      s.subjectMinutes.forEach((k, v) => result[k] = (result[k] ?? 0) + v);
    }
    return result;
  }

  // ── Persist ───────────────────────────────────────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsRaw = prefs.getString('parental_settings');
    if (settingsRaw != null) {
      _settings = ParentalSettings.fromMap(jsonDecode(settingsRaw));
    }
    final historyRaw = prefs.getString('play_history');
    if (historyRaw != null) {
      final list = jsonDecode(historyRaw) as List;
      _history = list.map((m) => DaySession.fromMap(m)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'parental_settings', jsonEncode(_settings.toMap()));
    await prefs.setString(
        'play_history', jsonEncode(_history.map((s) => s.toMap()).toList()));
  }
}
