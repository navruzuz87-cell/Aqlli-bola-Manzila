# v56 dastlabki audit va tuzatish jurnali

## Ushbu paketda bajarilgan kod tuzatishlari

1. `GameStatsService.init()` ilova startida profilesiz chaqirilgan, ammo avval `profileId` majburiy bo'lgan. Metod endi argumentsiz chaqirilganda xavfsiz qaytadi; profil ma'lum bo'lgach uning statistikasi yuklanadi.
2. `GameStatsService.record()` natija yozishdan oldin tegishli profil statistikasini yuklaydi.
3. Statistika JSON'i buzilgan bo'lsa, ilova ishga tushishini to'xtatmaydi; shu profil uchun bo'sh natija ro'yxati bilan davom etadi.
4. Statistika kaliti ism emas, `UserProfile.id` bo'ldi. Bu bir xil ismli bolalarning natijalari aralashib ketishining oldini oladi. Eski ism-kalitli statistikani yangi ID kalitiga ko'chirish uchun migratsiya yo'li qo'shildi.
5. Alpomish Kamoni natijalarini yozishda ham `profile.id` ishlatiladi.
6. Alpomish Runner va Math Zuma o'yinlaridagi fizik hisoblar uchun qotirib qo'yilgan 700 px ekran balandligi real qurilma balandligiga almashtirildi.
7. Math Zuma'da otilayotgan shar chiziladigan Y koordinatasi bilan to'qnashuv koordinatasi mos emas edi. To'qnashuv endi ekrandagi haqiqiy koordinata bilan tekshiriladi.
8. Alpomish Runner'ga dastlabki to'siq mexanikasi qo'shildi: uch yo'lak, sakrab o'tiladigan to'siq, sirpanib o'tiladigan to'siq, to'qnashuv va boshqaruv tugmalari.
9. So'z o'yinlaridagi noto'g'ri `BOLOX` yozuvi va majburiy `String` maydoniga berilgan `null` qiymati `BULOQ` bilan almashtirildi; Wordle'dagi `YOMGI` ham `YOMON`ga tuzatildi.
10. Ona tili savolidagi `She'r` so'zining undosh harflari soni noto'g'ri belgilangan edi: javob 2 ga, izoh ham 2 ta undoshga moslashtirildi.
11. Yagona rang, radius, soya va animatsiya tokenlari uchun `ManzilaDesignSystem` qo'shildi.

## Kodni ishga tushirish holati

Ushbu ish muhiti ichida Flutter/Dart SDK mavjud emas. Shu sababli `flutter analyze`, `flutter test` va Android build bajarilmadi. Bu tuzatishlar statik kod tahriri sifatida kiritildi; qurilmada sinovdan o'tgan deb hisoblanmasin.

## Hali bajarilishi kerak bo'lgan katta ishlar

- Runner: hozir sakrash/sirpanish to'siqlari uchun dastlabki mexanika qo'shildi; to'siqlar animatsiyasi, aylanib o'tish, so'z harflari bilan konfliktlarni oldini olish, level balans va qurilma sinovlari hali kerak.
- Matematik blok o'yini: rangli bloklar, ifoda, javob blokini joylashtirish va birlashtirish mexanikasini yangi rejim sifatida yaratish.
- Viloyat/shahar/tuman xaritasi: barcha manzillar va yo'nalishlarni fakt-tekshiruvdan o'tkazish; hozirgi xarita to'liq tuman darajasidagi sayohat katalogi emas.
- Hikoya muharriri: qahramon xarakterlari, dialoglar, sahna shartlari va o'yin qoidalarini kodni o'zgartirmasdan sozlash.
- Audio: `assets/sounds/` hozir bo'sh; original musiqa, ovoz effektlari va qahramon ovozlari qo'shilishi kerak.
- Statistika: hozirgi kodda natijani markaziy xizmatga yozadigan o'yinlar soni juda cheklangan; barcha o'yinlar bir xil natija shartnomasiga o'tkazilishi kerak.
- Grafikalar: hozircha rasmlar to'plami juda cheklangan; tasdiqlangan robot tasviri saqlangan holda qahramonlar, fonlar, ikonlar va animatsion holatlar ishlab chiqilishi kerak.
- Multiplayer: haqiqiy internet jamoaviy rejim uchun backend va real-time sinxronizatsiya kerak.

## Phase 2 — 2026-11-14

12. Alpomish Runner sakrash holati sinusoidal to'liq siklga o'tkazildi; oldingi holatda `_isJumping` `true` bo'lib qolishi ehtimoli bartaraf etildi.
13. Runner to'siqlari yaqinlashayotgan kerakli harf yo'laklaridan boshqa xavfsiz yo'lakka chiqariladi; harf va to'siqning bir vaqtda bir yo'lakda kelishi kamaytirildi.
14. Yangi `MathBlocksScreen` yaratildi: misolni yechish, javob blokini joylash, 3+ bir xil rangli tutash bloklarni tozalash, ustunlarni pastga tushirib to'ldirish, ball/ketma-ketlik/daraja/jon va profilga yulduz yozish.
15. Matematik blok o'yini `/game/math-blocks` router yo'liga va bosh sahifadagi alohida bannerga ulandi.
16. `docs/PHASE_2_IMPLEMENTATION.md` hujjati qo'shildi.

Sinov cheklovi: Flutter/Dart SDK mavjud bo'lmagani sababli kompilyatsiya va qurilma sinovlari bajarilmadi. Paketni Android Studio yoki Flutter SDK mavjud kompyuterda `flutter pub get`, `flutter analyze` va `flutter run` bilan tekshirish zarur.
