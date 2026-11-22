# ManZila: Aqlli Bola — v56 Phase 2 implementation

## Maqsad

v56 loyihasining mavjud arxitekturasini saqlab, foydalanuvchi taklif qilgan ikki asosiy o'yin mexanikasini kuchaytirish:

1. Alpomish Runner: harf yig'ish + to'siqdan qochish.
2. Al-Xorazmiy Matematik bloklar: misolni yechish + javob blokini joylash + rangli bloklar guruhini tozalash.

## Ushbu bosqichda kiritilgan o'zgarishlar

### Alpomish Runner

- Sakrash animatsiyasi to'liq siklga o'tkazildi: ko'tarilish, cho'qqi va yerga qaytish.
- Oldingi kodda sakrash holati `true` bo'lib qolishi va qahramon havoda osilib qolishi mumkin edi; bu holat tuzatildi.
- To'siq paydo bo'lishida yaqinlashayotgan to'g'ri harf yo'laklari vaqtincha band qilinadi. Bu o'yinchining kerakli harfni yig'ish va to'siqdan qochish vazifalari bir-biriga adolatsiz to'qnashishini kamaytiradi.
- Uch yo'lak bo'ylab harakat, sakrash, sirpanish va noto'g'ri harf jarimasi saqlab qolindi.

### Al-Xorazmiy Matematik bloklar

- Yangi mustaqil Flutter ekran yaratildi: `lib/features/games/mathblocks/math_blocks_screen.dart`.
- Qo'shish va ayirish dastlabki darajalarda, ko'paytirish keyingi darajalarda ochiladi.
- Bola uch javobdan birini tanlaydi; to'g'ri javobni tanlagach, javob blokini 6x5 taxtadagi katakka joylaydi.
- Bir xil rang guruhidan kamida 3 ta blok tutashsa, guruh tozalanadi va ustunlar pastga tushib to'ldiriladi.
- Ketma-ket to'g'ri javoblar qo'shimcha ball beradi; har 4 ta yechilgan misolda daraja ko'tariladi.
- Uchta xato urinishdan so'ng sessiya tugaydi; yechilgan misollar soniga qarab profil yulduzlari yangilanadi.
- Yangi o'yin bosh sahifaga banner va router yo'li orqali ulandi.

## Fayllar

- `lib/features/games/mathblocks/math_blocks_screen.dart` — yangi matematik blok o'yini.
- `lib/features/games/runner/alpomish_runner_screen.dart` — sakrash sikli va adolatli to'siq spawn tuzatishlari.
- `lib/core/router/app_router.dart` — `/game/math-blocks` yo'li.
- `lib/features/home/home_screen.dart` — yangi o'yin banneri.

## Muhim mahsulot qarorlari

- Manzila AI robotining tasdiqlangan tashqi ko'rinishi o'zgartirilmaydi.
- O'yinlar yakka rejimda ishlaydi; haqiqiy do'stlar bilan multiplayer uchun alohida backend va real-time sinxronizatsiya zarur.
- Hozirgi matematik bloklar — birinchi o'ynaladigan prototip. Keyingi iteratsiyada bloklarni drag-and-drop qilish, aniq 2x2 shaklli ifoda yig'ish, maxsus bloklar, boss bosqichlari va audio feedback qo'shiladi.
- O'zbekiston xaritasi va tarixiy hikoyalar uchun faktlar alohida tahririy tekshiruvdan o'tkaziladi; tarixiy ma'lumotlar tasdiqlanmagan holda o'yinga kiritilmaydi.

## Sinov holati

- Dart/Flutter SDK ushbu ish muhitida mavjud emas. Shu sababli `flutter analyze`, `flutter test` va Android APK build bajarilmadi.
- O'zgartirilgan Dart fayllarida qavslar va bloklar muvozanati statik tekshirildi.
- Android qurilmasida sensorli boshqaruv, kichik ekran, FPS, audio va profil saqlanishi alohida sinovdan o'tkazilishi shart.

## Keyingi bosqich

1. Runner uchun animatsiyalangan qahramon sprite-sheet, to'siq animatsiyasi, harf yig'ish effektlari va original musiqa.
2. Matematik bloklarda 2x2 shakl yig'ish va javobni aniq joylashtirish mexanikasi.
3. Game Editor ma'lumotlar modeli: qahramon, hikoya sahnasi, dialog, savol banki, qiyinlik, to'siq, mukofot va audio trekni kodsiz sozlash.
4. O'zbekiston xaritasidagi viloyat–shahar–tuman bosqichlarini manba bilan tekshirish.
