// ════════════════════════════════════════════════════════════════════════════
// O'ZBEKISTON XARITASI — Viloyatlar, shaharlar, bosqichlar
// Haqiqiy geografiya, tarix, madaniyat bo'yicha sayohat o'yini
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Viloyat ma'lumotlari ────────────────────────────────────────────────────

enum UzRegion {
  toshkentShahar,   // 1. Toshkent shahar
  toshkentViloyat,  // 2. Toshkent viloyati
  andijon,          // 3. Andijon
  namangan,         // 4. Namangan
  fargona,          // 5. Farg'ona
  samarqand,        // 6. Samarqand
  buxoro,           // 7. Buxoro
  navoiy,           // 8. Navoiy
  jizzax,           // 9. Jizzax
  sirdaryo,         // 10. Sirdaryo
  qashqadaryo,      // 11. Qashqadaryo
  surxondaryo,      // 12. Surxondaryo
  xorazm,           // 13. Xorazm
  qoraqalpogiston,  // 14. Qoraqalpog'iston
}

class UzRegionData {
  final UzRegion id;
  final String name;
  final String emoji;
  final String capital;
  final Color color;
  final Color colorDark;
  final String description;
  final double mapX; // 0.0-1.0 (xaritadagi pozitsiya)
  final double mapY;
  final List<UzCity> cities;
  final int requiredStars; // ochish uchun kerak bo'lgan yulduzlar
  final bool isLocked;

  const UzRegionData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.capital,
    required this.color,
    required this.colorDark,
    required this.description,
    required this.mapX,
    required this.mapY,
    required this.cities,
    this.requiredStars = 0,
    this.isLocked = false,
  });
}

class UzCity {
  final String name;
  final String emoji;
  final String description;
  final List<String> funFacts;
  final int stageCount;
  final UzStageTheme theme;

  const UzCity({
    required this.name,
    required this.emoji,
    required this.description,
    required this.funFacts,
    this.stageCount = 3,
    this.theme = UzStageTheme.culture,
  });
}

enum UzStageTheme {
  history,    // Tarix
  culture,    // Madaniyat
  geography,  // Geografiya
  science,    // Fan
  language,   // Til
}

// ─── Hamma viloyatlar ma'lumotlari ───────────────────────────────────────────

class UzbekistanMap {
  static const List<UzRegionData> regions = [

    // ══ 1. TOSHKENT SHAHAR (boshlang'ich, bepul ochiq) ═══════════════════════
    UzRegionData(
      id: UzRegion.toshkentShahar,
      name: 'Toshkent',
      emoji: '🏙️',
      capital: 'Toshkent',
      color: Color(0xFF3F51B5),
      colorDark: Color(0xFF1A237E),
      description: 'O\'zbekistonning poytaxti va eng katta shahri!',
      mapX: 0.72,
      mapY: 0.22,
      requiredStars: 0,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Chorsu bozori',
          emoji: '🛒',
          description: 'O\'rta Osiyoning eng qadimiy bozorlari',
          funFacts: [
            'Chorsu bozori 2000 yildan ko\'proq tarixga ega',
            'Bozorning gumbazi dengiz sathidan 25 metr baland',
            'Har kuni 30 000 dan ortiq xaridor keladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Mustaqillik maydoni',
          emoji: '🏛️',
          description: 'O\'zbekiston mustaqilligining ramzi',
          funFacts: [
            'Maydon 1991-yilda qurilgan',
            'Maydonda 164 metr baland bayroq ustuni bor',
            'Har yili 1-sentabrda katta bayram bo\'ladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Toshkent metrost.',
          emoji: '🚇',
          description: 'O\'rta Osiyodagi birinchi metro!',
          funFacts: [
            'Metro 1977-yilda ochilgan',
            'Har bir bekat alohida dizaynga ega',
            'Yunusobod liniyasi eng yangi liniya',
          ],
          stageCount: 3,
          theme: UzStageTheme.science,
        ),
        UzCity(
          name: 'Alisher Navoiy ko\'chasi',
          emoji: '📚',
          description: 'Buyuk shoir Alisher Navoiy nomi bilan atalgan',
          funFacts: [
            'Alisher Navoiy 1441-1501 yillarda yashagan',
            'U 30 dan ortiq asar yozgan',
            'Navoiy o\'zbek adabiyotining otasi deyiladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.language,
        ),
      ],
    ),

    // ══ 2. SAMARQAND (Ipak yo'li markazi) ════════════════════════════════════
    UzRegionData(
      id: UzRegion.samarqand,
      name: 'Samarqand',
      emoji: '🕌',
      capital: 'Samarqand',
      color: Color(0xFF7B1FA2),
      colorDark: Color(0xFF4A148C),
      description: 'Ipak yo\'lining oltin shahri — 2750 yillik tarix!',
      mapX: 0.52,
      mapY: 0.42,
      requiredStars: 10,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Registon',
          emoji: '🏯',
          description: 'Dunyoning eng go\'zal maydoni',
          funFacts: [
            'Registon 3 ta madrasadan iborat',
            'Ulug\'bek madrasasi 1420-yilda qurilgan',
            'UNESCO jahon merosi ro\'yxatida',
          ],
          stageCount: 4,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Shohi Zinda',
          emoji: '⭐',
          description: '11 asrdan beri davom etayotgan muqaddas joy',
          funFacts: [
            'Shohi Zinda "Tirik shoh" degan ma\'noni anglatadi',
            'Bu yerda 20 dan ortiq maqbara bor',
            'Ko\'k kashtalar uning bezagini tashkil etadi',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Ulug\'bek rasadxonasi',
          emoji: '🔭',
          description: 'XV asrdagi ulkan astronomik rasadxona',
          funFacts: [
            'Ulug\'bek 1001 yulduzni hisoblab chiqqan',
            'U bir yilni 365 kun 6 soat 10 daqiqa deb hisoblagan',
            'Bu hisob zamonaviy hisobdan atigi 58 soniyaga farq qiladi',
          ],
          stageCount: 4,
          theme: UzStageTheme.science,
        ),
        UzCity(
          name: 'Afrosiyob',
          emoji: '🏺',
          description: 'Qadimgi Samarqandning arxeologik muzeysi',
          funFacts: [
            'Afrosiyob 2700 yil oldin bunyod etilgan',
            'Bu yerdan ko\'plab qadimiy buyumlar topilgan',
            'Shahar Iskandar Zulqayrn tomonidan bosib olingan',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
      ],
    ),

    // ══ 3. BUXORO (Sharqning Pok shahri) ══════════════════════════════════════
    UzRegionData(
      id: UzRegion.buxoro,
      name: 'Buxoro',
      emoji: '🌙',
      capital: 'Buxoro',
      color: Color(0xFFF57F17),
      colorDark: Color(0xFFE65100),
      description: 'Sharqning yuragi — 2500 yillik muqaddas shahar!',
      mapX: 0.38,
      mapY: 0.48,
      requiredStars: 20,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Ark qal\'asi',
          emoji: '🏰',
          description: 'Buxoro amirlarining qadimiy qal\'asi',
          funFacts: [
            'Ark qal\'asi miloddan avvalgi 1-asrda qurilgan',
            'Oxirgi 1400 yil davomida xonlar bu yerda yashagan',
            'Devorlarning balandligi 20 metrga yetadi',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Lyabi-xovuz',
          emoji: '🏊',
          description: 'Buxoroning qadimiy ko\'li atrofidagi maydoni',
          funFacts: [
            'Lyabi-xovuz 1620-yilda qurilgan',
            'Ko\'l atrofida 300 yillik tut daraxtlari o\'sadi',
            'Nasriddin Afandining haykali shu yerda',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Kalon minorasi',
          emoji: '🗼',
          description: 'O\'rta Osiyodagi eng baland minora',
          funFacts: [
            'Minora 1127-yilda qurilgan',
            'Balandligi 47 metr',
            'Chingizxon bu minorani buzishni buyurgan, lekin go\'zalligi uni to\'xtatgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Ibn Sino xiyoboni',
          emoji: '🏥',
          description: 'Buyuk tabib Ibn Sino yurgan ko\'chalar',
          funFacts: [
            'Ibn Sino 980-1037 yillarda yashagan',
            'U 450 dan ortiq asar yozgan',
            '\'Tib qonunlari\' asari 500 yil davomida Yevropa dorilarida o\'tilgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.science,
        ),
      ],
    ),

    // ══ 4. FARG'ONA VODIYSI ═══════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.fargona,
      name: "Farg'ona",
      emoji: '🌸',
      capital: "Farg'ona",
      color: Color(0xFF388E3C),
      colorDark: Color(0xFF1B5E20),
      description: 'O\'zbekistonning bog\'i — ipak va meva vodiysi!',
      mapX: 0.88,
      mapY: 0.35,
      requiredStars: 30,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Marg\'ilon',
          emoji: '🧵',
          description: 'O\'rta Osiyoning ipak poytaxti',
          funFacts: [
            'Marg\'ilon 2000 yildan ko\'proq tarixga ega',
            'Bu yerda "Atlas" va "Adras" ipagi to\'qiladi',
            'Yodgorlik Ipakchilik kombinati bu yerda joylashgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Qo\'qon xonligi',
          emoji: '👑',
          description: 'O\'zbekistonning so\'nggi xonliklaridan biri',
          funFacts: [
            'Qo\'qon xonligi 1709-1876 yillarda mavjud bo\'lgan',
            'Xon saroyi 1871-yilda qurilgan',
            'Saroy 100 dan ortiq xonadan iborat',
          ],
          stageCount: 4,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Chimyon tog\'lari',
          emoji: '⛰️',
          description: 'Farg\'onaning tog\'li go\'zal tabiat parki',
          funFacts: [
            'Chimyon 1500 metr balandlikda joylashgan',
            'Qish oylarida ski kurort ishlaydi',
            'Yoz oylarida temir yo\'l to\'xtatib qoladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 5. NAMANGAN ═══════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.namangan,
      name: 'Namangan',
      emoji: '🫐',
      capital: 'Namangan',
      color: Color(0xFF0288D1),
      colorDark: Color(0xFF01579B),
      description: 'O\'zbekistonning uchta yirik shahri — Namangan!',
      mapX: 0.83,
      mapY: 0.25,
      requiredStars: 35,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Ko\'hna bozor',
          emoji: '🏪',
          description: 'Namanganninq qadimiy savdo markazi',
          funFacts: [
            'Ko\'hna bozor 500 yildan ko\'proq tarixga ega',
            'Bu yerda o\'zbek non va samarqand tortlari mashhur',
            'Ipak matolar bu bozorning asosiy mahsuloti',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Chust tumani',
          emoji: '🔪',
          description: 'O\'zbek pichoqlari ustasi — Chust',
          funFacts: [
            'Chust pichog\'i O\'zbekiston ramzlaridan biri',
            'An\'anaviy "Chust pichog\'" UNESCO merosida',
            'Har yili Chust pichog\'i festivali bo\'lib o\'tadi',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Namangan shahri',
          emoji: '🌃',
          description: 'O\'zbekistonning uchinchi yirik shahri',
          funFacts: [
            'Namangan aholisi 600 000 dan ortiq',
            'Shahar 17-asrda qurilgan',
            'O\'zbekistonning "Ipak yo\'li" bo\'ylab joylashgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 6. ANDIJON ════════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.andijon,
      name: 'Andijon',
      emoji: '🌺',
      capital: 'Andijon',
      color: Color(0xFFE53935),
      colorDark: Color(0xFFB71C1C),
      description: 'Bobur vatani — shoir va imperatorning tug\'ilgan shahri!',
      mapX: 0.9,
      mapY: 0.3,
      requiredStars: 40,
      isLocked: false,
      cities: [
        UzCity(
          name: 'Zahiriddin Bobur',
          emoji: '👑',
          description: 'Buyuk shoirning tug\'ilgan joyi',
          funFacts: [
            'Bobur 1483-yilda Andijonda tug\'ilgan',
            'U Hindistonda Boburiylar sulolasini barpo etgan',
            'Baburnomai kitob 15-asrda yozilgan',
          ],
          stageCount: 4,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Andijon bozori',
          emoji: '🛍️',
          description: 'Vodiyning eng katta savdo markazi',
          funFacts: [
            'Andijon aholisi 400 000 dan ortiq',
            'Shahar Farg\'ona vodiysining markazida joylashgan',
            'Bu yerda neft va gaz qazib olinadi',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 7. TOSHKENT VILOYATI ══════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.toshkentViloyat,
      name: 'Toshkent viloyati',
      emoji: '🌲',
      capital: 'Nurafshon',
      color: Color(0xFF00796B),
      colorDark: Color(0xFF004D40),
      description: 'Poytaxt atrofidagi ko\'hna qishloqlar va tog\'lar!',
      mapX: 0.70,
      mapY: 0.28,
      requiredStars: 45,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Chimgan',
          emoji: '🏔️',
          description: 'Toshkent yaqinidagi tog\' kurort',
          funFacts: [
            'Chimgan Toshkentdan 80 km uzoqda',
            'Qish oylarida eng mashhur ski joyi',
            'Charvak suv ombori bu yerda joylashgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
        UzCity(
          name: 'Chirchiq',
          emoji: '🏭',
          description: 'Sanoat shahri Chirchiq daryosi bo\'yida',
          funFacts: [
            'Chirchiq 1935-yilda asoslangan',
            'Bu yerda o\'g\'it va kimyo zavodi bor',
            'Daryoda baliq ovlash mashhur',
          ],
          stageCount: 3,
          theme: UzStageTheme.science,
        ),
      ],
    ),

    // ══ 8. NAVOIY ════════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.navoiy,
      name: 'Navoiy',
      emoji: '💎',
      capital: 'Navoiy',
      color: Color(0xFF5E35B1),
      colorDark: Color(0xFF311B92),
      description: 'O\'zbekistonning oltin va uranyum viloyati!',
      mapX: 0.42,
      mapY: 0.38,
      requiredStars: 50,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Navoiy shahri',
          emoji: '🏗️',
          description: 'Zamonaviy sanoat shahri',
          funFacts: [
            'Navoiy 1958-yilda qurilgan',
            'Shahar ikkinchi jahon urushida asir tushgan yaponlar tomonidan qurilgan',
            'Kimyo sanoati bu yerning asosi',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Uchquduq',
          emoji: '⛽',
          description: 'Cho\'ldagi shahar — uranyum qazib olinadigan joy',
          funFacts: [
            'Uchquduq cho\'lning o\'rtasida joylashgan',
            'Bu yerda katta uranyum koni bor',
            'Shahar atmosferasi maxsus muhofaza ostida',
          ],
          stageCount: 3,
          theme: UzStageTheme.science,
        ),
        UzCity(
          name: 'Nurota',
          emoji: '🏛️',
          description: 'Qadimiy tog\' shaharchasi',
          funFacts: [
            'Nurota 2300 yillik tarixga ega',
            'Iskandar Zulqayrn bu qal\'ani qurilgan deyiladi',
            'Bu yerda muqaddas buloq mavjud',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
      ],
    ),

    // ══ 9. JIZZAX ════════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.jizzax,
      name: 'Jizzax',
      emoji: '🌾',
      description: 'Eron va mo\'g\'ullarni to\'xtatgan o\'lka!',
      capital: 'Jizzax',
      color: Color(0xFF827717),
      colorDark: Color(0xFF524C00),
      mapX: 0.60,
      mapY: 0.35,
      requiredStars: 55,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Jizzax shahar',
          emoji: '🏙️',
          description: 'Jizzax viloyatining markazi',
          funFacts: [
            'Jizzax "Mo\'tadil iqlim" degan ma\'noni anglatadi',
            'Bu yerda Islam Karimov tug\'ilgan',
            'Viloyat g\'alla yetishtirish markazidir',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Do\'stlik tumani',
          emoji: '🤝',
          description: 'Paxta yetishtirish markazi',
          funFacts: [
            'O\'zbekiston paxta eksportida dunyoda yetakchi',
            'Paxta "Oq oltin" deb ataladi',
            'Jizzax dalalarida yiliga million tonna paxta yig\'iladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
      ],
    ),

    // ══ 10. SIRDARYO ═════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.sirdaryo,
      name: 'Sirdaryo',
      emoji: '🌊',
      capital: 'Guliston',
      color: Color(0xFF006064),
      colorDark: Color(0xFF00363A),
      description: 'Buyuk Sirdaryo daryosi bo\'yidagi viloyat!',
      mapX: 0.65,
      mapY: 0.25,
      requiredStars: 60,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Guliston',
          emoji: '🌹',
          description: 'Gullar shahri — Sirdaryo viloyatining markazi',
          funFacts: [
            'Guliston "Gulzor" degan ma\'noni anglatadi',
            'Shahar aholisi 60 000 dan ortiq',
            'Bu yerda katta neft-kimyo korxonalari bor',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
        UzCity(
          name: 'Sirdaryo daryosi',
          emoji: '🏞️',
          description: 'O\'rta Osiyoning uzun daryolaridan biri',
          funFacts: [
            'Sirdaryo daryosi 2212 km uzunlikka ega',
            'U Farg\'ona vodiysidan boshlanadi',
            'Qadimda "Yaksart" deb atalgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 11. QASHQADARYO ══════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.qashqadaryo,
      name: 'Qashqadaryo',
      emoji: '⚔️',
      capital: 'Qarshi',
      color: Color(0xFFBF360C),
      colorDark: Color(0xFF7F0000),
      description: 'Amir Temur vatani — Shahrisabz va Qarshi!',
      mapX: 0.55,
      mapY: 0.57,
      requiredStars: 65,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Shahrisabz',
          emoji: '👑',
          description: 'Amir Temurning tug\'ilgan joyi',
          funFacts: [
            'Shahrisabz "Ko\'k shahar" degan ma\'noni anglatadi',
            'Amir Temur 1336-yilda bu yerda tug\'ilgan',
            'Oq saroy (Ak-Saray) qoldiqlari bu yerda saqlanadi',
          ],
          stageCount: 4,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Qarshi',
          emoji: '🌵',
          description: 'Cho\'l viloyatining markazi',
          funFacts: [
            'Qarshi qadimda "Nasaf" deb atalgan',
            'Viloyatda katta gaz konlari bor',
            'Shahar O\'zbekiston janubining savdo markazidir',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
        UzCity(
          name: 'Kitob astronomik',
          emoji: '🌟',
          description: 'O\'zbekistondagi yagona xalqaro rasadxona',
          funFacts: [
            'Kitob rasadxonasi 1930-yilda qurilgan',
            'Bu yerda Er yuzining siljishi o\'lchanadi',
            'Xalqaro astronomiya tashkiloti tomonidan e\'tirof etilgan',
          ],
          stageCount: 3,
          theme: UzStageTheme.science,
        ),
      ],
    ),

    // ══ 12. SURXONDARYO ══════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.surxondaryo,
      name: 'Surxondaryo',
      emoji: '🦁',
      capital: 'Termiz',
      color: Color(0xFF4E342E),
      colorDark: Color(0xFF1A0000),
      description: 'O\'zbekistonning janubidagi qadimiy o\'lka!',
      mapX: 0.60,
      mapY: 0.68,
      requiredStars: 70,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Termiz',
          emoji: '☀️',
          description: 'O\'zbekistonning eng issiq shahri',
          funFacts: [
            'Termiz O\'zbekistonning janubiy chegarasida joylashgan',
            'Yoz kunlari harorat 50 gradusga yetishi mumkin',
            'Qadimgi buddist madaniyati bu yerda yashagan',
          ],
          stageCount: 3,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Zarafshon tizma',
          emoji: '⛰️',
          description: 'Surxondaryoning baland tog\'lari',
          funFacts: [
            'Bu tog\'larda qor yil bo\'yi erimaydi',
            'Endemik o\'simliklar bu yerda o\'sadi',
            'Leopardlar bu tog\'larda yashaydi',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 13. XORAZM ═══════════════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.xorazm,
      name: 'Xorazm',
      emoji: '🏺',
      capital: 'Urganch',
      color: Color(0xFF558B2F),
      colorDark: Color(0xFF1B5E00),
      description: 'Al-Xorazmiy vatani — algebraning tug\'ilgan joyi!',
      mapX: 0.28,
      mapY: 0.32,
      requiredStars: 75,
      isLocked: true,
      cities: [
        UzCity(
          name: 'Xiva (Ichon-Qal\'a)',
          emoji: '🏯',
          description: 'UNESCO merosi — butunlay saqlanib qolgan qadimiy shahar',
          funFacts: [
            'Xiva shahrining devor ichida butun qadimiy shahar bor',
            'Ichon-Qal\'a 400 dan ortiq tarixiy bino saqlaydi',
            'Bu O\'rta Osiyodagi eng yaxshi saqlangan qadimiy shahar',
          ],
          stageCount: 4,
          theme: UzStageTheme.history,
        ),
        UzCity(
          name: 'Muhammad al-Xorazmiy',
          emoji: '📐',
          description: 'Algebra fanini kashf etgan buyuk olim',
          funFacts: [
            'Al-Xorazmiy 780-850 yillarda yashagan',
            'Algebra nomi uning asaridan kelib chiqqan',
            '"Algorithm" so\'zi uning ismidan olingan',
          ],
          stageCount: 4,
          theme: UzStageTheme.science,
        ),
        UzCity(
          name: 'Orol dengizi',
          emoji: '🏜️',
          description: 'Quriib qolgan dengiz — ekologik fojianing saboqi',
          funFacts: [
            'Orol dengizi bir zamonlar 4-chi katta ko\'l edi',
            'Hozirda sathining 90% qurib ketgan',
            'Baliqchilik to\'xtab, temir kemalar cho\'lda qoldi',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),

    // ══ 14. QORAQALPOG'ISTON ═════════════════════════════════════════════════
    UzRegionData(
      id: UzRegion.qoraqalpogiston,
      name: "Qoraqalpog'iston",
      emoji: '🐪',
      capital: "No'kis",
      color: Color(0xFF37474F),
      colorDark: Color(0xFF102027),
      description: 'O\'zbekiston ichidagi avtonom respublika — Orol bo\'yi!',
      mapX: 0.22,
      mapY: 0.25,
      requiredStars: 80,
      isLocked: true,
      cities: [
        UzCity(
          name: "No'kis muzeysi",
          emoji: '🖼️',
          description: 'Dunyoning eng yirik avangard san\'at muzeysi',
          funFacts: [
            'Savitskiy muzeyi sovet davrida yashirin saqlangan asarlarni saqlaydi',
            'Bu yerda 90 000 dan ortiq san\'at asari bor',
            '"Qoʻriqxona" deb ataladi',
          ],
          stageCount: 3,
          theme: UzStageTheme.culture,
        ),
        UzCity(
          name: 'Qoraqum cho\'li',
          emoji: '🏜️',
          description: 'O\'rta Osiyoning ulkan cho\'li',
          funFacts: [
            'Qoraqum cho\'li 350 000 kv.km. maydonni egallaydi',
            'Yozda harorat 60 gradusga yetishi mumkin',
            'O\'ziga xos flora va fauna mavjud',
          ],
          stageCount: 3,
          theme: UzStageTheme.geography,
        ),
      ],
    ),
  ];

  // ─── Viloyatni ID bo'yicha topish ──────────────────────────────────────────
  static UzRegionData getRegion(UzRegion id) {
    return regions.firstWhere((r) => r.id == id);
  }

  // ─── Keyingi viloyatni topish (xarita bo'yicha yo'l) ──────────────────────
  static List<UzRegion> getPathTo(UzRegion destination) {
    // Toshkentdan boshlagan sayohat yo'li
    const paths = <UzRegion, List<UzRegion>>{
      UzRegion.toshkentShahar: [],
      UzRegion.samarqand: [UzRegion.toshkentShahar, UzRegion.jizzax],
      UzRegion.buxoro: [UzRegion.toshkentShahar, UzRegion.jizzax, UzRegion.samarqand],
      UzRegion.fargona: [UzRegion.toshkentShahar, UzRegion.toshkentViloyat],
      UzRegion.namangan: [UzRegion.toshkentShahar, UzRegion.toshkentViloyat, UzRegion.fargona],
      UzRegion.andijon: [UzRegion.toshkentShahar, UzRegion.toshkentViloyat, UzRegion.fargona, UzRegion.namangan],
    };
    return paths[destination] ?? [UzRegion.toshkentShahar];
  }

  // ─── Yulduzlar hisobi ─────────────────────────────────────────────────────
  static int getTotalStages() {
    return regions.fold(0, (sum, r) => sum + r.cities.fold(0, (s, c) => s + c.stageCount));
  }
}

// ─── O'yinchi progressi ───────────────────────────────────────────────────────

class MapProgress {
  final Map<String, int> stageStars;      // "region_city_stage" => 0-3
  final Map<UzRegion, bool> regionsUnlocked;
  final int totalStars;

  const MapProgress({
    required this.stageStars,
    required this.regionsUnlocked,
    required this.totalStars,
  });

  bool isStageComplete(UzRegion region, int cityIdx, int stageIdx) {
    final key = '${region.name}_${cityIdx}_$stageIdx';
    return (stageStars[key] ?? 0) > 0;
  }

  int getStageStars(UzRegion region, int cityIdx, int stageIdx) {
    final key = '${region.name}_${cityIdx}_$stageIdx';
    return stageStars[key] ?? 0;
  }

  bool isCityUnlocked(UzRegion region, int cityIdx, Map<UzRegion, int> cityStarsMap) {
    if (cityIdx == 0) return regionsUnlocked[region] ?? false;
    // Oldingi shaharning barcha bosqichlari tugallanganmi?
    return true; // Soddalashtirilgan
  }

  MapProgress copyWith({
    Map<String, int>? stageStars,
    Map<UzRegion, bool>? regionsUnlocked,
    int? totalStars,
  }) {
    return MapProgress(
      stageStars: stageStars ?? this.stageStars,
      regionsUnlocked: regionsUnlocked ?? this.regionsUnlocked,
      totalStars: totalStars ?? this.totalStars,
    );
  }
}
