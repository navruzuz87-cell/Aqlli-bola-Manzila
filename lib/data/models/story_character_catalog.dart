/// Manzila ertak va tarixiy qahramonlari uchun yagona xarakter katalogi.
/// Tarixiy shaxslar haqidagi sahnalar yoshga mos, zo'ravonlikni ulug'lamaydigan
/// va manbalar bilan tekshiriladigan shaklda yozilishi kerak.
class StoryCharacterProfile {
  final String id;
  final String name;
  final String role;
  final String personality;
  final String gameStyle;
  final String learningGoal;
  final String signatureLine;
  const StoryCharacterProfile({required this.id, required this.name, required this.role, required this.personality, required this.gameStyle, required this.learningGoal, required this.signatureLine});
}

class StoryCharacterCatalog {
  static const characters = <StoryCharacterProfile>[
    StoryCharacterProfile(id: 'alpomish', name: 'Alpomish', role: 'Doston qahramoni', personality: 'Jasur, sabrli, va’dasiga sodiq', gameStyle: 'Ot ustida sayohat, kamondan nishonga olish, to‘siqlardan o‘tish', learningGoal: 'So‘z boyligi, geografiya, diqqat va ketma-ketlik', signatureLine: 'Har bir manzilga aql va jasorat bilan yetamiz!'),
    StoryCharacterProfile(id: 'susambil_eshak', name: 'Susambildagi Eshak', role: 'Xalq ertagi qahramoni', personality: 'Sodda, mehnatkash, ovqatni yaxshi ko‘radi, do‘stlariga ishonadi', gameStyle: 'Yo‘l topish, oziq yig‘ish, hisob-kitob va resurs tanlash', learningGoal: 'Qo‘shish-ayirish, ko‘paytirish, rejalashtirish', signatureLine: 'Susambilga yetish uchun birga hisoblaymiz!'),
    StoryCharacterProfile(id: 'zumrad', name: 'Zumrad', role: 'Xalq ertagi qahramoni', personality: 'Mehribon, mehnatsevar, halol va topqir', gameStyle: 'Topshiriqlarni bajarish, so‘z tuzish, sandiq va jumboqlarni ochish', learningGoal: 'Ona tili, imlo, o‘qib tushunish va odob', signatureLine: 'Bilim bilan sehrli sandiqni ochamiz!'),
    StoryCharacterProfile(id: 'qimmat', name: 'Qimmat', role: 'Xalq ertagi qahramoni', personality: 'Ertakdagi xatti-harakatlari orqali tanlov oqibatlarini ko‘rsatadi', gameStyle: 'Qarorlar, oqibatlarni solishtirish, qayta urinish', learningGoal: 'Halollik, mehnatsevarlik, hurmat va tanqidiy fikrlash', signatureLine: 'Har bir tanlovning natijasi bor!'),
    StoryCharacterProfile(id: 'shiroq', name: 'Shiroq', role: 'Tarixiy rivoyat qahramoni', personality: 'Mard, topqir, el-yurtini sevadi', gameStyle: 'Xarita, yo‘l tanlash, mantiqiy strategiya va tarixiy savollar', learningGoal: 'Tarixiy tafakkur, xarita o‘qish va muammoli vaziyatni hal qilish', signatureLine: 'Aql bilan yo‘l topamiz!'),
    StoryCharacterProfile(id: 'tomiris', name: 'Tomiris', role: 'Tarixiy malika', personality: 'Qat’iyatli, dono, yetakchi', gameStyle: 'Strategik himoya, resurslarni boshqarish, qarorlar', learningGoal: 'Tarix, strategiya, jamoaviy mas’uliyat', signatureLine: 'Kuch — birlik va donolikda!'),
    StoryCharacterProfile(id: 'al_khwarizmi', name: 'Al-Xorazmiy', role: 'Buyuk alloma', personality: 'Izlanuvchan, tartibli, mantiqiy fikrlaydi', gameStyle: 'Matematik bloklar, amallar zanjiri, naqsh va algoritmlar', learningGoal: 'Hisoblash, algebraik fikrlash va algoritmik tafakkur', signatureLine: 'Har bir masalaning yechimi bor!'),
    StoryCharacterProfile(id: 'manzila_robot', name: 'Manzila AI robot', role: 'Doimiy yordamchi', personality: 'Mehribon, xotirjam, qiziquvchan va rag‘batlantiruvchi', gameStyle: 'Maslahat, ishora, tushuntirish, ovozli yo‘l-yo‘riq', learningGoal: 'Mustaqil fikrlashga yordam berish, tayyor javobni darhol bermaslik', signatureLine: 'Keling, birga o‘ylab ko‘ramiz!'),
  ];
}
