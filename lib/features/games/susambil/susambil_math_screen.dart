import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/game_stats_service.dart';
import '../../../data/models/user_profile.dart';

/// Phase 9 vertical slice: Susambil — Yo'qolgan buloq.
/// Existing navigation contract is preserved (profile + onUpdate).
/// Robot-mascot artwork is intentionally not recreated or modified here.
class SusambilMathScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const SusambilMathScreen({
    super.key,
    required this.profile,
    this.onUpdate,
  });

  @override
  State<SusambilMathScreen> createState() => _SusambilMathScreenState();
}

class _SusambilMathScreenState extends State<SusambilMathScreen> {
  static const _forest = Color(0xFF245B42);
  static const _cream = Color(0xFFFFF8E9);

  int _stage = 0;
  int _correct = 0;
  int _hintsUsed = 0;
  bool _donkeySkillUsed = false;
  bool _answered = false;
  int? _selected;
  bool _finished = false;
  bool _loadingSave = true;
  String? _villageChoice;
  final List<int?> _stageSelections = List<int?>.filled(4, null);
  String _ending = '';
  DateTime _startedAt = DateTime.now();

  final List<_AdventureStage> _stages = const [
    _AdventureStage(
      title: 'Loyqa so‘qmoq',
      story: 'Yomg‘irdan keyin yo‘l loy bo‘lib qolibdi. Eshak sirpanmasdan o‘tishi uchun xavfsiz toshlarni sanang.',
      warning: 'Ogohlantirish: yo‘lning chetida sirpanchiq loy bor. Faqat belgilangan toshlardan yuring.',
      subject: 'Matematika',
      question: '3 ta tosh bor edi. Yana 4 ta mustahkam tosh topildi. Jami nechta?',
      answers: ['6', '7', '8'],
      correctIndex: 1,
      explanation: '3 + 4 = 7. Yetti toshdan yo‘lcha hosil bo‘ldi.',
      icon: Icons.terrain_rounded,
      companion: 'Eshak yukni sekin ko‘tarib, toshlarni joyiga olib boradi.',
    ),
    _AdventureStage(
      title: 'Eski ko‘prik',
      story: 'Ko‘prikning bir taxtasi yo‘q. Eshak narigi tomonda qolgan do‘stlarga yordam bermoqchi.',
      warning: 'Ogohlantirish: ko‘prikning o‘rtasi bo‘sh. Avval mustahkam taxtani toping.',
      subject: 'Ona tili',
      question: 'Qaysi so‘z to‘g‘ri yozilgan?',
      answers: ['Ko‘prik', 'Koprik', 'Ko‘bрик'],
      correctIndex: 0,
      explanation: '“Ko‘prik” so‘zida o‘ harfi va p tovushi to‘g‘ri yoziladi.',
      icon: Icons.cabin_rounded,
      companion: 'Eshak taxtani ushlab turadi. Siz to‘g‘ri belgini tanlaysiz.',
    ),
    _AdventureStage(
      title: 'Shoshqin suv',
      story: 'Buloqqa eltuvchi ariqda suv ko‘paygan. Oqimni to‘g‘ri yo‘naltirish kerak.',
      warning: 'Ogohlantirish: suv oqimi tez. Avval hisoblang, keyin darvozani oching.',
      subject: 'Matematika',
      question: 'Ariqqa 12 chelak suv keldi. 5 chelagi bog‘ga yo‘naltirildi. Nechta chelak qoldi?',
      answers: ['6', '7', '8'],
      correctIndex: 1,
      explanation: '12 − 5 = 7. Qolgan suv buloq yo‘lini tozalashga yetadi.',
      icon: Icons.water_rounded,
      companion: 'Eshak suv darvozasini ushlab turadi, siz oqim miqdorini belgilaysiz.',
    ),
    _AdventureStage(
      title: 'Susambil ahliga yordam',
      story: 'Qishloq aholisi suvni adolatli taqsimlashni so‘radi. Oxirgi qaror sizniki.',
      warning: 'Tanlov: suvni faqat bir hovliga emas, barcha ehtiyojmandlarga yetkazish kerak.',
      subject: 'Odobnoma',
      question: 'Suv oz bo‘lsa, eng to‘g‘ri yo‘l qaysi?',
      answers: ['Faqat o‘zimga olish', 'Navbat bilan bo‘lishish', 'Boshqalarga bermaslik'],
      correctIndex: 1,
      explanation: 'Suvni navbat bilan va ehtiyojga qarab bo‘lishish — adolatli qaror.',
      icon: Icons.groups_rounded,
      companion: 'Eshak suv idishlarini qishloq bo‘ylab eltishga yordam beradi.',
    ),
  ];

  _AdventureStage get _current => _stages[_stage];
  String get _saveKey => 'susambil_campaign_${widget.profile.id}';

  @override
  void initState() {
    super.initState();
    _restoreCampaign();
  }

  Future<void> _restoreCampaign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_saveKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final data = Map<String, dynamic>.from(decoded);
          final savedSelections = (data['selections'] as List?) ?? const [];
          if (mounted) {
            setState(() {
              _stage = ((data['stage'] as num?)?.toInt() ?? 0).clamp(0, _stages.length - 1).toInt();
              _correct = ((data['correct'] as num?)?.toInt() ?? 0).clamp(0, _stages.length).toInt();
              _hintsUsed = ((data['hintsUsed'] as num?)?.toInt() ?? 0).clamp(0, 1).toInt();
              _donkeySkillUsed = data['donkeySkillUsed'] == true;
              _answered = data['answered'] == true;
              _selected = (data['selected'] as num?)?.toInt();
              _finished = data['finished'] == true;
              _villageChoice = data['villageChoice'] as String?;
              for (var i = 0; i < _stageSelections.length && i < savedSelections.length; i++) {
                final value = savedSelections[i];
                _stageSelections[i] = value is num ? value.toInt() : null;
              }
              final started = DateTime.tryParse(data['startedAt'] as String? ?? '');
              if (started != null) _startedAt = started;
              _ending = data['ending'] as String? ?? '';
            });
          }
        }
      }
    } catch (_) {
      // Saqlangan ma'lumot buzilgan bo'lsa, yangi sarguzasht ochiladi.
    } finally {
      if (mounted) setState(() => _loadingSave = false);
    }
  }

  Future<void> _saveCampaign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode({
      'stage': _stage,
      'correct': _correct,
      'hintsUsed': _hintsUsed,
      'donkeySkillUsed': _donkeySkillUsed,
      'answered': _answered,
      'selected': _selected,
      'selections': _stageSelections,
      'startedAt': _startedAt.toIso8601String(),
      'finished': _finished,
      'villageChoice': _villageChoice,
      'ending': _ending,
    }));
  }

  void _chooseVillagePath(String choice) {
    if (_villageChoice != null) return;
    setState(() => _villageChoice = choice);
    _saveCampaign();
  }

  void _choose(int index) {
    if (_answered || _finished) return;
    setState(() {
      _selected = index;
      _stageSelections[_stage] = index;
      _answered = true;
      if (index == _current.correctIndex) _correct++;
    });
    _saveCampaign();
  }

  void _useCompanionSkill() {
    if (_donkeySkillUsed || _answered) return;
    setState(() {
      _donkeySkillUsed = true;
      _hintsUsed++;
    });
    _saveCampaign();
    _showMessage('Eshakning yordami', _current.companion);
  }

  void _showWarning() => _showMessage('Xavf haqida ogohlantirish', _current.warning);

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tushunarli'))],
      ),
    );
  }

  Future<void> _continue() async {
    if (!_answered) return;
    if (_stage == _stages.length - 1) {
      await _finishAdventure();
      return;
    }
    setState(() {
      _stage++;
      _answered = false;
      _selected = null;
    });
    await _saveCampaign();
  }

  Future<void> _finishAdventure() async {
    if (_finished) return;
    final allSolved = _correct == _stages.length;
    setState(() {
      _finished = true;
      final sharedFairly = _villageChoice == 'adolatli';
      _ending = allSolved && sharedFairly
          ? 'Buloq qayta ochildi! Siz bilim va adolatli tanlov bilan Susambil ahliga yordam berdingiz.'
          : sharedFairly
              ? 'Siz suvni adolatli bo‘lishni tanladingiz. Ayrim sinovlarni yana mashq qilib, buloqni yanada mustahkamlash mumkin.'
              : 'Siz avval o‘z hovlingizni ta’minlashni tanladingiz. Qishloq ahli bilan kelishib, suvni bo‘lishish yo‘lini yana topishingiz mumkin.';
    });
    final stars = _correct >= 4 ? 3 : _correct >= 3 ? 2 : 1;
    final updated = widget.profile.copyWith(
      stars: widget.profile.stars + stars,
      subjectProgress: {
        ...widget.profile.subjectProgress,
        'matematika': (widget.profile.subjectProgress['matematika'] ?? 0) +
            _stages.asMap().entries.where((e) => e.value.subject == 'Matematika' && _stageSelections[e.key] == e.value.correctIndex).length,
        'ona_tili': (widget.profile.subjectProgress['ona_tili'] ?? 0) +
            (_stageSelections[1] == _stages[1].correctIndex ? 1 : 0),
        'odobnoma': (widget.profile.subjectProgress['odobnoma'] ?? 0) +
            (_stageSelections[3] == _stages[3].correctIndex ? 1 : 0),
      },
    );
    widget.onUpdate?.call(updated);
    await _saveCampaign();

    // Phase 9.2: Susambil natijasi umumiy statistika xizmatiga yoziladi.
    await GameStatsService.instance.record(
      widget.profile.id,
      GameResult(
        gameId: 'susambil',
        subject: 'Aralash fanlar',
        stars: stars,
        score: _correct,
        maxScore: _stages.length,
        durationSeconds: DateTime.now().difference(_startedAt).inSeconds,
        playedAt: DateTime.now(),
      ),
    );
  }


  void _restart() {
    setState(() {
      _stage = 0;
      _correct = 0;
      _hintsUsed = 0;
      _donkeySkillUsed = false;
      _answered = false;
      _selected = null;
      _finished = false;
      _villageChoice = null;
      for (var i = 0; i < _stageSelections.length; i++) { _stageSelections[i] = null; }
      _ending = '';
      _startedAt = DateTime.now();
    });
    _saveCampaign();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _forest,
        foregroundColor: Colors.white,
        title: const Text('Susambil: Yo‘qolgan buloq'),
        actions: [IconButton(tooltip: 'Xavf haqida', onPressed: _showWarning, icon: const Icon(Icons.warning_amber_rounded))],
      ),
      body: SafeArea(
        child: _loadingSave
            ? const Center(child: CircularProgressIndicator())
            : _finished ? _buildEnding() : _buildAdventure(),
      ),
    );
  }

  Widget _buildAdventure() {
    final stage = _current;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProgress(),
        const SizedBox(height: 14),
        _buildScene(stage),
        const SizedBox(height: 14),
        Text(stage.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: _forest)),
        const SizedBox(height: 8),
        Text(stage.story, style: const TextStyle(fontSize: 16, height: 1.4)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFFE7B0), borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.visibility_rounded, color: Color(0xFF8A5713)),
            const SizedBox(width: 8),
            Expanded(child: Text(stage.warning, style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _forest, borderRadius: BorderRadius.circular(20)), child: Text(stage.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Spacer(),
          Text('Topilgan yulduz: $_correct', style: const TextStyle(fontWeight: FontWeight.bold, color: _forest)),
        ]),
        const SizedBox(height: 10),
        if (_stage == _stages.length - 1 && _villageChoice == null) ...[
          const Text('Qishloq ahli sizdan maslahat so‘rayapti. Qaysi yo‘lni tanlaysiz?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => _chooseVillagePath('adolatli'), child: const Text('Suvni navbat va ehtiyojga qarab bo‘lishish')),
          OutlinedButton(onPressed: () => _chooseVillagePath('avval_ozim'), child: const Text('Avval o‘z hovlimni ta’minlash')),
          const SizedBox(height: 8),
        ] else if (_stage == _stages.length - 1) ...[
          Text(_villageChoice == 'adolatli' ? 'Tanlovingiz: suvni adolatli bo‘lishish.' : 'Tanlovingiz: avval o‘z hovlingizni ta’minlash.', style: const TextStyle(color: _forest, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        Text(stage.question, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate(stage.answers.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _answerButton(i),
        )),
        if (_answered) ...[
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _selected == stage.correctIndex ? const Color(0xFFDDF2DF) : const Color(0xFFFFE4DF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${_selected == stage.correctIndex ? 'To‘g‘ri!' : 'Bu safar to‘g‘ri kelmadi.'} ${stage.explanation}',
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _forest, minimumSize: const Size.fromHeight(50)),
            onPressed: _continue,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(_stage == _stages.length - 1 ? 'Sarguzasht yakuni' : 'Davom etish'),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _donkeySkillUsed ? null : _useCompanionSkill,
            icon: const Icon(Icons.pets_rounded),
            label: Text(_donkeySkillUsed ? 'Eshak yordami ishlatildi' : 'Eshak yordam bersin'),
          ),
          TextButton.icon(onPressed: _showWarning, icon: const Icon(Icons.info_outline), label: const Text('Xavfsizlik qoidasini ko‘rish')),
        ],
      ],
    );
  }

  Widget _buildProgress() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Buloqqa eltuvchi yo‘l', style: TextStyle(fontWeight: FontWeight.bold, color: _forest)),
        Text('${_stage + 1}/${_stages.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 7),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (_stage + (_answered ? 1 : 0)) / _stages.length, minHeight: 9, backgroundColor: const Color(0xFFD9E4D8), color: _forest)),
    ]);
  }

  Widget _buildScene(_AdventureStage stage) {
    return Container(
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB7D9D1), Color(0xFF78A878)]),
      ),
      child: Stack(children: [
        Positioned(left: 18, bottom: 15, child: Icon(stage.icon, size: 82, color: _forest.withOpacity(.8))),
        const Positioned(right: 18, bottom: 16, child: Icon(Icons.water_drop_rounded, size: 54, color: Color(0xFF2B91C7))),
        const Positioned(left: 118, bottom: 16, child: Icon(Icons.pets_rounded, size: 58, color: Color(0xFF795548))),
        Positioned(top: 12, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.85), borderRadius: BorderRadius.circular(20)), child: const Text('SUSAMBIL', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w900, color: _forest)))),
      ]),
    );
  }

  Widget _answerButton(int index) {
    final selected = _selected == index;
    final isCorrect = index == _current.correctIndex;
    Color color = Colors.white;
    if (_answered && isCorrect) color = const Color(0xFFDDF2DF);
    if (_answered && selected && !isCorrect) color = const Color(0xFFFFE4DF);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: (_answered || (_stage == _stages.length - 1 && _villageChoice == null)) ? null : () => _choose(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? _forest : const Color(0xFFD8DCCF), width: selected ? 2 : 1)),
          child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: _forest, child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(child: Text('${_current.answers[index]}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
            if (_answered && isCorrect) const Icon(Icons.check_circle, color: _forest),
            if (_answered && selected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent),
          ]),
        ),
      ),
    );
  }

  Widget _buildEnding() {
    final success = _correct == _stages.length && _villageChoice == 'adolatli';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(success ? Icons.water_drop_rounded : Icons.nature_people_rounded, size: 82, color: _forest),
          const SizedBox(height: 14),
          Text(success ? 'Buloq qayta ochildi!' : 'Susambil sizni kutadi!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: _forest)),
          const SizedBox(height: 12),
          Text(_ending, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.45)),
          const SizedBox(height: 18),
          Text('To‘g‘ri javoblar: $_correct/${_stages.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Ishlatilgan yordam: $_hintsUsed', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _forest, minimumSize: const Size.fromHeight(50)), onPressed: _restart, icon: const Icon(Icons.replay), label: const Text('Qayta o‘ynash')),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('O‘yinlar ro‘yxatiga qaytish')),
        ]),
      ),
    );
  }
}

class _AdventureStage {
  final String title;
  final String story;
  final String warning;
  final String subject;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String explanation;
  final IconData icon;
  final String companion;

  const _AdventureStage({
    required this.title,
    required this.story,
    required this.warning,
    required this.subject,
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
    required this.icon,
    required this.companion,
  });
}
