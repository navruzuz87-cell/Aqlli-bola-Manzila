class Companion {
  final String id;
  final String name;
  final String emoji;
  final String story;
  final int unlockLevel;
  final List<String> subjectEmojis;
  final String greeting;

  const Companion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.story,
    required this.unlockLevel,
    required this.subjectEmojis,
    required this.greeting,
  });

  static List<Companion> getUnlocked(int playerLevel) =>
      _all.where((c) => c.unlockLevel <= playerLevel).toList();

  static List<Companion> getLocked(int playerLevel) =>
      _all.where((c) => c.unlockLevel > playerLevel).toList();

  static Companion? getById(String id) {
    try {
      return _all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<Companion> _all = [
    Companion(
      id: 'alpomish',
      name: 'Alpomish',
      emoji: '🦸',
      story: 'O\'zbek xalq eposidagi bahodir qahramon. '
          'Jasorat va do\'stlikni sevadi!',
      unlockLevel: 1,
      subjectEmojis: ['🧮', '💪', '🏅'],
      greeting: 'Assalomu alaykum! Birga o\'rganamiz, do\'stim!',
    ),
    Companion(
      id: 'zumrad',
      name: 'Zumrad',
      emoji: '🌟',
      story: '"Zumrad va Qimmat" ertakidagi mehribon va aqlli qiz. '
          'Halollik va mehnatsevarlikni yoqtiradi!',
      unlockLevel: 1,
      subjectEmojis: ['📚', '🌸', '✨'],
      greeting: 'Salom! Birga o\'qib, ko\'p narsalarni o\'rganamiz!',
    ),
    Companion(
      id: 'aldar_kosa',
      name: 'Aldar Ko\'sa',
      emoji: '🤠',
      story: 'O\'zbek xalq ertaklaridagi dono va hazilkash qahramon. '
          'Adolatni himoya qiladi, zolimlarni aldaydi!',
      unlockLevel: 3,
      subjectEmojis: ['🧩', '😄', '⚖️'],
      greeting: 'Voy, bilimli bola kelibdi! Keling, o\'ynab o\'rganamiz!',
    ),
    Companion(
      id: 'malika',
      name: 'Malika Ayyor',
      emoji: '👸',
      story: 'O\'zbek ertaklaridagi dono malika. '
          'Topshmoqlarni sevadi va ilmni qadrlaydi!',
      unlockLevel: 5,
      subjectEmojis: ['🌍', '📜', '💫'],
      greeting: 'Salom, dono bola! Dunyoni birga kashf etamiz!',
    ),
    Companion(
      id: 'rustam',
      name: 'Rustam Zol',
      emoji: '⚔️',
      story: 'Firdavsiy Shohnomаsidagi mashhur pahlavan. '
          'Kuch va jasorat timsoli!',
      unlockLevel: 7,
      subjectEmojis: ['📖', '🏆', '🔥'],
      greeting: 'Barakalla! Sen ham qahramonsan — bilim bilan!',
    ),
  ];
}
