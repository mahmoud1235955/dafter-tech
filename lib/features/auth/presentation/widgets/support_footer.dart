import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:daftar_tech/core/utils/app_constants.dart';
import 'package:daftar_tech/features/customers/domain/usecases/communication_service.dart';
import 'package:flutter/material.dart';

/// سطر المساعدة الفورية (واتساب) وإصدار التطبيق.
class SupportFooter extends StatelessWidget {
  const SupportFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => _openSupport(context),
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.primary,
                  size: 15,
                ),
                SizedBox(width: 4),
                Text(
                  'مساعدة فورية (واتساب)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          'إصدار التاجر الذكي v${AppConstants.appVersion}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
        ),
      ],
    );
  }

  Future<void> _openSupport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await CommunicationService.sendWhatsAppReminder(
        phone: AppConstants.supportPhone,
        customerName: AppConstants.supportName,
        debtAmount: 0,
      );
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الواتساب حالياً، جرب مرة تانية'),
            backgroundColor: AppColors.moneyOut,
          ),
        );
    }
  }
}
