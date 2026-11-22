# ManZila: Aqlli Bola — Yakuniy O'zgarishlar Jurnali

**Versiya:** v56 / Phase 14  
**Muhit:** Claude bulut sessiyasi (Flutter SDK yo'q)  
**Davr:** 2026-11-14 — 2026-11-21

---

## Phase 14 — 2026-11-21 (Joriy sessiya)

### Yangi fayllar yaratildi

| Fayl | Maqsad |
|------|--------|
| `android/build.gradle` | Root Gradle konfiguratsiyasi (Kotlin 1.9.10, AGP 8.1.4) |
| `android/settings.gradle` | Modullar ro'yxati |
| `android/gradle.properties` | AndroidX, Kotlin, Jetifier sozlamalari |
| `android/app/build.gradle` | App moduli konfiguratsiyasi (applicationId, minSdk 21, targetSdk 34) |
| `android/app/src/main/AndroidManifest.xml` | Manifest (INTERNET ruxsati, flutterEmbedding v2) |
| `android/app/src/main/kotlin/uz/manzila/aqlli_bola/MainActivity.kt` | Kotlin MainActivity |
| `android/gradle/wrapper/gradle-wrapper.properties` | Gradle 8.3 wrapper |
| `analysis_options.yaml` | flutter_lints asosidagi lint konfiguratsiyasi |
| `.gitignore` | Flutter standart versiya nazorat istisnolari |
| `test/susambil_game_test.dart` | UserProfile, kampaniya, yulduz hisoblash testlari (9 test) |
| `test/game_stats_test.dart` | GameResult, GameStatsService testlari (8 test) |
| `FINAL_AUDIT_REPORT.md` | To'liq audit hisoboti |
| `BUILD_AND_INSTALL.md` | Qurish va o'rnatish qo'llanmasi |
| `TEST_REPORT.md` | Test holati hisoboti |
| `CHANGELOG_FINAL.md` | Ushbu fayl |

### O'zgartirilgan fayllar

| Fayl | O'zgarish |
|------|-----------|
| `lib/core/router/app_router.dart` | `SoundSettingsScreen` import va route qo'shildi |
| `lib/main.dart` | Keraksiz `AdaptiveService` import o'chirildi |

---

## Phase 2 — 2026-11-14 (Oldingi sessiya)

Manbа: `docs/V56_AUDIT_AND_FIX_LOG.md` — Phase 2 bo'limi

12. Alpomish Runner sakrash holati sinusoidal to'liq siklga o'tkazildi
13. Runner to'siqlari harf yo'laklaridan boshqasiga chiqarildi
14. Yangi `MathBlocksScreen` yaratildi (misollar, bloklarni tozalash, daraja/jon tizimi)
15. MathBlocks `/game/math-blocks` route va bosh sahifaga banner qo'shildi
16. `docs/PHASE_2_IMPLEMENTATION.md` yaratildi

---

## Phase 1 — 2026-11-14 (Oldingi sessiya)

Manbа: `docs/V56_AUDIT_AND_FIX_LOG.md` — asosiy bo'lim

1. `GameStatsService.init()` profilesiz xavfsiz ishlashi ta'minlandi
2. `GameStatsService.record()` profil statistikasini oldin yuklaydi
3. JSON buzilganda bo'sh ro'yxat bilan davom etish (ilova to'xtamaydi)
4. Statistika kaliti ism emas, `UserProfile.id` asosida
5. Alpomish Kamoni natijalari `profile.id` bilan yoziladi
6. Math Zuma va Runner ekran balandligi qotirib qo'yilgan 700px dan haqiqiy balandlikka o'zgardi
7. Math Zuma to'qnashuv koordinatasi to'g'rilandi
8. Alpomish Runner dastlabki to'siq mexanikasi qo'shildi (uch yo'lak, sakrash, sirpanish)
9. Wordle so'z xatoliklari tuzatildi (`BOLOX→BULOQ`, `YOMGI→YOMON`)
10. Ona tili savol javoblari to'g'rilandi (She'r — undosh sonlar)
11. `ManzilaDesignSystem` rang va animatsiya tokenlari qo'shildi

---

## O'zgartirilmagan Narsalar (Qoida 8 & Robot Dizayn)

Quyidagilar ataylab o'zgartirilmadi:
- Robot maskotining yuzi, ko'zlari, ranglari, ko'ksidagi 'M', antennasi va proporsiyalari
- Mavjud bo'lmagan xizmat, API yoki audio fayllari "mavjud" deb ko'rsatilmadi
- Hech qanday soxta test natijasi yoki soxta hisob yaratilmadi
- Maxfiy kalitlar, parollar yoki tokenlar kiritilinmadi

---

## Yetkazib Berilgan Fayllar

| Fayl | Tur |
|------|-----|
| `ManZila_Aqlli_Bola_v56_final_source.zip` | Yangilangan manba kodi (ZIP) |
| `FINAL_AUDIT_REPORT.md` | Hujjat |
| `BUILD_AND_INSTALL.md` | Hujjat |
| `TEST_REPORT.md` | Hujjat |
| `CHANGELOG_FINAL.md` | Hujjat |

> **APK:** Flutter SDK ushbu muhitda mavjud emasligi sababli release APK yaratilmadi. Mahalliy mashinada `flutter build apk --release` ishga tushiring.
