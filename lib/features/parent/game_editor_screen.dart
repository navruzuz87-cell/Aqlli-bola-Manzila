import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/story_character_catalog.dart';
import '../../core/services/parental_service.dart';
import '../../core/services/game_config_service.dart';

/// Ota-ona/administrator uchun mahalliy Game Editor.
/// Sozlamalar SharedPreferences'da saqlanadi; server/CMS bilan sinxronlash
/// keyingi backend bosqichida qo'shiladi.
class GameEditorScreen extends StatefulWidget {
  const GameEditorScreen({super.key});

  @override
  State<GameEditorScreen> createState() => _GameEditorScreenState();
}

class _GameEditorScreenState extends State<GameEditorScreen> {
  static const _storageKey = 'manzila_game_editor_configs_v1';
  static const _games = <_GameDefinition>[
    _GameDefinition('alpomish_runner', 'Alpomish Runner', '🏃', 'So‘z yig‘ish, sakrash va to‘siqlardan o‘tish'),
    _GameDefinition('math_blocks', 'Al-Xorazmiy bloklari', '🧮', 'Matematik misollar va bloklarni joylashtirish'),
    _GameDefinition('susambil', 'Susambildagi Eshak', '🫏', 'Matematika va yo‘l topish'),
    _GameDefinition('zumrad', 'Zumrad va Qimmat', '💎', 'Ona tili va ertak tanlovlari'),
    _GameDefinition('shiroq', 'Shiroq', '🏹', 'Tarixiy qarorlar va strategiya'),
    _GameDefinition('tomiris', 'Tomiris', '🛡️', 'Strategiya va tarix'),
  ];

  final Map<String, _GameConfig> _configs = {};
  String _selectedId = _games.first.id;
  bool _loading = true;
  bool _saving = false;
  bool _authorized = false;
  final TextEditingController _pinController = TextEditingController();
  String? _status;

  _GameConfig get _current => _configs[_selectedId]!;

  @override
  void initState() {
    super.initState();
    _authorized = !ParentalService.instance.settings.isEnabled;
    _load();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final game in _games) {
          final value = decoded[game.id];
          _configs[game.id] = value is Map<String, dynamic>
              ? _GameConfig.fromJson(value)
              : _GameConfig.defaults(game.id);
        }
      } catch (_) {
        for (final game in _games) {
          _configs[game.id] = _GameConfig.defaults(game.id);
        }
        _status = 'Saqlangan sozlamalar formati eskirgan. Standart sozlamalar yuklandi.';
      }
    } else {
      for (final game in _games) {
        _configs[game.id] = _GameConfig.defaults(game.id);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _update(_GameConfig value) {
    setState(() => _configs[_selectedId] = value);
  }

  Future<void> _save() async {
    setState(() { _saving = true; _status = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = <String, dynamic>{
        for (final entry in _configs.entries) entry.key: entry.value.toJson(),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
      GameConfigService.instance.invalidate();
      if (mounted) setState(() => _status = 'Sozlamalar ushbu qurilmada saqlandi.');
    } catch (error) {
      if (mounted) setState(() => _status = 'Saqlashda xato: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetCurrent() async {
    setState(() => _configs[_selectedId] = _GameConfig.defaults(_selectedId));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FC),
      appBar: AppBar(
        title: const Text('Manzila Game Editor', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF172B55),
        foregroundColor: Colors.white,
      ),
      body: !_authorized
          ? _pinGate()
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _introCard(),
                const SizedBox(height: 14),
                _sectionCard(title: 'Qahramonlar katalogi', child: _characterCatalog()),
                const SizedBox(height: 12),
                _sectionCard(
                  title: 'O‘yin tanlash',
                  child: DropdownButtonFormField<String>(
                    value: _selectedId,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Tahrir qilinadigan o‘yin'),
                    items: _games.map((game) => DropdownMenuItem(
                      value: game.id,
                      child: Text('${game.emoji}  ${game.title}', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (value) => setState(() { if (value != null) _selectedId = value; }),
                  ),
                ),
                const SizedBox(height: 12),
                _sectionCard(title: 'O‘yin qoidalari', child: _settingsFields()),
                const SizedBox(height: 12),
                _sectionCard(title: 'Qahramon va hikoya', child: _storyFields()),
                const SizedBox(height: 12),
                _sectionCard(title: 'Yosh va ta’lim sozlamalari', child: _learningFields()),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE5F5EC), borderRadius: BorderRadius.circular(12)),
                    child: Text(_status!, style: const TextStyle(color: Color(0xFF176B43), fontWeight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _resetCurrent, icon: const Icon(Icons.restart_alt), label: const Text('Standartga qaytarish'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                    label: Text(_saving ? 'Saqlanmoqda' : 'Barcha sozlamalarni saqlash'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF176BBA), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  )),
                ]),
                const SizedBox(height: 20),
                const Text('Eslatma: ushbu muharrir hozircha qurilmaning o‘zida saqlaydi. O‘yin ichidagi barcha qoidalarni avtomatik o‘zgartirish uchun keyingi bosqichda har bir o‘yin konfiguratsiyaga ulanishi va server CMS yaratilishi kerak.', style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4)),
              ],
            ),
    );
  }

  Widget _pinGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 54, color: Color(0xFF176BBA)),
            const SizedBox(height: 12),
            const Text('Game Editor — ota-ona ruxsati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Ota-ona PIN kodi', border: OutlineInputBorder(), counterText: ''),
              onSubmitted: (_) => _unlockEditor(),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _unlockEditor, child: const Text('Kirish'))),
            if (_status != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_status!, style: const TextStyle(color: Colors.red))),
          ]),
        ),
      ),
    );
  }

  void _unlockEditor() {
    if (ParentalService.instance.verifyPin(_pinController.text)) {
      setState(() { _authorized = true; _status = null; });
    } else {
      setState(() => _status = 'PIN kodi noto‘g‘ri.');
      _pinController.clear();
    }
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF173B76), Color(0xFF146C78)]),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('🛠️  O‘yinlarni boshqarish markazi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      SizedBox(height: 7),
      Text('Qiyinlik, tezlik, mukofot, yosh oralig‘i va hikoya matnlarini shu yerdan sozlang.', style: TextStyle(color: Colors.white70, height: 1.4)),
    ]),
  );

  Widget _sectionCard({required String title, required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1C2C50))),
      const SizedBox(height: 14),
      child,
    ]),
  );

  Widget _characterCatalog() {
    return Column(children: StoryCharacterCatalog.characters.map((character) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF3F6FC), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(character.name, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1C2C50))),
          Text(character.role, style: const TextStyle(color: Color(0xFF176BBA), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('Xarakter: ${character.personality}', style: const TextStyle(fontSize: 12)),
          Text('O‘yin: ${character.gameStyle}', style: const TextStyle(fontSize: 12)),
          Text('Ta’limiy maqsad: ${character.learningGoal}', style: const TextStyle(fontSize: 12)),
          Text('Ibora: “${character.signatureLine}”', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ]),
      ),
    )).toList());
  }

  Widget _settingsFields() {
    final c = _current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('O‘yin faol'), value: c.enabled, onChanged: (v) => _update(c.copyWith(enabled: v))),
      _slider('O‘yin tezligi', c.speed, 0.5, 2.0, (v) => _update(c.copyWith(speed: v)), suffix: 'x'),
      _slider('Bosqichdagi savollar', c.questionCount.toDouble(), 3, 20, (v) => _update(c.copyWith(questionCount: v.round())), divisions: 17),
      _slider('Mukofot yulduzlari', c.rewardStars.toDouble(), 1, 5, (v) => _update(c.copyWith(rewardStars: v.round())), divisions: 4),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Robot yordamini ko‘rsatish'), value: c.robotHints, onChanged: (v) => _update(c.copyWith(robotHints: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Vaqt cheklovi'), value: c.timerEnabled, onChanged: (v) => _update(c.copyWith(timerEnabled: v))),
      if (c.timerEnabled) _slider('Vaqt', c.timeLimitSeconds.toDouble(), 20, 180, (v) => _update(c.copyWith(timeLimitSeconds: v.round())), suffix: ' soniya', divisions: 16),
    ]);
  }

  Widget _storyFields() {
    final c = _current;
    return Column(children: [
      TextFormField(key: ValueKey('${c.id}_hero'), initialValue: c.heroName, decoration: const InputDecoration(labelText: 'Asosiy qahramon', border: OutlineInputBorder()), onChanged: (v) => _update(c.copyWith(heroName: v))),
      const SizedBox(height: 10),
      TextFormField(key: ValueKey('${c.id}_companion'), initialValue: c.companionName, decoration: const InputDecoration(labelText: 'Ikkinchi qahramon', border: OutlineInputBorder()), onChanged: (v) => _update(c.copyWith(companionName: v))),
      const SizedBox(height: 10),
      TextFormField(key: ValueKey('${c.id}_title'), initialValue: c.missionTitle, decoration: const InputDecoration(labelText: 'Sarguzasht nomi', border: OutlineInputBorder()), onChanged: (v) => _update(c.copyWith(missionTitle: v))),
      const SizedBox(height: 10),
      TextFormField(key: ValueKey('${c.id}_description'), initialValue: c.missionDescription, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Hikoya va topshiriq', border: OutlineInputBorder()), onChanged: (v) => _update(c.copyWith(missionDescription: v))),
    ]);
  }

  Widget _learningFields() {
    final c = _current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Yosh oralig‘i: ${c.minAge}–${c.maxAge} yosh', style: const TextStyle(fontWeight: FontWeight.w700)),
      RangeSlider(values: RangeValues(c.minAge.toDouble(), c.maxAge.toDouble()), min: 5, max: 12, divisions: 7, labels: RangeLabels('${c.minAge}', '${c.maxAge}'), onChanged: (v) => _update(c.copyWith(minAge: v.start.round(), maxAge: v.end.round()))),
      DropdownButtonFormField<String>(value: c.difficulty, decoration: const InputDecoration(labelText: 'Boshlang‘ich qiyinlik', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'easy', child: Text('Oson')), DropdownMenuItem(value: 'normal', child: Text('O‘rta')), DropdownMenuItem(value: 'hard', child: Text('Murakkab'))], onChanged: (v) { if (v != null) _update(c.copyWith(difficulty: v)); }),
    ]);
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged, {String suffix = '', int? divisions}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}$suffix', style: const TextStyle(color: Color(0xFF176BBA), fontWeight: FontWeight.w900))]),
    Slider(value: value.clamp(min, max).toDouble(), min: min, max: max, divisions: divisions, onChanged: onChanged),
  ]);
}

class _GameDefinition {
  final String id, title, emoji, description;
  const _GameDefinition(this.id, this.title, this.emoji, this.description);
}

class _GameConfig {
  final String id, difficulty, heroName, companionName, missionTitle, missionDescription;
  final bool enabled, robotHints, timerEnabled;
  final double speed;
  final int questionCount, rewardStars, timeLimitSeconds, minAge, maxAge;

  const _GameConfig({required this.id, required this.difficulty, required this.heroName, required this.companionName, required this.missionTitle, required this.missionDescription, required this.enabled, required this.robotHints, required this.timerEnabled, required this.speed, required this.questionCount, required this.rewardStars, required this.timeLimitSeconds, required this.minAge, required this.maxAge});

  factory _GameConfig.defaults(String id) {
    final defaults = <String, List<String>>{
      'alpomish_runner': ['Alpomish', 'Barchinoy', 'Yo‘qolgan so‘zlarni top!'],
      'math_blocks': ['Al-Xorazmiy', 'Shogird', 'Ilm bloklarini joylashtir!'],
      'susambil': ['Eshak', 'Susambil ahli', 'Susambilga yetib bor!'],
      'zumrad': ['Zumrad', 'Qimmat', 'Sehrli sandiqni och!'],
      'shiroq': ['Shiroq', 'Vatan', 'Elni himoya qil!'],
      'tomiris': ['Tomiris', 'Saklar', 'Yurtni himoya qil!'],
    }[id]!;
    return _GameConfig(id: id, difficulty: 'normal', heroName: defaults[0], companionName: defaults[1], missionTitle: defaults[2], missionDescription: 'Topshiriqlarni bajaring, bilimni mustahkamlang va qahramonga yordam bering.', enabled: true, robotHints: true, timerEnabled: false, speed: 1, questionCount: 8, rewardStars: 3, timeLimitSeconds: 60, minAge: 5, maxAge: 12);
  }

  factory _GameConfig.fromJson(Map<String, dynamic> j) => _GameConfig(
    id: j['id'] as String, difficulty: j['difficulty'] as String? ?? 'normal', heroName: j['heroName'] as String? ?? '', companionName: j['companionName'] as String? ?? '', missionTitle: j['missionTitle'] as String? ?? '', missionDescription: j['missionDescription'] as String? ?? '', enabled: j['enabled'] as bool? ?? true, robotHints: j['robotHints'] as bool? ?? true, timerEnabled: j['timerEnabled'] as bool? ?? false, speed: (j['speed'] as num?)?.toDouble() ?? 1, questionCount: j['questionCount'] as int? ?? 8, rewardStars: j['rewardStars'] as int? ?? 3, timeLimitSeconds: j['timeLimitSeconds'] as int? ?? 60, minAge: j['minAge'] as int? ?? 5, maxAge: j['maxAge'] as int? ?? 12,
  );

  Map<String, dynamic> toJson() => {'id': id, 'difficulty': difficulty, 'heroName': heroName, 'companionName': companionName, 'missionTitle': missionTitle, 'missionDescription': missionDescription, 'enabled': enabled, 'robotHints': robotHints, 'timerEnabled': timerEnabled, 'speed': speed, 'questionCount': questionCount, 'rewardStars': rewardStars, 'timeLimitSeconds': timeLimitSeconds, 'minAge': minAge, 'maxAge': maxAge};

  _GameConfig copyWith({String? difficulty, String? heroName, String? companionName, String? missionTitle, String? missionDescription, bool? enabled, bool? robotHints, bool? timerEnabled, double? speed, int? questionCount, int? rewardStars, int? timeLimitSeconds, int? minAge, int? maxAge}) => _GameConfig(
    id: id, difficulty: difficulty ?? this.difficulty, heroName: heroName ?? this.heroName, companionName: companionName ?? this.companionName, missionTitle: missionTitle ?? this.missionTitle, missionDescription: missionDescription ?? this.missionDescription, enabled: enabled ?? this.enabled, robotHints: robotHints ?? this.robotHints, timerEnabled: timerEnabled ?? this.timerEnabled, speed: speed ?? this.speed, questionCount: questionCount ?? this.questionCount, rewardStars: rewardStars ?? this.rewardStars, timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds, minAge: minAge ?? this.minAge, maxAge: maxAge ?? this.maxAge,
  );
}
