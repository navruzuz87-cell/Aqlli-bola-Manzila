import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: NotificationService.instance,
            builder: (_, __) {
              final svc = NotificationService.instance;
              return Column(children: [
                _topBar(svc),
                Expanded(
                  child: svc.all.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: svc.all.length,
                        itemBuilder: (_, i) => _notifCard(svc.all[i], i),
                      ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(NotificationService svc) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Text('Bildirishnomalar',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
      if (svc.unreadCount > 0) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${svc.unreadCount}',
              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A237E))),
        ),
      ],
      const Spacer(),
      if (svc.all.isNotEmpty)
        TextButton(
          onPressed: svc.unreadCount > 0 ? svc.markAllRead : svc.clearAll,
          child: Text(svc.unreadCount > 0 ? "Barchasini o'qi" : "Tozala",
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
        ),
    ]),
  );

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔔', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 12),
      Text('Bildirishnomalar yo\'q',
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70)),
      const SizedBox(height: 6),
      Text('O\'yin o\'ynaganingizda bu yerda\nxabarlar paydo bo\'ladi',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 13, color: Colors.white38)),
    ]),
  );

  Widget _notifCard(AppNotification n, int idx) {
    final typeColor = _typeColor(n.type);
    return GestureDetector(
      onTap: () => NotificationService.instance.markRead(n.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead ? Colors.transparent : typeColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(_typeEmoji(n.type),
                style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(n.title,
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: n.isRead ? Colors.white60 : Colors.white)),
              ),
              if (!n.isRead)
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
                ),
            ]),
            const SizedBox(height: 2),
            Text(n.body,
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 4),
            Text(_timeAgo(n.scheduledAt),
                style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38)),
          ])),
        ]),
      ).animate(delay: (idx * 60).ms).fadeIn().slideX(begin: 0.2),
    );
  }

  Color _typeColor(NotifType t) {
    switch (t) {
      case NotifType.dailyReminder: return const Color(0xFF42A5F5);
      case NotifType.missionComplete: return const Color(0xFF66BB6A);
      case NotifType.streakWarning: return const Color(0xFFFF7043);
      case NotifType.levelUp: return const Color(0xFFFFD54F);
      case NotifType.achievementUnlocked: return const Color(0xFFAB47BC);
    }
  }

  String _typeEmoji(NotifType t) {
    switch (t) {
      case NotifType.dailyReminder: return '🌅';
      case NotifType.missionComplete: return '✅';
      case NotifType.streakWarning: return '🔥';
      case NotifType.levelUp: return '⬆️';
      case NotifType.achievementUnlocked: return '🏆';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }
}
