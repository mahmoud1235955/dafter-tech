import 'package:flutter/material.dart';

/// مساعد التصميم المتجاوب (Responsive Helper)
/// يضمن تكيف واجهات التطبيق بسلاسة عبر مختلف أحجام الشاشات دون أخطاء تجاوز (Overflow).
class ResponsiveHelper {
  const ResponsiveHelper._();

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isMobile(BuildContext context) => screenWidth(context) < mobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= mobileBreakpoint && screenWidth(context) < tabletBreakpoint;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= tabletBreakpoint;

  /// حساب نسبة العرض من الشاشة
  static double wp(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100.0);
  }

  /// حساب نسبة الارتفاع من الشاشة
  static double hp(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100.0);
  }

  /// تحجيم الخطوط بشكل متجاوب مع سقف أدنى وأعلى
  static double sp(BuildContext context, double baseFontSize) {
    final width = screenWidth(context);
    final scaleFactor = (width / 375.0).clamp(0.85, 1.25);
    return baseFontSize * scaleFactor;
  }

  /// حشو متكيف مع حجم الشاشة
  static EdgeInsets adaptivePadding(BuildContext context, {double horizontal = 16, double vertical = 16}) {
    final width = screenWidth(context);
    final factor = width > mobileBreakpoint ? 1.5 : 1.0;
    return EdgeInsets.symmetric(
      horizontal: horizontal * factor,
      vertical: vertical * factor,
    );
  }

  /// حاوية لتحديد العرض الأقصى على الشاشات الكبيرة
  static Widget maxContentWidth({
    required Widget child,
    double maxWidth = 640.0,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
