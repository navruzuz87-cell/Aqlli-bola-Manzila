// Kunlik vazifalar tizimi

enum MissionType {
  playQuestions,  // N ta savol javobla
  playSubjects,   // N ta fan o'yna
  getCombo,       // Combo yig'ish
  earnStars,      // N ta yulduz top
  streak,         // Streak saqlash
}

class DailyMission {
  final String id;
  final MissionType type;
  final String emoji;
  final String title;
  final String description;
  final int target;       // Maqsad soni
  final int current;      // Joriy progress
  final int starsReward;  // Mukofot
  final bool completed;

  const DailyMission({
    required this.id,
    required this.type,
    required this.emoji,
    required this.title,
    required this.description,
    required this.target,
    this.current = 0,
    required this.starsReward,
    this.completed = false,
  });

  DailyMission copyWith({int? current, bool? completed}) => DailyMission(
        id: id,
        type: type,
        emoji: emoji,
        title: title,
        description: description,
        target: target,
        current: current ?? this.current,
        starsReward: starsReward,
        completed: completed ?? this.completed,
      );

  double get progress => (current / target).clamp(0.0, 1.0);
}

class DailyMissions {
  /// Bugungi kun uchun 3 ta vazifa qaytaradi (kun bo'yicha rotatsiya)
  static List<DailyMission> getToday() {
    final day = DateTime.now().weekday; // 1=Dush, 7=Yak
    return _rotations[day % _rotations.length];
  }

  static const List<List<DailyMission>> _rotations = [
    // Dushanba
    [
      DailyMission(id: 'd1a', type: MissionType.playQuestions,
          emoji: '✅', title: '10 ta savol javobla',
          description: 'Istalgan fanda 10 ta to\'g\'ri javob ber',
          target: 10, starsReward: 30),
      DailyMission(id: 'd1b', type: MissionType.playSubjects,
          emoji: '📚', title: '2 ta fan o\'yna',
          description: 'Kamida 2 xil fanda o\'yna',
          target: 2, starsReward: 20),
      DailyMission(id: 'd1c', type: MissionType.streak,
          emoji: '🔥', title: 'Kun saqlа',
          description: 'Bugun o\'ynab streak\'ni davom ettir',
          target: 1, starsReward: 15),
    ],
    // Seshanba
    [
      DailyMission(id: 'd2a', type: MissionType.earnStars,
          emoji: '⭐', title: '50 yulduz top',
          description: 'Bugun 50 ta yulduz yig\'',
          target: 50, starsReward: 25),
      DailyMission(id: 'd2b', type: MissionType.getCombo,
          emoji: '🔥', title: '3 ta combo yig\'',
          description: 'Ketma-ket to\'g\'ri javob bilan combo qil',
          target: 3, starsReward: 20),
      DailyMission(id: 'd2c', type: MissionType.playSubjects,
          emoji: '🌍', title: 'Geografiya o\'yna',
          description: 'Geografiya fanida bir partiya o\'yna',
          target: 1, starsReward: 15),
    ],
    // Chorshanba
    [
      DailyMission(id: 'd3a', type: MissionType.playQuestions,
          emoji: '🧮', title: 'Matematika — 5 ta',
          description: 'Matematikada 5 ta to\'g\'ri javob',
          target: 5, starsReward: 20),
      DailyMission(id: 'd3b', type: MissionType.earnStars,
          emoji: '⭐', title: '30 yulduz top',
          description: 'Bugun 30 ta yulduz yig\'',
          target: 30, starsReward: 15),
      DailyMission(id: 'd3c', type: MissionType.playSubjects,
          emoji: '🤝', title: 'Odobnoma o\'yna',
          description: 'Odobnoma hikoyasini tugat',
          target: 1, starsReward: 15),
    ],
    // Payshanba
    [
      DailyMission(id: 'd4a', type: MissionType.playSubjects,
          emoji: '🇬🇧', title: 'Ingliz tili o\'yna',
          description: 'English Fun! o\'yinida bir partiya',
          target: 1, starsReward: 20),
      DailyMission(id: 'd4b', type: MissionType.getCombo,
          emoji: '⚡', title: '5 ta combo yig\'',
          description: 'Combo x2 ni 5 marta qo\'lga kirit',
          target: 5, starsReward: 30),
      DailyMission(id: 'd4c', type: MissionType.streak,
          emoji: '🔥', title: 'Streak saqlа',
          description: 'Bugun o\'yinni to\'xtatma',
          target: 1, starsReward: 10),
    ],
    // Juma
    [
      DailyMission(id: 'd5a', type: MissionType.playQuestions,
          emoji: '🏺', title: 'Tarix — 5 ta',
          description: 'Tarix fanida 5 ta to\'g\'ri javob',
          target: 5, starsReward: 20),
      DailyMission(id: 'd5b', type: MissionType.earnStars,
          emoji: '🌟', title: '80 yulduz top',
          description: 'Bugun eng ko\'p yulduz yig\'',
          target: 80, starsReward: 40),
      DailyMission(id: 'd5c', type: MissionType.playSubjects,
          emoji: '🇺🇿', title: 'Ona tili o\'yna',
          description: 'Ona tilida qal\'a qur',
          target: 1, starsReward: 15),
    ],
    // Shanba
    [
      DailyMission(id: 'd6a', type: MissionType.playSubjects,
          emoji: '🎮', title: '3 ta fan o\'yna',
          description: 'Kamida 3 xil fanda o\'yna',
          target: 3, starsReward: 35),
      DailyMission(id: 'd6b', type: MissionType.earnStars,
          emoji: '💫', title: '100 yulduz top',
          description: 'Shanba — katta kun! 100 yulduz yig\'',
          target: 100, starsReward: 50),
      DailyMission(id: 'd6c', type: MissionType.streak,
          emoji: '🔥', title: 'Streak davom ettir',
          description: 'Bugun ham o\'yna',
          target: 1, starsReward: 20),
    ],
    // Yakshanba
    [
      DailyMission(id: 'd7a', type: MissionType.playQuestions,
          emoji: '🏆', title: '20 ta savol javobla',
          description: 'Yakshanba — champion kuni! 20 ta savol',
          target: 20, starsReward: 50),
      DailyMission(id: 'd7b', type: MissionType.getCombo,
          emoji: '⚡', title: 'Super combo — 3 marta',
          description: 'x2 combo ni 3 marta qil',
          target: 3, starsReward: 30),
      DailyMission(id: 'd7c', type: MissionType.earnStars,
          emoji: '🌟', title: '50 yulduz top',
          description: 'Yakshanba bonusi',
          target: 50, starsReward: 25),
    ],
  ];
}
