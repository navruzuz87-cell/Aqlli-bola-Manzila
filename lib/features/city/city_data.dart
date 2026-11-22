// ── Shaharcha ma'lumotlari ────────────────────────────────────────────────────

class BuildingInfo {
  final String id;
  final String name;        // O'zbek nomi
  final String emoji;       // Asosiy emoji
  final String subject;     // Bog'liq fan
  final String resource;    // Kerakli resurs
  final String story;       // Qisqa ertak tavsifi
  final List<int> levelCost; // Har daraja uchun resurs miqdori [1→2, 2→3, 3→max]
  final List<String> levelDesc; // Har darajada nima paydo bo'ladi

  const BuildingInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.subject,
    required this.resource,
    required this.story,
    required this.levelCost,
    required this.levelDesc,
  });

  int get maxLevel => levelCost.length + 1;
}

class ResourceInfo {
  final String id;
  final String emoji;
  final String name;
  final String fromSubject;

  const ResourceInfo({
    required this.id,
    required this.emoji,
    required this.name,
    required this.fromSubject,
  });
}

// ── Binolar ro'yxati ──────────────────────────────────────────────────────────
const kBuildings = [
  BuildingInfo(
    id: 'alpomish_qala',
    name: "Alpomish Qal'asi",
    emoji: '🏰',
    subject: 'matematika',
    resource: 'tosh',
    story: "Alpomish bahodir qal'asi — har hisob-kitob uni mustahkamlaydi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Kichik minora qurildi",
      "Ikkinchi minora va devor",
      "To'liq qal'a — bayroq ko'tarildi!",
      "Legendar qal'a — Alpomish tasviri",
    ],
  ),
  BuildingInfo(
    id: 'zumrad_kutubxona',
    name: "Zumrad Kutubxonasi",
    emoji: '📚',
    subject: 'ona_tili',
    resource: 'yogoch',
    story: "Zumrad qiz kitoblarni yig'adi — har so'z uni boyitadi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Kichik kutubxona ochildi",
      "Javonlar kitobga to'ldi",
      "Katta zal va o'qish xonasi",
      "Noyob qo'lyozmalar xazinasi",
    ],
  ),
  BuildingInfo(
    id: 'spitamen_muzey',
    name: "Spitamen Muzeyi",
    emoji: '🏺',
    subject: 'tarix',
    resource: 'mis',
    story: "Spitamen qo'mondoni muzeyda ajdodlar ruhini saqlaydi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Birinchi eksponat o'rnatildi",
      "Qadimiy qurollar zali",
      "Ajdodlar haykallari",
      "Buyuk tarix galereyasi",
    ],
  ),
  BuildingInfo(
    id: 'rustam_maydon',
    name: "Rustam Maydoni",
    emoji: '🌍',
    subject: 'geo',
    resource: 'tuproq',
    story: "Rustam zamin O'zbekiston xaritasini bir-bir zabt etadi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Kichik xarita o'rnatildi",
      "Viloyatlar rangli bo'ldi",
      "Interaktiv globus",
      "Butun O'zbekiston zabt etildi!",
    ],
  ),
  BuildingInfo(
    id: 'semurg_minora',
    name: "Semurg' Minorasi",
    emoji: '🦅',
    subject: 'ingliz',
    resource: 'shisha',
    story: "Semurg' qushi eng baland minorada yashaydi — har so'z uni ko'taradi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Past minora qurildi",
      "Minora balandlashdi",
      "Kristall minora",
      "Semurg' uyasi ziyorat joyi",
    ],
  ),
  BuildingInfo(
    id: 'donishmand_bog',
    name: "Donishmand Bog'i",
    emoji: '🌸',
    subject: 'odobnoma',
    resource: 'gul',
    story: "Oqil kampir bog'i — yaxshi xulq gullarni ochadi!",
    levelCost: [5, 12, 25],
    levelDesc: [
      "Birinchi ko'chat ekildi",
      "Gullar ochildi",
      "Favvora va yo'laklar",
      "To'liq gulzor — ertak bog'i",
    ],
  ),
];

// ── Resurslar ─────────────────────────────────────────────────────────────────
const kResources = [
  ResourceInfo(id: 'tosh',    emoji: '🪨', name: 'Tosh',    fromSubject: 'matematika'),
  ResourceInfo(id: 'yogoch',  emoji: '🌲', name: "Yog'och", fromSubject: 'ona_tili'),
  ResourceInfo(id: 'mis',     emoji: '⚙️', name: 'Mis',     fromSubject: 'tarix'),
  ResourceInfo(id: 'tuproq',  emoji: '🌱', name: 'Tuproq',  fromSubject: 'geo'),
  ResourceInfo(id: 'shisha',  emoji: '💎', name: 'Shisha',  fromSubject: 'ingliz'),
  ResourceInfo(id: 'gul',     emoji: '🌸', name: 'Gul',     fromSubject: 'odobnoma'),
];

// Fan → resurs
const kSubjectResource = {
  'matematika': 'tosh',
  'ona_tili':   'yogoch',
  'tarix':      'mis',
  'geo':        'tuproq',
  'ingliz':     'shisha',
  'odobnoma':   'gul',
};

// O'yindan keyin beriladigan resurs miqdori (yulduz asosida)
int resourceReward(int starsEarned) {
  if (starsEarned >= 8) return 3;
  if (starsEarned >= 4) return 2;
  if (starsEarned >= 1) return 1;
  return 0;
}
