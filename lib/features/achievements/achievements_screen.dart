import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/achievements.dart';

class AchievementsScreen extends StatelessWidget {
  final UserProfile profile;

  const AchievementsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Demo: ba'zi yutuqlarni ochilgan deb ko'rsatamiz
    final unlockedIds = _getUnlocked();

    final categories = AchievementCategory.values;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
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
                        '🏆 Yutuqlar',
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
                        '${unlockedIds.length}/${Achievements.all.length}',
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

              // Umumiy progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: Achievements.all.isEmpty
                            ? 0
                            : unlockedIds.length / Achievements.all.length,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${unlockedIds.length} ta yutuq ochildi!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Kategoriyalar bo'yicha
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((cat) {
                    final catItems = Achievements.all
                        .where((a) => a.category == cat)
                        .toList();
                    return _CategorySection(
                      category: cat,
                      items: catItems,
                      unlockedIds: unlockedIds,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Set<String> _getUnlocked() {
    // Do'kondan xarid qilganini subjectStars orqali bilamiz (odobnoma > 0 = shop unlocked)
    final boughtFromShop = (profile.subjectStars['shop_bought'] ?? 0) > 0
        || profile.stars < profile.stars; // fallback: har doim false emas

    final unlocked = Achievements.checkUnlocked(
      totalStars: profile.stars,
      streakDays: profile.dailyStreakDays,
      subjectCorrect: profile.subjectStars,
      hadPerfectGame: profile.subjectStars.values.any((v) => v >= 30),
      boughtFromShop: boughtFromShop,
    );
    return unlocked.toSet();
  }
}

class _CategorySection extends StatelessWidget {
  final AchievementCategory category;
  final List<Achievement> items;
  final Set<String> unlockedIds;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.unlockedIds,
  });

  String get _catLabel {
    switch (category) {
      case AchievementCategory.stars:    return '⭐ Yulduzlar';
      case AchievementCategory.streak:   return '🔥 Streak';
      case AchievementCategory.subjects: return '📚 Fanlar';
      case AchievementCategory.speed:    return '⚡ Tezlik';
      case AchievementCategory.special:  return '🎁 Maxsus';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            _catLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.82,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final a = items[i];
            final unlocked = unlockedIds.contains(a.id);
            final secret = a.isSecret && !unlocked;
            return _AchievementTile(
              achievement: a,
              unlocked: unlocked,
              secret: secret,
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final bool secret;

  const _AchievementTile({
    required this.achievement,
    required this.unlocked,
    required this.secret,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!unlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                secret
                    ? '🔒 Bu yashirin yutuq — kashf et!'
                    : '${achievement.description} — davom et! 💪',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked
              ? Colors.white.withOpacity(0.22)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? const Color(0xFFFFC107).withOpacity(0.7)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              secret ? '❓' : achievement.emoji,
              style: TextStyle(
                fontSize: 34,
                color: unlocked ? null : const Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              secret ? '???' : achievement.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.white : Colors.white38,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (unlocked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${achievement.starsReward}⭐',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              )
            else
              Text(
                '${achievement.starsReward}⭐',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
