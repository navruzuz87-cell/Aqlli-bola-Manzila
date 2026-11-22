// Tarix savollari — 5-12 yosh uchun, sodda va qiziqarli

enum HistoryEra {
  uzbekistan, // O'zbekiston qahramonlari
  ancient,    // Qadimgi dunyo
  medieval,   // O'rta asrlar
  world,      // Dunyo tarixi
}

extension HistoryEraExt on HistoryEra {
  String get label {
    switch (this) {
      case HistoryEra.uzbekistan: return 'O\'zbekiston';
      case HistoryEra.ancient:    return 'Qadimgi davr';
      case HistoryEra.medieval:   return 'O\'rta asrlar';
      case HistoryEra.world:      return 'Dunyo';
    }
  }
  String get emoji {
    switch (this) {
      case HistoryEra.uzbekistan: return '🇺🇿';
      case HistoryEra.ancient:    return '🏺';
      case HistoryEra.medieval:   return '🏰';
      case HistoryEra.world:      return '🌍';
    }
  }
}

class HistoryQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final HistoryEra era;
  final int grade;         // 1-6
  final String imageEmoji; // Katta ko'rinadigan emoji
  final String funFact;    // To'g'ri javobdan keyin ko'rsatiladigan qiziqarli fakt
  final int starsReward;

  const HistoryQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.era,
    required this.grade,
    required this.imageEmoji,
    required this.funFact,
    this.starsReward = 10,
  });
}

class HistoryQuestions {
  static List<HistoryQuestion> getAll() => _questions;

  static List<HistoryQuestion> getByGrade(int grade) =>
      _questions.where((q) => q.grade <= grade).toList();

  static List<HistoryQuestion> getByEra(HistoryEra era) =>
      _questions.where((q) => q.era == era).toList();

  static const List<HistoryQuestion> _questions = [

    // ══ O'ZBEKISTON — GRADE 1-2 (eng sodda) ════════════════════

    HistoryQuestion(
      id: 'h1',
      question: 'O\'zbekistonning poytaxti qaysi shahar?',
      options: ['Samarqand', 'Toshkent', 'Buxoro', 'Namangan'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 1,
      imageEmoji: '🏙️',
      funFact: 'Toshkent — 2000 yildan ko\'proq tarixga ega qadimiy shahar! 🌟',
    ),
    HistoryQuestion(
      id: 'h2',
      question: 'O\'zbekiston bayrog\'ida nechta yulduz bor?',
      options: ['8', '10', '12', '5'],
      correctIndex: 2,
      era: HistoryEra.uzbekistan,
      grade: 1,
      imageEmoji: '🇺🇿',
      funFact: '12 yulduz — O\'zbekistonning 12 viloyatini bildiradi! ⭐',
    ),
    HistoryQuestion(
      id: 'h3',
      question: 'O\'zbekiston bayrog\'idagi yashil rang nimani bildiradi?',
      options: ['Daryolarni', 'Tabiatni va umidni', 'Cho\'lni', 'Tog\'larni'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 2,
      imageEmoji: '💚',
      funFact: 'Yashil rang — O\'zbekistonning go\'zal bog\'lari va umidli kelajagini bildiradi! 🌿',
    ),
    HistoryQuestion(
      id: 'h4',
      question: 'Qaysi shahar "Sharqning oltin shahri" deb ataladi?',
      options: ['Toshkent', 'Farg\'ona', 'Samarqand', 'Termiz'],
      correctIndex: 2,
      era: HistoryEra.uzbekistan,
      grade: 2,
      imageEmoji: '✨',
      funFact: 'Samarqand 2700 yillik tarixga ega — Iskandar Zulqarnayn ham bu shaharga hayron qolgan! 😲',
    ),
    HistoryQuestion(
      id: 'h5',
      question: 'O\'zbekistonning milliy guli qaysi?',
      options: ['Lola', 'Atirgul', 'Boychechak', 'Nilufar'],
      correctIndex: 3,
      era: HistoryEra.uzbekistan,
      grade: 2,
      imageEmoji: '🌸',
      funFact: 'Nilufar — suv ustida o\'sadigan go\'zal gul! U toza qolb va go\'zallikni bildiradi 💙',
    ),

    // ══ O'ZBEKISTON — GRADE 3-4 ════════════════════

    HistoryQuestion(
      id: 'h6',
      question: 'Amir Temur qaysi shaharda tug\'ilgan?',
      options: ['Samarqand', 'Shahrisabz', 'Buxoro', 'Toshkent'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 3,
      imageEmoji: '🏯',
      funFact: 'Shahrisabz — "Yashil shahar" demak! Amir Temur shu yerda o\'sib ulg\'aygan 🌱',
    ),
    HistoryQuestion(
      id: 'h7',
      question: 'Ulug\'bek nimalar bilan mashhur?',
      options: ['Urush qilgani', 'Yulduzlarni o\'rgangani', 'Ot minishi', 'Ko\'p yegani 😄'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 3,
      imageEmoji: '🔭',
      funFact: 'Ulug\'bek 1000 dan ortiq yulduzning aniq joyini topgan — 600 yil oldin! Hozirgi teleskoplarsiz! 🌟',
    ),
    HistoryQuestion(
      id: 'h8',
      question: 'Al-Xorazmiy nimani ixtiro qilgan?',
      options: ['Velosiped', 'Algebra', 'Telefon', 'Poyezd'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 3,
      imageEmoji: '🔢',
      funFact: 'Al-Xorazmiy algebra ilmini yaratgan — sen maktabda o\'qiydigan algebrani! "Algorithm" so\'zi ham uning ismidan! 🧮',
    ),
    HistoryQuestion(
      id: 'h9',
      question: 'Ibn Sino kim bo\'lgan?',
      options: ['Shoʻx bola 😄', 'Buyuk tabib-olim', 'Jangchi', 'Qo\'shiqchi'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 4,
      imageEmoji: '🏥',
      funFact: 'Ibn Sino yozgan kitob 500 yil davomida Yevropa universitetlarida o\'qitilgan! "Tibbiyot qonunlari" deb ataladi 📚',
    ),
    HistoryQuestion(
      id: 'h10',
      question: 'Navoiy qanday buyuk ish qilgan?',
      options: ['Ko\'p ovqat pishirgan 😄', 'O\'zbek tilida she\'r yozgan', 'Baland tog\'ga chiqqan', 'Tez yugurgan'],
      correctIndex: 1,
      era: HistoryEra.uzbekistan,
      grade: 3,
      imageEmoji: '📜',
      funFact: 'Navoiy 30 000 dan ortiq she\'r yozgan va O\'zbek adabiyotining otasi hisoblanadi! 🖋️',
    ),

    // ══ QADIMGI DUNYO — GRADE 2-4 ════════════════════

    HistoryQuestion(
      id: 'h11',
      question: 'Misr ehromlari (piramidalari) nima uchun qurilgan?',
      options: ['O\'yin maydoni', 'Fir\'avn uyumi', 'Maktab', 'Bozor'],
      correctIndex: 1,
      era: HistoryEra.ancient,
      grade: 2,
      imageEmoji: '🔺',
      funFact: 'Buyuk Giza ehromini qurish uchun 20 yil vaqt va 100 000 kishi ishlagan! 😲',
    ),
    HistoryQuestion(
      id: 'h12',
      question: 'Qog\'oz qayerda ixtiro qilingan?',
      options: ['Misr', 'Hindiston', 'Xitoy', 'Yevropada'],
      correctIndex: 2,
      era: HistoryEra.ancient,
      grade: 3,
      imageEmoji: '📄',
      funFact: 'Qog\'oz ixtiro qilinmasidan oldin odamlar toshga va teriega yozishgan. Og\'ir daftarlar bo\'lardi! 😂',
    ),
    HistoryQuestion(
      id: 'h13',
      question: 'Ipak yo\'li nima edi?',
      options: ['Ipak olinadigan joy', 'Savdo yo\'li', 'Daryo nomi', 'O\'rmon nomi'],
      correctIndex: 1,
      era: HistoryEra.ancient,
      grade: 3,
      imageEmoji: '🛣️',
      funFact: 'Ipak yo\'li orqali Xitoydan Yevropaga ipak, ziravor va oltin olib o\'tilgan. Samarqand bu yo\'lning markazida! 🌍',
    ),

    // ══ O'RTA ASRLAR — GRADE 3-5 ════════════════════

    HistoryQuestion(
      id: 'h14',
      question: 'Temuriylar davlatining poytaxti qaysi shahar bo\'lgan?',
      options: ['Buxoro', 'Samarqand', 'Hirot', 'Toshkent'],
      correctIndex: 1,
      era: HistoryEra.medieval,
      grade: 3,
      imageEmoji: '🕌',
      funFact: 'Amir Temur Samarqandni dunyoning eng go\'zal shahriga aylantirgan! Hatto Xitoy va Fransiyadan mehmonlar kelgan 🌟',
    ),
    HistoryQuestion(
      id: 'h15',
      question: 'Bobur kim bo\'lgan?',
      options: ['Oddiy dehqon', 'Shoir va hukmdor', 'Tabib', 'Savdogar'],
      correctIndex: 1,
      era: HistoryEra.medieval,
      grade: 4,
      imageEmoji: '👑',
      funFact: 'Bobur Farg\'onada tug\'ilib, keyinchalik Hindistonda katta saltanat qurishgan! "Boburnoma" kitobi hali ham o\'qiladi 📖',
    ),

    // ══ DUNYO TARIXI — GRADE 2-5 ════════════════════

    HistoryQuestion(
      id: 'h16',
      question: 'Birinchi inson oyga qachon borgan?',
      options: ['1945', '1961', '1969', '1980'],
      correctIndex: 2,
      era: HistoryEra.world,
      grade: 2,
      imageEmoji: '🌙',
      funFact: 'Neil Armstrong oyda birinchi qadam qo\'yib: "Bu bir kishi uchun kichik qadam, lekin insoniyat uchun ulkan sakrash!" degan! 🚀',
    ),
    HistoryQuestion(
      id: 'h17',
      question: 'Kompyuter kim tomonidan ixtiro qilingan?',
      options: ['Bir kishi emas, ko\'p olimlar', 'Eynshteyn', 'Edison', 'Nyuton'],
      correctIndex: 0,
      era: HistoryEra.world,
      grade: 4,
      imageEmoji: '💻',
      funFact: 'Birinchi kompyuter xona katta edi! Hozirgi telefon undan millionlab marta kuchliroq 😲',
    ),
    HistoryQuestion(
      id: 'h18',
      question: 'Internet nima uchun yaratilgan?',
      options: ['O\'yin o\'ynash uchun', 'Olimlar ma\'lumot almashishi uchun', 'Film ko\'rish uchun', 'Musiqa eshitish uchun'],
      correctIndex: 1,
      era: HistoryEra.world,
      grade: 3,
      imageEmoji: '🌐',
      funFact: 'Internet avvaliga faqat olimlar uchun bo\'lgan! Hozir 5 mlrd dan ortiq kishi ishlatadi 🌍',
    ),
    HistoryQuestion(
      id: 'h19',
      question: 'Qaysi hayvon inson yurishi kabi ikki oyoqda yuradi?',
      options: ['Pingvin', 'Kenguru', 'Inson va maymun', 'Ayiq'],
      correctIndex: 2,
      era: HistoryEra.world,
      grade: 1,
      imageEmoji: '🦶',
      funFact: 'Qadimiy insonlar avval 4 oyoqda yurgan! Ikki oyoqda yurish qo\'llarni ozod qildi va asboblar yasashga imkon berdi 🛠️',
    ),
    HistoryQuestion(
      id: 'h20',
      question: 'O\'zbekiston mustaqil bo\'lgan yil nechanchi?',
      options: ['1989', '1990', '1991', '1992'],
      correctIndex: 2,
      era: HistoryEra.uzbekistan,
      grade: 2,
      imageEmoji: '🎉',
      funFact: 'Har yil 1-sentabr — O\'zbekiston mustaqillik bayrami! Butun mamlakat bayram qiladi 🇺🇿🎊',
    ),
  ];
}
