class AncestorQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const AncestorQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class GreatAncestor {
  final String id;
  final String name;
  final String emoji;
  final String years;
  final String city;
  final String field;
  final String forKids;      // bolalar uchun qisqa ta'rif
  final List<String> facts;  // qiziqarli faktlar
  final List<AncestorQuestion> questions;

  const GreatAncestor({
    required this.id,
    required this.name,
    required this.emoji,
    required this.years,
    required this.city,
    required this.field,
    required this.forKids,
    required this.facts,
    required this.questions,
  });

  static List<GreatAncestor> getAll() => _ancestors;

  static const List<GreatAncestor> _ancestors = [
    GreatAncestor(
      id: 'ibn_sino',
      name: 'Ibn Sino',
      emoji: '🏥',
      years: '980–1037',
      city: 'Buxoro',
      field: 'Tabobat (Tibbiyot)',
      forKids: 'Ibn Sino 1000 yil oldin yashagan buyuk shifokor. '
          'U kasalliklarni qanday davolashni yozgan — bu kitob 500 yil davomida '
          'Yevropa universitetlarida o\'qitilgan!',
      facts: [
        '🔬 10 yoshida Qur\'onni yod olgan',
        '📚 "Tib qonunlari" asari 5 jilddan iborat',
        '💊 Spirt ishlab chiqarishning birinchi usulini kashf etgan',
        '🌍 Asarlari lotin tiliga tarjima qilingan',
        '🧠 Falsafa, matematika, musiqa ham o\'rgangan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Ibn Sino qaysi shaharda tug\'ilgan?',
          options: ['Samarqand', 'Buxoro', 'Toshkent', 'Xiva'],
          correctIndex: 1,
          explanation: 'Ibn Sino 980-yilda Buxoro yaqinidagi Afshona qishlog\'ida tug\'ilgan.',
        ),
        AncestorQuestion(
          question: 'Ibn Sinoning eng mashhur asari nomi nima?',
          options: ['Kitob ul-Hind', 'Tib qonunlari', 'Zafarnoma', 'Rubaiyot'],
          correctIndex: 1,
          explanation: '"Al-Qonun fit-tib" (Tib qonunlari) — tibbiyot ensiklopediyasi.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'al_xorazmiy',
      name: 'Al-Xorazmiy',
      emoji: '🔢',
      years: '783–850',
      city: 'Xorazm (Xiva)',
      field: 'Matematika, Astronomiya',
      forKids: 'Al-Xorazmiy "algebra" so\'zini ixtiro qilgan buyuk olim. '
          'Bugungi kunda hamma foydalanadigan raqamlar (0,1,2,...) uning '
          'yordamida Yevropa\'ga kirib kelgan!',
      facts: [
        '0️⃣ "Nol" raqami tushunchasini kiritgan',
        '📐 "Algebra" so\'zi uning asari nomidan olingan',
        '🌐 "Algorithm" so\'zi uning lotincha ismidan — Algoritmi',
        '🗺️ Dunyoning birinchi aniq xaritalarini tuzgan',
        '⭐ Astronomiya jadvallarini tuzgan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Qaysi zamonaviy so\'z Al-Xorazmiy nomidan olingan?',
          options: ['Algebra', 'Algorithm', 'Atom', 'Analiz'],
          correctIndex: 1,
          explanation: '"Algorithm" so\'zi Al-Xorazmiyning lotincha ismi "Algoritmi"dan kelib chiqqan.',
        ),
        AncestorQuestion(
          question: 'Al-Xorazmiy qaysi sohada eng mashhur?',
          options: ['Tibbiyot', 'Matematika', 'Musiqa', 'She\'riyat'],
          correctIndex: 1,
          explanation: 'Al-Xorazmiy algebra va algoritmlarning otasi hisoblanadi.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'ulugbek',
      name: 'Mirzo Ulug\'bek',
      emoji: '🔭',
      years: '1394–1449',
      city: 'Samarqand',
      field: 'Astronomiya, Matematika',
      forKids: 'Ulug\'bek shoh bo\'lsa ham, kechalari yulduzlarni kuzatishni '
          'yaxshi ko\'rgan. U 1000 dan ortiq yulduzning joylashuvini '
          'aniqlab, katta observatoriya qurgan!',
      facts: [
        '⭐ 1018 yulduzning aniq koordinatalarini belgilagan',
        '🏛️ Samarqandda ulkan observatoriya qurgan',
        '📐 Sinuslar jadvali tuzgan — 5 xil aniqlikda!',
        '🎓 Samarqand madrasasida o\'zi dars bergan',
        '👑 Temur sulolasidan — Amir Temurning nabirasi',
      ],
      questions: [
        AncestorQuestion(
          question: 'Ulug\'bek nimani kuzatish bilan mashg\'ul bo\'lgan?',
          options: ['Baliqlar', 'Yulduzlar', 'O\'simliklar', 'Hayvonlar'],
          correctIndex: 1,
          explanation: 'Ulug\'bek buyuk astronom bo\'lib, Samarqandda observatoriya qurgan.',
        ),
        AncestorQuestion(
          question: 'Ulug\'bek kim bo\'lgan?',
          options: ['Shifokor', 'Shoir', 'Shoh va olim', 'Jangchi'],
          correctIndex: 2,
          explanation: 'Ulug\'bek ham shoh (hukmdor), ham buyuk olim (astronom) bo\'lgan.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'navoiy',
      name: 'Alisher Navoiy',
      emoji: '📜',
      years: '1441–1501',
      city: 'Hirot (Hozirgi Afg\'oniston)',
      field: 'Adabiyot, She\'riyat',
      forKids: 'Navoiy o\'zbek tilida she\'r yozgan birinchi buyuk shoirdir. '
          'Uning "Xamsa" asari 5 ta doston bo\'lib, hali ham maktablarda '
          'o\'qitiladi. U shuningdek vazir ham bo\'lgan!',
      facts: [
        '✍️ 30 dan ortiq asar yozgan',
        '🏰 Ko\'plab masjid va maktablar qurdirgan',
        '🌸 "Xamsa" — 5 mashhur doston',
        '👫 Husayn Boyqaro bilan do\'st bo\'lgan',
        '📚 O\'zbek adabiy tilini yaratgan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Navoiyning "Xamsa"da nechta doston bor?',
          options: ['3', '4', '5', '6'],
          correctIndex: 2,
          explanation: '"Xamsa" arabcha "besh" degani — 5 ta dostondan iborat.',
        ),
        AncestorQuestion(
          question: 'Navoiy nima bilan mashhur?',
          options: ['Tibbiyot', 'O\'zbek she\'riyati', 'Matematika', 'Astronomiya'],
          correctIndex: 1,
          explanation: 'Alisher Navoiy o\'zbek adabiyotining otasi, buyuk shoir va davlat arbobi.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'beruniy',
      name: 'Abu Rayhon Beruniy',
      emoji: '🌍',
      years: '973–1048',
      city: 'Xorazm (Berun qishlog\'i)',
      field: 'Geografiya, Fizika, Tarix',
      forKids: 'Beruniy juda qiziquvchan olim bo\'lgan. U hisob-kitob qilib, '
          'Yer dumaloq ekanini, hatto uning kattaligini deyarli to\'g\'ri '
          'aniqlagan — teleskopsiz!',
      facts: [
        '🌐 Yer sharining radiusini 1% xato bilan hisoblagan',
        '📖 Hindiston haqida birinchi encyclopediyani yozgan',
        '⚖️ Ko\'plab metallarning zichligini o\'lchagan',
        '🗓️ Turli xalqlar taqvimini solishtirgan',
        '🔭 Quyosh tutilishini oldindan bashorat qilgan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Beruniy qaysi buyuk kashfiyotni qilgan?',
          options: [
            'Suv formulasini topgan',
            'Yer sharining o\'lchamini hisoblagan',
            'Qon aylanishini kashf etgan',
            'Gravitatsiyani topgan',
          ],
          correctIndex: 1,
          explanation: 'Beruniy tog\' tepaligidan Yer radiusini juda aniq hisoblagan.',
        ),
        AncestorQuestion(
          question: 'Beruniy qaysi mamlakatni chuqur o\'rgangan?',
          options: ['Xitoy', 'Hindiston', 'Misr', 'Italiya'],
          correctIndex: 1,
          explanation: 'Beruniy Hindistonga safar qilib, uning tarixi, fani va madaniyatini o\'rgangan.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'manguberdi',
      name: 'Jaloliddin Manguberdi',
      emoji: '⚔️',
      years: '1199–1231',
      city: 'Urganch (Xorazm)',
      field: 'Harbiy san\'at, Qo\'mondonlik',
      forKids: 'Jaloliddin Manguberdi mo\'g\'ullarga qarshi jangda hech qachon '
          'taslim bo\'lmagan qahramon. Chingizxonning kuchli qo\'shini oldida '
          'ham mardona kurashgan!',
      facts: [
        '🏇 Ind daryosida qahramonlik ko\'rsatgan',
        '🛡️ Chingizxon uning jasoratini o\'zi e\'tirof etgan',
        '👑 Xorazmshoh davlatining so\'nggi hukmdori',
        '🌊 Daryodan kechib o\'tib qochishdan bosh tortgan',
        '⚡ "O\'lmay turib taslim bo\'lma!" shiori bilan yashagan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Jaloliddin Manguberdi kimga qarshi kurashgan?',
          options: ['Araблар', 'Mo\'g\'ullar', 'Ruslar', 'Hindlar'],
          correctIndex: 1,
          explanation: 'Jaloliddin Manguberdi Chingizxon boshliq mo\'g\'ul qo\'shiniga qarshi qahramonlarcha kurashgan.',
        ),
        AncestorQuestion(
          question: 'Jaloliddin Manguberdi qaysi davlatning hukmdori bo\'lgan?',
          options: ['Temuriylar', 'Somoniylar', 'Xorazmshohlar', 'Qoraxoniylar'],
          correctIndex: 2,
          explanation: 'U Xorazmshohlar sulolasining so\'nggi hukmdori edi.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'tomavis',
      name: 'To\'maris Malika',
      emoji: '👑',
      years: '~530 miloddan avvalgi',
      city: 'Massaget (Qadimgi O\'rta Osiyo)',
      field: 'Harbiy rahbarlik, Davlat boshqaruvi',
      forKids: 'To\'maris dunyoning eng kuchli qo\'shinlaridan birini mag\'lub etgan '
          'malika! Forsning kuchli shohi Kir II unga qarshi kelgan, '
          'lekin To\'maris g\'alaba qozongan.',
      facts: [
        '👸 Massaget qabilasining malikayi',
        '⚔️ Fors shohi Kir IIni yenggan yagona hukmdorlardan',
        '🛡️ Jangda shaxsan qatnashgan',
        '🌟 Ayol hukmdorlar uchun ulkan namuna',
        '📜 Gerodot tarixida yozib qoldirilgan',
      ],
      questions: [
        AncestorQuestion(
          question: 'To\'maris malika kimni yenggan?',
          options: ['Iskandar Zulqarnayn', 'Kir II (Fors shohi)', 'Chingizxon', 'Doro'],
          correctIndex: 1,
          explanation: 'To\'maris Fors imperiyasining qudratli shohi Kir IIni miloddan avvalgi 530-yilda mag\'lub etgan.',
        ),
        AncestorQuestion(
          question: 'To\'maris qaysi xalqning malikayi bo\'lgan?',
          options: ['Skiflar', 'Massagetlar', 'Parfiyaliklar', 'So\'g\'diylar'],
          correctIndex: 1,
          explanation: 'To\'maris Massaget qabilalar ittifoqining malika-boshlig\'i edi.',
        ),
      ],
    ),

    GreatAncestor(
      id: 'amir_temur',
      name: 'Amir Temur',
      emoji: '🏰',
      years: '1336–1405',
      city: 'Shahrisabz (Kesh)',
      field: 'Davlat boshqaruvi, Qurilish',
      forKids: 'Amir Temur katta imperiya qurgan va uning poytaxti '
          'Samarqand dunyodagi eng go\'zal shaharlardan biriga aylangan. '
          'Uning shiorи: "Kuch — adolatda!"',
      facts: [
        '🏛️ Samarqandni jahonning go\'zal shahrига aylantirgan',
        '📐 Ko\'plab masjid va inshootlar qurdirgan',
        '⚖️ Shiorи: "Kuch — adolatda!"',
        '🌍 Hindiston, Eron, Turkiyagacha yetgan',
        '🎓 Olimlar va san\'atkorlarni homiylik qilgan',
      ],
      questions: [
        AncestorQuestion(
          question: 'Amir Temurning shiorи nima edi?',
          options: [
            '"Ilm — nur!"',
            '"Kuch — adolatda!"',
            '"Vatan — muqaddas!"',
            '"Birlik — g\'alaba!"',
          ],
          correctIndex: 1,
          explanation: 'Amir Temurning mashhur shiorи "Kuch — adolatda!" — bu uning tanga va binolariga yozib qo\'yilgan.',
        ),
        AncestorQuestion(
          question: 'Amir Temur poytaxti qaysi shahar edi?',
          options: ['Buxoro', 'Toshkent', 'Samarqand', 'Shahrisabz'],
          correctIndex: 2,
          explanation: 'Amir Temur poytaxtni Samarqandga ko\'chirgan va uni ulkan shaharga aylantirgan.',
        ),
        AncestorQuestion(
          question: 'Amir Temur qayerda tug\'ilgan?',
          options: ['Samarqand', 'Shahrisabz', 'Buxoro', 'Xiva'],
          correctIndex: 1,
          explanation: 'Amir Temur 1336-yilda Shahrisabz (o\'sha paytda Kesh) shahrida tug\'ilgan.',
        ),
      ],
    ),
  ];
}
