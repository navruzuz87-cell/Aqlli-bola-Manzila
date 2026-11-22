# ManZila: Aqlli Bola — Qurish va O'rnatish Qo'llanmasi

**Versiya:** v56 / Phase 14  
**Paket:** `uz.manzila.aqlli_bola`  
**Min Android:** API 21 (Android 5.0 Lollipop)  
**Target Android:** API 34 (Android 14)

---

## Talablar

| Vosita | Versiya | Izoh |
|--------|---------|------|
| Flutter SDK | ≥ 3.3.0 | https://flutter.dev/docs/get-started/install |
| Dart SDK | ≥ 3.3.0 | Flutter bilan birga keladi |
| Android Studio | Koala (2024.1) yoki yangi | https://developer.android.com/studio |
| Java JDK | 17 yoki 21 | Android Studio bilan birga keladi |
| Android SDK | compileSdk 34, minSdk 21 | SDK Manager orqali |
| Gradle | 8.3 | Wrapper orqali avtomatik |

---

## 1. Loyihani Tayyorlash

```bash
# 1. ZIP ni ochish
unzip ManZila_Aqlli_Bola_v56_final.zip -d manzila_project
cd manzila_project/source/manzila_phase9_work

# 2. Flutter paketlarini yuklash
flutter pub get

# 3. Platformani tekshirish
flutter doctor
```

---

## 2. Kod Tekshiruvi (Ixtiyoriy, Tavsiya Etiladi)

```bash
# Lint tekshiruvi
flutter analyze

# Testlarni ishga tushirish
flutter test

# Muayyan test fayli
flutter test test/susambil_game_test.dart
flutter test test/game_stats_test.dart
```

---

## 3. Emulatorda Ishlatish

```bash
# Mavjud qurilmalarni ko'rish
flutter devices

# Emulatorda ishga tushirish (debug rejimi)
flutter run

# Muayyan qurilmada
flutter run -d <device_id>
```

---

## 4. Release APK Qurish

```bash
# Imzolash kalitini yaratish (birinchi marta)
keytool -genkey -v \
  -keystore manzila_release.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias manzila

# key.properties fayli yaratish (android/ katalogida)
cat > android/key.properties << EOF
storePassword=SIZNING_PAROLINGIZ
keyPassword=SIZNING_KALIT_PAROLINGIZ
keyAlias=manzila
storeFile=../manzila_release.jks
EOF

# Release APK qurish
flutter build apk --release

# APK joylashuvi:
# build/app/outputs/flutter-apk/app-release.apk
```

> **Muhim:** `key.properties` va `manzila_release.jks` fayllarini `.gitignore` orqali versiya nazoratiga qo'shmang. Ular allaqachon `.gitignore` da mavjud.

---

## 5. Android Qurilmaga O'rnatish

### USB orqali:
```bash
# USB debugging yoqilgan qurilmani ulash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Fayl orqali:
1. `app-release.apk` ni qurilmaga nusxalash
2. Qurilmada "Noma'lum manbalardan o'rnatish" ga ruxsat berish
3. APK faylni ochib o'rnatish

---

## 6. Android Studio Orqali Qurish

1. Android Studio ni oching
2. `File → Open` → `manzila_phase9_work` katalogini tanlang
3. Gradle sync tugashini kuting
4. `Build → Build Bundle(s)/APK(s) → Build APK(s)`
5. APK `app/build/outputs/apk/release/` da yaratiladi

---

## 7. Muammolar va Yechimlar

### `flutter pub get` xatosi
```bash
# Pub keshni tozalash
flutter pub cache repair
flutter pub get
```

### `Gradle build failed`
```bash
# Gradle wrapper ni yangilash
cd android
./gradlew --version
# Agar xato bo'lsa:
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### `minSdkVersion` xatosi
`android/app/build.gradle` da `minSdkVersion 21` ekanligini tekshiring.

### Audio ishlamaydi
`assets/sounds/` katalogiga quyidagi MP3 fayllarni qo'shing:
- `correct.mp3`, `wrong.mp3`, `button_tap.mp3`
- `star_earn.mp3`, `coin_earn.mp3`, `victory.mp3`, `level_up.mp3`
- `home_music.mp3`, `game_music.mp3`, `city_music.mp3`

Fayllar bo'lmasa ham ilova ishlab qoladi (xatosiz).

---

## 8. Paket Tuzilmasi

```
manzila_phase9_work/
├── lib/
│   ├── main.dart               # Ilova kirish nuqtasi
│   ├── core/
│   │   ├── router/             # go_router navigatsiyasi
│   │   ├── services/           # AudioService, GameStatsService, ...
│   │   └── widgets/            # Umumiy widget'lar
│   ├── data/models/            # UserProfile, GameResult, ...
│   └── features/               # Ekranlar (home, games, settings, ...)
├── android/                    # Android platforma fayllari
├── assets/
│   ├── images/                 # Robot va boshqa rasmlar
│   └── sounds/                 # Audio fayllar (bo'sh - qo'shish kerak)
├── test/                       # Birlik testlari
├── pubspec.yaml
├── analysis_options.yaml
└── FINAL_AUDIT_REPORT.md
```

---

## 9. Muhim Fayl yo'llari

| Fayl | Maqsad |
|------|--------|
| `lib/main.dart` | Xizmatlarni ishga tushirish |
| `lib/core/router/app_router.dart` | Barcha route ta'riflari |
| `lib/data/models/user_profile.dart` | Foydalanuvchi profil modeli |
| `lib/features/games/susambil/susambil_math_screen.dart` | Asosiy Phase 14 o'yini |
| `lib/core/services/profile_storage_service.dart` | Profil saqlash/yuklash |
| `android/app/build.gradle` | Android qurilish konfiguratsiyasi |
