import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ovoz effektlari utility
/// assets/sounds/ papkasidagi mp3 fayllarni ishlatadi.
///
/// Fayllar:
///   correct.mp3  — to'g'ri javob (ding! yoki "Bravo!")
///   wrong.mp3    — xato javob (buuu!)
///   combo.mp3    — combo x2 (fanfara)
///   win.mp3      — o'yin tugadi g'alaba (katta fanfara)
///   click.mp3    — tugma bosildi (klik)
///   coin.mp3     — yulduz/tangа (ching!)
///
/// Haqiqiy MP3 fayllarni qo'shish uchun:
///   assets/sounds/ papkasiga fayl soling va flutter pub get bajaring.
///   Tavsiya etilgan manba: freesound.org (CC0 litsenziya)
class SoundUtils {
  static bool _soundOn = true;
  static bool _loaded = false;

  // AudioPlayer larni pool sifatida ishlatamiz (bir vaqtda bir nechta ovoz)
  static final _pool = <AudioPlayer>[];
  static const _poolSize = 4;

  static Future<void> _init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _soundOn = prefs.getBool('sound_on') ?? true;
    _loaded = true;
    // Pool yaratish
    for (var i = 0; i < _poolSize; i++) {
      _pool.add(AudioPlayer());
    }
  }

  static Future<void> _play(String assetName) async {
    await _init();
    if (!_soundOn) return;
    try {
      // Bo'sh player topamiz
      AudioPlayer? player;
      for (final p in _pool) {
        if (p.state != PlayerState.playing) {
          player = p;
          break;
        }
      }
      // Hammasi band bo'lsa yangi player
      player ??= AudioPlayer();
      await player.play(
        AssetSource('sounds/$assetName'),
        volume: 0.8,
      );
    } catch (_) {
      // Ovoz fayli yo'q bo'lsa yoki xato bo'lsa — sukut saqlaymiz
    }
  }

  /// To'g'ri javob
  static Future<void> correct() => _play('correct.mp3');

  /// Xato javob
  static Future<void> wrong() => _play('wrong.mp3');

  /// Combo x2
  static Future<void> combo() => _play('combo.mp3');

  /// O'yin tugadi (g'alaba)
  static Future<void> win() => _play('win.mp3');

  /// Tugma bosildi
  static Future<void> click() => _play('click.mp3');

  /// Yulduz/tangа topildi
  static Future<void> coin() => _play('coin.mp3');

  /// Settings dan sound toggle o'zganda chaqiriladi
  static void invalidateCache() {
    _loaded = false;
    // Poolni tozalaymiz
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
  }
}
