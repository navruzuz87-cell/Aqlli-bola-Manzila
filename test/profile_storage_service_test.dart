import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:manzila_aqlli_bola/core/services/profile_storage_service.dart';
import 'package:manzila_aqlli_bola/data/models/user_profile.dart';

void main() {
  final storage = ProfileStorageService.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  UserProfile makeProfile(String id, String name) => UserProfile(
        id: id,
        name: name,
        grade: 2,
        age: 8,
      );

  test('active profile remains selected when app data is reloaded', () async {
    final first = makeProfile('child-1', 'Ali');
    final second = makeProfile('child-2', 'Vali');

    await storage.selectProfile(first);
    await storage.selectProfile(second);

    final active = await storage.loadActiveProfile();
    expect(active?.id, 'child-2');

    final updated = second.copyWith(stars: 25);
    await storage.updateProfile(updated);

    final profiles = await storage.loadProfiles();
    expect(profiles.length, 2);
    expect(profiles.firstWhere((p) => p.id == 'child-2').stars, 25);
    expect((await storage.loadActiveProfile())?.id, 'child-2');
  });

  test('legacy single profile is migrated into profile collection', () async {
    final legacy = makeProfile('legacy-1', 'Old profile');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(legacy.toJson()));

    final active = await storage.loadActiveProfile();
    expect(active?.id, 'legacy-1');

    final profiles = await storage.loadProfiles();
    expect(profiles.map((p) => p.id), contains('legacy-1'));
  });

  test('deleting active profile selects a remaining profile', () async {
    final first = makeProfile('child-1', 'Ali');
    final second = makeProfile('child-2', 'Vali');
    await storage.selectProfile(first);
    await storage.selectProfile(second);

    await storage.deleteProfile('child-2');

    expect((await storage.loadActiveProfile())?.id, 'child-1');
    expect((await storage.loadProfiles()).length, 1);
  });
}
