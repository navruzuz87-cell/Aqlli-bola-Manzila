# Manzila: Aqlli Bola — Phase 5

Sana: 2026-11-14  
Asos: `manzila_Aqlli_Bola_v56_phase4.zip`

## Maqsad

Phase 5 da foydalanuvchi profilida yoshni sinfdan alohida saqlash, yoshga mos Game Editor cheklovlarini ishga tushirish, Alpomish Runner taymer/qiyinlik sozlamalarini runtime bilan bog‘lash va Al-Xorazmiy bloklarida drag-and-drop boshqaruvini qo‘shish.

## Bajarilgan o‘zgarishlar

### 1. UserProfile: yosh maydoni

`lib/data/models/user_profile.dart`
- `age` nomli nullable `int?` maydon qo‘shildi.
- Constructor va `copyWith` ga qo‘shildi.
- `fromJson` va `toJson` ga qo‘shildi.
- Eski profillarda `age` bo‘lmasa `null` bo‘lib qoladi; eski saqlangan profil buzilmaydi.
- `grade` maktab sinfi sifatida o‘z holicha saqlandi; yosh bilan almashtirilmadi.

Eslatma: profil yaratish/tahrirlash ekraniga yosh kiritish UI hali ulanmagan. Shu sababli eski profillarda yosh noma’lum bo‘lsa, `GameConfigData.isSuitableForAge(null)` mos deb qabul qiladi; ota-ona keyin profil yoshini kiritishi kerak.

### 2. Al-Xorazmiy Math Blocks

`lib/features/games/mathblocks/math_blocks_screen.dart`
- Game Editor konfiguratsiyasi bo‘yicha yosh oralig‘i tekshiriladi.
- Yosh chegarasidan tashqarida bo‘lsa o‘yin boshlanmaydi va sabab ko‘rsatiladi.
- Javob variantlari `Draggable<int>` qilindi.
- Taxta kataklari `DragTarget<int>` bo‘ldi; faqat to‘g‘ri javob qabul qilinadi.
- Avvalgi tap orqali tanlash/joylashtirish usuli ham saqlandi (accessibility/fallback).
- Drag qilingan javobni ko‘rsatish uchun vizual feedback qo‘shildi.

### 3. Alpomish Runner

`lib/features/games/runner/alpomish_runner_screen.dart`
- Yosh oralig‘i tekshiriladi; mos bo‘lmasa o‘yin bloklanadi va tushuntirish ko‘rsatiladi.
- `timerEnabled` va `timeLimitSeconds` sessiya taymeriga ulandi.
- Qolgan vaqt HUD ichida ko‘rsatiladi.
- Vaqt tugasa o‘yin to‘xtaydi.
- `difficulty` (`easy`, `normal`, `hard`) harf/to‘siq paydo bo‘lish tezligiga ta’sir qiladi.
- `questionCount` kampaniya uchun maksimal bosqichlar sonini belgilaydi; amaldagi kontent 8 ta tayyor bosqich bilan cheklangan. Yakuniy bosqichdan so‘ng safar yakunlanadi.
- `robotHints=false` bo‘lsa Runner HUD'da maslahat matni berilmaydi.
- Level/retry davomida taymer qayta boshlanadi; ekran yopilganda timer bekor qilinadi.

## O‘zgargan fayllar

- `lib/data/models/user_profile.dart`
- `lib/features/games/mathblocks/math_blocks_screen.dart`
- `lib/features/games/runner/alpomish_runner_screen.dart`
- `docs/PHASE_5_IMPLEMENTATION.md`
- `docs/PHASE_5_CHANGELOG.md`
- `NEXT_CHAT_PROMPT.txt`

## Hali bajarilmagan ishlar

1. Profil yaratish va tahrirlash UI'siga yosh tanlash maydoni qo‘shish.
2. Runner `questionCount` qiymati mavjud 8 ta level bilan chegaralanadi; yakuniy bosqichda safar yakunlanishi ko‘rsatiladi. Kelajakda yangi level kontenti qo‘shilganda limit kengaytiriladi.
3. Runner `rewardStars` ni GameStatsService bilan yagona, takrorlanmaydigan transaction sifatida qayd qilish.
4. Math Blocks'da 2×2 amal plitkalarini sudrab tenglama yig‘ish rejimi (hozirgi drag-and-drop javob blokini katakka joylash bilan cheklangan).
5. Math Blocks `speed` parametrini animatsiya/taxta yangilanish tezligiga ulash.
6. Game Editor'da to‘siqlar, savollar banki, sahna ketma-ketligi, dialog/choice/ending va audio sozlamalari.
7. Barcha o‘yinlar uchun yagona GameStatsService integratsiyasi.
8. Hudud → shahar → tuman → diqqatga sazovor joy xarita daraxti.
9. Original musiqa, sound effects, 3D model, rig va mimika animatsiyalari.
10. Haqiqiy multiplayer backend va bolalar xavfsizligi.

## Sinov holati

Flutter/Dart SDK ushbu ish muhitida mavjud emas (`dart: command not found`). Shu sababli `flutter pub get`, `dart format`, `flutter analyze`, `flutter test` va Android build bajarilmadi. Kod o‘zgarishlari manba darajasida ko‘rib chiqildi; bu kompilyatsiya kafolati emas.

## Keyingi bosqich — Phase 6

- Profil UI'da yoshni kiritish/tahrirlash va mavjud profillar uchun backward-compatible migratsiya.
- Runner campaign limit va final victory overlay.
- Math Blocks uchun 2×2 tenglama plitkalari va drag/drop operand/operator joylashtirish.
- `GameStatsService` bilan standart natija yozish modeli.
- Editor kontentini JSON schema va preview bilan kengaytirish.
- Testlar yozish va Flutter SDK mavjud muhitda to‘liq build.
