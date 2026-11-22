# ManZila Aqlli Bola — v56 Phase 7

## Maqsad
Umumiy `GameStatsService` xizmatini real o‘yin yakunlariga ulash va statistika ekranida yangi o‘yinlarni ko‘rsatish.

## Bajarilgan ishlar
1. `MathBlocksScreen` yakunlangan mashg‘ulotda profil ID bo‘yicha `GameResult` yozadi.
2. Matematik bloklar natijasi fan sifatida `Matematika`, o‘yin ID sifatida `math_blocks` bilan saqlanadi.
3. `AlpomishRunnerScreen` kampaniya tugaganda yoki urinish mag‘lubiyat/taymer bilan yakunlanganda bitta natija yozadi. Qayta urinish uchun takror yozuvdan himoya qayta tiklanadi.
4. Runner natijasi `Geografiya` faniga va `alpomish_runner` o‘yin ID siga bog‘landi.
5. Statistikadagi o‘yinlar ro‘yxatiga Matematik bloklar va Alpomish Runner qo‘shildi.
6. `GameStatsService` o‘yin nomlarini ham taniydi, eski saqlangan natijalardagi sonli maydonlarni xavfsizroq o‘qiydi va profil statistikasi yuklangach tinglovchilarga xabar beradi.
7. Runner mukofot yulduzlarini profilga har bosqichda faqat shu bosqich mukofoti miqdorida qo‘shish tuzatildi; avval yig‘ilgan yulduzlarni qayta qo‘shish holati oldi olindi.

## O‘zgargan fayllar
- `lib/core/services/game_stats_service.dart`
- `lib/features/games/mathblocks/math_blocks_screen.dart`
- `lib/features/games/runner/alpomish_runner_screen.dart`
- `lib/features/stats/stats_screen.dart`
- `docs/PHASE_7_IMPLEMENTATION.md`
- `docs/PHASE_7_CHANGELOG.md`
- `NEXT_CHAT_PROMPT.txt`

## Tekshiruv va cheklovlar
- Manba kod o‘zgartirishlari va muhim chaqiruv nuqtalari ko‘zdan kechirildi.
- Oddiy qavs/ajratgich statik tekshiruvi bajarilishi rejalashtirilgan; bu Dart kompilyatsiyasi o‘rnini bosmaydi.
- Ushbu muhitda Flutter/Dart SDK aniqlanmadi. `dart format`, `flutter analyze`, `flutter test`, `flutter pub get` va Android build bajarilmadi.
- Statistik natijalar qurilmada tekshirilishi kerak: yangi profil, eski ism-kalitli profil migratsiyasi, matematik o‘yin timeout/yakun, Runner yakun/mag‘lubiyat/qayta urinish.

## Keyingi bosqich
1. Flutter SDK bilan Phase 7 ni format, analyze va testdan o‘tkazish.
2. Boshqa o‘yinlarni `GameStatsService` ga standart natija yozish qoidasi bilan ulash.
3. O‘yin natijalarini fan, sana va o‘yin bo‘yicha filtrlash hamda umumiy progress grafiklarini yaxshilash.
4. Hikoya o‘yinlarida tanlovli dialoglar va bir nechta yakunlarni real gameplay oqimiga ulash.
5. Game Editor uchun kontentni boshqarish maydonlarini kengaytirish.

## Qat’iy dizayn talabi
ManZila robot-mascotining yuzi, ko‘zlari va joylashuvi, og‘zi/tabassumi, antenna, bosh shakli, oq-ko‘k kiyimi, ranglari va ko‘krakdagi `M` belgisi o‘zgartirilmaydi.
