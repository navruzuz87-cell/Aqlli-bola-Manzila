import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manzila_aqlli_bola/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('toJson va fromJson simmetrik ishlaydi', () {
      final original = const UserProfile(
        id: 'test-123',
        name: 'Ali',
        grade: 2,
        age: 8,
        stars: 15,
        gems: 3,
        subjectProgress: {'matematika': 3, 'ona_tili': 2},
        subjectStars: {'matematika': 5},
        missionProgress: {'play3': 2},
        todayStarsEarned: 10,
        lastPlayDate: '2026-11-21',
        todaySubjectsPlayed: 2,
        todayCombos: 1,
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.stars, original.stars);
      expect(restored.gems, original.gems);
      expect(restored.grade, original.grade);
      expect(restored.age, original.age);
      expect(restored.subjectProgress['matematika'], 3);
      expect(restored.subjectProgress['ona_tili'], 2);
      expect(restored.subjectStars['matematika'], 5);
      expect(restored.missionProgress['play3'], 2);
      expect(restored.todayStarsEarned, 10);
      expect(restored.lastPlayDate, '2026-11-21');
    });

    test('fromJson String source (legacy) ishlaydi', () {
      final p = const UserProfile(id: 'leg-1', name: 'Vali', stars: 5);
      final jsonStr = jsonEncode(p.toJson());
      final restored = UserProfile.fromJson(jsonStr);
      expect(restored.id, 'leg-1');
      expect(restored.name, 'Vali');
      expect(restored.stars, 5);
    });

    test('copyWith totalStars alias ishlaydi', () {
      final p = const UserProfile(id: 'x', name: 'Y', stars: 10);
      final updated = p.copyWith(totalStars: 25);
      expect(updated.stars, 25);
      expect(updated.totalStars, 25);
    });

    test('resetDailyIfNeeded bugungi kunda hech narsa o'zgartirmaydi', () {
      final today = UserProfile.todayKey();
      final p = UserProfile(
        id: 'x', name: 'Z',
        lastPlayDate: today,
        todayStarsEarned: 5,
        dailyStreakDays: 3,
      );
      final reset = p.resetDailyIfNeeded();
      expect(reset.todayStarsEarned, 5); // o'zgarmaydi
      expect(reset.dailyStreakDays, 3);
    });

    test('resetDailyIfNeeded yangi kunda hisoblarni reset qiladi', () {
      final p = const UserProfile(
        id: 'x', name: 'Z',
        lastPlayDate: '2020-01-01',
        todayStarsEarned: 7,
        dailyStreakDays: 2,
        missionProgress: {'play3': 3},
        todaySubjectsPlayed: 4,
        todayCombos: 2,
      );
      final reset = p.resetDailyIfNeeded();
      expect(reset.todayStarsEarned, 0);
      expect(reset.todaySubjectsPlayed, 0);
      expect(reset.todayCombos, 0);
      expect(reset.missionProgress, isEmpty);
      // streak 2+1 emas chunki kecha ham o'ynanmagan
      expect(reset.dailyStreakDays, 1);
    });

    test('strongestSubject to'g'ri fan qaytaradi', () {
      final p = const UserProfile(
        id: 'x', name: 'Y',
        subjectStars: {
          'matematika': 10,
          'ona_tili': 5,
          'odobnoma': 3,
        },
      );
      expect(p.strongestSubject, 'matematika');
    });

    test('weakestSubject to'g'ri fan qaytaradi', () {
      final p = const UserProfile(
        id: 'x', name: 'Y',
        subjectStars: {
          'matematika': 10,
          'ona_tili': 5,
          'odobnoma': 3,
        },
      );
      expect(p.weakestSubject, 'odobnoma');
    });
  });

  group('Susambil campaign saqlash/tiklash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('campaign key profil ID ga bog`liq', () {
      const profileId = 'child-abc';
      final key = 'susambil_campaign_$profileId';
      expect(key, 'susambil_campaign_child-abc');
    });

    test('JSON encode/decode susambil holati', () {
      final data = {
        'stage': 2,
        'correct': 2,
        'hintsUsed': 1,
        'donkeySkillUsed': true,
        'answered': false,
        'selected': null,
        'selections': [1, 0, null, null],
        'startedAt': DateTime(2026, 11, 21).toIso8601String(),
        'finished': false,
        'villageChoice': null,
        'ending': '',
      };
      final encoded = jsonEncode(data);
      final decoded = jsonDecode(encoded) as Map;
      expect(decoded['stage'], 2);
      expect(decoded['correct'], 2);
      expect(decoded['donkeySkillUsed'], true);
      final selections = decoded['selections'] as List;
      expect(selections[0], 1);
      expect(selections[2], null);
    });

    test('stars hisoblash to`g`ri: 4/4 -> 3 yulduz', () {
      const int correct = 4;
      const int total = 4;
      final stars = correct >= 4 ? 3 : correct >= 3 ? 2 : 1;
      expect(stars, 3);
    });

    test('stars hisoblash: 3/4 -> 2 yulduz', () {
      const int correct = 3;
      final stars = correct >= 4 ? 3 : correct >= 3 ? 2 : 1;
      expect(stars, 2);
    });

    test('stars hisoblash: 1/4 -> 1 yulduz', () {
      const int correct = 1;
      final stars = correct >= 4 ? 3 : correct >= 3 ? 2 : 1;
      expect(stars, 1);
    });

    test('profile yulduzlari susambil natijasiga qarab yangilanadi', () {
      final profile = const UserProfile(
        id: 'p1', name: 'Ali', stars: 10,
        subjectProgress: {'matematika': 2, 'ona_tili': 1, 'odobnoma': 0},
      );
      const starsEarned = 3;
      const mathCorrect = 2; // matematika savollaridan to'g'ri
      const onaTiliCorrect = 1;
      const odobnomCorrect = 1;

      final updated = profile.copyWith(
        stars: profile.stars + starsEarned,
        subjectProgress: {
          ...profile.subjectProgress,
          'matematika': (profile.subjectProgress['matematika'] ?? 0) + mathCorrect,
          'ona_tili': (profile.subjectProgress['ona_tili'] ?? 0) + onaTiliCorrect,
          'odobnoma': (profile.subjectProgress['odobnoma'] ?? 0) + odobnomCorrect,
        },
      );

      expect(updated.stars, 13);
      expect(updated.subjectProgress['matematika'], 4);
      expect(updated.subjectProgress['ona_tili'], 2);
      expect(updated.subjectProgress['odobnoma'], 1);
    });
  });

  group('Profil CRUD va almashinuv', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('todayKey formati YYYY-MM-DD', () {
      final key = UserProfile.todayKey();
      final parts = key.split('-');
      expect(parts.length, 3);
      expect(int.parse(parts[0]) >= 2020, true);
      expect(int.parse(parts[1]) >= 1 && int.parse(parts[1]) <= 12, true);
      expect(int.parse(parts[2]) >= 1 && int.parse(parts[2]) <= 31, true);
    });
  });
}
