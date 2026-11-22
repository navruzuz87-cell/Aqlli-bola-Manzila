import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Bitta o'yin natijasi ──────────────────────────────────────────────────
class GameResult {
  final String gameId;      // 'archery', 'wordle', etc.
  final String subject;
  final int stars;          // 0-3
  final int score;
  final int maxScore;
  final int durationSeconds;
  final DateTime playedAt;

  const GameResult({
    required this.gameId,
    required this.subject,
    required this.stars,
    required this.score,
    required this.maxScore,
    required this.durationSeconds,
    required this.playedAt,
  });

  double get pct => maxScore > 0 ? score / maxScore : 0;

  Map<String, dynamic> toMap() => {
    'g': gameId, 's': subject, 'st': stars, 'sc': score,
    'mx': maxScore, 'd': durationSeconds, 'at': playedAt.toIso8601String(),
  };
  factory GameResult.fromMap(Map<String, dynamic> m) => GameResult(
    gameId: (m['g'] as String?) ?? 'unknown',
    subject: (m['s'] as String?) ?? 'Umumiy',
    stars: (((m['st'] as num?)?.toInt() ?? 0).clamp(0, 3)).toInt(),
    score: (m['sc'] as num?)?.toInt() ?? 0,
    maxScore: (m['mx'] as num?)?.toInt() ?? 0,
    durationSeconds: (m['d'] as num?)?.toInt() ?? 0,
    playedAt: DateTime.parse(m['at']),
  );
}

// ── GameStatsService ──────────────────────────────────────────────────────
class GameStatsService extends ChangeNotifier {
  GameStatsService._();
  static final instance = GameStatsService._();

  // profileId → results (so'nggi 200 ta)
  final Map<String, List<GameResult>> _data = {};
  static const _maxResults = 200;

  static const _gameNames = {
    'archery':  'Alpomish Kamoni',
    'wordle':   'Zumrad Sandiq',
    'semurg':   "Semurg' Parvozi",
    'fortress': "Spitamen Qal'asi",
    'donkey':   'Susambildagi Eshak',
    'susambil': 'Susambil: Yo‘qolgan buloq',
    'geomap':   'Rustam Maydon',
    'city':     'Shaharcha',
    'math_blocks': 'Al-Xorazmiy: Matematik bloklar',
    'alpomish_runner': 'Alpomish: So‘z yig‘ish sayohati',
  };
  static String gameName(String id) => _gameNames[id] ?? id;

  // ── Init ──────────────────────────────────────────────────────────────────
  /// Profile ma'lum bo'lganda uning natijalarini yuklaydi.
  /// Ilova startida profile hali tanlanmagan bo'lsa, argumentsiz chaqirish xavfsiz.
  Future<void> init([String? profileId], {String? legacyProfileId}) async {
    if (profileId == null || profileId.trim().isEmpty) return;
    if (_data.containsKey(profileId)) return;

    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString('game_stats_$profileId');
    // v56 va undan oldingi versiyalarda ism profil kaliti sifatida ishlatilgan.
    // Yangi ID kaliti bo'sh bo'lsa, eski natijalarni bir marta ko'chiramiz.
    if ((raw == null || raw.isEmpty) &&
        legacyProfileId != null && legacyProfileId != profileId) {
      raw = prefs.getString('game_stats_$legacyProfileId');
      if (raw != null && raw.isNotEmpty) {
        await prefs.setString('game_stats_$profileId', raw);
      }
    }
    if (raw == null || raw.isEmpty) {
      _data[profileId] = [];
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Natijalar ro\u2018yxati noto\u2018g\u2018ri');
      _data[profileId] = decoded
          .whereType<Map>()
          .map((m) => GameResult.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      // Buzilgan eski statistika ilovani ishga tushishdan to'xtatmasin.
      _data[profileId] = [];
    }
    notifyListeners();
  }

  // ── Yozish ────────────────────────────────────────────────────────────────
  Future<void> record(String profileId, GameResult result, {String? legacyProfileId}) async {
    await init(profileId, legacyProfileId: legacyProfileId);
    _data.putIfAbsent(profileId, () => []);
    _data[profileId]!.insert(0, result);
    if (_data[profileId]!.length > _maxResults) {
      _data[profileId]!.removeLast();
    }
    await _save(profileId);
    notifyListeners();
  }

  // ── Statistika ────────────────────────────────────────────────────────────
  List<GameResult> resultsFor(String profileId, {String? gameId, String? subject}) {
    final list = _data[profileId] ?? [];
    return list.where((r) =>
      (gameId == null || r.gameId == gameId) &&
      (subject == null || r.subject == subject)
    ).toList();
  }

  // O'yin bo'yicha eng yuqori ball
  int bestScore(String profileId, String gameId) {
    final r = resultsFor(profileId, gameId: gameId);
    if (r.isEmpty) return 0;
    return r.map((e) => e.score).reduce((a, b) => a > b ? a : b);
  }

  // O'rtacha yulduz (0-3)
  double avgStars(String profileId, String gameId) {
    final r = resultsFor(profileId, gameId: gameId);
    if (r.isEmpty) return 0;
    return r.map((e) => e.stars).reduce((a, b) => a + b) / r.length;
  }

  // So'nggi 7 kun: kun bo'yicha o'ynalgan soni
  List<int> weeklyGames(String profileId) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return resultsFor(profileId).where((r) =>
        r.playedAt.year == d.year &&
        r.playedAt.month == d.month &&
        r.playedAt.day == d.day
      ).length;
    });
  }

  // Fan bo'yicha umumiy yulduz
  Map<String, int> subjectStarMap(String profileId) {
    final map = <String, int>{};
    for (final r in resultsFor(profileId)) {
      map[r.subject] = (map[r.subject] ?? 0) + r.stars;
    }
    return map;
  }

  // O'yin bo'yicha o'ynalgan marta
  int playCount(String profileId, String gameId) =>
      resultsFor(profileId, gameId: gameId).length;

  Future<void> _save(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (_data[profileId] ?? []).map((r) => r.toMap()).toList();
    await prefs.setString('game_stats_$profileId', jsonEncode(list));
  }
}
