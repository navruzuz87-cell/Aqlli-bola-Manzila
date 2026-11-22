import 'package:flutter/material.dart';

/// Manzila: Aqlli Bola uchun yagona vizual til.
/// Yangi ekranlar va o'yinlar shu tokenlardan foydalanishi kerak.
class ManzilaDesignSystem {
  ManzilaDesignSystem._();

  static const Color midnight = Color(0xFF071B35);
  static const Color deepBlue = Color(0xFF103D70);
  static const Color royalBlue = Color(0xFF1769AA);
  static const Color sky = Color(0xFF61C8F2);
  static const Color gold = Color(0xFFFFC857);
  static const Color cream = Color(0xFFFFF7E6);
  static const Color success = Color(0xFF35B879);
  static const Color danger = Color(0xFFE85D75);
  static const Color violet = Color(0xFF8067D8);

  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 28;
  static const double radiusPill = 999;

  static const Duration motionFast = Duration(milliseconds: 160);
  static const Duration motionNormal = Duration(milliseconds: 280);
  static const Duration motionCinematic = Duration(milliseconds: 650);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33051B35),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  static LinearGradient heroGradient({Color? start, Color? end}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start ?? royalBlue, end ?? deepBlue],
      );
}
