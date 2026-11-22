// ════════════════════════════════════════════════════════════════════════════
// O'ZBEKISTON SAYOHATI — Savollar bazasi
// Haqiqiy geografiya, tarix, fan, madaniyat bo'yicha savollar
// ════════════════════════════════════════════════════════════════════════════

import 'uzbekistan_map.dart';

class UzQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String funFact;

  const UzQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.funFact = '',
  });
}

class UzQuestionsData {

  // ─── TOSHKENT SHAHRI ───────────────────────────────────────────────────────

  static const toshkent_stage1 = [
    UzQuestion(
      question: 'Toshkent O\'zbekistonning nechi yillik poytaxti?',
      options: ['100 yil', '500 yil', '2200+ yil', '50 yil'],
      correctIndex: 2,
      explanation: 'Toshkent 2200 yildan ko\'proq tarixga ega va uzoq vaqt davomida mintaqaning yirik shahri bo\'lgan!',
      funFact: 'Toshkent 1966-yilgi zilziladan keyin qayta qurilgan',
    ),
    UzQuestion(
      question: 'Toshkentdagi "Chorsu" bozorining nomi nimani anglatadi?',
      options: ['To\'rt ko\'cha', 'Yashil joy', 'Suv yaqinida', 'Qadimiy bozor'],
      correctIndex: 0,
      explanation: '"Chorsu" so\'zi to\'rt tomonga ketadigan ko\'chalar kesishmasini anglatadi!',
      funFact: 'Chorsu bozori O\'rta Osiyoning eng qadimiy bozorlaridan biri',
    ),
    UzQuestion(
      question: 'O\'rta Osiyodagi birinchi metro qaysi shaharda ochilgan?',
      options: ['Samarqand', 'Buxoro', 'Toshkent', 'Olmaota'],
      correctIndex: 2,
      explanation: 'Toshkent metrost 1977-yilda ochilgan — O\'rta Osiyodagi birinchi metro!',
      funFact: 'Metro bekatlarining har biri o\'ziga xos bezakka ega',
    ),
    UzQuestion(
      question: 'Toshkentda 1-sentabrda nima nishonlanadi?',
      options: ['Navro\'z', 'Mustaqillik kuni', 'Maktabga birinchi qadam', 'Yangi yil'],
      correctIndex: 2,
      explanation: '1-sentabr — O\'qituvchi va murabbiylar kuni hamda "Maktabga birinchi qadam" bayrami!',
      funFact: 'Bu kuni butun O\'zbekistonda birinchi sinf o\'quvchilari maktabga boradi',
    ),
    UzQuestion(
      question: 'Alisher Navoiy qaysi asrda yashagan?',
      options: ['X asr', 'XIII asr', 'XV asr', 'XVII asr'],
      correctIndex: 2,
      explanation: 'Alisher Navoiy 1441-1501 yillarda yashagan — XV asrning buyuk shoiri!',
      funFact: 'Navoiy o\'zbek adabiyotida 30 dan ortiq asar yaratgan',
    ),
  ];

  static const toshkent_stage2 = [
    UzQuestion(
      question: 'Toshkentdagi Mustaqillik maydoni necha yilda qurilgan?',
      options: ['1960', '1991', '2000', '1980'],
      correctIndex: 1,
      explanation: 'Mustaqillik maydoni 1991-yilda O\'zbekiston mustaqilligi sharafiga qurilgan!',
      funFact: 'Bayroq ustunining balandligi 164 metr',
    ),
    UzQuestion(
      question: 'O\'zbekiston qaysi sanada mustaqillik e\'lon qildi?',
      options: ['1 sentyabr 1991', '31 avgust 1991', '25 dekabr 1991', '1 yanvar 1992'],
      correctIndex: 1,
      explanation: 'O\'zbekiston 31 avgust 1991-yilda Mustaqilligini e\'lon qildi, 1-sentabr esa rasmiy bayram sifatida nishonlanadi!',
      funFact: 'O\'zbekiston 1991-yilda SSSRdan ajralib chiqdi',
    ),
    UzQuestion(
      question: 'Toshkentdagi "Amir Temur" maydoni kim sharafiga nomlangan?',
      options: ['Alisher Navoiy', 'Ibn Sino', 'Amir Temur', 'Ulug\'bek'],
      correctIndex: 2,
      explanation: 'Amir Temur (Tamerlane) XIV-XV asrlardagi buyuk O\'zbek hukmdori va qo\'mondoni!',
      funFact: 'Amir Temur imperiyasi Ispaniyadan Hindistonga qadar yetgan',
    ),
    UzQuestion(
      question: 'Toshkent metrost necha yilda ishga tushirilgan?',
      options: ['1960', '1977', '1985', '1991'],
      correctIndex: 1,
      explanation: 'Toshkent metrost 1977-yilda ochilgan va hozirda 3 ta liniyadan iborat!',
      funFact: 'Yunusobod liniyasi 2020-yilda ochilgan — eng yangi liniya',
    ),
    UzQuestion(
      question: 'O\'zbekistonning poytaxti qaysi shahar?',
      options: ['Samarqand', 'Buxoro', 'Namangan', 'Toshkent'],
      correctIndex: 3,
      explanation: 'Toshkent O\'zbekistonning poytaxti va eng yirik shahri!',
      funFact: 'Toshkentda 2.5 million dan ortiq kishi yashaydi',
    ),
  ];

  // ─── SAMARQAND ────────────────────────────────────────────────────────────

  static const samarqand_stage1 = [
    UzQuestion(
      question: 'Samarqandda necha yillik tarix mavjud?',
      options: ['500 yil', '1000 yil', '2750+ yil', '200 yil'],
      correctIndex: 2,
      explanation: 'Samarqand 2750 yildan ko\'proq tarixga ega — dunyoning eng qadimiy shaharlaridan biri!',
      funFact: 'Samarqand qadimda "Marakanda" deb atalgan',
    ),
    UzQuestion(
      question: 'Registon maydonidagi necha ta madrasa bor?',
      options: ['1 ta', '2 ta', '3 ta', '4 ta'],
      correctIndex: 2,
      explanation: 'Registonda 3 ta madrasa bor: Ulug\'bek, Sherdor va Tillakori madrasalari!',
      funFact: 'Registon dunyoning eng go\'zal maydoni deb tanilgan',
    ),
    UzQuestion(
      question: 'Ulug\'bek madrasa necha yilda qurilgan?',
      options: ['1200', '1420', '1600', '1800'],
      correctIndex: 1,
      explanation: 'Ulug\'bek madrasa 1420-yilda Amir Temurning nabirasi Ulug\'bek tomonidan qurilgan!',
      funFact: 'Ulug\'bek ham buyuk olim bo\'lgan — astronomiyadagi hisoblari hali ham aniq',
    ),
    UzQuestion(
      question: 'Shohi Zinda nima degan ma\'noni anglatadi?',
      options: ['Ko\'k joy', 'Tirik shoh', 'Qadimiy qal\'a', 'Muqaddas tepa'],
      correctIndex: 1,
      explanation: '"Shohi Zinda" — "Tirik shoh" degan ma\'noni anglatadi!',
      funFact: 'Bu yerda 20 dan ortiq maqbara joylashgan',
    ),
    UzQuestion(
      question: 'Ulug\'bek rasadxonasida necha yulduz hisoblab chiqilgan?',
      options: ['100', '500', '1001', '2000'],
      correctIndex: 2,
      explanation: 'Ulug\'bek rasadxonasida 1001 yulduz katalogi tuzilgan — XV asrda bu ulkan yutuq edi!',
      funFact: 'Ulug\'bek yil uzunligini atigi 58 soniya xato hisoblagan',
    ),
  ];

  static const samarqand_stage2 = [
    UzQuestion(
      question: 'Samarqand qaysi mashhur yo\'l bo\'ylab joylashgan?',
      options: ['Shoyi yo\'li', 'Bahor yo\'li', 'Ipak yo\'li', 'Oltin yo\'l'],
      correctIndex: 2,
      explanation: 'Samarqand Ipak yo\'lining markaziy nuqtasi bo\'lgan — Xitoydan Ovro\'paga savdo yo\'li!',
      funFact: 'Ipak yo\'li orqali ipak, ziravorlar va g\'oyalar almashilgan',
    ),
    UzQuestion(
      question: 'Afrosiyob nima?',
      options: ['Shahar nomi', 'Qadimiy Samarqandning arxeologik joyi', 'Ko\'l', 'Tog\''],
      correctIndex: 1,
      explanation: 'Afrosiyob — qadimiy Samarqandning arxeologik joyi va muzeyi. Bu yerdan 2700 yillik buyumlar topilgan!',
      funFact: 'Afrosiyob muzeyida shoh ziyofatini tasvirlaydigan ulkan freskalar bor',
    ),
    UzQuestion(
      question: 'Samarqandning qadimiy nomi nima?',
      options: ['Sogd', 'Marakanda', 'Kapisa', 'Naxshab'],
      correctIndex: 1,
      explanation: 'Samarqandning qadimiy nomi "Marakanda" bo\'lgan — Iskandar Zulqayrn bu shaharga BC 329-yilda kelgan!',
      funFact: 'Iskandar Zulqayrn bu shaharda bir necha oy qolgan',
    ),
    UzQuestion(
      question: 'Registon UNESCO merosi ro\'yxatiga qaysi yilda kiritilgan?',
      options: ['1980', '1988', '2001', '2010'],
      correctIndex: 1,
      explanation: 'Samarqandning tarixiy markazi 1988-yilda UNESCO Jahon Merosi ro\'yxatiga kiritilgan!',
      funFact: 'UNESCO merosi degani butun dunyo tomonidan muhofaza qilinishi',
    ),
    UzQuestion(
      question: 'Qaysi buyuk olim Samarqandda rasadxona qurgan?',
      options: ['Ibn Sino', 'Al-Xorazmiy', 'Ulug\'bek', 'Beruniy'],
      correctIndex: 2,
      explanation: 'Ulug\'bek (1394-1449) Samarqandda katta rasadxona qurgan va astronomiya rivojiga ulkan hissa qo\'shgan!',
      funFact: 'Ulug\'bek ham shoh, ham buyuk olim bo\'lgan',
    ),
  ];

  // ─── BUXORO ───────────────────────────────────────────────────────────────

  static const buxoro_stage1 = [
    UzQuestion(
      question: 'Buxorodagi Ark qal\'asi nechanchi asrda qurilgan?',
      options: ['Miloddan avvalgi 1-asr', 'VI asr', 'X asr', 'XIV asr'],
      correctIndex: 0,
      explanation: 'Ark qal\'asi miloddan avvalgi 1-asrda qurilgan — 2000 yildan ko\'proq tarixga ega!',
      funFact: 'Oxirgi amir bu qal\'ani 1920-yilgacha qo\'riqchilik ostida ushlab turgan',
    ),
    UzQuestion(
      question: 'Lyabi-xovuz nima?',
      options: ['Muzey', 'Ko\'l atrofidagi maydoni', 'Bozor', 'Qal\'a'],
      correctIndex: 1,
      explanation: 'Lyabi-xovuz — Buxoroning qadimiy ko\'li atrofidagi go\'zal maydoni, 1620-yilda qurilgan!',
      funFact: 'Lyabi-xovuz atrofida 300 yillik tut daraxtlari o\'sadi',
    ),
    UzQuestion(
      question: 'Kalon minorasi necha metr baland?',
      options: ['20 metr', '35 metr', '47 metr', '60 metr'],
      correctIndex: 2,
      explanation: 'Kalon minorasi 47 metr balandligida — 1127-yilda qurilgan va O\'rta Osiyoning eng baland minorasidan biri!',
      funFact: 'Chingizxon bu minorani buzishni buyurgan, lekin ko\'rinishi uni to\'xtatgan',
    ),
    UzQuestion(
      question: 'Ibn Sino qayerda yashagan va nima kashf etgan?',
      options: ['Toshkent — metro', 'Buxoro — tibbiyot', 'Samarqand — astronomiya', 'Xiva — matematika'],
      correctIndex: 1,
      explanation: 'Ibn Sino (980-1037) Buxoroda tug\'ilib o\'sgan va tibbiyot fanini rivojlantirgan. Uning "Tib qonunlari" asari 500 yil Yevropa maktablarida o\'tilgan!',
      funFact: 'Ibn Sino 450 dan ortiq asar yozgan',
    ),
    UzQuestion(
      question: 'Buxoro qanday laqab bilan tanilgan?',
      options: ['Ipak yo\'li markazi', 'Sharqning yuragi', 'O\'rta Osiyoning bog\'i', 'Oltin shahar'],
      correctIndex: 1,
      explanation: 'Buxoro "Sharqning yuragi" deb ataladi — islom madaniyatining eng muhim markazlaridan biri!',
      funFact: 'Buxoroda 350 dan ortiq masjid va 100 dan ortiq madrasa bo\'lgan',
    ),
  ];

  // ─── FARG'ONA VODIYSI ─────────────────────────────────────────────────────

  static const fargona_stage1 = [
    UzQuestion(
      question: 'Marg\'ilon qaysi mahsulot bilan mashhur?',
      options: ['Paxta', 'Ipak', 'Neft', 'Oltin'],
      correctIndex: 1,
      explanation: 'Marg\'ilon "O\'rta Osiyoning ipak poytaxti" — bu yerda "Atlas" va "Adras" ipagi to\'qiladi!',
      funFact: 'Yodgorlik Ipakchilik kombinati bu yerda ishlaydi',
    ),
    UzQuestion(
      question: 'Qo\'qon xonligi qaysi yillarda mavjud bo\'lgan?',
      options: ['1200-1400', '1500-1700', '1709-1876', '1800-1950'],
      correctIndex: 2,
      explanation: 'Qo\'qon xonligi 1709-1876 yillarda mavjud bo\'lgan — O\'zbekistonning so\'nggi xonliklaridan biri!',
      funFact: 'Xon saroyi 1871-yilda qurilgan va 100 xonadan iborat',
    ),
    UzQuestion(
      question: 'Farg\'ona vodiysi qayerda joylashgan?',
      options: ['O\'zbekiston g\'arbida', 'O\'zbekiston shimolida', 'O\'zbekiston sharqida', 'O\'zbekiston janubida'],
      correctIndex: 2,
      explanation: 'Farg\'ona vodiysi O\'zbekiston sharqida, tog\'lar o\'rtasidagi hosildor vodiyda joylashgan!',
      funFact: 'Farg\'ona vodiysi O\'rta Osiyoning eng zich joylashgan hududi',
    ),
    UzQuestion(
      question: 'Bobur (Zahiriddin Muhammad Bobur) qayerdan?',
      options: ['Farg\'ona', 'Andijon', 'Namangan', 'Toshkent'],
      correctIndex: 1,
      explanation: 'Bobur 1483-yilda Andijonda tug\'ilgan va keyinchalik Hindistonda Boburiylar sulolasini barpo etgan!',
      funFact: 'Bobur ham buyuk shoir bo\'lgan — "Boburnoma" uning eng mashhur asari',
    ),
    UzQuestion(
      question: 'Chust tumani nima bilan mashhur?',
      options: ['Ipak', 'Pichok yasash', 'Qozon yasash', 'Kulolchilik'],
      correctIndex: 1,
      explanation: 'Chust an\'anaviy o\'zbek pichoqlari ustasi — "Chust pichog\'i" UNESCO ro\'yxatida!',
      funFact: 'Har yili Chust pichog\'i festivali bo\'lib o\'tadi',
    ),
  ];

  // ─── XORAZM ───────────────────────────────────────────────────────────────

  static const xorazm_stage1 = [
    UzQuestion(
      question: 'Muhammad al-Xorazmiy qaysi fanni kashf etgan?',
      options: ['Kimyo', 'Algebra', 'Fizika', 'Biologiya'],
      correctIndex: 1,
      explanation: 'Al-Xorazmiy (780-850) algebrani kashf etgan. "Algebra" so\'zi uning asaridan kelib chiqqan!',
      funFact: '"Algorithm" so\'zi ham al-Xorazmiy ismidan olingan',
    ),
    UzQuestion(
      question: 'Xivadagi Ichon-Qal\'a nima?',
      options: ['Muzey', 'Butunlay saqlanib qolgan qadimiy shahar', 'Bozor', 'Hovuz'],
      correctIndex: 1,
      explanation: 'Ichon-Qal\'a — devorlar ichida butunlay saqlanib qolgan qadimiy shahar. 400 dan ortiq tarixiy bino mavjud!',
      funFact: 'Bu O\'rta Osiyodagi eng yaxshi saqlangan qadimiy shahar',
    ),
    UzQuestion(
      question: 'Orol dengizi hozir qanday holatda?',
      options: ['Avvalgidek katta', 'Biroz kichraygan', 'Sathining 90% quriib ketgan', 'Yangi suv bilan to\'lgan'],
      correctIndex: 2,
      explanation: 'Orol dengizining 90% dan ko\'prog\'i quriib ketgan — bu XX asrning eng katta ekologik falokatlaridan biri!',
      funFact: 'Qadimda Orol dengizi 4-chi katta ko\'l bo\'lgan',
    ),
    UzQuestion(
      question: 'Xorazmdan chiqqan al-Xorazmiy qaysi asrda yashagan?',
      options: ['V asr', 'VIII-IX asr', 'XII asr', 'XV asr'],
      correctIndex: 1,
      explanation: 'Al-Xorazmiy 780-850 yillarda yashagan — IX asrning buyuk matematiki!',
      funFact: 'Uning algebra kitobi XII asrda lotinchaga tarjima qilingan',
    ),
    UzQuestion(
      question: 'Urganchdan qancha uzoqda Xiva joylashgan?',
      options: ['5 km', '35 km', '100 km', '200 km'],
      correctIndex: 1,
      explanation: 'Xiva Urganchdan 35 km uzoqda joylashgan — ikki shahar ham Xorazm viloyatida!',
      funFact: 'Urganchdan Xivaga avtobusda 40 daqiqa',
    ),
  ];

  // ─── QASHQADARYO (Shahrisabz) ─────────────────────────────────────────────

  static const qashqadaryo_stage1 = [
    UzQuestion(
      question: 'Shahrisabz qaysi buyuk shaxsning vatani?',
      options: ['Alisher Navoiy', 'Ulug\'bek', 'Amir Temur', 'Ibn Sino'],
      correctIndex: 2,
      explanation: 'Amir Temur 1336-yilda Shahrisabzda tug\'ilgan. Shahrisabz uning vatani!',
      funFact: 'Amir Temur imperiyasi 3 kontinentga yoyilgan',
    ),
    UzQuestion(
      question: '"Shahrisabz" so\'zi nima degan ma\'noni anglatadi?',
      options: ['Qizil shahar', 'Ko\'k shahar', 'Oltin shahar', 'Qadimiy shahar'],
      correctIndex: 1,
      explanation: '"Shahrisabz" tojik tilida "Ko\'k shahar" yoki "Yashil shahar" degan ma\'noni anglatadi!',
      funFact: 'Bu nom bahor mavsumidagi yashil tabiatdan kelib chiqqan',
    ),
    UzQuestion(
      question: 'Kitob rasadxonasi nima uchun mashhur?',
      options: ['Yulduzlarni ko\'rish uchun', 'Er yuzining siljishini o\'lchash uchun', 'Havoni o\'rganish uchun', 'Dengizni kuzatish uchun'],
      correctIndex: 1,
      explanation: 'Kitob rasadxonasi 1930-yildan beri Er yuzining siljishini (Latitude service) o\'lchab kelmoqda — xalqaro ahamiyatga ega!',
      funFact: 'Bu dunyodagi bir necha shunday rasadxonalardan biri',
    ),
    UzQuestion(
      question: 'Oq saroy (Ak-Saray) nima?',
      options: ['Hozirgi saroy', 'Amir Temur qal\'asining qoldiqlari', 'Muzey', 'Bozor'],
      correctIndex: 1,
      explanation: 'Ak-Saray — Amir Temur qurdirgan ulkan saroy qoldiqlari. Qurilishi 24 yil davom etgan!',
      funFact: 'Saroy darvozasining balandligi 50 metr bo\'lgan',
    ),
    UzQuestion(
      question: 'Qarshida qanday tabiiy boylik bor?',
      options: ['Oltin', 'Ko\'mir', 'Gaz', 'Olmos'],
      correctIndex: 2,
      explanation: 'Qashqadaryo viloyatida O\'zbekistonning katta gaz konlari joylashgan. Bu yerdan gaz butun mamlakatga tarqatiladi!',
      funFact: 'O\'zbekiston dunyodagi yirik gaz ishlab chiqaruvchi mamlakatlardan biri',
    ),
  ];

  // ─── Viloyat va bosqich bo'yicha savollarni olish ─────────────────────────

  static List<UzQuestion> getQuestions(UzRegion region, int cityIdx, int stageIdx) {
    switch (region) {
      case UzRegion.toshkentShahar:
        return stageIdx == 0 ? toshkent_stage1 : toshkent_stage2;
      case UzRegion.samarqand:
        return stageIdx == 0 ? samarqand_stage1 : samarqand_stage2;
      case UzRegion.buxoro:
        return buxoro_stage1;
      case UzRegion.fargona:
        return fargona_stage1;
      case UzRegion.xorazm:
        return xorazm_stage1;
      case UzRegion.qashqadaryo:
        return qashqadaryo_stage1;
      default:
        return _defaultQuestions(region);
    }
  }

  // Qolgan viloyatlar uchun umumiy savollar
  static List<UzQuestion> _defaultQuestions(UzRegion region) {
    final regionData = UzbekistanMap.getRegion(region);
    return [
      UzQuestion(
        question: '${regionData.name} viloyatining poytaxti qaysi shahar?',
        options: [regionData.capital, 'Toshkent', 'Samarqand', 'Buxoro'],
        correctIndex: 0,
        explanation: '${regionData.capital} — ${regionData.name} viloyatining poytaxti!',
      ),
      UzQuestion(
        question: '${regionData.name} viloyati qayerda joylashgan?',
        options: ['Shimolda', 'G\'arbda', 'Sharqda', 'O\'zbekistonda'],
        correctIndex: 3,
        explanation: '${regionData.name} O\'zbekiston Respublikasining bir viloyati!',
      ),
      UzQuestion(
        question: 'O\'zbekiston nechta viloyatdan iborat?',
        options: ['10 ta', '12 ta', '14 ta', '16 ta'],
        correctIndex: 1,
        explanation: 'O\'zbekiston 12 viloyat, 1 avtonom respublika (Qoraqalpog\'iston) va 1 shahar (Toshkent)dan iborat!',
      ),
      UzQuestion(
        question: 'O\'zbekistonning rasmiy tili qaysi?',
        options: ['Rus tili', 'O\'zbek tili', 'Tojik tili', 'Ingliz tili'],
        correctIndex: 1,
        explanation: 'O\'zbek tili — O\'zbekiston Respublikasining rasmiy davlat tili!',
      ),
      UzQuestion(
        question: 'O\'zbekiston qaysi qit\'ada joylashgan?',
        options: ['Yevropa', 'Afrika', 'O\'rta Osiyo', 'Janubiy Osiyo'],
        correctIndex: 2,
        explanation: 'O\'zbekiston O\'rta Osiyoda joylashgan — er o\'rtasiga ham eng yaqin mamlakat!',
      ),
    ];
  }
}
