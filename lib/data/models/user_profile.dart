import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  /// Profil kartasida ko‘rsatiladigan avatar belgisi.
  final String avatarEmoji;
  final int? grade;
  /// Yosh (yil hisobida); grade (maktab sinfi) bilan aralashtirilmaydi.
  final int? age;
  final int stars;
  final int gems;
  final String selectedCompanion;
  final Map<String, int> subjectProgress; // subject -> level (1-10)
  final int avatarSkin;    // 0-3
  final int avatarHair;    // 0-3
  final int avatarClothes; // 0-3
  final String gender;     // 'boy' | 'girl'
  final int dailyStreakDays;
  final String ownedItems; // comma-separated item ids
  final Map<String, int> subjectStars; // subject -> stars earned
  final int totalPlayMinutes; // umumiy o'ynalgan daqiqa

  // Missions progress: mission_id -> current count (bugungi kun uchun)
  final Map<String, int> missionProgress;
  // Bugungi yulduzlar (streak/mission reset uchun)
  final int todayStarsEarned;
  // Oxirgi o'ynalgan kun (YYYY-MM-DD formatida)
  final String lastPlayDate;
  // Bugun o'ynalgan fanlar soni (mission: playSubjects)
  final int todaySubjectsPlayed;
  // Bugun yig'ilgan combo soni
  final int todayCombos;

  // ── Shaharcha resurslari ─────────────────────────────────
  // tosh (matematika), yogoch (ona_tili), mis (tarix),
  // tuproq (geo), shisha (ingliz), gul (odobnoma)
  final Map<String, int> cityResources;
  // Binolar darajasi: 'alpomish_qala', 'zumrad_kutubxona',
  // 'spitamen_muzey', 'rustam_maydon', 'semurg_minora', 'donishmand_bog'
  final Map<String, int> buildingLevels;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarEmoji = '🧒',
    this.grade,
    this.age,
    this.stars = 0,
    this.gems = 0,
    this.selectedCompanion = 'alpomish',
    this.subjectProgress = const {},
    this.avatarSkin = 0,
    this.avatarHair = 0,
    this.avatarClothes = 0,
    this.gender = 'boy',
    this.dailyStreakDays = 0,
    this.ownedItems = '',
    this.subjectStars = const {},
    this.totalPlayMinutes = 0,
    this.missionProgress = const {},
    this.todayStarsEarned = 0,
    this.lastPlayDate = '',
    this.todaySubjectsPlayed = 0,
    this.todayCombos = 0,
    this.cityResources = const {},
    this.buildingLevels = const {},
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarEmoji,
    int? grade,
    int? age,
    int? stars,
    int? gems,
    String? selectedCompanion,
    Map<String, int>? subjectProgress,
    int? avatarSkin,
    int? avatarHair,
    int? avatarClothes,
    String? gender,
    int? dailyStreakDays,
    String? ownedItems,
    Map<String, int>? subjectStars,
    int? totalPlayMinutes,
    Map<String, int>? missionProgress,
    int? todayStarsEarned,
    String? lastPlayDate,
    int? todaySubjectsPlayed,
    int? todayCombos,
    Map<String, int>? cityResources,
    Map<String, int>? buildingLevels,
    // backward-compat aliases
    int? totalStars,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      grade: grade ?? this.grade,
      age: age ?? this.age,
      stars: totalStars ?? stars ?? this.stars,
      gems: gems ?? this.gems,
      selectedCompanion: selectedCompanion ?? this.selectedCompanion,
      subjectProgress: subjectProgress ?? this.subjectProgress,
      avatarSkin: avatarSkin ?? this.avatarSkin,
      avatarHair: avatarHair ?? this.avatarHair,
      avatarClothes: avatarClothes ?? this.avatarClothes,
      gender: gender ?? this.gender,
      dailyStreakDays: dailyStreakDays ?? this.dailyStreakDays,
      ownedItems: ownedItems ?? this.ownedItems,
      subjectStars: subjectStars ?? this.subjectStars,
      totalPlayMinutes: totalPlayMinutes ?? this.totalPlayMinutes,
      missionProgress: missionProgress ?? this.missionProgress,
      todayStarsEarned: todayStarsEarned ?? this.todayStarsEarned,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      todaySubjectsPlayed: todaySubjectsPlayed ?? this.todaySubjectsPlayed,
      todayCombos: todayCombos ?? this.todayCombos,
      cityResources: cityResources ?? this.cityResources,
      buildingLevels: buildingLevels ?? this.buildingLevels,
    );
  }

  factory UserProfile.fromJson(dynamic source) {
    final Map<String, dynamic> json = source is String
        ? jsonDecode(source) as Map<String, dynamic>
        : source as Map<String, dynamic>;
    return UserProfile(
      id: (json['id'] as String?) ?? 'legacy-${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] as String,
      avatarEmoji: (json['avatarEmoji'] as String?) ?? '🧒',
      grade: json['grade'] as int?,
      age: json['age'] as int?,
      stars: (json['stars'] as int?) ?? 0,
      gems: (json['gems'] as int?) ?? 0,
      selectedCompanion: (json['selectedCompanion'] as String?) ?? 'alpomish',
      subjectProgress: (json['subjectProgress'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      avatarSkin: (json['avatarSkin'] as int?) ?? 0,
      avatarHair: (json['avatarHair'] as int?) ?? 0,
      avatarClothes: (json['avatarClothes'] as int?) ?? 0,
      gender: (json['gender'] as String?) ??
          ((json['isGirl'] as bool? ?? false) ? 'girl' : 'boy'),
      dailyStreakDays: (json['dailyStreakDays'] as int?) ?? 0,
      ownedItems: (json['ownedItems'] as String?) ?? '',
      subjectStars: (json['subjectStars'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      totalPlayMinutes: (json['totalPlayMinutes'] as int?) ?? 0,
      missionProgress: (json['missionProgress'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      todayStarsEarned: (json['todayStarsEarned'] as int?) ?? 0,
      lastPlayDate: (json['lastPlayDate'] as String?) ?? '',
      todaySubjectsPlayed: (json['todaySubjectsPlayed'] as int?) ?? 0,
      todayCombos: (json['todayCombos'] as int?) ?? 0,
      cityResources: (json['cityResources'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      buildingLevels: (json['buildingLevels'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarEmoji': avatarEmoji,
    'grade': grade,
    'age': age,
    'stars': stars,
    'gems': gems,
    'selectedCompanion': selectedCompanion,
    'subjectProgress': subjectProgress,
    'avatarSkin': avatarSkin,
    'avatarHair': avatarHair,
    'avatarClothes': avatarClothes,
    'gender': gender,
    'dailyStreakDays': dailyStreakDays,
    'ownedItems': ownedItems,
    'subjectStars': subjectStars,
    'totalPlayMinutes': totalPlayMinutes,
    'missionProgress': missionProgress,
    'todayStarsEarned': todayStarsEarned,
    'lastPlayDate': lastPlayDate,
    'todaySubjectsPlayed': todaySubjectsPlayed,
    'todayCombos': todayCombos,
    'cityResources': cityResources,
    'buildingLevels': buildingLevels,
  };

  // Helpers
  int get totalStars => stars;

  bool get isGirl => gender == 'girl';

  int get playerLevel {
    if (subjectProgress.isEmpty) return 1;
    final avg = subjectProgress.values.reduce((a, b) => a + b) /
        subjectProgress.length;
    return avg.round().clamp(1, 10);
  }

  String get strongestSubject {
    if (subjectStars.isEmpty) return '—';
    final entry = subjectStars.entries.reduce(
        (a, b) => a.value >= b.value ? a : b);
    return entry.key;
  }

  String? get weakestSubject {
    if (subjectStars.length < 2) return null;
    final entry = subjectStars.entries.reduce(
        (a, b) => a.value <= b.value ? a : b);
    return entry.key;
  }

  /// Bugungi sana string (YYYY-MM-DD)
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  /// Yangi kun boshlanganini tekshirib, bugungi hisoblarni reset qiladi
  UserProfile resetDailyIfNeeded() {
    final today = UserProfile.todayKey();
    if (lastPlayDate == today) return this;
    // Yangi kun: streak +1 (agar kecha o'ynagan bo'lsa), bugungi hisoblar 0
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
    final newStreak = lastPlayDate == yesterdayKey
        ? dailyStreakDays + 1
        : (lastPlayDate.isEmpty ? dailyStreakDays : 1);
    return copyWith(
      lastPlayDate: today,
      todayStarsEarned: 0,
      todaySubjectsPlayed: 0,
      todayCombos: 0,
      missionProgress: const {},
      dailyStreakDays: newStreak,
    );
  }
}
