import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';

/// Barcha bolalar profillarini va faol profilni yagona joyda saqlaydi.
/// Eski `user_profile` kalitidan avtomatik migratsiyani ham qo'llab-quvvatlaydi.
class ProfileStorageService {
  ProfileStorageService._();
  static final instance = ProfileStorageService._();

  static const String _profilesKey = 'all_profiles';
  static const String _activeIdKey = 'active_profile_id';
  static const String _legacyProfileKey = 'user_profile';

  Future<List<UserProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final profiles = decoded
              .whereType<Map>()
              .map((item) => UserProfile.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
          if (profiles.isNotEmpty) return profiles;
        }
      } catch (_) {
        // Buzilgan ro'yxat eski bitta profilni tiklashga to'sqinlik qilmasin.
      }
    }

    final legacyRaw = prefs.getString(_legacyProfileKey);
    if (legacyRaw == null || legacyRaw.isEmpty) return [];

    try {
      final legacy = UserProfile.fromJson(legacyRaw);
      await saveProfiles([legacy]);
      await prefs.setString(_activeIdKey, legacy.id);
      return [legacy];
    } catch (_) {
      return [];
    }
  }

  Future<UserProfile?> loadActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await loadProfiles();
    if (profiles.isEmpty) return null;

    final activeId = prefs.getString(_activeIdKey);
    UserProfile selected;
    try {
      selected = profiles.firstWhere((p) => p.id == activeId);
    } catch (_) {
      selected = profiles.first;
    }

    await prefs.setString(_activeIdKey, selected.id);
    await prefs.setString(_legacyProfileKey, jsonEncode(selected.toJson()));
    return selected;
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );

    if (profiles.isEmpty) {
      await prefs.remove(_activeIdKey);
      await prefs.remove(_legacyProfileKey);
      return;
    }

    final currentId = prefs.getString(_activeIdKey);
    UserProfile active;
    try {
      active = profiles.firstWhere((p) => p.id == currentId);
    } catch (_) {
      active = profiles.first;
      await prefs.setString(_activeIdKey, active.id);
    }
    await prefs.setString(_legacyProfileKey, jsonEncode(active.toJson()));
  }

  Future<void> selectProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index < 0) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await prefs.setString(_activeIdKey, profile.id);
    await prefs.setString(_legacyProfileKey, jsonEncode(profile.toJson()));
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index < 0) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );

    final activeId = prefs.getString(_activeIdKey);
    if (activeId == null || activeId == profile.id) {
      await prefs.setString(_activeIdKey, profile.id);
      await prefs.setString(_legacyProfileKey, jsonEncode(profile.toJson()));
    }
  }

  Future<void> deleteProfile(String profileId) async {
    final profiles = await loadProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    await saveProfiles(profiles);
  }
}
