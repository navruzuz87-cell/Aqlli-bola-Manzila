# Manzila: Aqlli Bola — Phase 4: GameConfigService integratsiyasi

Sana: 2026-11-14  
Asos: Phase 3 loyiha holati

## 1. Maqsad

Game Editor'da saqlangan sozlamalarni kamida ikkita asosiy o'yinning real ishlashiga ulash. Shu bilan muharrir faqat ma'lumot saqlovchi prototip bo'lib qolmasdan, ayrim o'yin parametrlariga amalda ta'sir qiladi.

## 2. Kiritilgan o'zgarishlar

### 2.1 Yangi konfiguratsiya xizmati

`lib/core/services/game_config_service.dart` qo'shildi.

- `GameConfigData` typed model.
- `GameConfigService.instance.load(gameId)` orqali konfiguratsiyani yuklash.
- Standart konfiguratsiyaga qaytish.
- Noto'g'ri JSON yoki noma'lum qiymatlarga xavfsiz fallback.
- Parametrlar diapazonini tekshirish: speed 0.5–2.0, savollar 3–20, yulduz 1–5, vaqt 20–180 soniya, yosh 5–12.
- Cache invalidation.

### 2.2 Game Editor bilan bog'lash

Editor saqlashdan keyin `GameConfigService.instance.invalidate()` chaqiradi. Shuning uchun o'yin keyingi ochilganda yangi sozlama yuklanadi.

### 2.3 Al-Xorazmiy Matematik bloklari

`lib/features/games/mathblocks/math_blocks_screen.dart`:
- `difficulty` qiymati `easy`, `normal`, `hard` bo'yicha amallarni belgilaydi.
- `hard` darajada bo'lish amali ham ochiladi.
- `questionCount` sessiyadagi yechilgan misollar sonini belgilaydi.
- `timerEnabled` va `timeLimitSeconds` sessiya taymerini boshqaradi.
- `robotHints` xato javobdagi tushuntirish matniga ta'sir qiladi.
- `rewardStars` beriladigan yulduzlar sonining yuqori chegarasini belgilaydi.
- To'g'ri javobni tanlashda misol yechilgan deb sanalmasligi uchun `_solved` hisoblagichi blok taxtaga joylangandan keyin oshiriladi.

### 2.4 Alpomish Runner

`lib/features/games/runner/alpomish_runner_screen.dart`:
- `speed` boshlang'ich harakat va harf/to'siq paydo bo'lish intervaliga ta'sir qiladi.
- `enabled=false` bo'lsa o'yin ishga tushirilmaydi.
- `rewardStars` bosqich muvaffaqiyatli tugaganda profil yulduzlariga qo'shiladi.
- Bir bosqichni qayta-qayta tugatib yulduzlarni cheksiz yig'ib olishning oldini olish uchun shu sessiyada bosqich ID bo'yicha mukofot bir marta beriladi.

## 3. Hali ulanmagan parametrlar

- Game Editor'dagi `minAge` / `maxAge` hozircha o'yin boshlanishida tekshirilmaydi. `UserProfile` modelida yosh alohida saqlanmaydi; `grade` maktab sinfi bo'lib, yosh bilan bir xil emas.
- Runner uchun `questionCount`, `difficulty`, `timerEnabled` va `robotHints` hali to'liq runtime integratsiyasiga ega emas.
- Math Blocks uchun `speed` va yosh oralig'i o'yin fizikasi/son diapazoniga ulanmagan.
- Editor hozircha 6 ta konfiguratsiya profilini beradi; barcha o'yinlar qamrab olinmagan.
- Konfiguratsiya lokal qurilmada saqlanadi; server CMS va ko'p qurilmali sync yo'q.

## 4. Sinov holati

Flutter/Dart SDK mavjud emas. Shu sababli `flutter analyze`, `flutter test` va Android build bajarilmadi. O'zgartirilgan fayllarda delimiter muvozanati va qo'lda statik ko'rik o'tkazildi, lekin bu kompilyatsiya kafolati emas.

## 5. O'zgargan fayllar

- `lib/core/services/game_config_service.dart` — yangi.
- `lib/features/parent/game_editor_screen.dart` — save paytida cache invalidation.
- `lib/features/games/mathblocks/math_blocks_screen.dart` — difficulty, timer, question count, hints, reward integratsiyasi.
- `lib/features/games/runner/alpomish_runner_screen.dart` — speed, enabled, reward integratsiyasi.

## 6. Phase 5 tavsiyasi

1. `UserProfile`ga `age` qo'shish yoki ota-ona profilida tug'ilgan yil/yoshni xavfsiz saqlash; `grade` bilan almashtirmaslik.
2. Runner'da robot hint, timer, level count va difficulty sozlamalarini to'liq ulash.
3. Math Blocks'da drag-and-drop, 2x2 shaklli amallar, bloklar fizikasi va speed sozlamasini qo'shish.
4. Game Editor'ga savollar banki, to'siq turlari, scene/choice/ending, musiqa va audio effektlarni qo'shish.
5. Barcha o'yinlarni yagona `GameStatsService` natija yozish formatiga ulash.
6. Flutter SDK muhitida analiz, test va Android build.
