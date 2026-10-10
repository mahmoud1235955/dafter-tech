import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../../transactions/presentation/screens/dashboard_screen.dart';

/// شاشة البداية والترحيب (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // إبقاء شاشة البداية لمدة ثانيتين للمشاهدة والتحميل
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    try {
      final getCurrentUser = di.sl<GetCurrentUserUseCase>();
      final result = await getCurrentUser();

      final isLoggedIn = result.fold(
        (_) => false,
        (user) => user != null,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) =>
              isLoggedIn ? const DashboardScreen() : const RegisterScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.splashGradient,
          ),
          child: SafeArea(
            child: ResponsiveHelper.maxContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 10),

                    // الجزء الأوسط: الأيقونة ثلاثية الأبعاد والشعار
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // أيقونة المحفظة ودفتر الحسابات المتوهجة ثلاثية الأبعاد
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFF0EA5E9), Color(0xFF0265B8), Colors.transparent],
                                radius: 0.85,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // اسم التطبيق باللغتين
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '| ${AppConstants.appNameEn}',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // الشعار الملهم (Slogan)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: const Text(
                              AppConstants.appSlogan,
                              style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // الجزء السفلي: مؤشر التحميل وشارة الأمان ورقم الإصدار
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'أمان مصرفي مشفر ومعتمد 🔒',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الإصدار ${AppConstants.appVersion}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
