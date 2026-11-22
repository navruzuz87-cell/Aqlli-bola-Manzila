# ManZila Aqlli Bola — Phase 8: Game Architecture Re-audit & Redesign

**Tayanch:** v56 Phase 7  
**Bosqich turi:** audit va arxitektura loyihalash (yangi gameplay kodi hali kiritilmagan)  
**Maqsad:** mavjud mini-o‘yinlarni yagona, sarguzashtga asoslangan ta’lim olamiga aylantirish uchun aniq texnik va kreativ yo‘nalish belgilash.

## 1. Qisqa xulosa

ManZila oddiy savol-javob ilovasi bo‘lib qolmasligi kerak. U — o‘zbek milliy muhiti, tanish qahramonlar, kashfiyot, xavf-xatarni yengish, do‘stga yordam berish va bilimni amalda qo‘llash orqali rivojlanadigan interaktiv olam.

Asosiy o‘yin sikli:

1. **Maqsad:** qahramon va uning jamoasi oldida tushunarli muammo paydo bo‘ladi.
2. **Kashfiyot:** bola yangi joyni o‘rganadi, iz, xarita, buyum yoki ma’lumot topadi.
3. **Xavf:** tabiiy yoki mantiqiy to‘siq paydo bo‘ladi; xavf oldindan ko‘rsatiladi va uni yengish yo‘li mavjud bo‘ladi.
4. **Bilim amalda:** fan topshirig‘i o‘yin mexanikasining o‘ziga aylanadi.
5. **Do‘stlik:** hamrohning qobiliyati, yordam so‘rash yoki boshqa qahramonni qutqarish muhim bo‘ladi.
6. **Natija:** jamoa manzilga yetadi, joy tiklanadi yoki yangi sir ochiladi.
7. **Mustahkamlash:** bola nimani o‘rganganini qisqa, tabiiy va yoshiga mos tarzda ko‘radi.

## 2. Phase 7 dan aniqlangan arxitektura holati

| Yo‘nalish | Hozirgi holat | Muammo / xulosa |
|---|---|---|
| O‘yinlar | 25 ta atrofida alohida o‘yin ekrani va bir nechta umumiy hikoya ekranlari | Mexanika va UI takrorlanadi, yagona o‘yin tajribasi yo‘q |
| Statistik yozuv | `GameStatsService` ga 3 o‘yin natija yozadi: `archery`, `math_blocks`, `alpomish_runner` | Qolgan o‘yinlar progressi statistikaga to‘liq tushmaydi |
| Hikoya HUD | `StoryGameState` / `StoryHUD` 6 ta o‘yinda ishlatiladi: Alpomish Geo, Avazxon, Shiroq, Susambil, Tumarisxon, Zumrad | Qolgan o‘yinlarda qahramon holati va robot yordami bir xil standartga ega emas |
| Game Editor | `GameConfigService` hozir Math Blocks va Runner’da ishlatiladi | Sozlamalar katalogdagi barcha o‘yinlarga umumiy emas |
| Saqlash | Profil va ayrim progresslar `SharedPreferences` orqali, profil ID bo‘yicha | Kampaniya, tanlovlar, do‘stlik va jamoa hissi uchun yagona saqlash modeli kerak |
| Grafika | Ayrim ekranlarda `CustomPainter` va animatsiyalar bor; assets ichida hozircha bir necha fon/robot/rasm fayli bor | To‘liq 3D yoki boy animatsion assetlar mavjud deb bo‘lmaydi; ko‘p ekranlar emoji va kodda chizilgan tasvirlarga tayanadi |
| Multiplayer | Alohida ekran/prototip bor | Haqiqiy qurilmalararo sinxron multiplayer deb hisoblash mumkin emas; server va xavfsizlik qatlami talab etiladi |

**Muhim:** Phase 8 da bu holatni hujjatlashtirish va kelajak arxitekturasini belgilash bajariladi. Flutter SDK mavjud bo‘lmagani sababli kompilyatsiya/build/test natijasi haqida da’vo qilinmaydi.

## 3. Zamonaviy o‘yinlardan olinadigan dizayn saboqlari

Tashqi tajriba nusxa ko‘chirish uchun emas, ManZila’ga mos tamoyillarni tanlash uchun ko‘rib chiqildi.

- **Minecraft Education:** o‘rganish faqat savol oynasida emas, qurish, izlanish, tajriba va birgalikdagi vazifada sodir bo‘ladi. NPC yo‘l ko‘rsatishi, xavfsiz multiplayer, dars kutubxonasi va o‘quvchi ishining natijasini saqlash foydali andozalardir.
- **Kooperativ o‘yin dizayni:** umumiy maqsad, rollar va bir-birini to‘ldiruvchi qobiliyatlar jamoaviy muammoni hal qilishga undaydi. Qoidalarni bosqichma-bosqich kiritish murakkablikni kamaytiradi.
- **Bolalar uchun serious-game tadqiqotlari:** qisqa va tushunarli hikoya, real hayot bilan aloqa, tezkor fikr-mulohaza, mos qiyinlik, shaxsiylashtirish, madaniy moslik va ijtimoiy o‘zaro ta’sir muhim.
- **Game-based learning bo‘yicha yangi tahlillar:** estetika, o‘yin mexanikasi va o‘quv maqsadi, o‘zaro ta’sir, o‘rganishni qo‘llab-quvvatlash, maqsad tuzilishi va bilimning real dars bilan bog‘lanishi birgalikda loyihalanishi kerak.

Manbalar: [Minecraft Education — Features](https://edusupport.minecraft.net/hc/en-us/articles/360047117032-Features-of-Minecraft-Education), [Minecraft Education — What is Minecraft?](https://education.minecraft.net/en-us/discover/what-is-minecraft), [Serious educational games for children: A comprehensive framework](https://pmc.ncbi.nlm.nih.gov/articles/PMC10963373/), [Identifying Key Principles and Commonalities in Digital Serious Game Design Frameworks](https://games.jmir.org/2025/1/e54075/), [Cooperative board games under the educational perspective](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70048).

## 4. Yangi mahsulot arxitekturasi: ManZila Adventure World

### 4.1. Bir-biriga bog‘langan 6 qatlam

1. **World Layer — olam va xarita**
   - O‘zbekiston hududlari, shaharlar, tarixiy maskanlar, tabiat hududlari va ertak olamlari.
   - Har bir manzil: lokatsiya, hikoya, topshiriqlar, xavflar, NPC, o‘quv maqsadi va mukofotdan tashkil topadi.
   - Bola xaritada shunchaki keyingi testni emas, jamoasiga kerakli manzilni tanlaydi.

2. **Adventure Layer — sarguzasht va missiya**
   - Har bir missiyada maqsad, sabab, to‘siq, tanlov va yakun bo‘ladi.
   - Missiyalar ketma-ketligi: tanishuv → yangi mexanika → ikki mexanikani birlashtirish → katta sinov → hikoya yakuni.
   - Har bir bosqichda kichik sir yoki kashfiyot bo‘lishi kerak.

3. **Gameplay Layer — o‘yin mexanikasi**
   - Yugurish, uchish, nishonga olish, yo‘l topish, qurish, bloklarni joylashtirish, so‘z yig‘ish, mantiqiy tanlov va ritm kabi alohida mexanikalar.
   - O‘yin mexanikasi savolni bezab turmasin; bilim mexanikani boshqarsin.

4. **Learning Layer — dars va bilim**
   - Har bir topshiriq aniq o‘quv maqsadi va sinf/yosh diapazoniga bog‘lanadi.
   - Javobdan keyin qisqa izoh, noto‘g‘ri tushuncha bo‘yicha tuzatish va keyingi safar mustaqil bajarish imkoniyati beriladi.
   - Takroriy mashq hikoya ichida tabiiy qaytadi, alohida zerikarli testga aylanmaydi.

5. **Bond & Community Layer — do‘stlik va jamoa**
   - Hamrohlar shunchaki bezak emas: har birining foydali qobiliyati, xarakteri va o‘ziga xos yordam usuli bor.
   - NPC va qishloq aholisi bolaning yordamini eslab, keyingi missiyalarda munosabatini o‘zgartiradi.
   - Jamoa bazasi/mahalla markazi umumiy yutuqlar bilan rivojlanadi: ko‘prik tiklanadi, kutubxona ochiladi, bog‘ yashnaydi, suv yo‘li tiklanadi.
   - Yakka o‘yinchi ham jamoaga tegishlilikni his qiladi; multiplayer majburiy bo‘lmaydi.

6. **Progress & Safety Layer — rivojlanish va xavfsizlik**
   - Profil ID asosida saqlash, o‘yin natijasi, o‘quv mahorati, hikoya tanlovlari va ochilgan manzillar.
   - Kelajakdagi onlayn rejimda faqat taklif/kod orqali xona, tayyor xavfsiz iboralar va ota-ona nazorati; ochiq chat bo‘lmaydi.

### 4.2. O‘yin ma’lumotlari uchun tavsiya etiladigan umumiy model

Keyingi kod bosqichida quyidagi tushunchalar yagona typed modelga aylantiriladi:

- `WorldDefinition`: olam nomi, hudud, vizual mavzu, ochilish sharti.
- `ChapterDefinition`: bob, hikoya kirishi, asosiy maqsad, yakun va keyingi bob.
- `LevelDefinition`: mexanika, qiyinlik, vaqt, xavf va o‘quv topshiriqlari.
- `LearningObjective`: fan, sinf, mavzu, ko‘nikma, o‘quv natijasi.
- `ChallengeDefinition`: savol yoki amaliy topshiriq, javob, izoh, ishora bosqichlari.
- `HazardDefinition`: xavf turi, ogohlantirish vaqti, qarshi harakat, oqibat, tiklanish.
- `CompanionDefinition`: qahramon, qobiliyat, dialog, do‘stlik darajasi.
- `StoryChoice`: tanlov, oqibat, ochiladigan dialog/manzil va yakun flaglari.
- `RewardDefinition`: yulduz, resurs, kosmetik buyum, jamoa qurilishi.
- `ProgressSnapshot`: profil ID, kampaniya holati, mahorat, yutuqlar, do‘stlik va vaqt belgisi.

Bularni birdaniga barcha ekranlarga tiqishtirmaslik kerak. Avval bitta vertical-slice o‘yinda sinovdan o‘tkaziladi, so‘ng umumiy komponentlar bosqichma-bosqich ko‘chiriladi.

## 5. Xavf-xatar tizimi

Xavf bolani qo‘rqitish yoki jazolash uchun emas, qaror qabul qilishga undash uchun ishlatiladi.

| Xavf turi | O‘yin ichidagi misol | Bilim bilan bog‘lanishi |
|---|---|---|
| Tabiiy | daryo oqimi, qum bo‘roni, qor ko‘chkisi, tuman | geografiya, tabiat, ob-havo, xarita |
| Harakat | qulagan shox, tosh, chuqur, ko‘prik uzilishi | tezlik, masofa, vaqt, kuzatuv |
| Mantiqiy | noto‘g‘ri yo‘l, yopiq darvoza, kodli qulf | matematika, mantiq, algoritm |
| Til | noto‘g‘ri yozuvli belgi, chalkash xabar | ona tili, ingliz tili, imlo, lug‘at |
| Ijtimoiy | do‘st bilan kelishmovchilik, yordamga muhtoj qahramon | odobnoma, muloqot, empatiya |
| Resurs | suv/vaqt/material yetishmasligi | hisoblash, taqqoslash, rejalashtirish |

**Adolat qoidalari:**
- Xavf oldindan ko‘rinadi yoki ovoz/animatsiya bilan ogohlantiriladi.
- Har bir xavfga kamida bitta o‘rganiladigan qarshi harakat bo‘ladi.
- Birinchi uchrashuvda xavf sekin va xavfsiz o‘rgatiladi.
- Xato qilgan bola butun bosqichni yo‘qotmaydi; qayta urinish, maslahat yoki muqobil yo‘l bo‘ladi.
- Yosh va natijaga qarab tezlik, zichlik, vaqt va ishora miqdori moslashadi.
- Zo‘ravonlik va qo‘rqinchli tasvirlar o‘rniga ramziy, yoshga mos xavflar ishlatiladi.

## 6. Do‘stlik, hamroh va jamoaga tegishlilik

### 6.1. Hamroh qobiliyatlari

- **Barchinoy:** kuzatuv va yo‘lni oldindan ko‘rish; yashirin belgi yoki xavfsiz yo‘lni payqash.
- **Rustam:** xarita, yo‘nalish va mantiqiy muammolarni yechish.
- **Zumrad:** so‘z, mehribonlik va buyumlarni to‘g‘ri tanlash.
- **Semurg‘:** uzoq masofani ko‘rish, shamol/uchish yo‘nalishini tushunish.
- **Eshak va Susambil ahli:** yuk, resurs va hisob-kitobga yordam.
- **ManZila AI robot:** qoidani eslatish, bilimga ishora berish va hissiy qo‘llab-quvvatlash.

Robotning tashqi ko‘rinishi qat’iy o‘zgarmaydi. Yangi emotsiya va animatsiyalar faqat tasdiqlangan mavjud dizayn doirasida qo‘shiladi.

### 6.2. Jamoa hissi

- O‘yin boshida bola o‘z qahramonini va hamrohini tanlaydi.
- NPC lar bolani nomi/avatar belgisi bilan tanib, uning avvalgi yordamini eslaydi.
- Har bir katta bobda umumiy muammo bo‘ladi: qishloqni suv bilan ta’minlash, kutubxonani tiklash, ko‘prik qurish yoki tarixiy yodgorlikni asrash.
- Har bir bola yakka o‘ynab ham umumiy jamoa rivojiga hissa qo‘shadi.
- Keyingi bosqichda sinfdoshlar xavfsiz kod orqali bir vazifada qatnashishi mumkin; rollar teng va bir-birini to‘ldiruvchi bo‘ladi.

## 7. Dars elementlarini mexanikaga singdirish

| Fan | O‘yin harakatiga aylantirish | Bola nimani o‘rganadi |
|---|---|---|
| Matematika | ko‘prik uchun uzunlikni hisoblash, bloklarni to‘g‘ri tenglama bilan faollashtirish, resursni taqsimlash | amallar, o‘lchov, kasr, mantiq |
| Ona tili | yo‘ldagi harflardan so‘z tuzish, xatoli yozuvni tuzatish, ma’noga mos belgini topish | imlo, so‘z turkumlari, lug‘at, matn tushunish |
| Ingliz tili | hamrohga buyruq berish, buyumni inglizcha nomlash, qisqa dialog orqali eshik ochish | so‘z, grammatika, tinglab tushunish |
| Tarix | manbaga mos belgini topish, tarixiy qaror oqibatini tanlash, davrlar ketma-ketligini tuzish | tarixiy tafakkur, vaqt, manba bilan ishlash |
| Geografiya | xaritada yo‘l chizish, relyef va ob-havoga qarab yo‘l tanlash | xarita, hudud, yo‘nalish, tabiat |
| Tabiat/STEM | suv aylanishi, o‘simlikni parvarishlash, oddiy mexanizm qurish | kuzatish, sabab-oqibat, tajriba |
| Odobnoma | do‘stga yordam berish, mehmon kutish, kelishmovchilikni hal qilish | empatiya, hurmat, muloqot |

Har bir savol uchun uch bosqichli yordam tavsiya etiladi: **1) yo‘naltiruvchi ishora → 2) tushuncha yoki misol → 3) yechimdan keyingi qisqa izoh.** Robot to‘g‘ri javobni darhol aytib bermaydi.

## 8. O‘yinlar katalogi: yangi rol va vizual yo‘nalish

Har bir o‘yin o‘zining taniladigan vizual tili va bitta asosiy mexanikasiga ega bo‘lishi kerak. Umumiy HUD va boshqaruv elementlari bir xil bo‘lishi mumkin, lekin sahna, rang, animatsiya, effekt va tovushlar o‘yinga xos bo‘ladi.

| Mavjud o‘yin | Yangi sarguzasht roli va dars integratsiyasi | O‘ziga xos grafik yo‘nalish |
|---|---|---|
| Alpomish Runner | ot-ulovli/yo‘lakli sayohat; so‘z yig‘ish, imlo, geografik manzillar; to‘siqdan qochish | 2.5D epik dasht, shamol, chang, uzoqdagi tog‘lar |
| Alpomish Geo | hududlarni topish, xarita bo‘laklarini birlashtirish | qo‘lda chizilgan atlas, naqshli xarita |
| Alpomish Kamoni | nishonga olishdan oldin masofa/burchak yoki savolni yechish | tarixiy poligon, yog‘och va naqshli nishonlar |
| Susambil Math | resurslarni hisoblab, do‘stlar bilan manzilga yetish | ertaknamo yashil vodiy, iliq ranglar, jonli hayvonlar |
| Donkey Road | yo‘l tanlash, yordam berish, resursni tejash | yumshoq 2D ertak kitobi, qo‘lda chizilgan fon |
| Zumrad Ona Tili | so‘z/grammatika orqali sehrli sandiq va yo‘llarni ochish | ipak mato, naqshli sandiq, yumshoq sehr effekti |
| Zumrad Wordle | belgilar va so‘z jumboqlari, ma’no topish | qimmatbaho toshlar, mozaika va sandiq ichki olami |
| Shiroq History | kuzatuv, strategiya, xarita va tarixiy tanlov | keng sahro, qadimiy xarita, quyosh botishi |
| Tomiris Tower | tarixiy himoya, hisob-kitob bilan mustahkam inshoot qurish | monumental minoralar, geometrik siluetlar |
| Spitamen Fortress | qal’ani himoya qilish uchun mantiq, geometriya va reja | tosh qal’a, bayroq, mexanik darvozalar |
| Semurg‘ Flight | shamol oqimi va yo‘nalishni o‘rganib uchish | rangli osmon, bulut qatlamlari, ipakdek patlar |
| Rustam Map | xarita bo‘yicha yo‘l topish va koordinata | miniatyura uslubidagi sayohat xaritasi |
| Math Blocks | ko‘prik, darvoza va mexanizmlarni tenglama bloklari bilan ishga tushirish | yorqin geometrik bloklar, toza kontrast |
| Math Zuma | matematik amal bilan harakatlanuvchi zanjirni boshqarish | rangli sharlar, milliy naqshli yo‘lak |
| Car Race | tezlikdan ko‘ra masofa, vaqt va hisob-kitobni to‘g‘ri qo‘llash | futuristik emas, milliy sayohat poygasi, dinamik kamera |
| Bubble | so‘z/ma’no yoki fan toifasiga mos pufaklarni tanlash | suv osti yoki osmon muhiti, yumshoq yorug‘lik |
| Word Game | harflarni topish va so‘z yasashni izlanish missiyasiga aylantirish | tipografik laboratoriya, harflardan qurilgan muhit |
| English Game | qisqa muloqot va buyruqlar orqali missiyani bajarish | xalqaro sayohat kundaligi, yorqin dialog sahnalari |
| Tumarisxon English | hamrohlar bilan inglizcha muloqot orqali muzokara/yo‘l ochish | tarixiy karvon yo‘li, pergament va mato teksturasi |
| Avazxon Odobnoma | ijtimoiy vaziyatlarda qaror va oqibatni ko‘rish | mahalla, mehmondo‘st hovli, jonli personajlar |
| Odobnoma | jamoani yarashtirish, yordam va hurmat missiyalari | iliq mahalla manzarasi, ifodali yuz/imo-ishora |
| Geography Game | tabiiy xavfga qarab marshrut va hudud tanlash | topografik xarita, qatlamli relyef |
| History Game | vaqt chizig‘i va tarixiy manbalar bilan sirni ochish | muzey/qo‘lyozma estetika, kinematik sahnalar |
| Uzbek Game | til qoidalarini dunyo obyektlari va belgilariga qo‘llash | naqshli yozuv, rangli kitob sahifalari |
| Multiplayer | keyinchalik xavfsiz jamoaviy topshiriqlar; hozircha prototip | umumiy jamoa maydoni, aniq rol belgisi |

`StoryGameWrapper`, `StoryIntroScreen` va `StoryOutroScreen` umumiy hikoya qatlami sifatida qoladi, lekin barcha o‘yinlarni bir xil ko‘rinishga majburlamasligi kerak.

## 9. Grafik va dizayn standartlari

### 9.1. Umumiy dizayn tizimi

- Bir xil: boshqaruv tugmalari, matn o‘qilishi, pauza, ovoz, yordam, xavfsiz chiqish, natija oynasi.
- Har xil: o‘yin olami, qahramon silueti, kamera, fon, rang palitrasi, zarracha effektlari, musiqa va harakat ritmi.
- Har bir o‘yinda birinchi 10 soniyada bola maqsadni ko‘rishi kerak.
- Katta sensorli tugmalar, rangdan tashqari shakl/ikon bilan ham farqlash, o‘qilishi oson shrift.
- Kuchsiz Android qurilmalarida yengil effekt rejimi; animatsiya va musiqa o‘chirilganda ham gameplay ishlashi.

### 9.2. Grafik ishlab chiqarish bosqichlari

1. Har bir o‘yin uchun 1 sahifali art brief: muhit, kamera, rang, shakl tili, yorug‘lik, personaj va UI.
2. 2D concept sheet: fon, qahramon, xavf, predmet va tugma holatlari.
3. Harakatlar ro‘yxati: idle, yurish/yugurish, sakrash, xato, g‘alaba, yordam, dialog.
4. Bitta sahnaning vertical-slice prototipi.
5. Telefonlarda FPS, xotira, o‘qilish va sensorli boshqaruv sinovi.
6. Shundan keyingina qolgan bosqichlarga assetlar ishlab chiqarish.

Hozirgi repo ichida yuqori sifatli 3D model yoki to‘liq animatsion assetlar mavjud deb bo‘lmaydi. Shuning uchun 3D tayyor deb ko‘rsatilmaydi; dastlab kuchli 2.5D/2D art-direction va animatsion prototip, keyin texnik imkoniyatga qarab 3D yo‘nalishi tavsiya etiladi.

## 10. Yagona texnik arxitektura

Tavsiya etiladigan modul tuzilishi:

```text
lib/
  game_core/
    models/       world, chapter, level, challenge, hazard, companion
    engine/       session, state machine, difficulty, reward
    learning/     objective, question resolver, hint ladder, mastery
    narrative/    story flags, dialogue choices, character bonds
    social/       safe room contracts, team roles (future backend)
    presentation/ shared HUD, pause, hint, result, accessibility
  features/
    games/        game-specific scenes and mechanics
    worldmap/     world and chapter navigation
    stats/        learning + gameplay analytics
```

**Qoidalar:**
- O‘yin ekranlari `GameCore` orqali umumiy sessiya, natija va yordamni oladi; o‘zining noyob gameplay kodini saqlaydi.
- Kontent modeldan keladi; UI ichida savol banki, mukofot va hikoya matnlarini tarqoq holda qattiq yozib qo‘yish kamaytiriladi.
- Har bir natija `profileId`, `gameId`, `levelId`, `subject`, `objectiveId`, `score`, `mastery`, `duration`, `hintsUsed`, `attempt` bilan bog‘lanadi.
- Offline birinchi: lokal saqlash; kelajakda backend qo‘shilganda sinxronlash adapteri.
- Server multiplayer va ota-ona paneli hozirgi lokal SharedPreferences bilan aralashtirilmaydi.

## 11. Ishlab chiqish tartibi

### Phase 9 — Vertical Slice: bitta to‘liq sarguzasht

Birinchi prototip sifatida **Susambil: Yo‘qolgan buloq** tavsiya etiladi:
- bola va Eshak Susambilga boradi;
- yo‘lda suv yo‘li uzilgan, do‘stlar yordamga muhtoj;
- xavflar: loyqa yo‘l, ko‘prik, suv oqimi, resurs cheklovi;
- matematika: suv miqdori, masofa, hisob-kitob;
- ona tili: belgilar va ko‘rsatmalarni o‘qish;
- do‘stlik: har bir hamroh o‘z qobiliyati bilan yordam beradi;
- jamoa: buloq tiklangach, Susambil aholisi umumiy bayram qiladi;
- robot: uch bosqichli ishora, tashqi ko‘rinish o‘zgarmaydi.

Bu tanlov mavjud `susambil_math_screen` va `StoryGameState` bazasidan bosqichma-bosqich foydalanish imkonini beradi.

### Phase 10 — Umumiy o‘yin sessiyasi va natija

- Barcha o‘yinlarga yagona session/result contract.
- Statistika va o‘quv mahorati alohida hisoblanadi.
- Takroriy natija yozilishi, noto‘g‘ri fan yorlig‘i va profil aralashishi test qilinadi.

### Phase 11 — Hikoya, do‘stlik va jamoa

- Tanlovli dialoglar, bir nechta oqibat va yakun.
- Hamroh qobiliyatlari va bond progress.
- Jamoa bazasi va NPC xotirasi.

### Phase 12 — Grafik ishlab chiqarish va katalogni ko‘chirish

- Har bir o‘yin uchun art brief va alohida vizual identitet.
- Qolgan o‘yinlarni yangi GameCore’ga ketma-ket ko‘chirish.

### Phase 13 — Xavfsiz multiplayer va CMS

- Faqat real backend, autentifikatsiya, room state, server-side natija tekshiruvi va bolalar xavfsizligi qoidalari tayyor bo‘lgandan keyin.

## 12. Sifat va qabul mezonlari

Vertical slice qabul qilinishi uchun:
- Bola 10 soniya ichida maqsad va boshqaruvni tushunadi.
- Kamida 3 xil xavf turi bor; har biri oldindan bildiriladi va adolatli qarshi harakatga ega.
- Kamida 2 fan topshirig‘i o‘yin mexanikasiga singdirilgan.
- Hamroh qobiliyati gameplay natijasini o‘zgartiradi.
- Jamoaga foydali real natija hikoyada ko‘rinadi.
- Xato javobdan so‘ng ishora/izoh mavjud; bosqichni qayta boshlash majburiy emas.
- Profil ID bo‘yicha progress saqlanadi.
- Robot-mascot dizayni o‘zgarmaydi.
- Android telefonlarda boshqaruv, FPS va ekran o‘lchamlari tekshiriladi.

## 13. Phase 8 bajarilgan ish va cheklovlar

- Phase 7 loyihasi va barcha o‘yin ekranlari ro‘yxati qayta ko‘rib chiqildi.
- Statistik integratsiya, Story HUD va GameConfig ulanish darajasi aniqlandi.
- Zamonaviy game-based learning va kooperativ dizayn manbalari o‘rganildi.
- Yangi umumiy arxitektura, o‘yin sikli, xavf, do‘stlik, jamoa, dars integratsiyasi va art-direction yozib chiqildi.
- Bu bosqichda Dart fayllariga yangi gameplay kodi qo‘shilmadi: avval tizimni to‘g‘ri loyihalash, keyin bitta vertical slice’da sinash tanlandi.
- Flutter/Dart SDK mavjud emas; `flutter analyze`, `flutter test`, `dart format` va Android build bajarilmadi.
