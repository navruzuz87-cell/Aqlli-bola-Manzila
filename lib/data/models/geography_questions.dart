// Geografiya savollari — 5-12 yosh uchun, sodda va qiziqarli

enum GeoTopic {
  uzbekistan,  // O'zbekiston
  centralAsia, // Qo'shni davlatlar
  world,       // Dunyo
  nature,      // Tabiat
  flags,       // Bayroqlar
}

extension GeoTopicExt on GeoTopic {
  String get label {
    switch (this) {
      case GeoTopic.uzbekistan:  return 'O\'zbekiston';
      case GeoTopic.centralAsia: return 'Qo\'shnilar';
      case GeoTopic.world:       return 'Dunyo';
      case GeoTopic.nature:      return 'Tabiat';
      case GeoTopic.flags:       return 'Bayroqlar';
    }
  }
  String get emoji {
    switch (this) {
      case GeoTopic.uzbekistan:  return '🇺🇿';
      case GeoTopic.centralAsia: return '🏔️';
      case GeoTopic.world:       return '🌍';
      case GeoTopic.nature:      return '🌿';
      case GeoTopic.flags:       return '🚩';
    }
  }
}

class GeoQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final GeoTopic topic;
  final int grade;
  final String imageEmoji;
  final String funFact;
  final int starsReward;

  const GeoQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.grade,
    required this.imageEmoji,
    required this.funFact,
    this.starsReward = 10,
  });
}

class GeoQuestions {
  static List<GeoQuestion> getAll() => _questions;

  static List<GeoQuestion> getByGrade(int grade) =>
      _questions.where((q) => q.grade <= grade).toList();

  static List<GeoQuestion> getByTopic(GeoTopic topic) =>
      _questions.where((q) => q.topic == topic).toList();

  static const List<GeoQuestion> _questions = [

    // ══ O'ZBEKISTON — GRADE 1-2 ════════════════════

    GeoQuestion(
      id: 'g1',
      question: 'O\'zbekistonning poytaxti qaysi?',
      options: ['Samarqand', 'Toshkent', 'Buxoro', 'Andijon'],
      correctIndex: 1,
      topic: GeoTopic.uzbekistan,
      grade: 1,
      imageEmoji: '🏙️',
      funFact: 'Toshkent — O\'rta Osiyoning eng katta shahri! 3 milliondan ortiq kishi yashaydi 🌆',
    ),
    GeoQuestion(
      id: 'g2',
      question: 'O\'zbekistonda qaysi daryo bor?',
      options: ['Nil', 'Amazon', 'Amudaryo', 'Volga'],
      correctIndex: 2,
      topic: GeoTopic.uzbekistan,
      grade: 1,
      imageEmoji: '🌊',
      funFact: 'Amudaryo juda kuchli daryo — qadimda "Okus" deb atalgan. Baliqlar va qushlar uning bo\'yida yashaydi 🐟',
    ),
    GeoQuestion(
      id: 'g3',
      question: 'O\'zbekiston qaysi qit\'ada joylashgan?',
      options: ['Afrika', 'Yevropa', 'Osiyo', 'Amerika'],
      correctIndex: 2,
      topic: GeoTopic.uzbekistan,
      grade: 1,
      imageEmoji: '🌏',
      funFact: 'Osiyo — dunyoning eng katta qit\'asi! Xitoy, Hindiston, Yaponiya ham shu yerda 🗺️',
    ),
    GeoQuestion(
      id: 'g4',
      question: 'O\'zbekiston nechta viloyatdan iborat?',
      options: ['8', '10', '12', '14'],
      correctIndex: 3,
      topic: GeoTopic.uzbekistan,
      grade: 2,
      imageEmoji: '🗺️',
      funFact: 'O\'zbekistonda 12 viloyat + 1 Respublika (Qoraqalpog\'iston) + Toshkent shahri bor — hammasi 14! 📍',
    ),
    GeoQuestion(
      id: 'g5',
      question: 'O\'zbekistondagi eng baland tog\' qaysi?',
      options: ['Chimyon', 'Beshtor', 'Xazratisulton', 'Ko\'hitang'],
      correctIndex: 1,
      topic: GeoTopic.uzbekistan,
      grade: 3,
      imageEmoji: '⛰️',
      funFact: 'Beshtor tog\'i 4299 metr baland — u yerda qor hech qachon erimaydigan joylar bor! ❄️',
    ),
    GeoQuestion(
      id: 'g6',
      question: 'Qaysi shahar "O\'rta Osiyoning incisi" deb ataladi?',
      options: ['Toshkent', 'Farg\'ona', 'Samarqand', 'Namangan'],
      correctIndex: 2,
      topic: GeoTopic.uzbekistan,
      grade: 2,
      imageEmoji: '💎',
      funFact: 'Samarqandning ko\'k gumbazlari yer yuzidagi eng go\'zal inshootlardan! Registon maydoni - dunyoda mashhur 🌟',
    ),

    // ══ QO'SHNI DAVLATLAR — GRADE 2-4 ════════════════════

    GeoQuestion(
      id: 'g7',
      question: 'O\'zbekiston bilan chegaradosh davlatni top:',
      options: ['Rossiya', 'Qozog\'iston', 'Gruziya', 'Ukraina'],
      correctIndex: 1,
      topic: GeoTopic.centralAsia,
      grade: 2,
      imageEmoji: '🤝',
      funFact: 'Qozog\'iston — O\'rta Osiyoning eng katta davlati! U yerda ham ko\'p o\'zbeklar yashaydi 🏠',
    ),
    GeoQuestion(
      id: 'g8',
      question: 'Qaysi tog\' tizmasi O\'rta Osiyoda eng baland?',
      options: ['Tyanshan', 'Pomir', 'Himolay', 'Qoraqum'],
      correctIndex: 1,
      topic: GeoTopic.centralAsia,
      grade: 4,
      imageEmoji: '🏔️',
      funFact: 'Pomir "Dunyoning tomi" deb ataladi! U yerda havo shunchalik siyrak, parvoz qilish ham qiyin 🛩️',
    ),

    // ══ DUNYO — GRADE 2-5 ════════════════════

    GeoQuestion(
      id: 'g9',
      question: 'Dunyoning eng uzun daryosi qaysi?',
      options: ['Amazon', 'Nil', 'Volga', 'Yanszi'],
      correctIndex: 1,
      topic: GeoTopic.world,
      grade: 3,
      imageEmoji: '🌊',
      funFact: 'Nil daryosi 6650 km — O\'zbekistondan Moskvagacha borib keladigan masofa! Misr u daryosiz yashay olmaydi 🏜️',
    ),
    GeoQuestion(
      id: 'g10',
      question: 'Dunyoning eng baland tog\'i qaysi?',
      options: ['Elbrus', 'Everest', 'Kilimanjaro', 'Mont Blanc'],
      correctIndex: 1,
      topic: GeoTopic.world,
      grade: 2,
      imageEmoji: '🏔️',
      funFact: 'Everest 8849 metr baland — samolyot uchib yurgan balandlikda! Tepasida qor va muzdan boshqa hech nima yo\'q ❄️',
    ),
    GeoQuestion(
      id: 'g11',
      question: 'Qaysi qit\'ada eng ko\'p mamlakat bor?',
      options: ['Osiyo', 'Amerika', 'Afrika', 'Yevropa'],
      correctIndex: 2,
      topic: GeoTopic.world,
      grade: 3,
      imageEmoji: '🌍',
      funFact: 'Afrikada 54 ta mustaqil mamlakat bor! Dunyodagi mamlakatlarning to\'rtdan biri Afrikada 🦁',
    ),
    GeoQuestion(
      id: 'g12',
      question: 'Okean degani nima?',
      options: ['Katta daryo', 'Katta sho\'r suv havzasi', 'Katta ko\'l', 'Qor tog\'i'],
      correctIndex: 1,
      topic: GeoTopic.world,
      grade: 1,
      imageEmoji: '🌊',
      funFact: 'Yer yuzining 71%  — suv! Biz aslida "Suv sayyorasi"da yashayapmiz 🌏💧',
    ),

    // ══ TABIAT — GRADE 1-3 ════════════════════

    GeoQuestion(
      id: 'g13',
      question: 'O\'zbekistonda qaysi meva ko\'p o\'sadi?',
      options: ['Kokos', 'O\'rik va uzum', 'Mango', 'Qovun va tarvuz ham! 🍈'],
      correctIndex: 3,
      topic: GeoTopic.nature,
      grade: 1,
      imageEmoji: '🍑',
      funFact: 'O\'zbekiston qovunlari dunyoda eng mazali! Farg\'ona va Xorazm qovunlari bir boshqa 😋',
    ),
    GeoQuestion(
      id: 'g14',
      question: 'Cho\'l degani nima?',
      options: ['Ko\'p suv bor joy', 'Yomg\'ir kam yogadigon quruq yer', 'O\'rmon', 'Tog\'li joy'],
      correctIndex: 1,
      topic: GeoTopic.nature,
      grade: 1,
      imageEmoji: '🏜️',
      funFact: 'Qizilqum cho\'lida tuyalar yashaydi! Tuyalar bir hafta suvsiz yura oladi 🐪',
    ),
    GeoQuestion(
      id: 'g15',
      question: 'Qaysi hayvon O\'zbekiston tabiatida yashaydi?',
      options: ['Sher', 'Yo\'lbars', 'Arqon ilon va ilonquş', 'Pingvin 😄'],
      correctIndex: 2,
      topic: GeoTopic.nature,
      grade: 2,
      imageEmoji: '🦅',
      funFact: 'Ilonquş — Qizilqum cho\'lida yashab, ilon ushlab yeydi! Juda botir qush 🐍➡️🦅',
    ),

    // ══ BAYROQLAR — GRADE 2-4 ════════════════════

    GeoQuestion(
      id: 'g16',
      question: 'O\'zbekiston bayrog\'ining ranglari qaysi?',
      options: [
        'Qizil, oq, yashil',
        'Ko\'k, oq, yashil — qizil chiziq bilan',
        'Sariq, qora, qizil',
        'Faqat ko\'k va oq',
      ],
      correctIndex: 1,
      topic: GeoTopic.flags,
      grade: 2,
      imageEmoji: '🇺🇿',
      funFact: 'Ko\'k — osmon va suv, oq — tinchlik, yashil — tabiat va umid. Qizil chiziqlar — hayot!',
    ),
    GeoQuestion(
      id: 'g17',
      question: 'Qaysi davlat bayrog\'ida quyosh tasviri bor?',
      options: ['Fransiya', 'Yaponiya', 'Germaniya', 'Braziliya'],
      correctIndex: 1,
      topic: GeoTopic.flags,
      grade: 2,
      imageEmoji: '🇯🇵',
      funFact: 'Yaponiya bayrog\'idagi qizil doira — quyosh! Yaponiya "Quyosh chiqadigan mamlakat" deb ataladi 🌅',
    ),
    GeoQuestion(
      id: 'g18',
      question: 'Qaysi davlatning bayrog\'i uchburchak shaklida?',
      options: ['Hindiston', 'Nepal', 'Pokiston', 'Tailand'],
      correctIndex: 1,
      topic: GeoTopic.flags,
      grade: 4,
      imageEmoji: '🚩',
      funFact: 'Nepal — dunyoda to\'rtburchak bo\'lmagan yagona bayroq! U yerda ham Himolay tog\'lari bor 🏔️',
    ),
  ];
}
