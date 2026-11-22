import 'dart:math' as math;
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// SusambilScenePainter — 4 bosqichli sarguzasht uchun sahna rasmi
// O'zbek qishlog'i, tepaliklar, Susambil uyi, osmonu yulduzlar
// ════════════════════════════════════════════════════════════════════════════

class SusambilScenePainter extends CustomPainter {
  final int stage;         // 0-3: bosqich raqami
  final double animValue;  // 0.0–1.0: animatsiya holati
  final bool isDay;        // kun/kecha

  const SusambilScenePainter({
    this.stage = 0,
    this.animValue = 0,
    this.isDay = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Fon: osmon ───────────────────────────────────────────────────────
    _drawSky(canvas, size);

    // ── Quyosh yoki oy ───────────────────────────────────────────────────
    if (isDay) {
      _drawSun(canvas, Offset(w * 0.85, h * 0.12), animValue);
    } else {
      _drawMoon(canvas, Offset(w * 0.8, h * 0.1));
      _drawStars(canvas, size, animValue);
    }

    // ── Tog'lar (orqa fon) ────────────────────────────────────────────────
    _drawMountains(canvas, size);

    // ── Tepaliklar ────────────────────────────────────────────────────────
    _drawHills(canvas, size, stage);

    // ── Daryocha (bosqich 2+) ─────────────────────────────────────────────
    if (stage >= 1) {
      _drawRiver(canvas, size, animValue);
    }

    // ── Daraxtlar ─────────────────────────────────────────────────────────
    _drawTrees(canvas, size);

    // ── Susambil uyi ──────────────────────────────────────────────────────
    _drawSusambilHouse(canvas, Offset(w * 0.65, h * 0.58), w * 0.28);

    // ── Yo'l ──────────────────────────────────────────────────────────────
    _drawPath(canvas, size);

    // ── Bosqichga qarab qo'shimcha elementlar ─────────────────────────────
    _drawStageElements(canvas, size, stage, animValue);
  }

  // ── Osmon ──────────────────────────────────────────────────────────────
  void _drawSky(Canvas canvas, Size size) {
    final colors = isDay
        ? [const Color(0xFF1565C0), const Color(0xFF42A5F5), const Color(0xFF90CAF9)]
        : [const Color(0xFF0D1B2A), const Color(0xFF1A237E), const Color(0xFF283593)];
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.65));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.65), sky);
  }

  // ── Quyosh ─────────────────────────────────────────────────────────────
  void _drawSun(Canvas canvas, Offset center, double anim) {
    // Nurlari
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.5)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + anim * 0.3;
      final inner = 18.0;
      final outer = 28.0 + math.sin(anim * 2 + i) * 3;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle)),
        rayPaint,
      );
    }
    // Quyosh
    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFFFFB300));
  }

  // ── Oy ─────────────────────────────────────────────────────────────────
  void _drawMoon(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFFFFECB3));
    canvas.drawCircle(Offset(center.dx + 6, center.dy - 4), 12,
        Paint()..color = const Color(0xFF1A237E));
  }

  // ── Yulduzlar ──────────────────────────────────────────────────────────
  void _drawStars(Canvas canvas, Size size, double anim) {
    final rng = math.Random(42);
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.5;
      final r = 1.0 + rng.nextDouble() * 2;
      final alpha = 0.5 + 0.5 * math.sin(anim * 2 + i * 0.7);
      canvas.drawCircle(Offset(x, y), r, starPaint..color = Colors.white.withOpacity(alpha));
    }
  }

  // ── Tog'lar ────────────────────────────────────────────────────────────
  void _drawMountains(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rock = Paint()..color = const Color(0xFF4A6741);
    final snow = Paint()..color = Colors.white.withOpacity(0.9);

    final peaks = [
      {'x': 0.0, 'base': 0.68, 'peak': 0.28},
      {'x': 0.25, 'base': 0.72, 'peak': 0.22},
      {'x': 0.55, 'base': 0.70, 'peak': 0.30},
      {'x': 0.80, 'base': 0.68, 'peak': 0.25},
    ];

    for (final peak in peaks) {
      final px = w * (peak['x']! + 0.15);
      final py = h * peak['peak']!;
      final bLeft = w * peak['x']!;
      final bRight = w * (peak['x']! + 0.3);
      final by = h * peak['base']!;

      final path = Path()
        ..moveTo(bLeft, by)
        ..lineTo(px, py)
        ..lineTo(bRight, by)
        ..close();
      canvas.drawPath(path, rock);

      // Qor
      final snowPath = Path()
        ..moveTo(px, py)
        ..lineTo(px - w * 0.04, py + h * 0.08)
        ..lineTo(px + w * 0.04, py + h * 0.08)
        ..close();
      canvas.drawPath(snowPath, snow);
    }
  }

  // ── Tepaliklar ─────────────────────────────────────────────────────────
  void _drawHills(Canvas canvas, Size size, int stage) {
    final w = size.width;
    final h = size.height;

    // Orqa tepalik
    final backHill = Paint()..color = const Color(0xFF388E3C);
    final backPath = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.2, h * 0.56, w * 0.4, h * 0.64)
      ..quadraticBezierTo(w * 0.6, h * 0.72, w * 0.8, h * 0.60)
      ..quadraticBezierTo(w * 0.9, h * 0.56, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backPath, backHill);

    // Old tepalik (bosqichga qarab rang o'zgaradi)
    final frontColors = [
      const Color(0xFF2E7D32), // 0: bahor
      const Color(0xFF1B5E20), // 1: yoz
      const Color(0xFF827717), // 2: kuz
      const Color(0xFF4CAF50), // 3: bahor qayta
    ];
    final frontHill = Paint()..color = frontColors[stage.clamp(0, 3)];
    final frontPath = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.15, h * 0.74, w * 0.3, h * 0.78)
      ..quadraticBezierTo(w * 0.5, h * 0.84, w * 0.7, h * 0.76)
      ..quadraticBezierTo(w * 0.85, h * 0.72, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontPath, frontHill);
  }

  // ── Daryocha ───────────────────────────────────────────────────────────
  void _drawRiver(Canvas canvas, Size size, double anim) {
    final w = size.width;
    final h = size.height;
    final river = Paint()
      ..color = const Color(0xFF29B6F6).withOpacity(0.7)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.1, h * 0.78)
      ..quadraticBezierTo(
        w * 0.3 + math.sin(anim) * 5, h * 0.74,
        w * 0.55, h * 0.80,
      )
      ..quadraticBezierTo(w * 0.75, h * 0.84, w * 0.9, h * 0.78);
    canvas.drawPath(path, river);
  }

  // ── Daraxtlar ──────────────────────────────────────────────────────────
  void _drawTrees(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final treePositions = [
      Offset(w * 0.08, h * 0.70),
      Offset(w * 0.18, h * 0.72),
      Offset(w * 0.88, h * 0.69),
      Offset(w * 0.78, h * 0.71),
    ];
    for (final pos in treePositions) {
      _drawTree(canvas, pos, 18);
    }
  }

  void _drawTree(Canvas canvas, Offset base, double size) {
    // Tanasi
    final trunk = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromLTWH(base.dx - size * 0.15, base.dy - size * 0.5, size * 0.3, size * 0.5),
      trunk,
    );
    // Bayrogi (uchburchak)
    final leaf = Paint()..color = const Color(0xFF1B5E20);
    for (int i = 0; i < 3; i++) {
      final top = base.dy - size * (1.0 + i * 0.4);
      final w2 = size * (0.8 - i * 0.15);
      final path = Path()
        ..moveTo(base.dx, top - size * 0.5)
        ..lineTo(base.dx - w2, base.dy - size * (0.5 + i * 0.3))
        ..lineTo(base.dx + w2, base.dy - size * (0.5 + i * 0.3))
        ..close();
      canvas.drawPath(path, leaf..color = Color.lerp(
        const Color(0xFF2E7D32), const Color(0xFF1B5E20), i * 0.3)!);
    }
  }

  // ── Susambil uyi ───────────────────────────────────────────────────────
  void _drawSusambilHouse(Canvas canvas, Offset center, double size) {
    // Devor
    final wall = Paint()..color = const Color(0xFFF5E6C8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.2), width: size, height: size * 0.9),
        const Radius.circular(4),
      ),
      wall,
    );

    // Tom
    final roof = Paint()..color = const Color(0xFFC62828);
    final roofPath = Path()
      ..moveTo(center.dx - size * 0.65, center.dy)
      ..lineTo(center.dx, center.dy - size * 0.55)
      ..lineTo(center.dx + size * 0.65, center.dy)
      ..close();
    canvas.drawPath(roofPath, roof);

    // Tom naqshi
    final roofLine = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - size * 0.5, center.dy - size * 0.15),
      Offset(center.dx, center.dy - size * 0.5),
      roofLine,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.5),
      Offset(center.dx + size * 0.5, center.dy - size * 0.15),
      roofLine,
    );

    // Darvoza
    final door = Paint()..color = const Color(0xFF795548);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size * 0.42),
          width: size * 0.3, height: size * 0.5,
        ),
        const Radius.circular(size * 0.08),
      ),
      door,
    );

    // Derazalar
    final window = Paint()..color = const Color(0xFFB3E5FC);
    final windowBorder = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final dx in [-0.22, 0.22]) {
      final wr = Rect.fromCenter(
        center: Offset(center.dx + size * dx, center.dy + size * 0.1),
        width: size * 0.2, height: size * 0.2,
      );
      canvas.drawRect(wr, window);
      canvas.drawRect(wr, windowBorder);
    }

    // Baca (tutun)
    final chimney = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromLTWH(center.dx + size * 0.2, center.dy - size * 0.4, size * 0.1, size * 0.25),
      chimney,
    );
  }

  // ── Yo'l ───────────────────────────────────────────────────────────────
  void _drawPath(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadPath = Path()
      ..moveTo(w * 0.5, h)
      ..quadraticBezierTo(w * 0.52, h * 0.88, w * 0.62, h * 0.75);
    canvas.drawPath(roadPath, path);
  }

  // ── Bosqichga mos elementlar ───────────────────────────────────────────
  void _drawStageElements(Canvas canvas, Size size, int stage, double anim) {
    final w = size.width;
    final h = size.height;

    switch (stage) {
      case 0:
        // 1-bosqich: Bahor — gullar
        _drawFlowers(canvas, Offset(w * 0.2, h * 0.84), 5);
        _drawFlowers(canvas, Offset(w * 0.75, h * 0.86), 4);
        break;
      case 1:
        // 2-bosqich: Ko'prik
        _drawBridge(canvas, Offset(w * 0.4, h * 0.80), w * 0.25);
        break;
      case 2:
        // 3-bosqich: Bozor
        _drawMarketStall(canvas, Offset(w * 0.2, h * 0.74), w * 0.18);
        break;
      case 3:
        // 4-bosqich: Tantana — bayroqlar
        _drawFlags(canvas, size, anim);
        break;
    }
  }

  void _drawFlowers(Canvas canvas, Offset center, int count) {
    final colors = [Colors.red, Colors.yellow, Colors.pink, Colors.orange, Colors.purple];
    for (int i = 0; i < count; i++) {
      final x = center.dx + i * 12.0;
      final petal = Paint()..color = colors[i % colors.length].withOpacity(0.9);
      for (int j = 0; j < 5; j++) {
        final angle = j * 2 * math.pi / 5;
        canvas.drawCircle(
          Offset(x + 4 * math.cos(angle), center.dy + 4 * math.sin(angle)),
          3, petal,
        );
      }
      canvas.drawCircle(Offset(x, center.dy), 2.5, Paint()..color = Colors.yellow);
    }
  }

  void _drawBridge(Canvas canvas, Offset center, double width) {
    final bridge = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - width / 2, center.dy),
      Offset(center.dx + width / 2, center.dy),
      bridge,
    );
    // Ustunlar
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(center.dx - width * 0.3 + i * width * 0.3, center.dy),
        Offset(center.dx - width * 0.3 + i * width * 0.3, center.dy + 15),
        bridge..strokeWidth = 4,
      );
    }
  }

  void _drawMarketStall(Canvas canvas, Offset center, double size) {
    // Chodir
    final canopy = Paint()..color = const Color(0xFFE53935);
    final path = Path()
      ..moveTo(center.dx - size, center.dy)
      ..lineTo(center.dx, center.dy - size * 0.5)
      ..lineTo(center.dx + size, center.dy)
      ..close();
    canvas.drawPath(path, canopy);
    // Stol
    canvas.drawRect(
      Rect.fromLTWH(center.dx - size * 0.8, center.dy, size * 1.6, size * 0.3),
      Paint()..color = const Color(0xFF795548),
    );
  }

  void _drawFlags(Canvas canvas, Size size, double anim) {
    final w = size.width;
    final h = size.height;
    final flagColors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFFFFB300),
    ];
    for (int i = 0; i < 5; i++) {
      final x = w * (0.1 + i * 0.2);
      final y = h * 0.55 + math.sin(anim + i) * 4;
      // Bayroqcha ustuni
      canvas.drawLine(
        Offset(x, y), Offset(x, y + 25),
        Paint()..color = const Color(0xFF795548)..strokeWidth = 2,
      );
      // Bayroqcha
      final flag = Paint()..color = flagColors[i % flagColors.length];
      final flagPath = Path()
        ..moveTo(x, y)
        ..lineTo(x + 14, y + 4)
        ..lineTo(x, y + 8)
        ..close();
      canvas.drawPath(flagPath, flag);
    }
  }

  @override
  bool shouldRepaint(SusambilScenePainter old) =>
      old.stage != stage || old.animValue != animValue || old.isDay != isDay;
}
