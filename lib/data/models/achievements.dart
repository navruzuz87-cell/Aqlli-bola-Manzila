// Yutuqlar (Achievements) tizimi

enum AchievementCategory {
  stars,    // Yulduz yig'ish
  streak,   // Kun ketma-ket
  subjects, // Fanlar
  speed,    // Tezlik
  special,  // Maxsus
}

class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final AchievementCategory category;
  final int requiredValue;   // Maqsad
  final int starsReward;
  final bool isSecret;       // Yashirin yutuq

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredValue,
    required this.starsReward,
    this.isSecret = false,
  });
}

class Achievements {
  static const List<Achievement> all = [
    // ── Yulduz yutuqlari ──────────────────────────────
    Achievement(
      id: 'stars_10',
      emoji: '⭐',
      title: 'Birinchi yulduz!',
      description: '10 ta yulduz yig\'',
      category: AchievementCategory.stars,
      requiredValue: 10,
      starsReward: 5,
    ),
    Achievement(
      id: 'stars_50',
      emoji: '🌟',
      title: 'Yulduz to\'plash',
      description: '50 ta yulduz yig\'',
      category: AchievementCategory.stars,
      requiredValue: 50,
      starsReward: 15,
    ),
    Achievement(
      id: 'stars_100',
      emoji: '💫',
      title: 'Yulduz ustasi',
      description: '100 ta yulduz yig\'',
      category: AchievementCategory.stars,
      requiredValue: 100,
      starsReward: 30,
    ),
    Achievement(
      id: 'stars_500',
      emoji: '🏆',
      title: 'Yulduz Qiroli',
      description: '500 ta yulduz yig\'',
      category: AchievementCategory.stars,
      requiredValue: 500,
      starsReward: 100,
    ),

    // ── Streak yutuqlari ──────────────────────────────
    Achievement(
      id: 'streak_3',
      emoji: '🔥',
      title: 'Uch kun!',
      description: '3 kun ketma-ket o\'yna',
      category: AchievementCategory.streak,
      requiredValue: 3,
      starsReward: 20,
    ),
    Achievement(
      id: 'streak_7',
      emoji: '🔥🔥',
      title: 'Bir hafta!',
      description: '7 kun ketma-ket o\'yna',
      category: AchievementCategory.streak,
      requiredValue: 7,
      starsReward: 50,
    ),
    Achievement(
      id: 'streak_30',
      emoji: '🌋',
      title: 'Bir oy!',
      description: '30 kun ketma-ket o\'yna',
      category: AchievementCategory.streak,
      requiredValue: 30,
      starsReward: 200,
    ),

    // ── Fan yutuqlari ──────────────────────────────
    Achievement(
      id: 'math_10',
      emoji: '🧮',
      title: 'Matematik',
      description: 'Matematikada 10 ta to\'g\'ri javob',
      category: AchievementCategory.subjects,
      requiredValue: 10,
      starsReward: 25,
    ),
    Achievement(
      id: 'uzbek_10',
      emoji: '🇺🇿',
      title: 'Ona tili piri',
      description: 'Ona tilida 10 ta to\'g\'ri javob',
      category: AchievementCategory.subjects,
      requiredValue: 10,
      starsReward: 25,
    ),
    Achievement(
      id: 'geo_10',
      emoji: '🌍',
      title: 'Geografiyachi',
      description: 'Geografiyada 10 ta to\'g\'ri javob',
      category: AchievementCategory.subjects,
      requiredValue: 10,
      starsReward: 25,
    ),
    Achievement(
      id: 'history_10',
      emoji: '🏺',
      title: 'Tarixchi',
      description: 'Tarixda 10 ta to\'g\'ri javob',
      category: AchievementCategory.subjects,
      requiredValue: 10,
      starsReward: 25,
    ),
    Achievement(
      id: 'english_10',
      emoji: '🇬🇧',
      title: 'English Star',
      description: 'Ingliz tilida 10 ta to\'g\'ri javob',
      category: AchievementCategory.subjects,
      requiredValue: 10,
      starsReward: 25,
    ),
    Achievement(
      id: 'all_subjects',
      emoji: '🎓',
      title: 'Har tomonlama!',
      description: 'Barcha 6 fanda o\'yna',
      category: AchievementCategory.subjects,
      requiredValue: 6,
      starsReward: 60,
    ),

    // ── Maxsus (yashirin) ──────────────────────────────
    Achievement(
      id: 'perfect_game',
      emoji: '💎',
      title: 'Mukammal!',
      description: 'Bir o\'yinda 100% natija',
      category: AchievementCategory.special,
      requiredValue: 1,
      starsReward: 50,
      isSecret: true,
    ),
    Achievement(
      id: 'night_owl',
      emoji: '🦉',
      title: 'Boyo\'g\'li',
      description: 'Kechqurun o\'yna (yashirin)',
      category: AchievementCategory.special,
      requiredValue: 1,
      starsReward: 30,
      isSecret: true,
    ),
    Achievement(
      id: 'first_shop',
      emoji: '🛒',
      title: 'Birinchi xarid',
      description: 'Do\'kondan biror narsa ol',
      category: AchievementCategory.special,
      requiredValue: 1,
      starsReward: 10,
    ),
  ];

  /// Qaysi yutuqlar ochilganini tekshirish
  static List<String> checkUnlocked({
    required int totalStars,
    required int streakDays,
    required Map<String, int> subjectCorrect,
    required bool hadPerfectGame,
    required bool boughtFromShop,
  }) {
    final unlocked = <String>[];

    for (final a in all) {
      switch (a.category) {
        case AchievementCategory.stars:
          if (totalStars >= a.requiredValue) unlocked.add(a.id);
          break;
        case AchievementCategory.streak:
          if (streakDays >= a.requiredValue) unlocked.add(a.id);
          break;
        case AchievementCategory.subjects:
          if (a.id == 'all_subjects') {
            if (subjectCorrect.length >= 6) unlocked.add(a.id);
          } else {
            final key = a.id.split('_').first;
            if ((subjectCorrect[key] ?? 0) >= a.requiredValue) unlocked.add(a.id);
          }
          break;
        case AchievementCategory.special:
          if (a.id == 'perfect_game' && hadPerfectGame) unlocked.add(a.id);
          if (a.id == 'first_shop' && boughtFromShop) unlocked.add(a.id);
          break;
        default:
          break;
      }
    }

    return unlocked;
  }
}
