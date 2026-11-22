import 'dart:math' as math;
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// O'YIN EKRANI CustomPainter'lari
// Har bir o'yin uchun alohida sahna fonlari
// ════════════════════════════════════════════════════════════════════════════

// ── 1. Yo'l o'yini — Eshak yo'lda ──────────────────────────────────────────
class YolCardPainter extends CustomPainter {
  final double anim;
  const YolCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ko'k osmon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.6),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.6)),
    );

    // Yashil o't
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.6, w, h * 0.4),
      Paint()..color = const Color(0xFF43A047),
    );

    // Quyosh
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.12),
      18,
      Paint()..color = const Color(0xFFFFD54F),
    );

    // Yo'l (kul rang)
    final roadPaint = Paint()..color = const Color(0xFFBDBDBD);
    final road = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.3, h * 0.65)
      ..lineTo(w * 0.7, h * 0.65)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(road, roadPaint);

    // Yo'l chiziqlari
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..strokeDashOffset = anim * 20;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * 0.5, h * 0.72 + i * 10),
        Offset(w * 0.5, h * 0.78 + i * 10),
        linePaint,
      );
    }

    // Eshak (sodda rasm)
    _drawDonkey(canvas, Offset(w * 0.35 + math.sin(anim) * 3, h * 0.60));
  }

  void _drawDonkey(Canvas canvas, Offset pos) {
    final body = Paint()..color = const Color(0xFF78909C);
    final dark = Paint()..color = const Color(0xFF546E7A);

    // Tana
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 30, height: 18),
      body,
    );
    // Bosh
    canvas.drawCircle(Offset(pos.dx + 18, pos.dy - 4), 9, body);
    // Quloq
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx + 20, pos.dy - 14), width: 4, height: 8),
      dark,
    );
    // Ko'z
    canvas.drawCircle(Offset(pos.dx + 21, pos.dy - 5), 1.5, Paint()..color = Colors.black);
    // Oyoqlar
    for (int i = 0; i < 4; i++) {
      final x = pos.dx - 10 + i * 7.0;
      canvas.drawLine(
        Offset(x, pos.dy + 7),
        Offset(x, pos.dy + 16),
        body..strokeWidth = 3,
      );
    }
    // Dum
    canvas.drawLine(
      Offset(pos.dx - 15, pos.dy),
      Offset(pos.dx - 22, pos.dy - 6),
      dark..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(YolCardPainter old) => old.anim != anim;
}

// ── 2. Xarita o'yini — Rustam va xarita ────────────────────────────────────
class XaritaCardPainter extends CustomPainter {
  final double anim;
  const XaritaCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Qog'oz rangi fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE082)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Xarita fonlari — qit'alar
    final land = Paint()..color = const Color(0xFF8BC34A).withOpacity(0.7);
    final ocean = Paint()..color = const Color(0xFF64B5F6).withOpacity(0.5);

    // Okean
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.45), width: w * 0.9, height: h * 0.6),
      ocean,
    );

    // Qit'alar (sodda shakllar)
    canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.3, h * 0.3), land);
    canvas.drawOval(Rect.fromLTWH(w * 0.55, h * 0.15, w * 0.35, h * 0.35), land);
    canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.5, w * 0.25, h * 0.2), land);

    // Ko'rsatkichlar (pin)
    _drawPin(canvas, Offset(w * 0.3, h * 0.3), const Color(0xFFF44336));
    _drawPin(canvas, Offset(w * 0.65, h * 0.28), const Color(0xFF4CAF50));

    // Yo'l chizig'i
    final routePaint = Paint()
      ..color = const Color(0xFFE53935).withOpacity(0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final routePath = Path()
      ..moveTo(w * 0.3, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.1, w * 0.65, h * 0.28);
    canvas.drawPath(routePath, routePaint);

    // Kompas
    _drawCompass(canvas, Offset(w * 0.85, h * 0.75), 16, anim);
  }

  void _drawPin(Canvas canvas, Offset pos, Color color) {
    canvas.drawCircle(pos, 7, Paint()..color = color);
    canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
    canvas.drawLine(
      pos, Offset(pos.dx, pos.dy + 10),
      Paint()..color = color..strokeWidth = 2,
    );
  }

  void _drawCompass(Canvas canvas, Offset center, double r, double anim) {
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawCircle(center, r,
        Paint()..color = const Color(0xFF795548)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Shimol igna
    final angle = anim * 0.5;
    canvas.drawLine(
      center,
      Offset(center.dx + r * 0.8 * math.cos(angle - math.pi / 2),
          center.dy + r * 0.8 * math.sin(angle - math.pi / 2)),
      Paint()..color = Colors.red..strokeWidth = 2.5,
    );
    canvas.drawLine(
      center,
      Offset(center.dx + r * 0.8 * math.cos(angle + math.pi / 2),
          center.dy + r * 0.8 * math.sin(angle + math.pi / 2)),
      Paint()..color = Colors.black..strokeWidth = 2.5,
    );
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(XaritaCardPainter old) => old.anim != anim;
}

// ── 3. MathZuma — Matematik sharlar ────────────────────────────────────────
class MathZumaCardPainter extends CustomPainter {
  final double anim;
  const MathZumaCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Qora-binafsha fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF311B92)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Sharlar zanjiri
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFFFFB300),
      const Color(0xFF8E24AA),
      const Color(0xFF00897B),
    ];
    final labels = ['+', '×', '−', '÷', '²', '√'];

    final cx = w * 0.5;
    final cy = h * 0.5;
    final radius = math.min(w, h) * 0.32;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + anim * 0.4;
      final bx = cx + radius * math.cos(angle);
      final by = cy + radius * math.sin(angle);
      final r = 18.0;

      canvas.drawCircle(
        Offset(bx, by), r,
        Paint()..color = colors[i].withOpacity(0.9),
      );
      canvas.drawCircle(
        Offset(bx - r * 0.25, by - r * 0.25), r * 0.35,
        Paint()..color = Colors.white.withOpacity(0.3),
      );

      // Belgi
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(bx - tp.width / 2, by - tp.height / 2));
    }

    // Markazda "MATH" yozuvi
    final tp = TextPainter(
      text: const TextSpan(
        text: 'MATH',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(MathZumaCardPainter old) => old.anim != anim;
}

// ── 4. Runner — Yuguruvchi qahramonlar ─────────────────────────────────────
class RunnerCardPainter extends CustomPainter {
  final double anim;
  const RunnerCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradiyent fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Zamin
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()..color = const Color(0xFF2E7D32),
    );

    // Yo'l chiziqlari
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(0, h * (0.80 + i * 0.06)),
        Offset(w, h * (0.80 + i * 0.06)),
        linePaint,
      );
    }

    // Platformalar
    final platform = Paint()..color = const Color(0xFF4CAF50);
    final platformPositions = [
      Rect.fromLTWH(w * 0.1 - anim * 50 % (w * 0.4), h * 0.60, w * 0.2, 8),
      Rect.fromLTWH(w * 0.5 - anim * 50 % (w * 0.4), h * 0.50, w * 0.2, 8),
    ];
    for (final r in platformPositions) {
      if (r.left >= 0 && r.right <= w) {
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), platform);
      }
    }

    // Yuguruvchi
    _drawRunner(canvas, Offset(w * 0.3, h * 0.70), anim);

    // Yulduzlar
    for (int i = 0; i < 3; i++) {
      final x = w * (0.5 + i * 0.15) - anim * 30 % w;
      if (x > 0 && x < w) {
        _drawStar(canvas, Offset(x, h * 0.25), 8, const Color(0xFFFFD54F));
      }
    }
  }

  void _drawRunner(Canvas canvas, Offset pos, double anim) {
    final col = Paint()..color = const Color(0xFFFF5722);
    final skin = Paint()..color = const Color(0xFFFFCCBC);
    final legAngle = math.sin(anim * 8) * 0.4;

    // Oyoqlar
    canvas.drawLine(
      Offset(pos.dx, pos.dy + 10),
      Offset(pos.dx - 6 * math.cos(legAngle), pos.dy + 22),
      col..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy + 10),
      Offset(pos.dx + 6 * math.cos(legAngle), pos.dy + 22),
      col..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
    // Tana
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 2), width: 14, height: 18),
      col,
    );
    // Bosh
    canvas.drawCircle(Offset(pos.dx, pos.dy - 8), 8, skin);
    // Qo'llar
    final armAngle = math.sin(anim * 8 + math.pi) * 0.5;
    canvas.drawLine(
      Offset(pos.dx, pos.dy),
      Offset(pos.dx - 10 * math.cos(armAngle), pos.dy + 8 * math.sin(armAngle) + 2),
      col..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy),
      Offset(pos.dx + 10 * math.cos(armAngle), pos.dy - 8 * math.sin(armAngle) + 2),
      col..strokeWidth = 3,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = i * 2 * math.pi / 5 - math.pi / 2;
      final innerA = (i + 0.5) * 2 * math.pi / 5 - math.pi / 2;
      final x1 = center.dx + r * math.cos(outerA);
      final y1 = center.dy + r * math.sin(outerA);
      final x2 = center.dx + r * 0.4 * math.cos(innerA);
      final y2 = center.dy + r * 0.4 * math.sin(innerA);
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(RunnerCardPainter old) => old.anim != anim;
}

// ── 5. Car Race — Mashina poygasi ──────────────────────────────────────────
class CarRaceCardPainter extends CustomPainter {
  final double anim;
  const CarRaceCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Asfalt fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF37474F),
    );

    // Yo'l belgilari
    final markPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;
    for (int i = 0; i < 6; i++) {
      final x = (i * w / 5 - anim * 60 % (w / 5));
      canvas.drawLine(
        Offset(x, h * 0.48), Offset(x + w * 0.08, h * 0.48),
        markPaint,
      );
    }

    // Gilyam (checkered pattern — start/finish)
    _drawCheckerboard(canvas, Offset(w * 0.85, h * 0.3), 20, 20);

    // Mashina 1 — qizil
    _drawCar(canvas, Offset(w * 0.3 + anim * 20 % (w * 0.4), h * 0.38),
        const Color(0xFFE53935));

    // Mashina 2 — ko'k
    _drawCar(canvas, Offset(w * 0.1 + anim * 15 % (w * 0.4), h * 0.56),
        const Color(0xFF1565C0));
  }

  void _drawCar(Canvas canvas, Offset pos, Color color) {
    final body = Paint()..color = color;
    final wheel = Paint()..color = Colors.black;
    final glass = Paint()..color = const Color(0xFF90CAF9).withOpacity(0.7);

    // Tana
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 36, height: 14),
        const Radius.circular(4),
      ),
      body,
    );
    // Kabina
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 10, pos.dy - 15, 20, 10),
        const Radius.circular(3),
      ),
      body,
    );
    // Shisha
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 8, pos.dy - 14, 16, 8),
        const Radius.circular(2),
      ),
      glass,
    );
    // G'ildiraklar
    for (final dx in [-12.0, 12.0]) {
      canvas.drawCircle(Offset(pos.dx + dx, pos.dy + 7), 5, wheel);
      canvas.drawCircle(Offset(pos.dx + dx, pos.dy + 7), 2.5,
          Paint()..color = Colors.grey);
    }
  }

  void _drawCheckerboard(Canvas canvas, Offset topLeft, double w, double h) {
    final cellW = w / 4;
    final cellH = h / 4;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final color = (r + c) % 2 == 0 ? Colors.white : Colors.black;
        canvas.drawRect(
          Rect.fromLTWH(topLeft.dx + c * cellW, topLeft.dy + r * cellH, cellW, cellH),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CarRaceCardPainter old) => old.anim != anim;
}

// ── 6. Bubble Shoot — Pufaklar ─────────────────────────────────────────────
class BubbleCardPainter extends CustomPainter {
  final double anim;
  const BubbleCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradiyent fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Pufaklar
    final bubbleColors = [
      const Color(0xFFE53935),
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFFFFB300),
      const Color(0xFFAB47BC),
      const Color(0xFF00ACC1),
    ];
    final rng = math.Random(123);
    for (int i = 0; i < 15; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.75 + math.sin(anim + i) * 5;
      final r = 14.0 + rng.nextDouble() * 10;
      final col = bubbleColors[i % bubbleColors.length];

      // Pufak
      canvas.drawCircle(Offset(x, y), r, Paint()..color = col.withOpacity(0.85));
      // Oydinlik
      canvas.drawCircle(
        Offset(x - r * 0.3, y - r * 0.3), r * 0.35,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }

    // Pastda otuvchi
    _drawShooter(canvas, Offset(w * 0.5, h * 0.9));
  }

  void _drawShooter(Canvas canvas, Offset pos) {
    // Maxsus ramka
    canvas.drawCircle(pos, 15, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(pos, 15,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(pos, 7, Paint()..color = Colors.white);
    // Nishon
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 15),
      Offset(pos.dx, pos.dy - 35),
      Paint()..color = Colors.white..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(BubbleCardPainter old) => old.anim != anim;
}

// ── 7. GeoMap — Geografiya xaritasi ────────────────────────────────────────
class GeoMapCardPainter extends CustomPainter {
  final double anim;
  const GeoMapCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ko'k fon (okean)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF1565C0),
    );

    // Geografiya chiziqlari
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(w * i / 5, 0), Offset(w * i / 5, h), gridPaint);
      canvas.drawLine(Offset(0, h * i / 5), Offset(w, h * i / 5), gridPaint);
    }

    // O'zbekiston xaritasi (taxminiy ko'rinish)
    final land = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.85);
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final uzPath = Path()
      ..moveTo(w * 0.3, h * 0.3)
      ..lineTo(w * 0.55, h * 0.25)
      ..lineTo(w * 0.75, h * 0.35)
      ..lineTo(w * 0.70, h * 0.55)
      ..lineTo(w * 0.55, h * 0.65)
      ..lineTo(w * 0.35, h * 0.60)
      ..lineTo(w * 0.20, h * 0.50)
      ..lineTo(w * 0.25, h * 0.38)
      ..close();
    canvas.drawPath(uzPath, land);
    canvas.drawPath(uzPath, borderPaint);

    // Yirik shaharlar
    final cities = [
      {'name': 'T', 'x': 0.52, 'y': 0.42},  // Toshkent
      {'name': 'S', 'x': 0.38, 'y': 0.52},  // Samarqand
      {'name': 'B', 'x': 0.28, 'y': 0.46},  // Buxoro
    ];
    for (final city in cities) {
      final x = w * (city['x'] as double);
      final y = h * (city['y'] as double);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.red);
      final tp = TextPainter(
        text: TextSpan(
          text: city['name'] as String,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - 14));
    }

    // Animatsion "radar" effekt
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.42),
      20 + 10 * math.sin(anim * 2),
      Paint()
        ..color = Colors.white.withOpacity(0.15 + 0.1 * math.sin(anim * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(GeoMapCardPainter old) => old.anim != anim;
}

// ── 8. Tower — Qal'a mudofaasi ─────────────────────────────────────────────
class TowerDefenseCardPainter extends CustomPainter {
  final double anim;
  const TowerDefenseCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tungi osmoni
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A237E)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Yulduzlar
    final rng = math.Random(77);
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.5;
      final alpha = 0.4 + 0.6 * math.sin(anim * 1.5 + i * 0.8);
      canvas.drawCircle(Offset(x, y), 1.2, Paint()..color = Colors.white.withOpacity(alpha));
    }

    // Zamin
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()..color = const Color(0xFF1B5E20),
    );

    // Asosiy qal'a
    _drawTower(canvas, Offset(w * 0.5, h * 0.72), w * 0.14, h * 0.35);

    // Kichik minoralar
    _drawTower(canvas, Offset(w * 0.2, h * 0.78), w * 0.09, h * 0.22);
    _drawTower(canvas, Offset(w * 0.8, h * 0.78), w * 0.09, h * 0.22);

    // O'q (animatsion)
    _drawArrow(canvas, Offset(w * 0.5, h * 0.4), anim);
  }

  void _drawTower(Canvas canvas, Offset base, double width, double towerH) {
    final stone = Paint()..color = const Color(0xFF607D8B);
    final dark = Paint()..color = const Color(0xFF37474F);
    final top = Offset(base.dx, base.dy - towerH);

    // Ustun
    canvas.drawRect(
      Rect.fromLTWH(base.dx - width / 2, base.dy - towerH, width, towerH),
      stone,
    );

    // Jangarg joylar (merlons)
    final merlonW = width / 5;
    for (int i = 0; i < 5; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            base.dx - width / 2 + i * merlonW,
            top.dy - merlonW,
            merlonW,
            merlonW,
          ),
          stone,
        );
      }
    }

    // Devor chiziqlari (tosh ko'rinishi)
    for (int row = 0; row < 4; row++) {
      canvas.drawLine(
        Offset(base.dx - width / 2, base.dy - towerH * (row + 1) / 4),
        Offset(base.dx + width / 2, base.dy - towerH * (row + 1) / 4),
        dark..strokeWidth = 1,
      );
    }

    // Oyna
    canvas.drawCircle(
      Offset(base.dx, base.dy - towerH * 0.5),
      width * 0.2,
      Paint()..color = const Color(0xFFFFB300).withOpacity(0.7),
    );
  }

  void _drawArrow(Canvas canvas, Offset target, double anim) {
    final progress = (anim % 1.0);
    final fromX = 0.0;
    final fromY = target.dy + 20;
    final x = fromX + (target.dx - fromX) * progress;
    final y = fromY + (target.dy - fromY) * progress;

    canvas.drawLine(
      Offset(x - 10, y + 5),
      Offset(x + 5, y - 5),
      Paint()..color = const Color(0xFFFFB300)..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(TowerDefenseCardPainter old) => old.anim != anim;
}

// ── 9. Math Blocks — Matematik bloklar ─────────────────────────────────────
class MathBlocksCardPainter extends CustomPainter {
  final double anim;
  const MathBlocksCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Bloklar
    final blocks = [
      {'x': 0.1, 'y': 0.15, 'label': '7', 'color': const Color(0xFFE53935)},
      {'x': 0.35, 'y': 0.15, 'label': '+', 'color': const Color(0xFF1565C0)},
      {'x': 0.60, 'y': 0.15, 'label': '5', 'color': const Color(0xFF43A047)},
      {'x': 0.85, 'y': 0.15, 'label': '=', 'color': const Color(0xFF6A1B9A)},
      {'x': 0.1, 'y': 0.42, 'label': '12', 'color': const Color(0xFF43A047)},
      {'x': 0.35, 'y': 0.42, 'label': '÷', 'color': const Color(0xFF1565C0)},
      {'x': 0.60, 'y': 0.42, 'label': '3', 'color': const Color(0xFFFFB300)},
      {'x': 0.85, 'y': 0.42, 'label': '?', 'color': const Color(0xFFE53935)},
    ];

    for (final block in blocks) {
      final x = w * (block['x'] as double);
      final y = h * (block['y'] as double);
      final col = block['color'] as Color;

      // Blok soyasi
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 18, y - 18 + 4, 36, 36),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.black26,
      );

      // Blok
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 18, y - 18, 36, 36),
          const Radius.circular(6),
        ),
        Paint()..color = col,
      );

      // Belgi
      final tp = TextPainter(
        text: TextSpan(
          text: block['label'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // Pastda natija ko'rsatgich
    final tp = TextPainter(
      text: TextSpan(
        text: '= ${(4 + anim * 0.1).toInt() % 5 == 0 ? "✓" : "?"}',
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.72));
  }

  @override
  bool shouldRepaint(MathBlocksCardPainter old) => old.anim != anim;
}
