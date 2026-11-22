# Manzila: Aqlli Bola — Phase 3: Game Editor va qahramonlar katalogi

Sana: 2026-11-14  
Asos: `manzila_Aqlli_Bola_v56_phase2.zip` (v56 Phase 2)

## 1. Maqsad

Ota-ona/admin uchun o'yin sozlamalarini boshqarish oynasining birinchi ishlaydigan poydevorini yaratish va ertak/tarixiy qahramonlarning xarakterini yagona katalogga chiqarish.

## 2. Ushbu bosqichda kodga kiritilgan o'zgarishlar

### 2.1 Game Editor

Yangi fayl: `lib/features/parent/game_editor_screen.dart`

Hozirgi muharrirda 6 ta o'yin uchun quyidagi parametrlarni tahrirlash mumkin:
- o'yinni faol/nofaol qilish;
- o'yin tezligi (0.5x–2.0x);
- bosqichdagi savollar soni;
- yulduz mukofoti;
- Manzila robotidan ishora ko'rsatish;
- vaqt cheklovi va vaqt miqdori;
- yosh oralig'i (5–12);
- boshlang'ich qiyinlik (oson/o'rta/murakkab);
- asosiy va ikkinchi qahramon nomi;
- sarguzasht sarlavhasi va hikoya matni.

Saqlash `SharedPreferences` orqali shu qurilmaning lokal xotirasiga JSON ko'rinishida yoziladi. Xatolikda standart konfiguratsiyaga qaytish yo'li mavjud.

### 2.2 Qahramonlar katalogi

Yangi fayl: `lib/data/models/story_character_catalog.dart`

Katalogga Alpomish, Susambildagi Eshak, Zumrad, Qimmat, Shiroq, Tomiris, Al-Xorazmiy va Manzila AI robot kiritildi. Har biri uchun roli, xarakteri, mos o'yin mexanikasi, ta'limiy maqsadi va namunaviy iborasi belgilandi.

### 2.3 Navigatsiya va ota-ona paneli

- `AppRoutes.gameEditor = '/settings/parental/game-editor'` yo'li qo'shildi.
- Router `GameEditorScreen` ekranini ochadi.
- Ota-ona panelida Game Editor kartasi qo'shildi.
- Editor route bevosita ochilganda ham ota-ona PIN tekshiruvi ishlaydi (ota-ona nazorati yoqilgan bo'lsa).
- Routerdagi mavjud nomuvofiqlik tuzatildi: import qilingan `parent_screen.dart` ichida `ParentalScreen` mavjud, `ParentScreen` nomi esa mavjud emas edi. Router endi `ParentalScreen` chaqiradi.

## 3. Muhim cheklovlar — bu hali to'liq CMS emas

Bu bosqichdagi Game Editor konfiguratsiyalarni saqlaydi va ko'rsatadi. Hozircha Alpomish Runner, Math Blocks va boshqa o'yinlarning runtime mexanikasi ushbu sozlamalarni o'qib ishlatmaydi. Keyingi bosqichda umumiy `GameConfigService` yaratilishi, o'yinlar konfiguratsiyani yuklashi va har bir parametr real o'yin mexanikasiga ulanishi kerak.

Hozircha sozlamalar faqat bitta qurilmada saqlanadi. Bir nechta qurilma yoki administratorlar orasida sinxronlash uchun server API va CMS kerak.

Qahramon katalogi hozircha matnli xarakter spetsifikatsiyasi. Maxsus 3D model, rig, yuz ifodalari, animatsion holatlar va ovoz fayllari bu bosqichda yaratilmagan.

## 4. O'zgartirilgan/yangi fayllar

- `lib/features/parent/game_editor_screen.dart` — yangi Game Editor UI va lokal JSON saqlash.
- `lib/data/models/story_character_catalog.dart` — qahramonlar xarakter katalogi.
- `lib/core/router/app_router.dart` — editor route va ParentalScreen nomi tuzatildi.
- `lib/features/parent/parent_screen.dart` — Game Editor kirish kartasi.

## 5. Sinov holati

- Flutter/Dart SDK ish muhitida mavjud emas.
- `flutter pub get`, `flutter analyze`, `flutter test`, Android APK build bajarilmadi.
- Real qurilmada PIN himoyasi, saqlash, ekran moslashuvi va o'yin sozlamalarining ta'siri tekshirilmagan.
- Shuning uchun bu paketni kodga kiritilgan Phase 3 prototipi deb hisoblash kerak; production-ready deb e'lon qilinmaydi.

## 6. Keyingi majburiy ishlar — Phase 4

1. `GameConfigService`ni alohida service/model sifatida ajratish va JSON versiyasini belgilash.
2. Runner, Math Blocks, Susambil, Zumrad, Shiroq va Tomiris o'yinlariga config o'qishni ulash.
3. Game Editorga savollar banki, to'siqlar turlari, sahna ketma-ketligi, audio trek va mukofot shartlarini qo'shish.
4. Qahramonlar uchun `idle`, `run`, `jump`, `happy`, `sad`, `thinking`, `helping` kabi animatsiya holatlari spetsifikatsiyasi va asset manifest tuzish.
5. O'zbekiston xaritasidagi hudud → shahar → tuman → manzil daraxtini ma'lumotlar modeli sifatida aniqlash; mavjud unlock holatlarini hard-code ro'yxatdan chiqarish.
6. Tarixiy va geografik matnlarni manbalar bilan fakt-tekshirish.
7. Audio papkasiga original musiqa/effektlar kiritish; litsenziya va mualliflik huquqini qayd etish.
8. Har bir o'yin uchun yagona natija shartnomasi va `GameStatsService.record()` integratsiyasi.
9. Android qurilmalarida build va UX sinovlari.

## 7. Dizayn bo'yicha qat'iy talablar

- Manzila AI robotining tasdiqlangan yuzi, ko'zlari, antenna, bosh shakli, oq-ko'k kiyimi, ranglari va ko'krakdagi M belgisi o'zgartirilmaydi.
- O'zbek milliy muhiti, naqshlari, tarixiy me'morchiligi va xalq og'zaki ijodi asosiy vizual yo'nalish bo'lib qoladi.
- Qahramonlar o'z hikoya xarakteriga mos o'yin mexanikasiga ega bo'ladi.
- Tarixiy shaxslar bolalar uchun hurmat bilan tasvirlanadi; janglar grafik zo'ravonlik emas, xavfsiz strategik mexanika sifatida beriladi.
- Bola xato qilganda sharmanda qilinmaydi; robot ishora va tushuntirish beradi.

## 8. Keyingi chat uchun davom ettirish matni

`Manzila_Aqlli_Bola_v56_Phase3_Handoff.pdf` va shu paketdagi `docs/PHASE_3_IMPLEMENTATION.md` hujjatlarini o'qing. Ishni Phase 4 dan davom ettiring: avval GameConfigService yarating va Game Editor saqlagan sozlamalarni real o'yin mexanikalariga ulang. Keyin Runner va Math Blocks uchun konfiguratsiyaga asoslangan qiyinlik, yosh diapazoni, savollar soni, robot ishoralari va mukofotlarni ishga tushiring. Mavjud kod va Manzila robotining tasdiqlangan dizaynini buzmay, har bir o'zgarishni hujjatlashtiring. Flutter/Dart SDK bo'lmasa, kompilyatsiya o'tdi deb aytmang.`
