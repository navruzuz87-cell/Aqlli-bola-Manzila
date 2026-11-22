import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ManZila: Aqlli Bola — O'yin karta rasmlari (CustomPainter)
// O'zbek milliy naqsh va qahramonlari asosida
// ═══════════════════════════════════════════════════════════════════════════

// ── 1. Susambil — Matematik sarguzasht ─────────────────────────────────────
class SusambilCardPainter extends CustomPainter {
  final double anim;
  const SusambilCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ko'k osmon gradient
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // Yashil tepalik
    final hill = Paint()..color = const Color(0xFF2E7D32);
    final hillPath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.3, h * 0.45, w * 0.5, h * 0.55)
      ..quadraticBezierTo(w * 0.7, h * 0.65, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillPath, hill);

    // Qishloq uyi (Susambil)
    _drawHouse(canvas, Offset(w * 0.6, h * 0.52), 22, const Color(0xFFE8D5B7));

    // Eshak silueti (Nasriddin's donkey)
    _drawDonkey(canvas, Offset(w * 0.2, h * 0.63), 18);

    // Yulduzlar
    final starPaint = Paint()..color = Colors.yellow.withOpacity(0.9);
    for (int i = 0; i < 3; i++) {
      final x = w * (0.2 + i * 0.3);
      final y = h * 0.12 + math.sin(anim * 2 + i) * 3;
      _drawStar(canvas, Offset(x, y), 7, starPaint);
    }

    // Matematik belgi (+)
    final mathPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.15, h * 0.3), Offset(w * 0.15, h * 0.42), mathPaint);
    canvas.drawLine(Offset(w * 0.09, h * 0.36), Offset(w * 0.21, h * 0.36), mathPaint);
  }

  void _drawHouse(Canvas canvas, Offset center, double size, Color wallColor) {
    // Devor
    final wall = Paint()..color = wallColor;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.3), width: size * 2, height: size * 1.4),
      wall,
    );
    // Tom
    final roof = Paint()..color = const Color(0xFFC62828);
    final roofPath = Path()
      ..moveTo(center.dx - size * 1.3, center.dy + size * 0.1)
      ..lineTo(center.dx, center.dy - size * 0.9)
      ..lineTo(center.dx + size * 1.3, center.dy + size * 0.1)
      ..close();
    canvas.drawPath(roofPath, roof);
    // Eshik
    final door = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.75), width: size * 0.6, height: size * 0.9),
        const Radius.circular(3),
      ),
      door,
    );
  }

  void _drawDonkey(Canvas canvas, Offset pos, double size) {
    final p = Paint()..color = const Color(0xFF795548);
    // Tana
    canvas.drawOval(Rect.fromCenter(center: pos, width: size * 2, height: size), p);
    // Bosh
    canvas.drawCircle(Offset(pos.dx + size, pos.dy - size * 0.2), size * 0.6, p);
    // Quloqlar
    final ear = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(pos.dx + size * 1.3, pos.dy - size * 0.7),
      width: size * 0.25, height: size * 0.6), ear);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(pos.dx + size * 1.0, pos.dy - size * 0.8),
      width: size * 0.25, height: size * 0.6), ear);
    // Oyoqlar
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(pos.dx - size * 0.7 + i * size * 0.5, pos.dy + size * 0.4, size * 0.2, size * 0.6),
        p,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final p = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      final inner = Offset(
        center.dx + r * 0.4 * math.cos(angle + math.pi / 5),
        center.dy + r * 0.4 * math.sin(angle + math.pi / 5),
      );
      if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SusambilCardPainter old) => old.anim != anim;
}

// ── 2. Zumrad — Ona tili ──────────────────────────────────────────────────
class ZumradCardPainter extends CustomPainter {
  const ZumradCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Binafsha gradient fon
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // O'zbek naqsh (girix) — yuqori
    _drawGeometricPattern(canvas, Offset(w * 0.5, h * 0.15), w * 0.8, const Color(0xFFCE93D8).withOpacity(0.3));

    // Kitob
    _drawBook(canvas, Offset(w * 0.5, h * 0.52), w * 0.4);

    // Qalam
    _drawPen(canvas, Offset(w * 0.72, h * 0.4), 28);

    // Harflar: A B C
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.7),
      fontSize: w * 0.14,
      fontWeight: FontWeight.w900,
    );
    _drawText(canvas, 'A', Offset(w * 0.12, h * 0.2), textStyle);
    _drawText(canvas, 'B', Offset(w * 0.72, h * 0.68), textStyle);
  }

  void _drawBook(Canvas canvas, Offset center, double size) {
    // Kitob asosi
    final bookPaint = Paint()..color = const Color(0xFFF3E5F5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size, height: size * 1.1),
        const Radius.circular(6),
      ),
      bookPaint,
    );
    // Muqova
    final cover = Paint()..color = const Color(0xFF9C27B0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - size * 0.5, center.dy - size * 0.55, size * 0.08, size * 1.1),
        const Radius.circular(3),
      ),
      cover,
    );
    // Qatorlar
    final linePaint = Paint()
      ..color = const Color(0xFFCE93D8)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final y = center.dy - size * 0.25 + i * size * 0.18;
      canvas.drawLine(
        Offset(center.dx - size * 0.3, y),
        Offset(center.dx + size * 0.4, y),
        linePaint,
      );
    }
  }

  void _drawPen(Canvas canvas, Offset pos, double size) {
    final penPaint = Paint()..color = const Color(0xFFFFD54F);
    final path = Path()
      ..moveTo(pos.dx, pos.dy - size)
      ..lineTo(pos.dx + size * 0.3, pos.dy - size * 0.8)
      ..lineTo(pos.dx + size * 0.3, pos.dy + size * 0.8)
      ..lineTo(pos.dx - size * 0.3, pos.dy + size * 0.8)
      ..lineTo(pos.dx - size * 0.3, pos.dy - size * 0.8)
      ..close();
    canvas.drawPath(path, penPaint);
    // Uchi
    final tip = Paint()..color = const Color(0xFF37474F);
    final tipPath = Path()
      ..moveTo(pos.dx, pos.dy - size * 1.2)
      ..lineTo(pos.dx - size * 0.15, pos.dy - size)
      ..lineTo(pos.dx + size * 0.15, pos.dy - size)
      ..close();
    canvas.drawPath(tipPath, tip);
  }

  void _drawGeometricPattern(Canvas canvas, Offset center, double width, Color color) {
    final p = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final r = width * 0.08;
    for (int i = -3; i <= 3; i++) {
      final x = center.dx + i * r * 2.5;
      final diamond = Path()
        ..moveTo(x, center.dy - r)
        ..lineTo(x + r, center.dy)
        ..lineTo(x, center.dy + r)
        ..lineTo(x - r, center.dy)
        ..close();
      canvas.drawPath(diamond, p);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(ZumradCardPainter old) => false;
}

// ── 3. Shiroq — Tarix o'yini ───────────────────────────────────────────────
class ShiroqCardPainter extends CustomPainter {
  const ShiroqCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Qizil-jigarrang gradient — qadim davr
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF7F0000), const Color(0xFFC62828)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Samarqand gumbazi
    _drawDome(canvas, Offset(w * 0.5, h * 0.45), w * 0.35);

    // Minora
    _drawMinaret(canvas, Offset(w * 0.2, h * 0.5), 12, h * 0.45);
    _drawMinaret(canvas, Offset(w * 0.8, h * 0.5), 12, h * 0.45);

    // Quyosh
    final sunPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), 14, sunPaint);

    // Qum tepasi (cho'l)
    final sand = Paint()..color = const Color(0xFFD7CCC8);
    final sandPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.25, h * 0.68, w * 0.5, h * 0.75)
      ..quadraticBezierTo(w * 0.75, h * 0.82, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(sandPath, sand);
  }

  void _drawDome(Canvas canvas, Offset center, double r) {
    final tilePaint = Paint()..color = const Color(0xFF1565C0);
    final domePath = Path()
      ..moveTo(center.dx - r, center.dy + r * 0.3)
      ..quadraticBezierTo(center.dx - r, center.dy - r, center.dx, center.dy - r * 1.1)
      ..quadraticBezierTo(center.dx + r, center.dy - r, center.dx + r, center.dy + r * 0.3)
      ..close();
    canvas.drawPath(domePath, tilePaint);
    // Naqsh
    final linePaint = Paint()..color = const Color(0xFF42A5F5).withOpacity(0.5)..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: r * 1.5, height: r * 1.5),
      math.pi, math.pi, false, linePaint,
    );
    // Ustun
    final wall = Paint()..color = const Color(0xFFE8D5B7);
    canvas.drawRect(
      Rect.fromLTWH(center.dx - r, center.dy + r * 0.3, r * 2, h * 0.3),
      wall,
    );
  }

  void _drawMinaret(Canvas canvas, Offset base, double r, double height) {
    final p = Paint()..color = const Color(0xFFE8D5B7);
    canvas.drawRect(Rect.fromLTWH(base.dx - r / 2, base.dy - height, r, height), p);
    // Tepa
    final top = Paint()..color = const Color(0xFF1565C0);
    final topPath = Path()
      ..moveTo(base.dx, base.dy - height - r * 1.5)
      ..lineTo(base.dx - r * 0.6, base.dy - height)
      ..lineTo(base.dx + r * 0.6, base.dy - height)
      ..close();
    canvas.drawPath(topPath, top);
  }

  double get h => 200; // approx

  @override
  bool shouldRepaint(ShiroqCardPainter old) => false;
}

// ── 4. Alpomish — Geografiya ──────────────────────────────────────────────
class AlpomishCardPainter extends CustomPainter {
  const AlpomishCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Moviy gradient — osmon
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // Tog' siluelti
    _drawMountains(canvas, size);

    // Yoy va o'q
    _drawBowAndArrow(canvas, Offset(w * 0.3, h * 0.5), 30);

    // O'zbek xaritasi sharti (oddiy shakl)
    _drawMapOutline(canvas, Offset(w * 0.65, h * 0.35), 25);
  }

  void _drawMountains(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final snowPaint = Paint()..color = Colors.white;
    final rockPaint = Paint()..color = const Color(0xFF37474F);

    final peaks = [
      [0.0, 0.7, 0.2, 0.3, 0.4, 0.65],
      [0.3, 0.75, 0.55, 0.25, 0.75, 0.6],
      [0.65, 0.8, 0.82, 0.35, 1.0, 0.72],
    ];

    for (final peak in peaks) {
      final path = Path()
        ..moveTo(w * peak[0], h * peak[1])
        ..lineTo(w * peak[2], h * peak[3])
        ..lineTo(w * peak[4], h * peak[5])
        ..close();
      canvas.drawPath(path, rockPaint);
      // Qor
      final snowPath = Path()
        ..moveTo(w * peak[2], h * peak[3])
        ..lineTo(w * (peak[2] - 0.06), h * (peak[3] + 0.1))
        ..lineTo(w * (peak[2] + 0.06), h * (peak[3] + 0.1))
        ..close();
      canvas.drawPath(snowPath, snowPaint);
    }

    // Yashil o't
    final grass = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), grass);
  }

  void _drawBowAndArrow(Canvas canvas, Offset center, double size) {
    final bow = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size * 1.5, height: size * 2),
      -math.pi * 0.7, math.pi * 1.4, false, bow,
    );
    // O'q
    final arrow = Paint()
      ..color = const Color(0xFFFFB300)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - size * 0.3, center.dy),
      Offset(center.dx + size * 0.9, center.dy),
      arrow,
    );
  }

  void _drawMapOutline(Canvas canvas, Offset center, double size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // O'zbekiston shakliga o'xshash oddiy shape
    final path = Path()
      ..moveTo(center.dx - size, center.dy + size * 0.2)
      ..lineTo(center.dx - size * 0.5, center.dy - size * 0.8)
      ..lineTo(center.dx + size * 0.3, center.dy - size)
      ..lineTo(center.dx + size, center.dy - size * 0.3)
      ..lineTo(center.dx + size * 0.8, center.dy + size * 0.5)
      ..lineTo(center.dx, center.dy + size * 0.9)
      ..close();
    canvas.drawPath(path, p);
    // Markazda nuqta
    canvas.drawCircle(center, 4, Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(AlpomishCardPainter old) => false;
}

// ── 5. Tumarisxon — Ingliz tili ───────────────────────────────────────────
class TumarisxonCardPainter extends CustomPainter {
  const TumarisxonCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Zangori-yashil gradient
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF004D40), const Color(0xFF00695C)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Ingliz va O'zbek bayroq elementlari
    _drawFlag(canvas, Offset(w * 0.5, h * 0.3), w * 0.5, h * 0.25);

    // "ABC" harflari
    final letters = ['A', 'B', 'C'];
    for (int i = 0; i < letters.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: w * 0.18,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(w * (0.1 + i * 0.3), h * 0.6));
    }

    // Globus chizigi
    final globe = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w * 0.8, h * 0.75), 20, globe);
    canvas.drawLine(Offset(w * 0.8, h * 0.75 - 20), Offset(w * 0.8, h * 0.75 + 20), globe);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.8, h * 0.75), width: 40, height: 20),
        0, math.pi * 2, false, globe);
  }

  void _drawFlag(Canvas canvas, Offset center, double w, double h) {
    // O'zbek bayrog'i ranglari
    final colors = [const Color(0xFF1565C0), const Color(0xFFFFFFFF), const Color(0xFF2E7D32)];
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(center.dx - w / 2, center.dy - h / 2 + i * h / 3, w, h / 3),
        Paint()..color = colors[i].withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(TumarisxonCardPainter old) => false;
}

// ── 6. Avazxon — Odobnoma ─────────────────────────────────────────────────
class AvazxonCardPainter extends CustomPainter {
  const AvazxonCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Issiq to'q sariq gradient
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFBF360C), const Color(0xFFE64A19)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Qo'l siqish (do'stlik belgisi)
    _drawHandshake(canvas, Offset(w * 0.5, h * 0.4), 35);

    // Yurak
    _drawHeart(canvas, Offset(w * 0.5, h * 0.72), 15, const Color(0xFFFFCDD2));

    // Naqsh gullari
    _drawFlower(canvas, Offset(w * 0.1, h * 0.15), 12);
    _drawFlower(canvas, Offset(w * 0.9, h * 0.8), 10);
  }

  void _drawHandshake(Canvas canvas, Offset center, double size) {
    final p = Paint()..color = const Color(0xFFFFCCBC);
    // Chap qo'l
    final leftHand = Path()
      ..moveTo(center.dx - size, center.dy)
      ..lineTo(center.dx - size * 0.1, center.dy - size * 0.3)
      ..lineTo(center.dx + size * 0.3, center.dy)
      ..lineTo(center.dx - size * 0.1, center.dy + size * 0.3)
      ..close();
    // O'ng qo'l
    final rightHand = Path()
      ..moveTo(center.dx + size, center.dy)
      ..lineTo(center.dx + size * 0.1, center.dy - size * 0.3)
      ..lineTo(center.dx - size * 0.3, center.dy)
      ..lineTo(center.dx + size * 0.1, center.dy + size * 0.3)
      ..close();
    canvas.drawPath(leftHand, p);
    canvas.drawPath(rightHand, p);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final p = Paint()..color = color;
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.5)
      ..cubicTo(center.dx - size * 1.5, center.dy - size * 0.5,
          center.dx - size * 1.5, center.dy - size * 1.5, center.dx, center.dy - size * 0.5)
      ..cubicTo(center.dx + size * 1.5, center.dy - size * 1.5,
          center.dx + size * 1.5, center.dy - size * 0.5, center.dx, center.dy + size * 0.5);
    canvas.drawPath(path, p);
  }

  void _drawFlower(Canvas canvas, Offset center, double r) {
    final petal = Paint()..color = const Color(0xFFFFE0B2).withOpacity(0.5);
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)),
        r * 0.6,
        petal,
      );
    }
    canvas.drawCircle(center, r * 0.4, Paint()..color = const Color(0xFFFFB300));
  }

  @override
  bool shouldRepaint(AvazxonCardPainter old) => false;
}

// ── 7. Archery — Yoy o'yini ───────────────────────────────────────────────
class ArcheryCardPainter extends CustomPainter {
  final double anim;
  const ArcheryCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Nishon (target)
    _drawTarget(canvas, Offset(w * 0.65, h * 0.4), 32);

    // O'q (harakat animatsiyasi)
    final arrowX = w * 0.1 + anim * w * 0.4;
    _drawArrow(canvas, Offset(arrowX, h * 0.4), 25);

    // Qo'riq yashil maydon
    final ground = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), ground);
  }

  void _drawTarget(Canvas canvas, Offset center, double r) {
    final colors = [
      const Color(0xFFF44336),
      Colors.white,
      const Color(0xFFF44336),
      Colors.white,
      const Color(0xFFFFD700),
    ];
    for (int i = colors.length - 1; i >= 0; i--) {
      canvas.drawCircle(center, r * (i + 1) / colors.length, Paint()..color = colors[i]);
    }
  }

  void _drawArrow(Canvas canvas, Offset tip, double length) {
    final shaft = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tip, Offset(tip.dx - length, tip.dy), shaft);
    // Uchi
    final head = Paint()..color = const Color(0xFF607D8B);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 8, tip.dy - 5)
      ..lineTo(tip.dx - 8, tip.dy + 5)
      ..close();
    canvas.drawPath(path, head);
  }

  @override
  bool shouldRepaint(ArcheryCardPainter old) => old.anim != anim;
}

// ── 8. Wordle — So'z o'yini ───────────────────────────────────────────────
class WordleCardPainter extends CustomPainter {
  const WordleCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Yashil gradient
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF1B5E20), const Color(0xFF388E3C)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Wordle katakchalar
    final letters = ['K', 'I', 'T', 'O', 'B'];
    final colors = [
      const Color(0xFF388E3C),
      const Color(0xFFFFB300),
      const Color(0xFF388E3C),
      Colors.grey,
      const Color(0xFF388E3C),
    ];
    final cellSize = w * 0.14;
    final startX = w * 0.5 - cellSize * 2.5 - 4;
    for (int i = 0; i < letters.length; i++) {
      final x = startX + i * (cellSize + 4);
      final y = h * 0.38;
      // Hujayra
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          const Radius.circular(4),
        ),
        Paint()..color = colors[i],
      );
      // Harf
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: cellSize * 0.6,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + cellSize * 0.5 - tp.width / 2, y + cellSize * 0.5 - tp.height / 2));
    }

    // Bo'sh kataklar (keyingi qator)
    for (int i = 0; i < 5; i++) {
      final x = startX + i * (cellSize + 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h * 0.57, cellSize, cellSize),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h * 0.57, cellSize, cellSize),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(WordleCardPainter old) => false;
}

// ── 9. Semurg — Uchish o'yini ─────────────────────────────────────────────
class SemurgCardPainter extends CustomPainter {
  final double anim;
  const SemurgCardPainter({this.anim = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // To'q sariq-to'q qizil gradient
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFE65100), const Color(0xFFFF7043)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Bulutlar
    _drawCloud(canvas, Offset(w * 0.2, h * 0.2 + math.sin(anim) * 3), 20, Colors.white.withOpacity(0.4));
    _drawCloud(canvas, Offset(w * 0.8, h * 0.35 + math.cos(anim) * 2), 15, Colors.white.withOpacity(0.3));

    // Semurg (afsonaviy qush)
    _drawSemurg(canvas, Offset(w * 0.5, h * 0.45 + math.sin(anim * 1.5) * 4), w * 0.5);
  }

  void _drawSemurg(Canvas canvas, Offset center, double size) {
    // Tana
    final body = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.5, height: size * 0.25),
      body,
    );
    // Qanotlar (animatsiyalangan)
    final wingAngle = math.sin(anim * 3) * 0.3;
    _drawWing(canvas, center, size, wingAngle, true);
    _drawWing(canvas, center, size, wingAngle, false);

    // Bosh
    final head = Paint()..color = const Color(0xFFFF8F00);
    canvas.drawCircle(Offset(center.dx + size * 0.28, center.dy - size * 0.05), size * 0.12, head);

    // Toj (patlari)
    final crownPaint = Paint()..color = const Color(0xFFFF6F00);
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(center.dx + size * 0.28, center.dy - size * 0.15),
        Offset(center.dx + size * (0.2 + i * 0.08), center.dy - size * 0.3),
        crownPaint..strokeWidth = 2,
      );
    }
  }

  void _drawWing(Canvas canvas, Offset center, double size, double angle, bool left) {
    final sign = left ? -1.0 : 1.0;
    final wingPaint = Paint()..color = const Color(0xFFFF8F00);
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx + sign * size * 0.3,
        center.dy - size * 0.15 + angle * size * 0.2,
        center.dx + sign * size * 0.5,
        center.dy - size * 0.05,
      )
      ..quadraticBezierTo(
        center.dx + sign * size * 0.35,
        center.dy + size * 0.1,
        center.dx,
        center.dy,
      );
    canvas.drawPath(path, wingPaint);
    // Pat uchlari
    final feather = Paint()..color = const Color(0xFFFFCC02)..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final t = 0.4 + i * 0.15;
      canvas.drawLine(
        Offset(center.dx + sign * size * t, center.dy - size * 0.05),
        Offset(center.dx + sign * size * t, center.dy - size * 0.18),
        feather,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(center, r, p);
    canvas.drawCircle(Offset(center.dx + r * 0.8, center.dy + r * 0.1), r * 0.75, p);
    canvas.drawCircle(Offset(center.dx - r * 0.6, center.dy + r * 0.2), r * 0.6, p);
    canvas.drawRect(
      Rect.fromLTWH(center.dx - r * 0.6, center.dy, r * 2, r * 0.5),
      p,
    );
  }

  @override
  bool shouldRepaint(SemurgCardPainter old) => old.anim != anim;
}

// ── 10. Qal'a (Fortress) — Spitamen ──────────────────────────────────────
class FortressCardPainter extends CustomPainter {
  const FortressCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // To'q binafsha
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Qal'a devori
    _drawFortress(canvas, size);

    // Oy va yulduzlar
    final moonPaint = Paint()..color = const Color(0xFFFFECB3);
    canvas.drawCircle(Offset(w * 0.8, h * 0.15), 15, moonPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.12), 10, bg);
  }

  void _drawFortress(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wall = Paint()..color = const Color(0xFF8D6E63);

    // Asosiy devor
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.5, w * 0.8, h * 0.5), wall);

    // Minoralar
    final towerPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.35, w * 0.2, h * 0.3), towerPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.2, h * 0.3), towerPaint);

    // Minora tepalari (mazluma)
    final crownPaint = Paint()..color = const Color(0xFF5D4037);
    for (final x in [w * 0.05, w * 0.75]) {
      for (int i = 0; i < 4; i++) {
        canvas.drawRect(
          Rect.fromLTWH(x + i * w * 0.05, h * 0.3, w * 0.03, h * 0.07),
          crownPaint,
        );
      }
    }

    // Devor tishchalari
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.1 + i * w * 0.1, h * 0.44, w * 0.06, h * 0.08),
        towerPaint,
      );
    }

    // Darvoza
    final gate = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.4, h * 0.6, w * 0.2, h * 0.4),
        const Radius.circular(50),
      ),
      gate,
    );
  }

  @override
  bool shouldRepaint(FortressCardPainter old) => false;
}

// ── Widget: AnimatedGameCard ───────────────────────────────────────────────
// Barcha o'yin kartalari uchun animatsiyali wrapper
class AnimatedGameCardPainter extends StatefulWidget {
  final CustomPainter Function(double anim) painterBuilder;
  final bool animated;

  const AnimatedGameCardPainter({
    super.key,
    required this.painterBuilder,
    this.animated = false,
  });

  @override
  State<AnimatedGameCardPainter> createState() => _AnimatedGameCardPainterState();
}

class _AnimatedGameCardPainterState extends State<AnimatedGameCardPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animated) {
      return CustomPaint(painter: widget.painterBuilder(0));
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: widget.painterBuilder(_ctrl.value * 2 * math.pi),
      ),
    );
  }
}
