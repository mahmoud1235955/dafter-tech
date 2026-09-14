import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors (Sky Blue Theme)
  static const Color primary = Color(0xFF0284C7);
  static const Color primaryLight = Color(0xFF0EA5E9);
  static const Color primaryDark = Color(0xFF0369A1);

  // Canvas & Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Financial Indicators
  static const Color moneyIn = Color(0xFF10B981); // تحصيل (أخضر هادئ)
  static const Color moneyOut = Color(0xFFF43F5E); // آجل/دين (وردي مرجاني)
  static const Color warning = Color(0xFFF59E0B); // تنبيه فحص إيصال

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
}
