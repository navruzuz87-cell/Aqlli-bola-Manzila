# ManZila: Aqlli Bola — Test Hisoboti
**Versiya:** v56 / Phase 14  
**Sana:** 2026-11-21

---

## Muhim Izoh

Flutter/Dart SDK ushbu bulut muhitida mavjud emas (proksi bloklaydi). Shuning uchun `flutter test` ishga tushirilmadi. Quyidagi jadval statik kod tahlili asosida to'ldirilgan. **Testlar mahalliy Flutter SDK mavjud kompyuterda bajarilishi kerak.**

---

## Flutter Buyruqlari Holati

| Buyruq | Holat | Sabab |
|--------|-------|-------|
| `flutter pub get` | BAJARILMADI | SDK mavjud emas |
| `flutter analyze` | BAJARILMADI | SDK mavjud emas |
| `flutter test` | BAJARILMADI | SDK mavjud emas |
| `flutter build apk --release` | BAJARILMADI | SDK mavjud emas |

---

## Yaratilgan Test Fayllari

### `test/susambil_game_test.dart`

| # | Test nomi | Kutilgan natija | Statik tahlil |
|---|-----------|-----------------|---------------|
| 1 | UserProfile toJson/fromJson o'zaro moslik | O'tadi | ✓ Mantiq to'g'ri |
| 2 | fromJson String kiritish (orqaga moslik) | O'tadi | ✓ `source is String` tekshiruvi mavjud |
| 3 | copyWith totalStars alias | O'tadi | ✓ `totalStars` alias `copyWith`da mavjud |
| 4 | resetDailyIfNeeded — bir xil kun | O'tadi | ✓ `lastPlayDate` mantiq to'g'ri |
| 5 | resetDailyIfNeeded — yangi kun | O'tadi | ✓ `todayStarsEarned = 0` yangilanadi |
| 6 | strongestSubject — eng yuqori fan | O'tadi | ✓ `entries.reduce` mantiq to'g'ri |
| 7 | weakestSubject — eng past fan | O'tadi | ✓ Mantiq to'g'ri |
| 8 | Susambil kampaniya JSON encode/decode | O'tadi | ✓ Map to'g'ri serializatsiya qilinadi |
| 9 | Yulduz hisoblash: 4→3, 3→2, 1→1 | O'tadi | ✓ Formulalar to'g'ri |

### `test/game_stats_test.dart`

| # | Test nomi | Kutilgan natija | Statik tahlil |
|---|-----------|-----------------|---------------|
| 1 | GameResult toMap/fromMap o'zaro moslik | O'tadi | ✓ Map kalitlari mos |
| 2 | pct — maxScore nol bo'lganda | O'tadi | ✓ `maxScore == 0 ? 0 : ...` tekshiruvi bor |
| 3 | stars — 10 ball → 3 yulduz (chegaralash) | O'tadi | ✓ `stars.clamp(1, 3)` mavjud |
| 4 | GameStatsService init xavfsiz | O'tadi | ✓ init() argumentsiz xavfsiz |
| 5 | record() va resultsFor() | O'tadi | ✓ `resultsFor()` metod nomi to'g'ri |
| 6 | Noto'g'ri JSON — bo'sh ro'yxat | O'tadi | ✓ `try/catch` mavjud |
| 7 | 200 dan ortiq natija — qirqiladi | O'tadi | ✓ `.take(200)` mantiq bor |
| 8 | gameName qidirish | O'tadi | ✓ `GameResult.fromMap` mantiq to'g'ri |

---

## Qo'lda Tekshirilgan Funksionallik

| Funksiya | Tekshirish usuli | Natija |
|----------|-----------------|--------|
| Profil yaratish/o'chirish (4 tagacha) | Kod tahlili | ✓ Mantiq to'g'ri |
| Profil saqlash/qayta yuklash | Kod tahlili | ✓ SharedPreferences mantiq to'g'ri |
| Susambil 4 bosqich navigatsiyasi | Kod tahlili | ✓ `_stage` va `_stageIndex` to'g'ri |
| Kampaniya saqlash (SharedPreferences) | Kod tahlili | ✓ JSON encode/decode to'g'ri |
| soundSettings route navigatsiyasi | Kod tahlili | ✓ Route qo'shildi, ekran mavjud |
| Android platforma fayllari | Fayl mavjudligi | ✓ Barcha kerakli fayllar yaratildi |
| Router 44 ta route | Kod tahlili | ✓ Har biri uchun ekran mavjud |

---

## Mahalliy Mashinada Test Bajarish

```bash
# Flutter SDK mavjud bo'lganda:
cd manzila_phase9_work
flutter pub get
flutter analyze
flutter test
flutter test --reporter=json > test_results.json
```

---

## Tavsiya Etiladigan Qo'shimcha Testlar

1. **Profil navigatsiyasi UI testi** — splash → profil tanlash → bosh sahifa
2. **Susambil to'liq oqim testi** — 4 bosqich, barcha variantlar
3. **Qishloq tanlovi natija testi** — `adolatli` va `avval_ozim` yakunlari
4. **Ota-ona rejimi testi** — PIN, vaqt cheklovi, himoyalash
5. **Audio xatoga chidamlilik** — `sounds/` bo'sh bo'lganda ilova ishlashi
