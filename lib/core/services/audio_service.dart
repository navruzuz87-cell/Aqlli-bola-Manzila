import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AudioService — audioplayers ^6.1.0 API bilan
/// Singleton pattern, ChangeNotifier
class AudioService extends ChangeNotifier {
  AudioService._();
  static final instance = AudioService._();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  bool _soundOn = true;
  bool _musicOn = true;

  bool get soundOn => _soundOn;
  bool get musicOn => _musicOn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundOn = prefs.getBool('sound_on') ?? true;
    _musicOn = prefs.getBool('music_on') ?? true;
  }

  Future<void> playCorrect() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/correct.mp3'));
    } catch (_) {}
  }

  Future<void> playWrong() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/wrong.mp3'));
    } catch (_) {}
  }

  Future<void> playStar() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/star.mp3'));
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/click.mp3'));
    } catch (_) {}
  }

  Future<void> playCombo() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/combo.mp3'));
    } catch (_) {}
  }

  Future<void> playVictory() async {
    if (!_soundOn) return;
    try {
      await _sfx.play(AssetSource('sounds/victory.mp3'));
    } catch (_) {}
  }

  Future<void> playBgMusic(String asset) async {
    if (!_musicOn) return;
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> setSoundOn(bool val) async {
    _soundOn = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_on', val);
    if (!val) await _sfx.stop();
    notifyListeners();
  }

  Future<void> setMusicOn(bool val) async {
    _musicOn = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_on', val);
    if (!val) await _music.stop();
    notifyListeners();
  }

  SharedPreferences? _cachedPrefs;
  Future<SharedPreferences> getPrefs() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }
}

// MusicTrack enum - home_screen.dart va boshqa joylar uchun
enum MusicTrack { home, game, city }

// SfxSound enum - barcha game screenlar uchun
enum SfxSound {
  correct,
  wrong,
  buttonTap,
  starEarn,
  coinEarn,
  victory,
  levelUp,
}

extension AudioServiceSfx on AudioService {
  Future<void> playSfx(SfxSound sound) async {
    switch (sound) {
      case SfxSound.correct:
        await playCorrect();
      case SfxSound.wrong:
        await playWrong();
      case SfxSound.buttonTap:
        await playClick();
      case SfxSound.starEarn:
        await playStar();
      case SfxSound.coinEarn:
        await playStar(); // coin earn uchun star sound
      case SfxSound.victory:
        await playVictory();
      case SfxSound.levelUp:
        await playCombo(); // levelUp uchun combo sound
    }
  }
}

extension AudioServiceMusic on AudioService {
  Future<void> playMusic(MusicTrack track) async {
    final asset = switch (track) {
      MusicTrack.home => 'sounds/bg_home.mp3',
      MusicTrack.game => 'sounds/bg_game.mp3',
      MusicTrack.city => 'sounds/bg_city.mp3',
    };
    await playBgMusic(asset);
  }
}
