import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// سطر رسالة الخطأ الظاهر أسفل حقول الإدخال.
class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.moneyOut,
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.moneyOut,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
