enum UzbekTopic { alifbo, imlo, sozTarkibi, gap, matal, sherNasr }

extension UzbekTopicExt on UzbekTopic {
  String get label {
    switch (this) {
      case UzbekTopic.alifbo:     return 'Alifbo';
      case UzbekTopic.imlo:       return 'Imlo';
      case UzbekTopic.sozTarkibi: return 'So\'z tarkibi';
      case UzbekTopic.gap:        return 'Gap';
      case UzbekTopic.matal:      return 'Maqol';
      case UzbekTopic.sherNasr:   return 'She\'r / Nasr';
    }
  }

  String get emoji {
    switch (this) {
      case UzbekTopic.alifbo:     return '🔤';
      case UzbekTopic.imlo:       return '✍️';
      case UzbekTopic.sozTarkibi: return '🧩';
      case UzbekTopic.gap:        return '💬';
      case UzbekTopic.matal:      return '📜';
      case UzbekTopic.sherNasr:   return '📖';
    }
  }
}

class UzbekQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final UzbekTopic topic;
  final int grade;         // 1–6
  final String? hint;
  final String? explanation;
  final int starsReward;

  const UzbekQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.grade,
    this.hint,
    this.explanation,
    this.starsReward = 10,
  });
}

class UzbekQuestions {
  static List<UzbekQuestion> getAll() => _questions;

  static List<UzbekQuestion> getByGrade(int grade) =>
      _questions.where((q) => q.grade == grade).toList();

  static List<UzbekQuestion> getByTopic(UzbekTopic topic) =>
      _questions.where((q) => q.topic == topic).toList();

  static const List<UzbekQuestion> _questions = [
    // ── ALIFBO (Grade 1-2) ──────────────────────────────
    UzbekQuestion(
      id: 'uz_a1',
      question: 'O\'zbek alifbosida nechta harf bor?',
      options: ['26', '29', '32', '36'],
      correctIndex: 1,
      topic: UzbekTopic.alifbo,
      grade: 1,
      hint: 'Lotin asosidagi o\'zbek yozuvi',
      explanation: 'O\'zbek lotin alifbosida 29 ta harf mavjud.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_a2',
      question: 'Qaysi harf O\'zbek alifbosiga xos, boshqa tillarda yo\'q?',
      options: ['A', 'O\'', 'E', 'I'],
      correctIndex: 1,
      topic: UzbekTopic.alifbo,
      grade: 1,
      hint: 'Apostrof bilan yoziladi',
      explanation: 'O\' (o apostrof) harfi o\'zbek tiliga xos bo\'lib, lablanmagan unlidir.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_a3',
      question: 'O\'zbek alifbosida nechta unli harf bor?',
      options: ['4', '5', '6', '7'],
      correctIndex: 2,
      topic: UzbekTopic.alifbo,
      grade: 1,
      hint: 'A, E, I, O, U, O\'',
      explanation: 'O\'zbek alifbosida 6 ta unli: a, e, i, o, u, o\'.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_a4',
      question: '"She\'r" so\'zidagi undosh harflar soni nechta?',
      options: ['1', '2', '3', '4'],
      correctIndex: 1,
      topic: UzbekTopic.alifbo,
      grade: 2,
      hint: 'SH — bitta harf hisoblanadi',
      explanation: 'She\'r so\'zida SH va R — 2 ta undosh harf. Apostrof harf hisoblanmaydi.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_a5',
      question: 'Qaysi so\'zda "ng" harfi bor?',
      options: ['Kitob', 'Rang', 'Qalam', 'Daftar'],
      correctIndex: 1,
      topic: UzbekTopic.alifbo,
      grade: 2,
      explanation: '"Rang" so\'zida "ng" harfi mavjud — bu o\'zbek tiliga xos harf.',
      starsReward: 10,
    ),

    // ── IMLO (Grade 2-4) ───────────────────────────────
    UzbekQuestion(
      id: 'uz_i1',
      question: '"Men maktabga ___" — bo\'sh joyga nima kerak?',
      options: ['boradi', 'bordim', 'boraman', 'bordi'],
      correctIndex: 2,
      topic: UzbekTopic.imlo,
      grade: 2,
      hint: '1-shaxs, hozirgi zamon',
      explanation: '"Men" (1-shaxs) + hozirgi-kelasi zamon = "-aman" qo\'shimchasi.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_i2',
      question: 'Qaysi so\'z to\'g\'ri yozilgan?',
      options: ['kitap', 'kitob', 'kitab', 'kittob'],
      correctIndex: 1,
      topic: UzbekTopic.imlo,
      grade: 2,
      explanation: '"Kitob" to\'g\'ri yozilishi — arabcha so\'z o\'zlashtirma.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_i3',
      question: '"O\'qituvchi" so\'zini bo\'g\'inga bo\'ling:',
      options: ['O\'-qi-tuv-chi', 'O\'qi-tuv-chi', 'O\'qit-uv-chi', 'O\'qi-t-uv-chi'],
      correctIndex: 1,
      topic: UzbekTopic.imlo,
      grade: 3,
      hint: 'Har bo\'g\'inda bitta unli bo\'ladi',
      explanation: 'O\'qi-tuv-chi — 3 bo\'g\'in, har birida bitta unli.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_i4',
      question: 'Qaysi gapda vergul to\'g\'ri qo\'yilgan?',
      options: [
        'Ali, va Vali o\'ynadi.',
        'Ali va, Vali o\'ynadi.',
        'Ali va Vali, o\'ynadi.',
        'Ali va Vali o\'ynadi.',
      ],
      correctIndex: 3,
      topic: UzbekTopic.imlo,
      grade: 4,
      hint: 'Bog\'lovchi so\'z bor — vergul kerak emas',
      explanation: '"Va" bog\'lovchisi bilan ulangan uyushiq bo\'laklar o\'rtasida vergul qo\'yilmaydi.',
      starsReward: 20,
    ),

    // ── SO'Z TARKIBI (Grade 3-5) ────────────────────────
    UzbekQuestion(
      id: 'uz_st1',
      question: '"Maktabdosh" so\'zining tarkibi qanday?',
      options: [
        'maktab + dosh (qo\'shimcha)',
        'mak + tab + dosh',
        'maktab (ildiz) + dosh (qo\'shimcha)',
        'maktabdo + sh',
      ],
      correctIndex: 2,
      topic: UzbekTopic.sozTarkibi,
      grade: 3,
      hint: '-dosh qo\'shimchasi "o\'rtoq" ma\'nosini beradi',
      explanation: 'Maktabdosh = maktab (ildiz so\'z) + -dosh (fe\'l yasovchi qo\'shimcha).',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_st2',
      question: '"Yozuvchi" so\'zida necta qo\'shimcha bor?',
      options: ['1', '2', '3', '0'],
      correctIndex: 1,
      topic: UzbekTopic.sozTarkibi,
      grade: 4,
      hint: 'Yoz + ... + ...',
      explanation: 'Yoz-uv-chi: -uv (harakat nomi) + -chi (kasb bildiruvchi) = 2 qo\'shimcha.',
      starsReward: 20,
    ),
    UzbekQuestion(
      id: 'uz_st3',
      question: 'Qaysi so\'z qo\'shma so\'z?',
      options: ['Maktab', 'Kitobxon', 'Daftar', 'Qalam'],
      correctIndex: 1,
      topic: UzbekTopic.sozTarkibi,
      grade: 5,
      hint: 'Ikki mustaqil so\'zdan hosil bo\'lgan',
      explanation: 'Kitobxon = kitob + xon (o\'quvchi) — qo\'shma so\'z.',
      starsReward: 15,
    ),

    // ── GAP (Grade 3-6) ─────────────────────────────────
    UzbekQuestion(
      id: 'uz_g1',
      question: '"Quyosh chiqdi." gapining kesimi nima?',
      options: ['Quyosh', 'chiqdi', 'Quyosh chiqdi', 'yo\'q'],
      correctIndex: 1,
      topic: UzbekTopic.gap,
      grade: 3,
      hint: 'Kesim — harakat yoki holat bildiradi',
      explanation: '"Chiqdi" — fe\'l, gapning kesimi hisoblanadi.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_g2',
      question: 'Qaysi gap so\'roq gap?',
      options: [
        'Bolalar o\'ynadi.',
        'Qanday yaxshi kun!',
        'Sen qayer bordingiz?',
        'Havo sovuq.',
      ],
      correctIndex: 2,
      topic: UzbekTopic.gap,
      grade: 3,
      explanation: 'So\'roq gap so\'roq so\'z yoki so\'roq intonatsiyasi bilan aytiladi.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_g3',
      question: '"Chiroyli" so\'zi qaysi gap bo\'lagiga kiradi?',
      options: ['Ega', 'Kesim', 'Aniqlovchi', 'To\'ldiruvchi'],
      correctIndex: 2,
      topic: UzbekTopic.gap,
      grade: 4,
      hint: 'Ot oldida keladi, uning belgisini bildiradi',
      explanation: 'Sifat — otni aniqlaydi va aniqlovchi vazifasini bajaradi.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_g4',
      question: 'Qo\'shma gapni toping:',
      options: [
        'Yomg\'ir yog\'di.',
        'Chiroyli gul.',
        'Qor yog\'di, bolalar shodlandi.',
        'Maktabga bordim.',
      ],
      correctIndex: 2,
      topic: UzbekTopic.gap,
      grade: 5,
      hint: 'Ikki va undan ortiq ega-kesim bor',
      explanation: 'Qo\'shma gap ikki oddiy gapdan tashkil topgan: "qor yog\'di" + "bolalar shodlandi".',
      starsReward: 20,
    ),

    // ── MAQOL (Grade 2-5) ───────────────────────────────
    UzbekQuestion(
      id: 'uz_m1',
      question: '"Kitob — bilim manbai." — Bu nima?',
      options: ['She\'r', 'Maqol', 'Topishmoq', 'Hikoya'],
      correctIndex: 1,
      topic: UzbekTopic.matal,
      grade: 2,
      explanation: 'Maqol — xalq donishmandligini qisqa ifodalovchi ibora.',
      starsReward: 10,
    ),
    UzbekQuestion(
      id: 'uz_m2',
      question: '"Mehnat — hayotning asosi" maqolining ma\'nosi nima?',
      options: [
        'Ishlash og\'ir',
        'Ishlash hayotning eng muhim qismi',
        'Pul ko\'p topish kerak',
        'Dam olish yaxshi',
      ],
      correctIndex: 1,
      topic: UzbekTopic.matal,
      grade: 3,
      explanation: 'Bu maqol mehnatkash bo\'lishni targ\'ib qiladi.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_m3',
      question: '"Bir qo\'lda ikki tarvuz tutib bo\'lmaydi" maqoli nimani anglatadi?',
      options: [
        'Tarvuz yeyish qiyin',
        'Ikki ishni bir vaqtda qilish qiyin',
        'Bozorga borma',
        'Ko\'p ovqat yema',
      ],
      correctIndex: 1,
      topic: UzbekTopic.matal,
      grade: 4,
      explanation: 'Bu maqol bir vaqtning o\'zida ko\'p ish qilishning qiyinligini bildiradi.',
      starsReward: 15,
    ),

    // ── SHE'R / NASR (Grade 3-6) ────────────────────────
    UzbekQuestion(
      id: 'uz_sn1',
      question: 'Alisher Navoiyning mashhur asari nomi nima?',
      options: ['Alpomish', 'Xamsa', 'Shohnoma', 'Boburnoma'],
      correctIndex: 1,
      topic: UzbekTopic.sherNasr,
      grade: 3,
      hint: 'Besh dostondan iborat',
      explanation: '"Xamsa" — Alisher Navoiyning 5 ta mashhur dostonidan iborat buyuk asari.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_sn2',
      question: '"Xamsa"da nechta doston bor?',
      options: ['3', '4', '5', '7'],
      correctIndex: 2,
      topic: UzbekTopic.sherNasr,
      grade: 4,
      hint: '"Xams" arabcha "besh" degani',
      explanation: 'Xamsa = 5 doston: Hayrat ul-abror, Farhod va Shirin, Layli va Majnun, Sab\'ai sayyor, Saddi Iskandariy.',
      starsReward: 20,
    ),
    UzbekQuestion(
      id: 'uz_sn3',
      question: '"Alpomish" qanday asar?',
      options: ['She\'r', 'Roman', 'Xalq eposi / dostoni', 'Hikoya'],
      correctIndex: 2,
      topic: UzbekTopic.sherNasr,
      grade: 4,
      explanation: '"Alpomish" — o\'zbek xalq eposi, og\'zaki ijod durdonasi.',
      starsReward: 15,
    ),
    UzbekQuestion(
      id: 'uz_sn4',
      question: 'She\'rda qofiya nima?',
      options: [
        'She\'r sarlavhasi',
        'Misralar oxiridagi tovush uyg\'unligi',
        'She\'r muallifi',
        'She\'rdagi raqamlar',
      ],
      correctIndex: 1,
      topic: UzbekTopic.sherNasr,
      grade: 5,
      hint: 'Misra oxirlarini tingla',
      explanation: 'Qofiya — she\'r misralarining oxirida keladigan uyg\'un tovushlar.',
      starsReward: 20,
    ),
  ];
}
