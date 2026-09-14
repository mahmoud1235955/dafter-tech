import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// الشريط العلوي لشاشات المصادقة (اسم التطبيق + زر التنبيهات).
class AuthAppBar extends StatelessWidget {
  const AuthAppBar({super.key, this.onNotificationsTap, this.notificationsCount = 0});

  final VoidCallback? onNotificationsTap;

  /// عدد التنبيهات غير المقروءة (يظهر كنقطة حمراء صغيرة).
  final int notificationsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NotificationsButton(
          count: notificationsCount,
          onTap: onNotificationsTap,
        ),
        Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'دفترتك',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Ledger',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              if (count > 0)
                const Positioned(
                  top: 10,
                  left: 11,
                  child: CircleAvatar(radius: 3.5, backgroundColor: AppColors.moneyOut),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
