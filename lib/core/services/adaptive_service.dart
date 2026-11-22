import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';
import 'game_stats_service.dart';

// ── AI Moslashuvchan savol tizimi (v47) ───────────────────────────────────
// Zaif fanlarni aniqlab, o'sha fandan ko'proq savol beradi
// Qiyinlikni o'yinchi natijasiga qarab sozlaydi

class SubjectStats {
  final String subject;
  final int totalQuestions;
  final int correctAnswers;
  final double avgDifficulty;

  const SubjectStats({
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.avgDifficulty,
  });

  double get accuracy => totalQuestions == 0 ? 0.5 : correctAnswers / totalQuestions;
  bool get isWeak => accuracy < 0.5 && totalQuestions >= 3;
  bool get isStrong => accuracy > 0.75 && totalQuestions >= 3;

  int get recommendedDifficulty {
    if (accuracy < 0.4) return 1;      // Oson
    if (accuracy < 0.65) return 2;     // O'rta
    return 3;                           // Qiyin
  }
}

class AdaptiveQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String subject;
  final int difficulty;
  final String hint;

  const AdaptiveQuestion({
    required this.text, required this.options,
    required this.correctIndex, required this.subject,
    required this.difficulty, this.hint = '',
  });
}

class AdaptiveService extends ChangeNotifier {
  AdaptiveService._();
  static final instance = AdaptiveService._();

  static const _keyPrefix = 'adaptive_';
  // subject → {total, correct, difficulty_sum}
  Map<String, Map<String, int>> _subjectData = {};

  Future<void> init(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = ['Matematika', "O'zbek tili", 'Ingliz tili', 'Tabiat', 'Tarix'];
    for (final s in keys) {
      final key = '$_keyPrefix${profileId}_$s';
      _subjectData[s] = {
        'total': prefs.getInt('${key}_total') ?? 0,
        'correct': prefs.getInt('${key}_correct') ?? 0,
        'diff_sum': prefs.getInt('${key}_diff') ?? 0,
      };
    }
    notifyListeners();
  }

  Future<void> recordAnswer({
    required String profileId,
    required String subject,
    required bool correct,
    required int difficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final d = _subjectData[subject] ?? {'total': 0, 'correct': 0, 'diff_sum': 0};
    d['total'] = (d['total'] ?? 0) + 1;
    if (correct) d['correct'] = (d['correct'] ?? 0) + 1;
    d['diff_sum'] = (d['diff_sum'] ?? 0) + difficulty;
    _subjectData[subject] = d;

    final key = '$_keyPrefix${profileId}_$subject';
    await prefs.setInt('${key}_total', d['total']!);
    await prefs.setInt('${key}_correct', d['correct']!);
    await prefs.setInt('${key}_diff', d['diff_sum']!);
    notifyListeners();
  }

  List<SubjectStats> getStats() {
    return _subjectData.entries.map((e) {
      final total = e.value['total'] ?? 0;
      final correct = e.value['correct'] ?? 0;
      final diffSum = e.value['diff_sum'] ?? 0;
      return SubjectStats(
        subject: e.key,
        totalQuestions: total,
        correctAnswers: correct,
        avgDifficulty: total > 0 ? diffSum / total : 1.5,
      );
    }).toList();
  }

  List<String> getWeakSubjects() =>
      getStats().where((s) => s.isWeak).map((s) => s.subject).toList();

  List<String> getStrongSubjects() =>
      getStats().where((s) => s.isStrong).map((s) => s.subject).toList();

  // Moslashuvchan savol tanlash
  List<AdaptiveQuestion> selectQuestions(int count) {
    final stats = getStats();
    final allQ = List.of(_questionBank);
    allQ.shuffle(Random());

    final selected = <AdaptiveQuestion>[];
    final usedSubjects = <String>{};

    // 1. Avval zaif fanlardan
    for (final stat in stats.where((s) => s.isWeak)) {
      final subjectQ = allQ.where((q) =>
        q.subject == stat.subject &&
        q.difficulty == stat.recommendedDifficulty).toList();
      if (subjectQ.isNotEmpty && selected.length < count) {
        selected.add(subjectQ.first);
        usedSubjects.add(stat.subject);
      }
    }

    // 2. Qolganlarni qiyinlikka qarab to'ldirish
    for (final stat in stats.where((s) => !s.isWeak)) {
      final subjectQ = allQ.where((q) =>
        q.subject == stat.subject &&
        q.difficulty == stat.recommendedDifficulty &&
        !selected.any((s) => s.text == q.text)).toList();
      if (subjectQ.isNotEmpty && selected.length < count) {
        selected.add(subjectQ.first);
      }
    }

    // 3. Yetmasa tasodifiy to'ldirish
    while (selected.length < count && allQ.isNotEmpty) {
      final remaining = allQ.where(
          (q) => !selected.any((s) => s.text == q.text)).toList();
      if (remaining.isEmpty) break;
      selected.add(remaining[Random().nextInt(remaining.length)]);
    }

    selected.shuffle(Random());
    return selected.take(count).toList();
  }
}

// ── Katta savol banki ─────────────────────────────────────────────────────
const _questionBank = [
  // ── Matematika 1 (oson) ──
  AdaptiveQuestion(text: '5 + 7 = ?',    options: ['10','11','12','13'], correctIndex: 2, subject: 'Matematika', difficulty: 1, hint: "5 dan 7 ta qo'shing"),
  AdaptiveQuestion(text: '3 × 4 = ?',    options: ['10','11','12','14'], correctIndex: 2, subject: 'Matematika', difficulty: 1),
  AdaptiveQuestion(text: '20 - 8 = ?',   options: ['10','11','12','13'], correctIndex: 2, subject: 'Matematika', difficulty: 1),
  AdaptiveQuestion(text: '18 ÷ 3 = ?',   options: ['4','5','6','7'],     correctIndex: 2, subject: 'Matematika', difficulty: 1),
  // ── Matematika 2 (o'rta) ──
  AdaptiveQuestion(text: '7 × 8 = ?',    options: ['54','56','58','60'], correctIndex: 1, subject: 'Matematika', difficulty: 2),
  AdaptiveQuestion(text: '144 ÷ 12 = ?', options: ['10','11','12','13'], correctIndex: 2, subject: 'Matematika', difficulty: 2),
  AdaptiveQuestion(text: '3 + 4 × 2 = ?',options: ['10','11','14','12'], correctIndex: 1, subject: 'Matematika', difficulty: 2, hint: "Avval ko'paytma"),
  AdaptiveQuestion(text: '√81 = ?',      options: ['7','8','9','10'],    correctIndex: 2, subject: 'Matematika', difficulty: 2),
  // ── Matematika 3 (qiyin) ──
  AdaptiveQuestion(text: '15² = ?',      options: ['175','200','225','250'],correctIndex:2,subject: 'Matematika', difficulty: 3),
  AdaptiveQuestion(text: '2³ × 3 = ?',   options: ['18','24','20','16'], correctIndex: 1, subject: 'Matematika', difficulty: 3),
  // ── O'zbek tili 1 ──
  AdaptiveQuestion(text: '"Kitob" ko\'pligi?', options: ['Kitoblar','Kitobi','Kitobning','Kitobga'], correctIndex: 0, subject: "O'zbek tili", difficulty: 1),
  AdaptiveQuestion(text: 'Qaysi so\'z ot?', options: ['Chiroyli','Yugurmoq','Bog\'','Tez'], correctIndex: 2, subject: "O'zbek tili", difficulty: 1),
  AdaptiveQuestion(text: '"Baxt" antonimi?', options: ['Quvonch','Shodlik','Baxtsizlik','Zavq'], correctIndex: 2, subject: "O'zbek tili", difficulty: 2),
  AdaptiveQuestion(text: '"Keldi" fe\'l zamonligi?', options: ['Hozirgi','O\'tgan','Kelasi','Buyruq'], correctIndex: 1, subject: "O'zbek tili", difficulty: 2),
  // ── Ingliz tili 1 ──
  AdaptiveQuestion(text: '"Apple" = ?', options: ['Nok','Olma','Limon','Uzum'], correctIndex: 1, subject: 'Ingliz tili', difficulty: 1),
  AdaptiveQuestion(text: 'I ___ a student.', options: ['am','is','are','be'], correctIndex: 0, subject: 'Ingliz tili', difficulty: 1),
  AdaptiveQuestion(text: '"Yesterday" = ?', options: ['Bugun','Ertaga','Kecha','Hozir'], correctIndex: 2, subject: 'Ingliz tili', difficulty: 1),
  AdaptiveQuestion(text: 'She ___ books. (3rd person)', options: ['read','reads','reading','readed'], correctIndex: 1, subject: 'Ingliz tili', difficulty: 2),
  // ── Tabiat ──
  AdaptiveQuestion(text: 'Fotosintez uchun nima kerak?', options: ['Kislorod','Suv+Yorug\'lik','Azot','Karbonat'], correctIndex: 1, subject: 'Tabiat', difficulty: 2, hint: "O'simliklar nima ishlatadi?"),
  AdaptiveQuestion(text: 'Qon aylanishni qaysi organ boshqaradi?', options: ['Jigar','O\'pka','Yurak','Buyrak'], correctIndex: 2, subject: 'Tabiat', difficulty: 1),
  AdaptiveQuestion(text: 'Quyoshdan eng yaqin sayyora?', options: ['Venera','Yer','Mars','Merkuriy'], correctIndex: 3, subject: 'Tabiat', difficulty: 2),
  AdaptiveQuestion(text: 'Suv necha darajada qaynaydi?', options: ['90°C','95°C','100°C','105°C'], correctIndex: 2, subject: 'Tabiat', difficulty: 1),
  // ── Tarix ──
  AdaptiveQuestion(text: 'Amir Temur qachon tug\'ilgan?', options: ['1336','1356','1300','1375'], correctIndex: 0, subject: 'Tarix', difficulty: 2),
  AdaptiveQuestion(text: 'O\'zbekiston mustaqilligi?', options: ['1990','1991','1992','1989'], correctIndex: 1, subject: 'Tarix', difficulty: 1),
  AdaptiveQuestion(text: 'Registon meydoni qayerda?', options: ['Toshkent','Buxoro','Samarqand','Xiva'], correctIndex: 2, subject: 'Tarix', difficulty: 1),
];
