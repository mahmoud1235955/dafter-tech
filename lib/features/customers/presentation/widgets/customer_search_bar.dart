import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomerSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const CustomerSearchBar({super.key, required this.onChanged, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: TextField(
          onChanged: onChanged,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'ابحث باسم الزبون أو رقم الهاتف...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }
}
