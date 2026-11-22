import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/services/game_config_service.dart';
import '../../../core/services/game_stats_service.dart';

/// Al-Xorazmiy matematik bloklari: misolni yechib, javob blokini taxtaga joylash.
class MathBlocksScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;
  const MathBlocksScreen({super.key, required this.profile, this.onUpdate});
  @override
  State<MathBlocksScreen> createState() => _MathBlocksScreenState();
}

class _MathBlocksScreenState extends State<MathBlocksScreen> {
  static const _palette = [Color(0xFF2878D0), Color(0xFF8B5CC7), Color(0xFF16A085), Color(0xFFE69A24), Color(0xFFE45D70)];
  final _random = Random();
  late List<List<int>> _board;
  late int _a, _b, _answer;
  late String _operation;
  late List<int> _options;
  int? _selected;
  int _score = 0, _streak = 0, _lives = 3, _level = 1, _solved = 0, _starsEarned = 0;
  bool _finished = false;
  bool _configReady = false;
  int _remainingSeconds = 0;
  Timer? _sessionTimer;
  GameConfigData _config = GameConfigData.defaults('math_blocks');
  String _feedback = 'To‘g‘ri javobni tanlang.';
  DateTime _sessionStartedAt = DateTime.now();
  bool _statsRecorded = false;

  @override
  void initState() { super.initState(); _newBoard(); _newQuestion(); _loadConfig(); }

  Future<void> _loadConfig() async {
    final loaded = await GameConfigService.instance.load('math_blocks');
    if (!mounted) return;
    setState(() {
      _config = loaded;
      _configReady = true;
      _remainingSeconds = loaded.timeLimitSeconds;
      _newQuestion();
      if (!loaded.enabled || !loaded.isSuitableForAge(widget.profile.age)) {
        _finished = true;
        _feedback = !loaded.enabled ? 'Bu o‘yin hozircha yopiq.' : 'Bu bosqich ${loaded.minAge}–${loaded.maxAge} yosh uchun mo‘ljallangan.';
      }
    });
    if (loaded.enabled && loaded.isSuitableForAge(widget.profile.age) && loaded.timerEnabled) _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _finished) { timer.cancel(); return; }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() { _remainingSeconds = 0; _finished = true; });
        _awardStars();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _endSession() {
    if (_finished) return;
    setState(() => _finished = true);
    _sessionTimer?.cancel();
    _awardStars();
  }

  @override
  void dispose() { _sessionTimer?.cancel(); super.dispose(); }

  Future<void> _showEquationPuzzle() async {
    if (_finished || !_configReady || !_config.enabled) return;
    final labels = <String>[_a.toString(), _operation, _b.toString(), _answer.toString()];
    final placed = List<int?>.filled(4, null);
    final order = <int>[0, 1, 2, 3]..shuffle(_random);
    var completed = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !completed,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: const Color(0xFF202F59),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('2×2 tenglamani yig‘ing',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Har bir plitkani mos katakka sudrab joylashtiring.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.35,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, slot) => DragTarget<int>(
                      onWillAccept: (token) => token == slot && placed[slot] == null,
                      onAccept: (token) {
                        dialogSetState(() {
                          placed[slot] = token;
                          completed = placed.asMap().entries.every(
                              (entry) => entry.value == entry.key);
                        });
                      },
                      builder: (context, candidates, rejected) {
                        final accepted = placed[slot] == slot;
                        final slotNames = ['1-son', 'Amal', '2-son', 'Javob'];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: accepted
                                ? const Color(0xFF168F78)
                                : const Color(0xFF304574),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: candidates.isNotEmpty
                                  ? const Color(0xFFFFD166)
                                  : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(slotNames[slot],
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 5),
                              Text(accepted ? labels[slot] : '＋',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: order.where((token) => placed[token] == null).map((token) {
                    return Draggable<int>(
                      data: token,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _equationTile(labels[token]),
                      ),
                      childWhenDragging: Opacity(
                        opacity: .25,
                        child: _equationTile(labels[token]),
                      ),
                      child: _equationTile(labels[token]),
                    );
                  }).toList(),
                ),
                if (completed) ...[
                  const SizedBox(height: 12),
                  const Text('To‘g‘ri! Tenglama yig‘ildi. +15 ball',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFFFD166), fontWeight: FontWeight.w900)),
                ],
              ],
            ),
          ),
          actions: [
            if (!completed)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Keyinroq', style: TextStyle(color: Colors.white70)),
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _score += 15;
                    _feedback = '2×2 tenglama muvaffaqiyatli yig‘ildi!';
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('Davom etish'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _equationTile(String value) => Container(
        constraints: const BoxConstraints(minWidth: 54, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD166),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(value,
              style: const TextStyle(
                  color: Color(0xFF18264A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
        ),
      );

  void _newBoard() => _board = List.generate(6, (_) => List.generate(5, (_) => 1 + _random.nextInt(9)));

  void _newQuestion() {
    final maxValue = min(5 + _level * 2, 12);
    _a = 1 + _random.nextInt(maxValue);
    _b = 1 + _random.nextInt(maxValue);
    final ops = _config.difficulty == 'easy'
        ? ['+', '-']
        : _config.difficulty == 'hard'
            ? ['+', '-', '×', '÷']
            : (_level < 3 ? ['+', '-'] : ['+', '-', '×']);
    _operation = ops[_random.nextInt(ops.length)];
    if (_operation == '-' && _b > _a) { final t = _a; _a = _b; _b = t; }
    if (_operation == '÷') {
      _b = 1 + _random.nextInt(maxValue);
      _answer = 1 + _random.nextInt(maxValue);
      _a = _b * _answer;
    } else {
      _answer = _operation == '+' ? _a + _b : _operation == '-' ? _a - _b : _a * _b;
    }
    final values = <int>{_answer};
    while (values.length < 3) {
      final offset = 1 + _random.nextInt(5);
      values.add(max(0, _answer + (_random.nextBool() ? offset : -offset)));
    }
    _options = values.toList()..shuffle(_random);
    _selected = null;
  }

  void _choose(int value) {
    if (_finished || _selected == _answer) return;
    setState(() {
      _selected = value;
      if (value == _answer) {
        _score += 10 + _streak * 2; _streak++;
        _feedback = 'To‘g‘ri! Endi javob blokini taxtadagi katakka joylang.';
        HapticFeedback.mediumImpact();
      } else {
        _lives--; _streak = 0;
        _feedback = _config.robotHints ? 'Bu javob noto‘g‘ri. Ifodani qayta hisoblang.' : 'Noto‘g‘ri javob. Yana urinib ko‘ring.';
        HapticFeedback.heavyImpact();
        if (_lives <= 0) { _finished = true; _sessionTimer?.cancel(); _awardStars(); }
      }
    });
  }

  void _place(int row, int col) {
    if (_selected != _answer || _finished) return;
    setState(() {
      _solved++;
      final color = _answer % _palette.length;
      _board[row][col] = _answer;
      final group = <Point<int>>[];
      final queue = <Point<int>>[Point(row, col)];
      final seen = <String>{};
      while (queue.isNotEmpty) {
        final p = queue.removeLast();
        final key = '${p.x}:${p.y}';
        if (!seen.add(key) || p.x < 0 || p.x >= 6 || p.y < 0 || p.y >= 5) continue;
        if (_board[p.x][p.y] < 0 || _board[p.x][p.y] % _palette.length != color) continue;
        group.add(p);
        queue.addAll([Point(p.x + 1, p.y), Point(p.x - 1, p.y), Point(p.x, p.y + 1), Point(p.x, p.y - 1)]);
      }
      if (group.length >= 3) {
        for (final p in group) { _board[p.x][p.y] = -1; }
        _collapseAndRefill();
        _score += group.length * 3;
        _feedback = 'Ajoyib! ${group.length} ta bir xil rangli blok birlashdi.';
      } else {
        _feedback = 'Javob joylandi. Yangi misolga tayyorlaning!';
      }
      if (_solved > 0 && _solved % 4 == 0) _level++;
      if (_solved >= _config.questionCount) {
        _finished = true;
        _sessionTimer?.cancel();
        _awardStars();
      } else {
        _newQuestion();
      }
    });
  }

  void _collapseAndRefill() {
    for (int col = 0; col < 5; col++) {
      final remaining = <int>[];
      for (int row = 5; row >= 0; row--) {
        if (_board[row][col] >= 0) remaining.add(_board[row][col]);
      }
      int index = 0;
      for (int row = 5; row >= 0; row--) {
        _board[row][col] = index < remaining.length ? remaining[index++] : 1 + _random.nextInt(9);
      }
    }
  }

  void _awardStars() {
    if (_solved == 0) return;
    if (_starsEarned == 0) {
      _starsEarned = min(_config.rewardStars, max(1, _solved ~/ 3));
      widget.onUpdate?.call(widget.profile.copyWith(stars: widget.profile.stars + _starsEarned));
    }
    if (_statsRecorded) return;
    _statsRecorded = true;
    final maxScore = max(1, _config.questionCount * 20);
    final ratio = (_solved / max(1, _config.questionCount)).clamp(0.0, 1.0);
    final stars = ratio >= 0.85 ? 3 : ratio >= 0.60 ? 2 : ratio >= 0.30 ? 1 : 0;
    GameStatsService.instance.record(widget.profile.id, GameResult(
      gameId: 'math_blocks',
      subject: 'Matematika',
      stars: stars,
      score: _score,
      maxScore: maxScore,
      durationSeconds: DateTime.now().difference(_sessionStartedAt).inSeconds,
      playedAt: DateTime.now(),
    ), legacyProfileId: widget.profile.name);
  }

  void _restart() {
    if (!_config.enabled) return;
    _sessionTimer?.cancel();
    setState(() {
      _score = 0; _streak = 0; _lives = 3; _level = 1; _solved = 0; _starsEarned = 0; _statsRecorded = false; _finished = false;
      _sessionStartedAt = DateTime.now();
      _remainingSeconds = _config.timeLimitSeconds;
      _feedback = 'To‘g‘ri javobni tanlang.'; _newBoard(); _newQuestion();
    });
    if (_config.timerEnabled) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101B3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B3A),
        foregroundColor: Colors.white,
        title: const Text('Al-Xorazmiy: Matematik bloklar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
        IconButton(
          tooltip: '2×2 tenglama yig‘ish',
          onPressed: _showEquationPuzzle,
          icon: const Icon(Icons.grid_view_rounded),
        ),
        IconButton(onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(
          title: const Text('O‘yin pauzada'),
          content: const Text('Davom etishga tayyormisiz?'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Davom etish')), TextButton(onPressed: () { Navigator.pop(context); _restart(); }, child: const Text('Qayta boshlash'))],
        )), icon: const Icon(Icons.pause_circle_outline)),
      ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(
                    children: [
                      _stat('BALL', '$_score', Icons.star, const Color(0xFFFFC857)),
                      const SizedBox(width: 8),
                      _stat('DARAJA', '$_level', Icons.bolt, const Color(0xFF65D6CE)),
                      if (_config.timerEnabled) ...[
                        _stat('VAQT', '${_remainingSeconds}s', Icons.timer, const Color(0xFFFFD166)),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      Text('♥ ' * _lives, style: const TextStyle(color: Color(0xFFFF7185), fontSize: 18)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF285CA8), Color(0xFF583D9C)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      const Text('MISOLNI YECHING', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      const SizedBox(height: 5),
                      Text('$_a  $_operation  $_b  =  ?', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Row(
                        children: _options.map((value) {
                          final isSelected = _selected == value;
                          final bg = isSelected ? (value == _answer ? const Color(0xFF20B88A) : const Color(0xFFE45D70)) : Colors.white;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Draggable<int>(
                                data: value,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 76,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(color: const Color(0xFF20B88A), borderRadius: BorderRadius.circular(13)),
                                    child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ),
                                ),
                                childWhenDragging: Opacity(opacity: .35, child: _answerTile(value, isSelected, bg)),
                                child: InkWell(
                                borderRadius: BorderRadius.circular(13),
                                onTap: () => _choose(value),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
                                  child: Text(
                                    '$value',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : const Color(0xFF18264A)),
                                  ),
                                ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Color(0xFFFFC857), size: 18),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _selected == _answer ? 'Javob blokini taxtadagi istalgan katakka joylang.' : 'Javobni tanlang, so‘ng blokni taxtaga joylang.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 5.0;
                        final cell = min((constraints.maxWidth - gap * 4) / 5, (constraints.maxHeight - gap * 5) / 6);
                        return Center(
                          child: SizedBox(
                            width: cell * 5 + gap * 4,
                            height: cell * 6 + gap * 5,
                            child: Column(
                              children: List.generate(6, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(5, (col) {
                                      final value = _board[row][col];
                                      final color = value < 0 ? const Color(0xFF26365F) : _palette[value % _palette.length];
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(right: col == 4 ? 0 : gap, bottom: row == 5 ? 0 : gap),
                                          child: DragTarget<int>(
                                            onWillAccept: (value) => value == _answer && !_finished,
                                            onAccept: (value) {
                                              if (_selected != _answer) _choose(value);
                                              _place(row, col);
                                            },
                                            builder: (context, candidates, rejected) => GestureDetector(
                                            onTap: () => _place(row, col),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: _selected == _answer ? const Color(0xFFFFD166) : Colors.white24, width: _selected == _answer ? 2 : 1),
                                                boxShadow: [BoxShadow(color: color.withOpacity(.25), blurRadius: 7, offset: const Offset(0, 3))],
                                              ),
                                              child: Center(
                                                child: value < 0 ? const SizedBox.shrink() : Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                                              ),
                                            ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(_feedback, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (!_configReady)
              const Positioned.fill(child: ColoredBox(color: Color(0xCC101B3A), child: Center(child: CircularProgressIndicator()))),
            if (_finished)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.78),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(28),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFF202F59), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFFC857), size: 58),
                          const SizedBox(height: 10),
                          Text(!_config.enabled ? 'O‘yin vaqtincha yopiq' : (!_config.isSuitableForAge(widget.profile.age) ? 'Yosh chegarasi' : 'Mashg‘ulot yakunlandi'), style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text('Ball: $_score  •  Yechilgan misollar: $_solved  •  Yulduz: $_starsEarned', style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 18),
                          ElevatedButton(onPressed: (_config.enabled && _config.isSuitableForAge(widget.profile.age)) ? _restart : null, child: const Text('Qayta o‘ynash')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _answerTile(int value, bool isSelected, Color bg) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
    child: Text('$value', textAlign: TextAlign.center,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
        color: isSelected ? Colors.white : const Color(0xFF18264A))),
  );

  Widget _stat(String label, String value, IconData icon, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(13)), child: Row(children: [Icon(icon, color: color, size: 17), const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))])]));
}
