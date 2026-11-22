// Odobnoma savollari — 5-12 yosh uchun, hikoya + savol formatida

enum OdobnomaTheme {
  hurmat,     // Hurmat-izzat
  dostlik,    // Do'stlik
  halollik,   // Halollik
  oila,       // Oila muhabbati
  mehnat,     // Mehnatsevarlik
  madaniyat,  // Madaniyat
  ilm,        // Ilm olish
}

extension OdobnomaThemeExt on OdobnomaTheme {
  String get label {
    switch (this) {
      case OdobnomaTheme.hurmat:    return 'Hurmat';
      case OdobnomaTheme.dostlik:   return 'Do\'stlik';
      case OdobnomaTheme.halollik:  return 'Halollik';
      case OdobnomaTheme.oila:      return 'Oila';
      case OdobnomaTheme.mehnat:    return 'Mehnat';
      case OdobnomaTheme.madaniyat: return 'Madaniyat';
      case OdobnomaTheme.ilm:       return 'Ilm';
    }
  }
  String get icon {
    switch (this) {
      case OdobnomaTheme.hurmat:    return '🤲';
      case OdobnomaTheme.dostlik:   return '🤝';
      case OdobnomaTheme.halollik:  return '💎';
      case OdobnomaTheme.oila:      return '👨‍👩‍👧';
      case OdobnomaTheme.mehnat:    return '💪';
      case OdobnomaTheme.madaniyat: return '🌸';
      case OdobnomaTheme.ilm:       return '📚';
    }
  }
  int get color {
    switch (this) {
      case OdobnomaTheme.hurmat:    return 0xFF6A1B9A;
      case OdobnomaTheme.dostlik:   return 0xFF1565C0;
      case OdobnomaTheme.halollik:  return 0xFF2E7D32;
      case OdobnomaTheme.oila:      return 0xFFE65100;
      case OdobnomaTheme.mehnat:    return 0xFF00695C;
      case OdobnomaTheme.madaniyat: return 0xFFAD1457;
      case OdobnomaTheme.ilm:       return 0xFF37474F;
    }
  }
}

class OdobnomaQuestion {
  final String id;
  final OdobnomaTheme theme;
  final String sceneEmoji;      // Hikoya "rasmi" — katta emoji kombinatsiyasi
  final String hikoya;          // Qisqa, bolalar uchun hikoya
  final String companionQuote;  // Afandi yoki do'st gapiradi
  final String question;        // Savol
  final List<String> options;
  final int correctIndex;
  final String moral;           // Xulosa — qisqa va yorqin
  final int starsReward;

  const OdobnomaQuestion({
    required this.id,
    required this.theme,
    required this.sceneEmoji,
    required this.hikoya,
    required this.companionQuote,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.moral,
    this.starsReward = 15,
  });

  int get themeColor => theme.color;
}

class OdobnomaQuestions {
  static List<OdobnomaQuestion> getAll() => _questions;

  static List<OdobnomaQuestion> getByTheme(OdobnomaTheme theme) =>
      _questions.where((q) => q.theme == theme).toList();

  static String getTodaysWisdom() {
    final day = DateTime.now().day;
    return _maqollar[day % _maqollar.length];
  }

  static const List<String> _maqollar = [
    '🌟 Ilm olish — oltindan qimmat!',
    '🤝 Do\'sting ko\'p bo\'lsa, yo\'ling yengil!',
    '💪 Mehnat — baxtning kaliti!',
    '🌸 Ota-onangni hurmat qil — jannat oyog\'i ostida!',
    '📚 Kitob o\'qigan — dunyo ko\'rgan!',
    '💎 Halol bo\'lsang — hamma sevinadi!',
    '🏡 Oila — eng katta boylik!',
    '🌱 Yaxshilik qilsang — qaytib keladi!',
    '🎯 Sabr qilsang — maqsadga yetasan!',
    '🌈 Kulgan yuz — do\'stlarni jalb qiladi!',
  ];

  static const List<OdobnomaQuestion> _questions = [

    // ══ HURMAT ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od1',
      theme: OdobnomaTheme.hurmat,
      sceneEmoji: '👴🏻🧒💐',
      hikoya: 'Alisher ko\'chada keksa Vaqos boboni ko\'rdi. Bobo og\'ir sumka ko\'tarib qiynalardi.',
      companionQuote: 'Kattalarni hurmat qilish — bizning an\'anamiz! 🤲',
      question: 'Alisher nima qilishi kerak?',
      options: [
        '🏃 Tez o\'tib ketish',
        '💐 Boborga yordam berish',
        '📱 Telefon o\'ynash',
        '😄 Kulish',
      ],
      correctIndex: 1,
      moral: '🌟 Kattalarni hurmat qilish — ulug\'lik belgisi!',
      starsReward: 15,
    ),

    OdobnomaQuestion(
      id: 'od2',
      theme: OdobnomaTheme.hurmat,
      sceneEmoji: '🧒🍽️👨‍👩‍👧',
      hikoya: 'Ovqat vaqtida Sarvinoz telefon o\'ynay boshladi. Ota-onasi dasturxon atrofida o\'tiribdi.',
      companionQuote: 'Dasturxon — oilaning eng baxtli paytlari! 🌺',
      question: 'Sarvinoz nima qilsa yaxshi bo\'ladi?',
      options: [
        '📱 Davom ettirish',
        '🤲 Telefonni qo\'yib oila bilan gaplashish',
        '😴 Uxlab qolish',
        '🏃 Dasturxondan ketish',
      ],
      correctIndex: 1,
      moral: '👨‍👩‍👧 Oila bilan vaqt — eng qimmatli xazina!',
      starsReward: 15,
    ),

    // ══ DO'STLIK ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od3',
      theme: OdobnomaTheme.dostlik,
      sceneEmoji: '😢🧒🤝😊',
      hikoya: 'Hamid maktabda yig\'lab o\'tirardi. Hech kim unga e\'tibor bermadi. Lekin Jasur uni ko\'rdi.',
      companionQuote: 'Haqiqiy do\'st — qiyin kunda yoningda bo\'ladi! 💪',
      question: 'Jasur nima qilishi kerak?',
      options: [
        '🙈 Ko\'rmaganga olish',
        '😂 Kulish',
        '🤝 Yoniga borib "Nima bo\'ldi?" deb so\'rash',
        '🏃 Qochib ketish',
      ],
      correctIndex: 2,
      moral: '🤝 Do\'sting g\'amini o\'z g\'amingday his qil!',
      starsReward: 15,
    ),

    OdobnomaQuestion(
      id: 'od4',
      theme: OdobnomaTheme.dostlik,
      sceneEmoji: '🧒🍬🤲🧒',
      hikoya: 'Nilufarda bitta konfet qoldi. Yonida do\'sti Zulfiya ham turardi. Ikkalasi ham konfetni sevadi.',
      companionQuote: 'Ulashish — do\'stlikni kuchaytiradigan sehr! ✨',
      question: 'Nilufar nima qilishi kerak?',
      options: [
        '🏃 Konfetni olib qochish',
        '🙈 Ko\'rmaganga olish',
        '🍬 Konfetni ikkiga bo\'lib do\'sti bilan ulashish',
        '😡 "Men yeyaman" deyish',
      ],
      correctIndex: 2,
      moral: '🌈 Ulashgan sevinchin — ikki baravar ortadi!',
      starsReward: 15,
    ),

    // ══ HALOLLIK ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od5',
      theme: OdobnomaTheme.halollik,
      sceneEmoji: '📝✏️👀🧒',
      hikoya: 'Imtihonda Rustam javobni bilmasdi. Yonidagi Kamol\'ning daftarini ko\'rish mumkin edi.',
      companionQuote: 'Halol baho — ming baravari qimmat! 💎',
      question: 'Rustam nima qilishi kerak?',
      options: [
        '👀 Ko\'chirish',
        '😴 Uxlab qolish',
        '✏️ O\'zi bilganini yozish va o\'qituvchiga aytish',
        '📝 Daftarni o\'g\'irlash',
      ],
      correctIndex: 2,
      moral: '💎 Halollik — eng katta boylik!',
      starsReward: 20,
    ),

    OdobnomaQuestion(
      id: 'od6',
      theme: OdobnomaTheme.halollik,
      sceneEmoji: '💰👛🧒😊',
      hikoya: 'Maktab yo\'lida Davron yerda 50 000 so\'m topdi. Egasini bilmaydi.',
      companionQuote: 'Topgan narsangni topshirish — qahramonlik! 🦸',
      question: 'Davron nima qilishi kerak?',
      options: [
        '💰 Cho\'ntagiga solish',
        '🏫 O\'qituvchiga yoki maktab qorovuliga topshirish',
        '🏃 Tez ketish',
        '😋 Non sotib olish',
      ],
      correctIndex: 1,
      moral: '🌟 Halol bola — hamma\'ning iftixori!',
      starsReward: 20,
    ),

    // ══ OILA ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od7',
      theme: OdobnomaTheme.oila,
      sceneEmoji: '👩🧹🧒🎮',
      hikoya: 'Onam uy yig\'ishtirdi, ovqat pishirdi. Charchagandi. Zafar esa o\'yin o\'ynardi.',
      companionQuote: 'Ota-onangga yordam ber — ular seni sevgani uchun hamma ishni qilishadi! ❤️',
      question: 'Zafar nima qilsa to\'g\'ri bo\'ladi?',
      options: [
        '🎮 O\'ynashda davom ettirish',
        '😴 Uxlash',
        '🧹 O\'yinni to\'xtatib onaga yordam berish',
        '📺 Televizor ko\'rish',
      ],
      correctIndex: 2,
      moral: '❤️ Ota-onangga yordam — eng katta sajda!',
      starsReward: 15,
    ),

    // ══ MEHNAT ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od8',
      theme: OdobnomaTheme.mehnat,
      sceneEmoji: '🧒📚😴⭐',
      hikoya: 'Ertaga Shahlo\'ning imtihoni bor. Lekin u o\'qishdan ko\'ra o\'ynashni xohladi. "Keyinroq o\'qirman" dedi.',
      companionQuote: 'Bugungi ishni ertaga qoldirma — keyin qiyin bo\'ladi! ⏰',
      question: 'Shahlo nima qilishi kerak?',
      options: [
        '😴 Uxlab qolish',
        '📱 Video ko\'rish',
        '📚 Hoziroq o\'qib tayyorlanish',
        '🎮 O\'yin o\'ynash',
      ],
      correctIndex: 2,
      moral: '💪 Mehnat qilsang — maqsadingga yetasan!',
      starsReward: 15,
    ),

    // ══ MADANIYAT ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od9',
      theme: OdobnomaTheme.madaniyat,
      sceneEmoji: '🗣️📢🧒😲',
      hikoya: 'Maktab kutubxonasida Ikrom va do\'stlari qattiq gaplashib kulishardi. Boshqalar o\'qiyotgandi.',
      companionQuote: 'Har joyning o\'z odobi bor — kutubxona tinchlik joyi! 📚',
      question: 'Ikrom nima qilishi kerak?',
      options: [
        '📢 Yanada baland gapirish',
        '🤫 Pastroq gapirish yoki tashqariga chiqish',
        '🏃 Kutubxonadan chiqib ketish',
        '😴 Uxlab qolish',
      ],
      correctIndex: 1,
      moral: '🌸 Boshqalarni hurmat qilish — madaniyatning belgisi!',
      starsReward: 15,
    ),

    // ══ ILM ══════════════════════════════════════════

    OdobnomaQuestion(
      id: 'od10',
      theme: OdobnomaTheme.ilm,
      sceneEmoji: '🧒❓👩‍🏫💡',
      hikoya: 'Dars vaqtida Murod biror narsani tushunmadi. "Ahmoq bo\'lib ko\'rinaman" deb o\'yladi va so\'ramadi.',
      companionQuote: 'Bilmagan narsani so\'rash — aqlli bolaning ishi! 🌟',
      question: 'Murod nima qilishi kerak edi?',
      options: [
        '😶 Jim o\'tirish',
        '😴 Uxlash',
        '🙋 O\'qituvchidan so\'rash',
        '📱 Internetdan qidirish',
      ],
      correctIndex: 2,
      moral: '📚 Savol bergan — ilm olgan! Uyalma, so\'ra!',
      starsReward: 15,
    ),
  ];
}
