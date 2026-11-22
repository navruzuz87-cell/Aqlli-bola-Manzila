import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/sound_utils.dart';

// ── Shop item modeli ─────────────────────────────────────────────────────────

enum ShopCategory { soch, kiyim, rang, aksessuar }

extension ShopCategoryExt on ShopCategory {
  String get label {
    switch (this) {
      case ShopCategory.soch:       return 'Soch';
      case ShopCategory.kiyim:      return 'Kiyim';
      case ShopCategory.rang:       return 'Rang';
      case ShopCategory.aksessuar:  return 'Bezak';
    }
  }
  String get emoji {
    switch (this) {
      case ShopCategory.soch:       return '💇';
      case ShopCategory.kiyim:      return '👕';
      case ShopCategory.rang:       return '🎨';
      case ShopCategory.aksessuar:  return '🎩';
    }
  }
}

class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final int price;          // yulduzlarda
  final ShopCategory category;
  final int colorValue;     // karta rangi

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
    required this.colorValue,
  });
}

const List<ShopItem> _shopItems = [
  // ── SOCH ────────────────────────────────────────────
  ShopItem(id: 's1', name: 'Qisqa soch',     emoji: '💈', price: 0,   category: ShopCategory.soch,      colorValue: 0xFF5D4037),
  ShopItem(id: 's2', name: 'To\'lqinli soch', emoji: '🌊', price: 30,  category: ShopCategory.soch,      colorValue: 0xFF1565C0),
  ShopItem(id: 's3', name: 'Qilichcha',       emoji: '⚔️', price: 50,  category: ShopCategory.soch,      colorValue: 0xFFB71C1C),
  ShopItem(id: 's4', name: 'Afro soch',       emoji: '🌟', price: 80,  category: ShopCategory.soch,      colorValue: 0xFF6A1B9A),
  ShopItem(id: 's5', name: 'Do\'ppi',          emoji: '🧢', price: 60,  category: ShopCategory.soch,      colorValue: 0xFF00695C),

  // ── KIYIM ────────────────────────────────────────────
  ShopItem(id: 'k1', name: 'Oddiy ko\'ylak',  emoji: '👕', price: 0,   category: ShopCategory.kiyim,     colorValue: 0xFF37474F),
  ShopItem(id: 'k2', name: 'Milliy to\'n',    emoji: '🥻', price: 50,  category: ShopCategory.kiyim,     colorValue: 0xFF006064),
  ShopItem(id: 'k3', name: 'Supermen',         emoji: '🦸', price: 100, category: ShopCategory.kiyim,     colorValue: 0xFFB71C1C),
  ShopItem(id: 'k4', name: 'Olim ko\'ylagi',  emoji: '🥼', price: 80,  category: ShopCategory.kiyim,     colorValue: 0xFF455A64),
  ShopItem(id: 'k5', name: 'Futbolchi',        emoji: '⚽', price: 70,  category: ShopCategory.kiyim,     colorValue: 0xFF2E7D32),
  ShopItem(id: 'k6', name: 'Qirol libosi',    emoji: '👑', price: 150, category: ShopCategory.kiyim,     colorValue: 0xFFE65100),

  // ── RANG ────────────────────────────────────────────
  ShopItem(id: 'r1', name: 'Tabiat yashili',  emoji: '🌿', price: 20,  category: ShopCategory.rang,      colorValue: 0xFF2E7D32),
  ShopItem(id: 'r2', name: 'Chaqmoq sariq',   emoji: '⚡', price: 40,  category: ShopCategory.rang,      colorValue: 0xFFF9A825),
  ShopItem(id: 'r3', name: 'Atirgul pushti',  emoji: '🌸', price: 40,  category: ShopCategory.rang,      colorValue: 0xFFAD1457),
  ShopItem(id: 'r4', name: 'Galaktika',        emoji: '🌌', price: 120, category: ShopCategory.rang,      colorValue: 0xFF311B92),
  ShopItem(id: 'r5', name: 'Oltin',            emoji: '🏆', price: 200, category: ShopCategory.rang,      colorValue: 0xFFF57F17),

  // ── AKSESSUAR ────────────────────────────────────────
  ShopItem(id: 'a1', name: 'Ko\'zoynak',       emoji: '🕶️', price: 30,  category: ShopCategory.aksessuar, colorValue: 0xFF263238),
  ShopItem(id: 'a2', name: 'Olim ko\'zoynagi', emoji: '🤓', price: 50,  category: ShopCategory.aksessuar, colorValue: 0xFF37474F),
  ShopItem(id: 'a3', name: 'Fotiha tasbeh',   emoji: '📿', price: 60,  category: ShopCategory.aksessuar, colorValue: 0xFF4A148C),
  ShopItem(id: 'a4', name: 'Yulduz medali',   emoji: '🥇', price: 100, category: ShopCategory.aksessuar, colorValue: 0xFFE65100),
  ShopItem(id: 'a5', name: 'Qirol toji',      emoji: '👑', price: 180, category: ShopCategory.aksessuar, colorValue: 0xFFB71C1C),
];

// ── Ekran ────────────────────────────────────────────────────────────────────

class ShopScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile)? onUpdate;

  const ShopScreen({super.key, required this.profile, this.onUpdate});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  ShopCategory _selectedCat = ShopCategory.soch;
  late UserProfile _profile;

  // Sotib olingan itemlar (profile da saqlanadi — string set)
  Set<String> get _owned => Set<String>.from(
    (_profile.ownedItems ?? '').split(',').where((e) => e.isNotEmpty),
  );

  late AnimationController _coinController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  List<ShopItem> get _filtered =>
      _shopItems.where((i) => i.category == _selectedCat).toList();

  bool _isOwned(ShopItem item) =>
      item.price == 0 || _owned.contains(item.id);

  void _buy(ShopItem item) {
    if (_isOwned(item)) return;
    if (_profile.totalStars < item.price) {
      _showNotEnoughStars();
      return;
    }
    _showBuyDialog(item);
  }

  void _showBuyDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${item.emoji} ${item.name}',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.price} ⭐ sarflaysizmi?',
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Qoladi: ${_profile.totalStars - item.price} ⭐',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: _profile.totalStars - item.price >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor', style: GoogleFonts.nunito(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _confirmBuy(item);
            },
            child: Text(
              'Sotib ol!',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBuy(ShopItem item) {
    final newOwned = {..._owned, item.id}.join(',');
    final updated = _profile.copyWith(
      totalStars: _profile.totalStars - item.price,
      ownedItems: newOwned,
    );
    setState(() => _profile = updated);
    widget.onUpdate?.call(updated);
    HapticUtils.gameComplete(); SoundUtils.coin();
    _coinController.forward(from: 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.emoji} ${item.name} — sotib olindi! 🎉',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotEnoughStars() {
    HapticUtils.wrong(); SoundUtils.wrong();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⭐ Yetarli yulduz yo\'q! Ko\'proq o\'yna!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              _buildTopBar(),
              _buildAvatarPreview(),
              _buildCategoryTabs(),
              Expanded(child: _buildGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '🛒 Do\'kon',
            style: GoogleFonts.nunito(
              fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          const Spacer(),
          // Yulduz balansi
          AnimatedBuilder(
            animation: _coinController,
            builder: (_, __) => Transform.scale(
              scale: 1.0 + _coinController.value * 0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      '${_profile.totalStars}',
                      style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    // Avatar emoji kombinatsiyasi
    final skins = ['👦', '👧', '🧒'];
    final avatarEmoji = skins[_profile.gender == 'girl' ? 1 : 0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(avatarEmoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 6),
              Text(
                _profile.name,
                style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoChip('⭐', '${_profile.totalStars} yulduz'),
              const SizedBox(height: 6),
              _infoChip('🏆', '${_owned.length} ta buyum'),
              const SizedBox(height: 6),
              _infoChip('📚', '${_profile.grade}-sinf'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$emoji  $text',
        style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ShopCategory.values.map((cat) {
          final sel = _selectedCat == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? Colors.amber : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Text(
                '${cat.emoji} ${cat.label}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.amber : Colors.white60,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final items = _filtered;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItemCard(items[i], i),
    );
  }

  Widget _buildItemCard(ShopItem item, int idx) {
    final owned = _isOwned(item);
    final canAfford = _profile.totalStars >= item.price;

    return GestureDetector(
      onTap: () => _buy(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Color(item.colorValue).withOpacity(0.25),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: owned
                ? Colors.greenAccent.withOpacity(0.7)
                : Color(item.colorValue).withOpacity(0.5),
            width: owned ? 2.5 : 1.5,
          ),
          boxShadow: owned
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(item.emoji, style: const TextStyle(fontSize: 52))
                .animate(key: ValueKey(item.id))
                .fadeIn(delay: (idx * 60).ms)
                .scale(begin: const Offset(0.6, 0.6), delay: (idx * 60).ms),

            const SizedBox(height: 10),

            // Nomi
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Narx yoki "Mavjud"
            if (owned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Text(
                  '✅ Mavjud',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.greenAccent,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: canAfford
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: canAfford
                        ? Colors.amber.withOpacity(0.5)
                        : Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  item.price == 0 ? 'Bepul 🎁' : '${item.price} ⭐',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: canAfford ? Colors.amber : Colors.white38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
