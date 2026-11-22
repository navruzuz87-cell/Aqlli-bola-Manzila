import '../../data/models/user_profile.dart';
import '../../data/models/daily_missions.dart';

/// O'yin natijasini missions progressiga aylantiruvchi helper
class MissionHelper {
  /// O'yin tugagandan keyin profil yangilaydi:
  /// - todayStarsEarned += starsEarned
  /// - todaySubjectsPlayed += 1
  /// - todayCombos += combosGot
  /// - missionProgress yangilanadi (avtomatik tekshiruv)
  static UserProfile applyGameResult(
    UserProfile profile, {
    required int starsEarned,
    int correctAnswers = 0,
    int combosGot = 0,
  }) {
    final today = UserProfile.todayKey();
    // Yangi kun bo'lsa reset
    var p = profile.lastPlayDate == today
        ? profile
        : profile.resetDailyIfNeeded();

    // Bugungi hisoblarni yangilaymiz
    final newTodayStars = p.todayStarsEarned + starsEarned;
    final newSubjects = p.todaySubjectsPlayed + 1;
    final newCombos = p.todayCombos + combosGot;

    // Missions progress yangilash
    final missions = DailyMissions.getToday();
    final prog = Map<String, int>.from(p.missionProgress);

    for (final m in missions) {
      if (prog[m.id] != null && prog[m.id]! >= m.target) continue; // tugagan
      switch (m.type) {
        case MissionType.earnStars:
          prog[m.id] = newTodayStars.clamp(0, m.target);
          break;
        case MissionType.playSubjects:
          prog[m.id] = newSubjects.clamp(0, m.target);
          break;
        case MissionType.getCombo:
          prog[m.id] = newCombos.clamp(0, m.target);
          break;
        case MissionType.playQuestions:
          prog[m.id] = ((prog[m.id] ?? 0) + correctAnswers).clamp(0, m.target);
          break;
        case MissionType.streak:
          // Streak mission: o'ynagan bo'lsa 1
          prog[m.id] = 1;
          break;
      }
    }

    // Tugallangan mission lari uchun bonus yulduzlar
    int bonusStars = 0;
    for (final m in missions) {
      final prev = p.missionProgress[m.id] ?? 0;
      final curr = prog[m.id] ?? 0;
      if (prev < m.target && curr >= m.target) {
        // Yangi tugallandi!
        bonusStars += m.starsReward;
      }
    }

    return p.copyWith(
      stars: p.stars + starsEarned + bonusStars,
      todayStarsEarned: newTodayStars,
      todaySubjectsPlayed: newSubjects,
      todayCombos: newCombos,
      missionProgress: prog,
    );
  }

  /// Bugungi missions va ularning real progressini qaytaradi
  static List<DailyMission> getTodayWithProgress(UserProfile profile) {
    final today = UserProfile.todayKey();
    final prog = profile.lastPlayDate == today
        ? profile.missionProgress
        : const <String, int>{};
    return DailyMissions.getToday().map((m) {
      final cur = prog[m.id] ?? 0;
      return m.copyWith(
        current: cur.clamp(0, m.target),
        completed: cur >= m.target,
      );
    }).toList();
  }

  /// Bugun nechta mission tugallangan
  static int completedCount(UserProfile profile) {
    return getTodayWithProgress(profile).where((m) => m.completed).length;
  }
}
