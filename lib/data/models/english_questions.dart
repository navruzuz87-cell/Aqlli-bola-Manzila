// Ingliz tili savollari — 5-12 yosh uchun
// Mexanika: Katta rasm emoji ko'r → inglizcha so'z top

enum EnglishCategory {
  animals,   // Hayvonlar
  colors,    // Ranglar
  food,      // Ovqat
  body,      // Tana a'zolari
  family,    // Oila
  nature,    // Tabiat
  numbers,   // Raqamlar
  actions,   // Harakatlar
}

extension EnglishCategoryExt on EnglishCategory {
  String get label {
    switch (this) {
      case EnglishCategory.animals:  return 'Hayvonlar';
      case EnglishCategory.colors:   return 'Ranglar';
      case EnglishCategory.food:     return 'Ovqat';
      case EnglishCategory.body:     return 'Tana';
      case EnglishCategory.family:   return 'Oila';
      case EnglishCategory.nature:   return 'Tabiat';
      case EnglishCategory.numbers:  return 'Raqamlar';
      case EnglishCategory.actions:  return 'Harakatlar';
    }
  }
  String get emoji {
    switch (this) {
      case EnglishCategory.animals:  return '🐾';
      case EnglishCategory.colors:   return '🎨';
      case EnglishCategory.food:     return '🍎';
      case EnglishCategory.body:     return '🤲';
      case EnglishCategory.family:   return '👨‍👩‍👧';
      case EnglishCategory.nature:   return '🌿';
      case EnglishCategory.numbers:  return '🔢';
      case EnglishCategory.actions:  return '🏃';
    }
  }
}

class EnglishQuestion {
  final String id;
  final String imageEmoji;      // Katta ko'rinadigan rasm emoji
  final String uzbekWord;       // O'zbekcha ma'nosi
  final String englishWord;     // To'g'ri inglizcha javob
  final List<String> options;   // 4 ta variant (inglizcha)
  final int correctIndex;
  final EnglishCategory category;
  final int grade;
  final String pronunciation;   // Talaffuz: [kæt]
  final String funSentence;     // Qiziqarli misol jumla
  final int starsReward;

  const EnglishQuestion({
    required this.id,
    required this.imageEmoji,
    required this.uzbekWord,
    required this.englishWord,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.grade,
    required this.pronunciation,
    required this.funSentence,
    this.starsReward = 10,
  });
}

class EnglishQuestions {
  static List<EnglishQuestion> getAll() => _questions;

  static List<EnglishQuestion> getByGrade(int grade) =>
      _questions.where((q) => q.grade <= grade).toList();

  static List<EnglishQuestion> getByCategory(EnglishCategory cat) =>
      _questions.where((q) => q.category == cat).toList();

  static const List<EnglishQuestion> _questions = [

    // ══ HAYVONLAR ════════════════════════════════════════

    EnglishQuestion(
      id: 'en1',
      imageEmoji: '🐱',
      uzbekWord: 'Mushuk',
      englishWord: 'Cat',
      options: ['Dog', 'Cat', 'Bird', 'Fish'],
      correctIndex: 1,
      category: EnglishCategory.animals,
      grade: 1,
      pronunciation: '[kæt]',
      funSentence: 'The cat says MEOW! 🎵',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en2',
      imageEmoji: '🐶',
      uzbekWord: 'It',
      englishWord: 'Dog',
      options: ['Cat', 'Cow', 'Dog', 'Horse'],
      correctIndex: 2,
      category: EnglishCategory.animals,
      grade: 1,
      pronunciation: '[dɒɡ]',
      funSentence: 'The dog says WOOF! 🎵',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en3',
      imageEmoji: '🐘',
      uzbekWord: 'Fil',
      englishWord: 'Elephant',
      options: ['Lion', 'Elephant', 'Tiger', 'Bear'],
      correctIndex: 1,
      category: EnglishCategory.animals,
      grade: 2,
      pronunciation: '[ˈelɪfənt]',
      funSentence: 'Elephants never forget! 🧠',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en4',
      imageEmoji: '🦁',
      uzbekWord: 'Sher',
      englishWord: 'Lion',
      options: ['Tiger', 'Wolf', 'Lion', 'Fox'],
      correctIndex: 2,
      category: EnglishCategory.animals,
      grade: 2,
      pronunciation: '[laɪən]',
      funSentence: 'Lion is the king of animals! 👑',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en5',
      imageEmoji: '🐦',
      uzbekWord: 'Qush',
      englishWord: 'Bird',
      options: ['Fish', 'Bird', 'Frog', 'Bee'],
      correctIndex: 1,
      category: EnglishCategory.animals,
      grade: 1,
      pronunciation: '[bɜːrd]',
      funSentence: 'Birds can fly in the sky! ☁️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en6',
      imageEmoji: '🐠',
      uzbekWord: 'Baliq',
      englishWord: 'Fish',
      options: ['Fish', 'Frog', 'Snake', 'Crab'],
      correctIndex: 0,
      category: EnglishCategory.animals,
      grade: 1,
      pronunciation: '[fɪʃ]',
      funSentence: 'Fish live in water! 🌊',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en7',
      imageEmoji: '🐰',
      uzbekWord: 'Quyon',
      englishWord: 'Rabbit',
      options: ['Mouse', 'Rabbit', 'Hamster', 'Squirrel'],
      correctIndex: 1,
      category: EnglishCategory.animals,
      grade: 2,
      pronunciation: '[ˈræbɪt]',
      funSentence: 'Rabbits love carrots! 🥕',
      starsReward: 10,
    ),

    // ══ RANGLAR ════════════════════════════════════════

    EnglishQuestion(
      id: 'en8',
      imageEmoji: '🔴',
      uzbekWord: 'Qizil',
      englishWord: 'Red',
      options: ['Blue', 'Red', 'Green', 'Yellow'],
      correctIndex: 1,
      category: EnglishCategory.colors,
      grade: 1,
      pronunciation: '[red]',
      funSentence: 'Apples are red! 🍎',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en9',
      imageEmoji: '💙',
      uzbekWord: 'Ko\'k',
      englishWord: 'Blue',
      options: ['Blue', 'Green', 'Purple', 'Pink'],
      correctIndex: 0,
      category: EnglishCategory.colors,
      grade: 1,
      pronunciation: '[bluː]',
      funSentence: 'The sky is blue! ☀️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en10',
      imageEmoji: '💚',
      uzbekWord: 'Yashil',
      englishWord: 'Green',
      options: ['Yellow', 'Green', 'Orange', 'Brown'],
      correctIndex: 1,
      category: EnglishCategory.colors,
      grade: 1,
      pronunciation: '[ɡriːn]',
      funSentence: 'Grass is green! 🌿',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en11',
      imageEmoji: '💛',
      uzbekWord: 'Sariq',
      englishWord: 'Yellow',
      options: ['Orange', 'White', 'Yellow', 'Gold'],
      correctIndex: 2,
      category: EnglishCategory.colors,
      grade: 1,
      pronunciation: '[ˈjeləʊ]',
      funSentence: 'The sun is yellow! ☀️',
      starsReward: 10,
    ),

    // ══ OVQAT ════════════════════════════════════════

    EnglishQuestion(
      id: 'en12',
      imageEmoji: '🍎',
      uzbekWord: 'Olma',
      englishWord: 'Apple',
      options: ['Apple', 'Orange', 'Banana', 'Grape'],
      correctIndex: 0,
      category: EnglishCategory.food,
      grade: 1,
      pronunciation: '[ˈæpl]',
      funSentence: 'An apple a day keeps the doctor away! 👨‍⚕️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en13',
      imageEmoji: '🍌',
      uzbekWord: 'Banan',
      englishWord: 'Banana',
      options: ['Mango', 'Banana', 'Lemon', 'Peach'],
      correctIndex: 1,
      category: EnglishCategory.food,
      grade: 1,
      pronunciation: '[bəˈnɑːnə]',
      funSentence: 'Monkeys love bananas! 🐒',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en14',
      imageEmoji: '🍕',
      uzbekWord: 'Pizza',
      englishWord: 'Pizza',
      options: ['Burger', 'Pizza', 'Pasta', 'Bread'],
      correctIndex: 1,
      category: EnglishCategory.food,
      grade: 2,
      pronunciation: '[ˈpiːtsə]',
      funSentence: 'Pizza comes from Italy! 🇮🇹',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en15',
      imageEmoji: '🥕',
      uzbekWord: 'Sabzi',
      englishWord: 'Carrot',
      options: ['Potato', 'Carrot', 'Tomato', 'Onion'],
      correctIndex: 1,
      category: EnglishCategory.food,
      grade: 2,
      pronunciation: '[ˈkærət]',
      funSentence: 'Carrots help you see better! 👀',
      starsReward: 10,
    ),

    // ══ TANA A'ZOLARI ════════════════════════════════

    EnglishQuestion(
      id: 'en16',
      imageEmoji: '👁️',
      uzbekWord: 'Ko\'z',
      englishWord: 'Eye',
      options: ['Ear', 'Eye', 'Nose', 'Mouth'],
      correctIndex: 1,
      category: EnglishCategory.body,
      grade: 1,
      pronunciation: '[aɪ]',
      funSentence: 'We have TWO eyes! 👁️👁️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en17',
      imageEmoji: '👃',
      uzbekWord: 'Burun',
      englishWord: 'Nose',
      options: ['Mouth', 'Ear', 'Nose', 'Eye'],
      correctIndex: 2,
      category: EnglishCategory.body,
      grade: 1,
      pronunciation: '[nəʊz]',
      funSentence: 'We smell flowers with our nose! 🌸',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en18',
      imageEmoji: '🤲',
      uzbekWord: 'Qo\'l',
      englishWord: 'Hand',
      options: ['Foot', 'Hand', 'Arm', 'Leg'],
      correctIndex: 1,
      category: EnglishCategory.body,
      grade: 2,
      pronunciation: '[hænd]',
      funSentence: 'We write with our hands! ✍️',
      starsReward: 10,
    ),

    // ══ OILA ════════════════════════════════════════

    EnglishQuestion(
      id: 'en19',
      imageEmoji: '👩',
      uzbekWord: 'Ona',
      englishWord: 'Mother',
      options: ['Sister', 'Mother', 'Aunt', 'Daughter'],
      correctIndex: 1,
      category: EnglishCategory.family,
      grade: 1,
      pronunciation: '[ˈmʌðər]',
      funSentence: 'Mother loves us always! ❤️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en20',
      imageEmoji: '👨',
      uzbekWord: 'Ota',
      englishWord: 'Father',
      options: ['Father', 'Brother', 'Uncle', 'Son'],
      correctIndex: 0,
      category: EnglishCategory.family,
      grade: 1,
      pronunciation: '[ˈfɑːðər]',
      funSentence: 'Father is strong and kind! 💪',
      starsReward: 10,
    ),

    // ══ TABIAT ════════════════════════════════════════

    EnglishQuestion(
      id: 'en21',
      imageEmoji: '☀️',
      uzbekWord: 'Quyosh',
      englishWord: 'Sun',
      options: ['Moon', 'Star', 'Sun', 'Cloud'],
      correctIndex: 2,
      category: EnglishCategory.nature,
      grade: 1,
      pronunciation: '[sʌn]',
      funSentence: 'The sun gives us light and warmth! 🌟',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en22',
      imageEmoji: '🌙',
      uzbekWord: 'Oy',
      englishWord: 'Moon',
      options: ['Sun', 'Moon', 'Star', 'Cloud'],
      correctIndex: 1,
      category: EnglishCategory.nature,
      grade: 1,
      pronunciation: '[muːn]',
      funSentence: 'The moon shines at night! 🌟',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en23',
      imageEmoji: '🌲',
      uzbekWord: 'Daraxt',
      englishWord: 'Tree',
      options: ['Flower', 'Grass', 'Tree', 'Bush'],
      correctIndex: 2,
      category: EnglishCategory.nature,
      grade: 1,
      pronunciation: '[triː]',
      funSentence: 'Trees give us fresh air! 🌬️',
      starsReward: 10,
    ),

    // ══ RAQAMLAR ════════════════════════════════════

    EnglishQuestion(
      id: 'en24',
      imageEmoji: '1️⃣',
      uzbekWord: 'Bir',
      englishWord: 'One',
      options: ['Two', 'One', 'Three', 'Four'],
      correctIndex: 1,
      category: EnglishCategory.numbers,
      grade: 1,
      pronunciation: '[wʌn]',
      funSentence: 'One sun in the sky! ☀️',
      starsReward: 10,
    ),
    EnglishQuestion(
      id: 'en25',
      imageEmoji: '5️⃣',
      uzbekWord: 'Besh',
      englishWord: 'Five',
      options: ['Four', 'Six', 'Five', 'Seven'],
      correctIndex: 2,
      category: EnglishCategory.numbers,
      grade: 1,
      pronunciation: '[faɪv]',
      funSentence: 'Five fingers on one hand! ✋',
      starsReward: 10,
    ),
  ];
}
