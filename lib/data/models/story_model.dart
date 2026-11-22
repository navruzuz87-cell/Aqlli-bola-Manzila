// ══════════════════════════════════════════════════════════════════════════════
// MANZILA — Ertak Qahramonlari Tizimi
// Har bir fan o'z ertaki, qahramoni va sujetiga ega
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

enum StorySubject {
  matematika,  // Susambil — Eshak va o'tloq
  onaTili,     // Zumrad va Qimmat — Sehrli sandiq
  tarix,       // Shiroq — Vatan himoyachisi
  geografiya,  // Alpomish — Bahodir sayohati
  inglizTili,  // Tumarisxon — Diplomat malika
  odobnoma,    // Avazxon — Mehmondo'st sayohat
}

// ── Ertak qahramoni ───────────────────────────────────────────────────────────
class StoryHero {
  final StorySubject subject;
  final String heroName;         // Alpomish
  final String heroEmoji;        // 🦸
  final String companionName;    // Barchinoy (kahramon do'sti)
  final String companionEmoji;   // 👸
  final String worldName;        // "Boysun tog'lari"
  final String worldEmoji;       // 🏔️
  final String questTitle;       // "Barchinoyni qutqar!"
  final String questDescription; // To'liq sujet
  final String winEnding;        // Yaxshi tugash matni
  final String loseEnding;       // Yomon tugash matni
  final List<Color> storyColors; // Ertak ranglari
  final String bgPattern;        // Fon naqsh turi

  const StoryHero({
    required this.subject,
    required this.heroName,
    required this.heroEmoji,
    required this.companionName,
    required this.companionEmoji,
    required this.worldName,
    required this.worldEmoji,
    required this.questTitle,
    required this.questDescription,
    required this.winEnding,
    required this.loseEnding,
    required this.storyColors,
    required this.bgPattern,
  });
}

// ── Manzila AI Robot maslahat ────────────────────────────────────────────────
class RobotHint {
  final String question;    // Savol matni
  final String hint;        // Robot maslahat
  final String robotMood;   // 'thinking' | 'helping' | 'celebrating' | 'sad'
  const RobotHint({
    required this.question,
    required this.hint,
    this.robotMood = 'thinking',
  });
}

// ── O'yin holati ──────────────────────────────────────────────────────────────
class StoryProgress {
  final int totalSteps;      // Jami qadam
  final int currentStep;     // Hozirgi qadam
  final int heroHealth;      // Kahramon sog'lig'i (0-5 ❤️)
  final bool companionHappy; // Do'st xursandmi?
  final String mood;         // 'great'|'good'|'ok'|'worried'|'sad'

  const StoryProgress({
    required this.totalSteps,
    required this.currentStep,
    required this.heroHealth,
    required this.companionHappy,
    required this.mood,
  });

  double get progress => currentStep / totalSteps;

  StoryProgress withStep(int step) => StoryProgress(
    totalSteps: totalSteps,
    currentStep: step,
    heroHealth: heroHealth,
    companionHappy: companionHappy,
    mood: mood,
  );

  StoryProgress withHealth(int health) => StoryProgress(
    totalSteps: totalSteps,
    currentStep: currentStep,
    heroHealth: health.clamp(0, 5),
    companionHappy: health >= 3,
    mood: health >= 4 ? 'great' : health >= 3 ? 'good' : health >= 2 ? 'ok' : health >= 1 ? 'worried' : 'sad',
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ERTAK MA'LUMOTLARI — Barcha 6 fan
// ══════════════════════════════════════════════════════════════════════════════

class StoryData {
  static const Map<StorySubject, StoryHero> heroes = {

    // ── 1. MATEMATIKA: Susambil ────────────────────────────────────────────
    StorySubject.matematika: StoryHero(
      subject: StorySubject.matematika,
      heroName: 'Eshak',
      heroEmoji: '🫏',
      companionName: 'Susambil o\'tlari',
      companionEmoji: '🌿',
      worldName: 'Susambil O\'lkasi',
      worldEmoji: '🏕️',
      questTitle: 'Susambilga Yo\'l!',
      questDescription:
          'Bizning kambag\'al Eshak juda ochqab qoldi. '
          'Susambil o\'lkasida mazali o\'tlar bor, lekin yo\'l uzun va qiyin. '
          'Har bir hisob-kitob masalasini hal qil — Eshak bir qadam olg\'a bosadi. '
          'Susambilga yeting, Eshakni to\'ydiring!',
      winEnding:
          '🎉 Barakalla! Eshak Susambilga yetib keldi!\n'
          'U yashil o\'tlarni to\'yib-to\'yib yedi.\n'
          'Sen unga yo\'l ko\'rsatding — haqiqiy do\'st!',
      loseEnding:
          '😢 Voy, Eshak Susambilga eta olmadi...\n'
          'Lekin u seni kutmoqda! Yana bir bor urinib ko\'r,\n'
          'bu safar albatta yetasiz!',
      storyColors: [Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFFA5D6A7)],
      bgPattern: 'meadow',
    ),

    // ── 2. ONA TILI: Zumrad va Qimmat ──────────────────────────────────────
    StorySubject.onaTili: StoryHero(
      subject: StorySubject.onaTili,
      heroName: 'Zumrad',
      heroEmoji: '👧',
      companionName: 'Qimmat',
      companionEmoji: '😤',
      worldName: 'Sehrli Sandiq',
      worldEmoji: '🪄',
      questTitle: 'Sandiqni Och!',
      questDescription:
          'Zumrad va Qimmat bir sehrli sandiq topishdi.\n'
          'Sandiq ertakdagi so\'zlarni bilgandagina ochiladi.\n'
          'Har to\'g\'ri javob — Zumrad baxtli kuladi, sandiq ochiladi.\n'
          'Har xato — Qimmat g\'alaba qozonadi, sandiq yopiladi.\n'
          'Zumradga yordam ber — sandiqni och!',
      winEnding:
          '✨ Zumrad g\'olib chiqdi!\n'
          'Sandiq ochilib, ichida oltin-kumushlar chiqdi.\n'
          'Zumrad senga katta rahmat aytdi!',
      loseEnding:
          '😤 Bu safar Qimmat g\'olib bo\'ldi...\n'
          'Lekin Zumrad yana urinishga tayyor.\n'
          'Ona tilimizni o\'rgan va Zumradga yordam ber!',
      storyColors: [Color(0xFF6A1B9A), Color(0xFFAB47BC), Color(0xFFCE93D8)],
      bgPattern: 'forest',
    ),

    // ── 3. TARIX: Shiroq ───────────────────────────────────────────────────
    StorySubject.tarix: StoryHero(
      subject: StorySubject.tarix,
      heroName: 'Shiroq',
      heroEmoji: '🧑‍🌾',
      companionName: 'Vatan',
      companionEmoji: '🏔️',
      worldName: 'Qadim Turonzamin',
      worldEmoji: '⚔️',
      questTitle: 'Vatanni Himoya Qil!',
      questDescription:
          'Yunon lashkari Turonzaminga bostirib keldi!\n'
          'Jasur cho\'pon Shiroq ularni chalg\'itishga qaror qildi.\n'
          'Tarixni bilsang — Shiroq to\'g\'ri yo\'l tanlaydi.\n'
          'Bilmasang — dushman o\'tib ketadi.\n'
          'Tariximizni bil, Shiroqqa kuch ber!',
      winEnding:
          '🏆 Shiroq g\'olib chiqdi!\n'
          'Dushman chalg\'itilib, Vatan xavfsiz qoldi.\n'
          'Sen Shiroqqa tarixni o\'rgatib, uni qahramonga aylantirding!',
      loseEnding:
          '😔 Bu safar qiyin bo\'ldi...\n'
          'Lekin Shiroq umidini yo\'qotmadi.\n'
          'Tariximizni o\'rgan va Shiroqqa yana yordam ber!',
      storyColors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFEF9A9A)],
      bgPattern: 'steppe',
    ),

    // ── 4. GEOGRAFIYA: Alpomish ────────────────────────────────────────────
    StorySubject.geografiya: StoryHero(
      subject: StorySubject.geografiya,
      heroName: 'Alpomish',
      heroEmoji: '🦸‍♂️',
      companionName: 'Barchinoy',
      companionEmoji: '👸',
      worldName: 'O\'zbekiston Yurtlari',
      worldEmoji: '🗺️',
      questTitle: 'Barchinoyni Top!',
      questDescription:
          'Bahodir Alpomish Barchinoyni qidirib yurtni kezmoqda.\n'
          'Har viloyat, har tog\' va daryoni bilsang —\n'
          'Alpomish to\'g\'ri yo\'l tanlaydi.\n'
          'O\'zbekistonni yaxshi bilasan!\n'
          'Alpomishga yo\'l ko\'rsat, Barchinoyni top!',
      winEnding:
          '❤️ Alpomish Barchinoyni topdi!\n'
          'Sen unga butun yurtni ko\'rsatding.\n'
          'Ular birga baxtli yashashdi!',
      loseEnding:
          '😢 Alpomish adashib qoldi...\n'
          'Lekin u taslim bo\'lmaydi!\n'
          'Geografiyani o\'rgan va Alpomishga yo\'l ko\'rsat!',
      storyColors: [Color(0xFF01579B), Color(0xFF0288D1), Color(0xFF81D4FA)],
      bgPattern: 'map',
    ),

    // ── 5. INGLIZ TILI: Tumarisxon ─────────────────────────────────────────
    StorySubject.inglizTili: StoryHero(
      subject: StorySubject.inglizTili,
      heroName: 'Tumarisxon',
      heroEmoji: '👑',
      companionName: "O'g'li",
      companionEmoji: '🧒',
      worldName: 'Qadim Massagetlar Yurti',
      worldEmoji: '🛡️',
      questTitle: 'Yurtni Himoya Qil!',
      questDescription:
          'Malika Tumarisxon juda kuchli va dono.\n'
          'Yunon elchilari muzokaraga keldi — inglizcha gapirmoqchi!\n'
          'Ingliz so\'zlarini bilsang — Tumarisxon muzokarada g\'olib.\n'
          'Bilmasang — elchilar g\'olib keladi.\n'
          'Inglizchani o\'rgan, Tumarisxonga kuch ber!',
      winEnding:
          '👑 Tumarisxon g\'olib chiqdi!\n'
          'Elchilar uning bilimiga tan berib ketishdi.\n'
          'Yurt tinch qoldi, sen qahramon!',
      loseEnding:
          '😤 Bu safar muzokaralar qiyin bo\'ldi...\n'
          'Lekin Tumarisxon yana kurashadi!\n'
          'Inglizchani mashq qil va unga yordam ber!',
      storyColors: [Color(0xFF004D40), Color(0xFF00897B), Color(0xFF80CBC4)],
      bgPattern: 'battle',
    ),

    // ── 6. ODOBNOMA: Avazxon ──────────────────────────────────────────────
    StorySubject.odobnoma: StoryHero(
      subject: StorySubject.odobnoma,
      heroName: 'Avazxon',
      heroEmoji: '👦',
      companionName: 'Qo\'shnilar',
      companionEmoji: '👨‍👩‍👦',
      worldName: 'Mahalla',
      worldEmoji: '🏡',
      questTitle: 'Yaxshi Odam Bo\'l!',
      questDescription:
          'Avazxon yangi mahallaga ko\'chib keldi.\n'
          'Qo\'shnilar bilan tanishishi va to\'yda yaxshi xulq ko\'rsatishi kerak.\n'
          'Odobli javob — hammani sevintiradi.\n'
          'Odobsiz javob — ular xafa bo\'ladi.\n'
          'Avazxonga yaxshi xulqni o\'rgan!',
      winEnding:
          '🌟 Avazxon hammaning sevimli do\'sti bo\'ldi!\n'
          'Mahalla uni yaxshi ko\'radi, u baxtli.\n'
          'Sen unga yaxshi xulqni o\'rgatding!',
      loseEnding:
          '😔 Avazxon bu safar xato qildi...\n'
          'Lekin u kechirim so\'rab, yana urinadi.\n'
          'Odobni o\'rgan va unga yordam ber!',
      storyColors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFFCC80)],
      bgPattern: 'village',
    ),
  };

  // Fandan StoryHero olish
  static StoryHero getHero(StorySubject subject) => heroes[subject]!;

  // Fan nomidan subject topish
  static StorySubject? subjectFromKey(String key) {
    switch (key) {
      case 'matematika': return StorySubject.matematika;
      case 'ona_tili':   return StorySubject.onaTili;
      case 'tarix':      return StorySubject.tarix;
      case 'geo':        return StorySubject.geografiya;
      case 'ingliz':     return StorySubject.inglizTili;
      case 'odobnoma':   return StorySubject.odobnoma;
      default:           return null;
    }
  }
}
