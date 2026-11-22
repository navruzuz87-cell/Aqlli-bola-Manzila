import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O'yin uchun haptic feedback yordamchi funksiyalar
class HapticUtils {
  static bool _hapticOn = true;
  static bool _loaded = false;

  static Future<void> _load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _hapticOn = prefs.getBool('haptic_on') ?? true;
    _loaded = true;
  }

  /// To'g'ri javob — qisqa ijobiy tebranish
  static Future<void> correct() async {
    await _load();
    if (!_hapticOn) return;
    HapticFeedback.lightImpact();
  }

  /// Xato javob — kuchli tebranish
  static Future<void> wrong() async {
    await _load();
    if (!_hapticOn) return;
    HapticFeedback.heavyImpact();
  }

  /// Combo yutish — ikki marta tebranish
  static Future<void> combo() async {
    await _load();
    if (!_hapticOn) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  /// O'yin tugashi — uch marta tebranish
  static Future<void> gameComplete() async {
    await _load();
    if (!_hapticOn) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.lightImpact();
  }

  /// Tugma bosilganda — oddiy tebranish
  static Future<void> tap() async {
    await _load();
    if (!_hapticOn) return;
    HapticFeedback.selectionClick();
  }

  /// Kesh tozalash (sozlamalar o'zgarsa)
  static void invalidateCache() => _loaded = false;
}
