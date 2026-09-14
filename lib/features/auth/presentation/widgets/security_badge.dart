import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// بادج الأمان الظاهر أسفل كارت التسجيل.
class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمان مصرفي مشفّر ومعتمد 🔒',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'بياناتك مبيعاتك وحسابات عملائك مشفرة ومحمية بالكامل في سحابة آمنة، حتى لو ضاع موبايلك دفترك يرجع بضغطة واحدة.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
