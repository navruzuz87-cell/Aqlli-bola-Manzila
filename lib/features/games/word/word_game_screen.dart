import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/user_profile.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/widgets/victory_overlay.dart';

// ── So'z ma'lumoti ────────────────────────────────────────────────────────────
class _WordEntry {
  final String word;    // 4-5 harf, katta harf
  final String hint;    // masalan "meva 🍎"
  const _WordEntry(this.word, this.hint);
}

// ── So'zlar ro'yxati (o'zbek, 4-5 harf) ──────────────────────────────────────
const _wordBank = [
  // 4 harfli
  _WordEntry('OLMA', 'Qizil meva 🍎'),
  _WordEntry('KEMA', 'Suvda suzadi ⛵'),
  _WordEntry('BOLA', 'Yosh inson 👦'),
  _WordEntry('QUSH', 'Uchadi 🐦'),
  _WordEntry('BALIQ', 'Suvda yashaydi 🐟'),
  _WordEntry('KITOB', 'O\'qiladigan narsa 📚'),
  _WordEntry('UYQU', 'Tunda qilinadi 😴'),
  _WordEntry('GILOS', 'Qizil meva 🍒'),
  _WordEntry('ARZON', 'Narx past 💰'),
  _WordEntry('BAHOR', 'Fasl 🌸'),
  _WordEntry('KUZGI', 'Fasl 🍂'),
  _WordEntry('TARVUZ', 'Yoz mevasi 🍉'),
  _WordEntry('UZUM', 'Tok mevasi 🍇'),
  _WordEntry('ANOR', 'Qizil dona 🍎'),
  _WordEntry('LIMON', 'Nordon meva 🍋'),
  _WordEntry('KARAM', 'Sabzavot 🥬'),
  _WordEntry('SABZI', 'Sabzavot 🥕'),
  _WordEntry('TUXUM', 'Tovuq tuxumi 🥚'),
  _WordEntry('QUYON', 'Hayvon 🐰'),
  _WordEntry('TULKI', 'Hayvon 🦊'),
  _WordEntry('AYIQ', 'Hayvon 🐻'),
  _WordEntry('ILON', 'Sudralib yuradi 🐍'),
  _WordEntry('BAQA', 'Sakraydi 🐸'),
  _WordEntry('GULOB', 'Gul suvi 🌹'),
  _WordEntry('DARAXT', 'Baland 🌳'),
  _WordEntry('DENGIZ', 'Suv havzasi 🌊'),
  _WordEntry('DARYO', 'Oqar suv 🏞️'),
  _WordEntry('YULDUZ', 'Osmonda 🌟'),
  _WordEntry('QUYOSH', 'Issiqlik beradi ☀️'),
  _WordEntry('BULUT', 'Osmonda suzadi ☁️'),
  _WordEntry('BULOQ', 'Suv chiqadigan tabiiy manba 💧'),
  _WordEntry('QADAM', 'Oyoq yurishi 👣'),
  _WordEntry('YURAK', 'Tananing qismi ❤️'),
  _WordEntry('QALAM', 'Yozish uchun ✏️'),
  _WordEntry('DAFTAR', 'Yozish kitobi 📒'),
  _WordEntry('MAKTAB', 'O\'qish joyi 🏫'),
  _WordEntry('DOKTOR', 'Kasalni davolaydi 👨‍⚕️'),
  _WordEntry('OVQAT', 'Yeyish uchun 🍽️'),
  _WordEntry('SHIRIN', 'Mazali 🍬'),
  _WordEntry('BALAND', 'Baland joy 🏔️'),
  _WordEntry('QISQA', 'Uzun emas 📏'),
  _WordEntry('YAXSHI', 'Yomon emas 👍'),
  _WordEntry('HAYOT', 'Tirik bo\'lish 🌱'),
];

// Faqat 4-5 harfli, hech qanday apostrofe yo'q so'zlarni olamiz
List<_WordEntry> get _validWords {
  return _wordBank.where((w) {
    final clean = w.word.replaceAll("'", "").replaceAll("ʻ", "").replaceAll("ʼ", "");
    return clean.length >= 4 && clean.length <= 5 && !clean.contains(' ');
  }).toList();
}

// ── Harf holati ───────────────────────────────────────────────────────────────
enum _LetterState { empty, typed, correct, present, absent }

class _LetterCell {
  String letter;
  _LetterState state;
  _LetterCell({this.letter = '', this.state = _LetterState.empty});
}

// ── O'yin ekrani ──────────────────────────────────────────────────────────────
class WordGameScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const WordGameScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with TickerProviderStateMixin {
  static const _maxAttempts = 6;

  late UserProfile _profile;
  late _WordEntry _target;
  late int _wordLen;

  // Grid: [attempt][position]
  late List<List<_LetterCell>> _grid;
  int _currentRow = 0;
  int _currentCol = 0;

  // Klaviatura harflari holati
  final Map<String, _LetterState> _keyStates = {};

  bool _gameWon = false;
  bool _gameLost = false;
  bool _showResult = false;
  int _starsEarned = 0;

  late AnimationController _shakeCtrl;
  late AnimationController _winCtrl;

  static final _rng = Random();

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _winCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _startNewGame();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _winCtrl.dispose();
    super.dispose();
  }

  void _startNewGame() {
    final valid = _validWords;
    _target = valid[_rng.nextInt(valid.length)];
    // So'zdagi apostroflarni olib tashlash
    final cleanWord = _target.word
        .replaceAll("'", "")
        .replaceAll("ʻ", "")
        .replaceAll("ʼ", "");
    _wordLen = cleanWord.length;

    _grid = List.generate(
      _maxAttempts,
      (_) => List.generate(_wordLen, (_) => _LetterCell()),
    );
    _currentRow = 0;
    _currentCol = 0;
    _keyStates.clear();
    _gameWon = false;
    _gameLost = false;
    _showResult = false;
    _starsEarned = 0;
  }

  String get _cleanTarget => _target.word
      .replaceAll("'", "")
      .replaceAll("ʻ", "")
      .replaceAll("ʼ", "");

  void _onKey(String letter) {
    if (_gameWon || _gameLost) return;
    if (_currentCol >= _wordLen) return;
    setState(() {
      _grid[_currentRow][_currentCol].letter = letter;
      _grid[_currentRow][_currentCol].state = _LetterState.typed;
      _currentCol++;
    });
    HapticUtils.click();
    SoundUtils.click();
  }

  void _onDelete() {
    if (_currentCol == 0) return;
    setState(() {
      _currentCol--;
      _grid[_currentRow][_currentCol].letter = '';
      _grid[_currentRow][_currentCol].state = _LetterState.empty;
    });
  }

  void _onEnter() {
    if (_currentCol < _wordLen) {
      // Yetarli harf yo'q — shake
      _shakeCtrl.forward(from: 0);
      return;
    }

    final guess = _grid[_currentRow].map((c) => c.letter).join();
    final target = _cleanTarget;

    // Ranglarni hisoblash
    final targetChars = target.split('').toList();
    final result = List.filled(_wordLen, _LetterState.absent);

    // 1-o'tish: aniq mos (correct)
    for (int i = 0; i < _wordLen; i++) {
      if (guess[i] == targetChars[i]) {
        result[i] = _LetterState.correct;
        targetChars[i] = '*'; // ishlatildi
      }
    }

    // 2-o'tish: mavjud lekin noto'g'ri joyda (present)
    for (int i = 0; i < _wordLen; i++) {
      if (result[i] == _LetterState.correct) continue;
      final idx = targetChars.indexOf(guess[i]);
      if (idx != -1) {
        result[i] = _LetterState.present;
        targetChars[idx] = '*';
      }
    }

    setState(() {
      for (int i = 0; i < _wordLen; i++) {
        _grid[_currentRow][i].state = result[i];
        // Klaviatura yangilash (eng yaxshi natija)
        final prev = _keyStates[guess[i]] ?? _LetterState.empty;
        if (_statePriority(result[i]) > _statePriority(prev)) {
          _keyStates[guess[i]] = result[i];
        }
      }
    });

    final won = result.every((s) => s == _LetterState.correct);

    if (won) {
      // Yulduz: qancha urinishda topdi
      _starsEarned = switch (_currentRow) {
        0 => 10,
        1 => 8,
        2 => 6,
        3 => 4,
        4 => 3,
        _ => 2,
      };
      HapticUtils.gameComplete();
      SoundUtils.win();
      _winCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _saveResult();
          setState(() { _gameWon = true; _showResult = true; });
        }
      });
    } else if (_currentRow + 1 >= _maxAttempts) {
      HapticUtils.wrong();
      SoundUtils.wrong();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _starsEarned = 0;
          _saveResult();
          setState(() { _gameLost = true; _showResult = true; });
        }
      });
    } else {
      setState(() {
        _currentRow++;
        _currentCol = 0;
      });
    }
  }

  int _statePriority(_LetterState s) => switch (s) {
    _LetterState.correct => 3,
    _LetterState.present => 2,
    _LetterState.absent  => 1,
    _               => 0,
  };

  void _saveResult() {
    final prevStars = _profile.subjectStars['ona_tili'] ?? 0;
    final newSubjectStars = Map<String, int>.from(_profile.subjectStars)
      ..['ona_tili'] = prevStars + _starsEarned;
    final updated = _profile.copyWith(
      stars: _profile.stars + _starsEarned,
      subjectStars: newSubjectStars,
      totalPlayMinutes: _profile.totalPlayMinutes + 2,
    );
    _profile = updated;
    widget.onUpdate?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
            ),
          ),
          child: Stack(children: [
            VictoryOverlay(
              correctCount: _gameWon ? 1 : 0,
              totalCount: 1,
              starsEarned: _starsEarned,
              maxCombo: _gameWon ? (_maxAttempts - _currentRow) : 0,
              subjectEmoji: '🔤',
              subjectName: 'So\'z topish',
              onReplay: () => setState(_startNewGame),
              onHome: () => Navigator.of(context).pop(),
            ),
            // So'zni ko'rsatish (agar yutqizsa)
            if (_gameLost)
              Positioned(
                bottom: 220,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'So\'z: $_cleanTarget',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildTopBar(),
            if (_target.hint != null) ...[
              const SizedBox(height: 4),
              Text(
                'Maslahat: ${_target.hint}',
                style: GoogleFonts.nunito(
                  color: Colors.white54, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            _buildGrid(),
            const Spacer(),
            _buildKeyboard(),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            '🔤 So\'z Topish',
            style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.w800),
          ),
        ),
        // Qolgan urinishlar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_maxAttempts - _currentRow} ta urinish',
            style: GoogleFonts.nunito(
              color: Colors.white70, fontSize: 12),
          ),
        ),
      ]),
    );
  }

  Widget _buildGrid() {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (ctx, child) {
        final shake = sin(_shakeCtrl.value * pi * 5) * 8;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_maxAttempts, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_wordLen, (col) {
                return _buildCell(_grid[row][col], row, col);
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(_LetterCell cell, int row, int col) {
    Color bgColor;
    Color borderColor;
    Color textColor = Colors.white;

    switch (cell.state) {
      case _LetterState.correct:
        bgColor = const Color(0xFF388E3C);
        borderColor = const Color(0xFF66BB6A);
        break;
      case _LetterState.present:
        bgColor = const Color(0xFFF57F17);
        borderColor = const Color(0xFFFFB300);
        break;
      case _LetterState.absent:
        bgColor = const Color(0xFF37474F);
        borderColor = const Color(0xFF546E7A);
        break;
      case _LetterState.typed:
        bgColor = Colors.white.withOpacity(0.1);
        borderColor = Colors.white54;
        break;
      default:
        bgColor = Colors.white.withOpacity(0.05);
        borderColor = Colors.white24;
    }

    final isCurrentRow = row == _currentRow;
    final cellSize = _wordLen <= 4 ? 56.0 : 50.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: cellSize,
      height: cellSize,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: isCurrentRow && cell.state == _LetterState.empty ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          cell.letter,
          style: GoogleFonts.nunito(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ── Klaviatura ──────────────────────────────────────────────────────────────
  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['O\'', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'SH'],
  ];

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          ..._rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((k) => _buildKey(k)).toList(),
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey('⌫', _onDelete, const Color(0xFF37474F)),
              const SizedBox(width: 6),
              _buildSpecialKey('ENTER', _onEnter, const Color(0xFF1565C0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String letter) {
    final state = _keyStates[letter] ?? _LetterState.empty;
    Color bgColor;
    switch (state) {
      case _LetterState.correct: bgColor = const Color(0xFF388E3C); break;
      case _LetterState.present: bgColor = const Color(0xFFF57F17); break;
      case _LetterState.absent:  bgColor = const Color(0xFF263238); break;
      default: bgColor = const Color(0xFF37474F);
    }

    final isWide = letter.length > 1;

    return GestureDetector(
      onTap: () => _onKey(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: isWide ? 46 : 30,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            letter,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: isWide ? 10 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
