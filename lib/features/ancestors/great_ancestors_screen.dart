import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/great_ancestors.dart';
import '../../data/models/user_profile.dart';

class GreatAncestorsScreen extends StatefulWidget {
  final UserProfile profile;
  const GreatAncestorsScreen({super.key, required this.profile});

  @override
  State<GreatAncestorsScreen> createState() => _GreatAncestorsScreenState();
}

class _GreatAncestorsScreenState extends State<GreatAncestorsScreen> {
  GreatAncestor? _selected;

  static const List<Color> _colors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFB71C1C),
    Color(0xFF004D40),
    Color(0xFFE65100),
    Color(0xFF37474F),
    Color(0xFF880E4F),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
          ),
        ),
        child: SafeArea(
          child: _selected == null ? _buildList() : _buildDetail(),
        ),
      ),
    );
  }

  Widget _buildList() {
    final ancestors = GreatAncestor.getAll();
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '🏛️ Buyuk Ajdodlarimiz',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ancestors.length,
            itemBuilder: (context, i) {
              final anc = ancestors[i];
              final color = _colors[i % _colors.length];
              return _AncestorCard(
                ancestor: anc,
                color: color,
                index: i,
                onTap: () => setState(() => _selected = anc),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetail() {
    final anc = _selected!;
    final idx = GreatAncestor.getAll().indexOf(anc);
    final color = _colors[idx % _colors.length];

    return Column(
      children: [
        // Back bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => setState(() => _selected = null),
            ),
            Expanded(
              child: Text(
                anc.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Text(anc.emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(anc.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(anc.years,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Text('📍 ${anc.city}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white20,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(anc.field,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ).animate().fadeIn().slideY(begin: -0.3),

                const SizedBox(height: 16),

                // For kids
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('👦 Bolalar uchun:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(anc.forKids,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, height: 1.6)),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 16),

                // Facts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⭐ Qiziqarli faktlar:',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      ...anc.facts.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${e.key + 1}. ${e.value}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13, height: 1.5),
                            ),
                          )),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Questions
                const Text(
                  '🧩 Savollar:',
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...anc.questions.asMap().entries.map((e) =>
                    _AncestorQuestionWidget(
                      question: e.value,
                      index: e.key,
                      color: color,
                    ).animate().fadeIn(delay: (300 + e.key * 100).ms)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AncestorCard extends StatelessWidget {
  final GreatAncestor ancestor;
  final Color color;
  final int index;
  final VoidCallback onTap;
  const _AncestorCard(
      {required this.ancestor,
      required this.color,
      required this.index,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ancestor.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 6),
            Text(
              ancestor.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            Text(
              ancestor.years,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }
}

class _AncestorQuestionWidget extends StatefulWidget {
  final AncestorQuestion question;
  final int index;
  final Color color;
  const _AncestorQuestionWidget(
      {required this.question, required this.index, required this.color});

  @override
  State<_AncestorQuestionWidget> createState() =>
      _AncestorQuestionWidgetState();
}

class _AncestorQuestionWidgetState extends State<_AncestorQuestionWidget> {
  int? _selected;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.index + 1}. ${q.question}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ...q.options.asMap().entries.map((e) {
            final isSelected = _selected == e.key;
            final isCorrect = e.key == q.correctIndex;
            Color bg = Colors.white10;
            Color border = Colors.white24;

            if (_answered) {
              if (isCorrect) {
                bg = const Color(0xFF1B5E20).withOpacity(0.6);
                border = const Color(0xFF69F0AE);
              } else if (isSelected) {
                bg = const Color(0xFFB71C1C).withOpacity(0.6);
                border = const Color(0xFFEF5350);
              }
            }

            return GestureDetector(
              onTap: () {
                if (_answered) return;
                setState(() {
                  _selected = e.key;
                  _answered = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  if (_answered && isCorrect) const Text('✅'),
                  if (_answered && isSelected && !isCorrect) const Text('❌'),
                ]),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '📖 ${q.explanation}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
