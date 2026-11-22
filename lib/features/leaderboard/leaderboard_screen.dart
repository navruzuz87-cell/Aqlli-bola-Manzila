import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

// Demo reyting ma'lumotlari (haqiqiy ilovada server dan keladi)
class _LeaderEntry {
  final String name;
  final String emoji;
  final int stars;
  final int grade;
  final int streakDays;
  final String badge; // maxsus belgi

  const _LeaderEntry({
    required this.name,
    required this.emoji,
    required this.stars,
    required this.grade,
    required this.streakDays,
    this.badge = '',
  });
}

const _demoLeaders = [
  _LeaderEntry(name: 'Zulfiya',  emoji: '👧', stars: 1240, grade: 4, streakDays: 21, badge: '🏆'),
  _LeaderEntry(name: 'Jasur',    emoji: '👦', stars: 1105, grade: 5, streakDays: 14, badge: '🔥'),
  _LeaderEntry(name: 'Malika',   emoji: '👧', stars:  980, grade: 3, streakDays: 7,  badge: '⭐'),
  _LeaderEntry(name: 'Bobur',    emoji: '👦', stars:  870, grade: 4, streakDays: 5,  badge: ''),
  _LeaderEntry(name: 'Nilufar',  emoji: '👧', stars:  755, grade: 2, streakDays: 10, badge: ''),
  _LeaderEntry(name: 'Sherzod',  emoji: '👦', stars:  620, grade: 3, streakDays: 3,  badge: ''),
  _LeaderEntry(name: 'Gulnora',  emoji: '👧', stars:  510, grade: 2, streakDays: 8,  badge: ''),
  _LeaderEntry(name: 'Doniyor',  emoji: '👦', stars:  445, grade: 1, streakDays: 2,  badge: ''),
  _LeaderEntry(name: 'Sarvinoz', emoji: '👧', stars:  390, grade: 2, streakDays: 6,  badge: ''),
  _LeaderEntry(name: 'Mansur',   emoji: '👦', stars:  280, grade: 1, streakDays: 1,  badge: ''),
];

class LeaderboardScreen extends StatefulWidget {
  final UserProfile profile;
  const LeaderboardScreen({super.key, required this.profile});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // Foydalanuvchi reytingdagi o'rni
  int get _myRank {
    final myStars = widget.profile.stars;
    int rank = 1;
    for (final e in _demoLeaders) {
      if (e.stars > myStars) rank++;
    }
    return rank;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB71C1C), Color(0xFFC62828), Color(0xFFD32F2F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        '🏆 Reyting',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '⭐ ${widget.profile.stars}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Podium (top 3)
              _buildPodium(),

              const SizedBox(height: 12),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: '🌍 Umumiy'),
                    Tab(text: '📚 Mening sinfim'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Ro'yxat
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(_demoLeaders),
                    _buildList(_demoLeaders
                        .where((e) => e.grade == widget.profile.grade)
                        .toList()),
                  ],
                ),
              ),

              // Mening o'rnim
              _buildMyRank(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    if (_demoLeaders.length < 3) return const SizedBox();
    final top3 = _demoLeaders.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2-o'rin
          Expanded(child: _PodiumItem(entry: top3[1], rank: 2, height: 80)),
          // 1-o'rin
          Expanded(child: _PodiumItem(entry: top3[0], rank: 1, height: 110)),
          // 3-o'rin
          Expanded(child: _PodiumItem(entry: top3[2], rank: 3, height: 60)),
        ],
      ),
    );
  }

  Widget _buildList(List<_LeaderEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        final isMe = e.name == widget.profile.name;
        return _LeaderRow(
          entry: e,
          rank: i + 1,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildMyRank() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_myRank',
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.profile.isGirl ? '👧' : '👦',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.profile.name} (sen)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${widget.profile.grade}-sinf • 🔥 ${widget.profile.dailyStreakDays} kun',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '⭐ ${widget.profile.stars}',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final _LeaderEntry entry;
  final int rank;
  final double height;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
  });

  Color get _medalColor {
    if (rank == 1) return const Color(0xFFFFC107);
    if (rank == 2) return const Color(0xFFB0BEC5);
    return const Color(0xFFBF8C4F);
  }

  String get _medal {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    return '🥉';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(entry.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          entry.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          '⭐${entry.stars}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _medalColor.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: _medalColor.withOpacity(0.6)),
          ),
          child: Center(
            child: Text(_medal, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final _LeaderEntry entry;
  final int rank;
  final bool isMe;

  const _LeaderRow({
    required this.entry,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? const Color(0xFFFFC107).withOpacity(0.8)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // O'rin raqami
          SizedBox(
            width: 32,
            child: Text(
              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
              style: TextStyle(
                fontSize: rank <= 3 ? 20 : 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Text(entry.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (entry.badge.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(entry.badge),
                    ],
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Sen',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.grade}-sinf • 🔥${entry.streakDays} kun',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '⭐ ${entry.stars}',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
