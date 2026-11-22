import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/victory_overlay.dart';
import '../../../data/models/user_profile.dart';

// ── So'zlar banki (5 harfli, apostrofsiz) ────────────────────────────────────
const _wordBank = [
  'OLCHA', 'GILOS', 'TARVUZ', // 6 harfli tarvuz → olib tashlaymiz
  'KITOB', 'QALAM', 'MAKTAB',
  'BAHOR', 'KUZGI', 'QUYOSH',
  'BULUT', 'YOMON', 'QADAM',
  'YURAK', 'OVQAT', 'SHIRIN',
  'HAYOT', 'DARAXT', 'DENGIZ',
  'BULOQ', 'TULKI', 'QUYON',
  'BALIQ', 'TUXUM', 'SABZI',
  'KARAM', 'LIMON', 'UZUM',
  'GILOS', 'ANOR', 'BAXIL',
];

// Faqat 5 harflilarni ajratamiz
final _fiveLetterWords = _wordBank
    .where((w) => w.length == 5)
    .toSet()
    .toList();

// ── Harf holati ───────────────────────────────────────────────────────────────
enum _LetterState { empty, typed, correct, present, absent }

class _LetterCell {
  String letter;
  _LetterState state;
  _LetterCell({this.letter = '', this.state = _LetterState.empty});
}

// ── Ertak sahna holatlari ─────────────────────────────────────────────────────
enum _StoryPhase { intro, playing, win, lose }

// ═════════════════════════════════════════════════════════════════════════════
class ZumradWordleScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const ZumradWordleScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<ZumradWordleScreen> createState() => _ZumradWordleScreenState();
}

class _ZumradWordleScreenState extends State<ZumradWordleScreen>
    with TickerProviderStateMixin {
  static const int _maxRows = 6;
  static const int _cols = 5;

  late String _target;
  late List<List<_LetterCell>> _grid;
  late Map<String, _LetterState> _keyStates;
  int _currentRow = 0;
  String _currentInput = '';
  bool _gameOver = false;
  bool _won = false;
  _StoryPhase _phase = _StoryPhase.intro;
  String _message = '';
  bool _showVictory = false;
  int _shakeRow = -1;

  late AnimationController _chestCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _zumradCtrl;

  static const _uzbekAlphabet = [
    ['A', 'B', 'D', 'E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L', 'M', 'N', 'O'],
    ['P', 'Q', 'R', 'S', 'T', 'U', 'V'],
    ['X', 'Y', 'Z', 'CH', '⌫', 'ENTER'],
  ];

  @override
  void initState() {
    super.initState();
    _target = (_fiveLetterWords..shuffle(Random())).first;
    _initGrid();
    _keyStates = {};

    _chestCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _zumradCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  void _initGrid() {
    _grid = List.generate(
      _maxRows,
      (_) => List.generate(_cols, (_) => _LetterCell()),
    );
  }

  @override
  void dispose() {
    _chestCtrl.dispose();
    _glowCtrl.dispose();
    _zumradCtrl.dispose();
    super.dispose();
  }

  // ── Klaviatura bosish ───────────────────────────────────────────────────────
  void _onKey(String key) {
    if (_gameOver) return;

    if (key == '⌫') {
      if (_currentInput.isNotEmpty) {
        setState(() {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          _updateCurrentRow();
        });
      }
      return;
    }

    if (key == 'ENTER') {
      _submitGuess();
      return;
    }

    if (_currentInput.length < _cols) {
      setState(() {
        _currentInput += key;
        _updateCurrentRow();
      });
    }
  }

  void _updateCurrentRow() {
    for (int c = 0; c < _cols; c++) {
      _grid[_currentRow][c].letter = c < _currentInput.length
          ? _currentInput[c]
          : '';
      _grid[_currentRow][c].state = c < _currentInput.length
          ? _LetterState.typed
          : _LetterState.empty;
    }
  }

  void _submitGuess() {
    if (_currentInput.length < _cols) {
      // Qisqa so'z
      setState(() {
        _message = 'So\'z ${_cols} harf bo\'lishi kerak!';
        _shakeRow = _currentRow;
      });
      Future.delayed(600.ms, () {
        if (mounted) setState(() { _shakeRow = -1; _message = ''; });
      });
      return;
    }

    final guess = _currentInput;
    final targetChars = _target.split('');
    final guessChars = guess.split('');

    // Wordle algoritmi
    final states = List.filled(_cols, _LetterState.absent);
    final remaining = List<String?>.from(targetChars);

    // 1-o'tish: to'g'ri joylar
    for (int i = 0; i < _cols; i++) {
      if (guessChars[i] == targetChars[i]) {
        states[i] = _LetterState.correct;
        remaining[i] = null;
      }
    }
    // 2-o'tish: mavjud lekin noto'g'ri joy
    for (int i = 0; i < _cols; i++) {
      if (states[i] == _LetterState.correct) continue;
      final idx = remaining.indexOf(guessChars[i]);
      if (idx != -1) {
        states[i] = _LetterState.present;
        remaining[idx] = null;
      }
    }

    setState(() {
      for (int c = 0; c < _cols; c++) {
        _grid[_currentRow][c].state = states[c];
        // Klaviaturani yangilash
        final ch = guessChars[c];
        final prev = _keyStates[ch];
        if (prev == null || _stateOrder(states[c]) > _stateOrder(prev)) {
          _keyStates[ch] = states[c];
        }
      }

      if (guess == _target) {
        // G'alaba!
        _won = true;
        _gameOver = true;
        _phase = _StoryPhase.win;
        _message = _winMessage(_currentRow);
        _chestCtrl.forward();
        Future.delayed(1200.ms, () {
          if (mounted) _endGame();
        });
      } else if (_currentRow + 1 >= _maxRows) {
        // Yutqizdi
        _gameOver = true;
        _phase = _StoryPhase.lose;
        _message = 'So\'z: $_target edi. Keyingi safar!';
        Future.delayed(1500.ms, () {
          if (mounted) _endGame();
        });
      } else {
        _currentRow++;
        _currentInput = '';
        _phase = _StoryPhase.playing;
        _message = _hintMessage(_currentRow);
      }
    });
  }

  int _stateOrder(_LetterState s) {
    return switch (s) {
      _LetterState.correct => 3,
      _LetterState.present => 2,
      _LetterState.absent  => 1,
      _                    => 0,
    };
  }

  String _winMessage(int row) {
    return switch (row) {
      0 => '🌟 Ajoyib! Birinchi urinishda!',
      1 => '🏆 Zo\'r! Ikkinchi urinishda!',
      2 => '✨ Yaxshi! Uchinchi urinishda!',
      3 => '👏 Barakalla!',
      4 => '😮 Mana shu ham bo\'ladi!',
      _ => '😅 Zo\'rg\'a topdingiz!',
    };
  }

  String _hintMessage(int row) {
    return switch (row) {
      1 => '💚 Yashil = to\'g\'ri joy, 💛 sariq = boshqa joyda',
      2 => '🤔 Ko\'proq harflarni sinab ko\'ring...',
      3 => '⚡ Sandiq yaqinlashmoqda!',
      4 => '😰 Ikki urinish qoldi!',
      5 => '🆘 Oxirgi imkoniyat!',
      _ => '',
    };
  }

  void _endGame() {
    final starsEarned = _won
        ? (_currentRow <= 2 ? 3 : _currentRow <= 4 ? 2 : 1)
        : 0;
    final subStars = Map<String, int>.from(widget.profile.subjectStars);
    final prev = subStars['ona_tili'] ?? 0;
    if (starsEarned > prev) subStars['ona_tili'] = starsEarned;

    final updated = widget.profile.copyWith(
      stars: widget.profile.stars + starsEarned,
      subjectStars: subStars,
    );
    widget.onUpdate?.call(updated);
    setState(() => _showVictory = true);
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_phase == _StoryPhase.intro) ...[
                  Expanded(child: _buildIntro()),
                ] else ...[
                  _buildStoryBanner(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildGrid(),
                          const SizedBox(height: 8),
                          if (_message.isNotEmpty) _buildMessage(),
                          const SizedBox(height: 8),
                          _buildKeyboard(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_showVictory)
            VictoryOverlay(
              score: _won ? (_currentRow <= 2 ? 3 : _currentRow <= 4 ? 2 : 1) : 0,
              maxScore: 3,
              message: _won
                  ? 'Zumrad sandiqni ochdingiz! 💎'
                  : 'Keyingi safar omad! 🌸',
              onContinue: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0533),
            Color(0xFF2D1B69),
            Color(0xFF4A148C),
            Color(0xFF6A1B9A),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              '💎 Zumrad Sandiq',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.purple.shade200,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Urinish ko'rsatkichi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '${_currentRow}/$_maxRows',
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sandiq animatsiyasi
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3 + _glowCtrl.value * 0.4),
                    blurRadius: 20 + _glowCtrl.value * 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text('📦', style: TextStyle(fontSize: 80)),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

          const SizedBox(height: 20),
          Text(
            'Zumradning Sehrli Sandiq',
            style: GoogleFonts.nunito(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade200.withOpacity(0.3)),
            ),
            child: Text(
              'Zumrad o\'zining sehrli sandiqini yashirdi.\n'
              'Sandiqni ochish uchun 5 harfli so\'zni toping!\n\n'
              '💚 Yashil — to\'g\'ri harf, to\'g\'ri joy\n'
              '💛 Sariq — to\'g\'ri harf, noto\'g\'ri joy\n'
              '⬜ Kulrang — bu harf yo\'q',
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() {
              _phase = _StoryPhase.playing;
              _message = '💡 5 harfli so\'z kiriting';
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Text(
                '🗝️ O\'ynash',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 700.ms).scale(
            begin: const Offset(0.8, 0.8),
            curve: Curves.elasticOut,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryBanner() {
    // Zumrad rasmi + holat
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.shade200.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _zumradCtrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, sin(_zumradCtrl.value * pi) * 4),
              child: Text(
                _phase == _StoryPhase.win ? '🎉' :
                _phase == _StoryPhase.lose ? '😢' :
                _currentRow < 3 ? '😊' : '😰',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zumrad',
                  style: GoogleFonts.nunito(
                    color: Colors.purple.shade200,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedBuilder(
                  animation: _chestCtrl,
                  builder: (_, __) {
                    return Text(
                      _phase == _StoryPhase.win
                          ? '✨ Sandiq ochildi! Tabriklayman!'
                          : _phase == _StoryPhase.lose
                              ? '😢 Sandiq qoldi...'
                              : '🗝️ Sandiqni ochgin, yosh do\'stim!',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Sandiq (ochiluvchi)
          AnimatedBuilder(
            animation: _chestCtrl,
            builder: (_, __) {
              return Text(
                _chestCtrl.value > 0.5 ? '🎁' : '📦',
                style: TextStyle(
                  fontSize: 28 + _chestCtrl.value * 8,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_maxRows, (row) {
        final isShaking = row == _shakeRow;
        return _buildRow(row, isShaking);
      }),
    );
  }

  Widget _buildRow(int row, bool shake) {
    final cells = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cols, (col) {
        final cell = _grid[row][col];
        return _buildCell(cell, row, col);
      }),
    );

    if (!shake) return cells;
    return cells
        .animate(onPlay: (c) => c.forward())
        .shakeX(amount: 6, hz: 4, duration: 500.ms);
  }

  Widget _buildCell(
    _LetterCell cell,
    int row,
    int col,
  ) {
    Color bg;
    Color border;
    Color text = Colors.white;

    switch (cell.state) {
      case _LetterState.correct:
        bg = const Color(0xFF388E3C);
        border = const Color(0xFF4CAF50);
        break;
      case _LetterState.present:
        bg = const Color(0xFFF57F17);
        border = const Color(0xFFFFB300);
        break;
      case _LetterState.absent:
        bg = const Color(0xFF37474F);
        border = const Color(0xFF546E7A);
        break;
      case _LetterState.typed:
        bg = Colors.white.withOpacity(0.12);
        border = Colors.purple.shade200;
        break;
      default:
        bg = Colors.white.withOpacity(0.06);
        border = Colors.white24;
        text = Colors.white38;
    }

    final w = Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        cell.letter,
        style: GoogleFonts.nunito(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    if (cell.state == _LetterState.correct ||
        cell.state == _LetterState.present ||
        cell.state == _LetterState.absent) {
      return w
          .animate(delay: (col * 150).ms)
          .flipV(duration: 350.ms);
    }
    if (cell.state == _LetterState.typed && cell.letter.isNotEmpty) {
      return w.animate().scale(
        begin: const Offset(1.2, 1.2),
        end: const Offset(1.0, 1.0),
        duration: 120.ms,
        curve: Curves.easeOut,
      );
    }
    return w;
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        _message,
        style: GoogleFonts.nunito(
          color: Colors.white70,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildKeyboard() {
    return Column(
      children: _uzbekAlphabet.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) => _buildKey(key)).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isSpecial = key == '⌫' || key == 'ENTER' || key == 'CH';
    final state = _keyStates[key];

    Color bg;
    Color textColor = Colors.white;
    switch (state) {
      case _LetterState.correct:
        bg = const Color(0xFF388E3C);
        break;
      case _LetterState.present:
        bg = const Color(0xFFF57F17);
        break;
      case _LetterState.absent:
        bg = const Color(0xFF37474F);
        textColor = Colors.white38;
        break;
      default:
        bg = Colors.white.withOpacity(0.12);
    }

    return GestureDetector(
      onTap: () => _onKey(key),
      child: Container(
        width: isSpecial ? (key == 'ENTER' ? 60 : 44) : 36,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          key == 'ENTER' ? '✓' : key,
          style: GoogleFonts.nunito(
            color: key == 'ENTER' ? Colors.greenAccent : textColor,
            fontSize: key.length > 1 ? 11 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
