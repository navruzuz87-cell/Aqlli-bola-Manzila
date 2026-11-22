import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manzila_aqlli_bola/core/services/game_stats_service.dart';

void main() {
  group('GameResult', () {
    test('toMap va fromMap simmetrik', () {
      final now = DateTime(2026, 11, 21, 10, 30);
      final r = GameResult(
        gameId: 'susambil',
        subject: 'Matematika',
        stars: 3,
        score: 4,
        maxScore: 4,
        durationSeconds: 180,
        playedAt: now,
      );
      final m = r.toMap();
      final r2 = GameResult.fromMap(m);

      expect(r2.gameId, 'susambil');
      expect(r2.subject, 'Matematika');
      expect(r2.stars, 3);
      expect(r2.score, 4);
      expect(r2.maxScore, 4);
      expect(r2.durationSeconds, 180);
      expect(r2.pct, 1.0);
    });

    test('pct nol maxScore da 0 qaytaradi', () {
      final r = GameResult(
        gameId: 'x', subject: 'Y', stars: 0,
        score: 0, maxScore: 0, durationSeconds: 0,
        playedAt: DateTime.now(),
      );
      expect(r.pct, 0);
    });

    test('stars 0-3 oraligida clamp qilinadi', () {
      final r = GameResult.fromMap({
        'g': 'x', 's': 'Y', 'st': 10, 'sc': 5, 'mx': 5,
        'd': 60, 'at': DateTime.now().toIso8601String(),
      });
      expect(r.stars, 3); // 10 -> clamp -> 3
    });
  });

  group('GameStatsService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('yangi profil uchun bo`sh natijalar', () async {
      final svc = GameStatsService.instance;
      await svc.init('new-profile-123');
      final results = svc.resultsFor('new-profile-123');
      expect(results, isEmpty);
    });

    test('natija yoziladi va o`qiladi', () async {
      final svc = GameStatsService.instance;
      await svc.init('profile-abc');
      await svc.record('profile-abc', GameResult(
        gameId: 'susambil',
        subject: 'Matematika',
        stars: 2,
        score: 3,
        maxScore: 4,
        durationSeconds: 120,
        playedAt: DateTime.now(),
      ));
      final results = svc.resultsFor('profile-abc');
      expect(results.length, 1);
      expect(results.first.gameId, 'susambil');
      expect(results.first.stars, 2);
    });

    test('gameName noma`lum ID uchun ID qaytaradi', () {
      expect(GameStatsService.gameName('susambil'), 'Susambil: Yo\'qolgan buloq');
      expect(GameStatsService.gameName('unknown_game'), 'unknown_game');
    });
  });
}
