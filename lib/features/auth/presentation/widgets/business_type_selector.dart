import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:daftar_tech/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';

import 'error_text.dart';

/// اختيار طبيعة النشاط التجاري أثناء التسجيل.
class BusinessTypeSelector extends StatelessWidget {
  const BusinessTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final BusinessType selected;
  final ValueChanged<BusinessType> onChanged;
  final bool enabled;
  final String? errorText;

  static const List<_BusinessTypeData> _options = [
    _BusinessTypeData(
      type: BusinessType.grocery,
      title: 'محل / بقالة / سوبرماركت',
      subtitle: 'دفتر يومي سريع لحسابات الزبائن',
      icon: Icons.storefront_rounded,
    ),
    _BusinessTypeData(
      type: BusinessType.wholesaler,
      title: 'موزع / تاجر جملة',
      subtitle: 'تتبع الفواتير ودفعات المحلات',
      icon: Icons.local_shipping_outlined,
    ),
    _BusinessTypeData(
      type: BusinessType.onlineStore,
      title: 'مشروع منزلي / متجر أونلاين',
      subtitle: 'إدارة طلبات الشحن ومستحقات الدفع',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'حدد طبيعة نشاطك التجاري:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'اختياري',
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 7),
        for (int i = 0; i < _options.length; i++) ...[
          _BusinessTypeOption(
            data: _options[i],
            isSelected: selected == _options[i].type,
            enabled: enabled,
            onTap: () => onChanged(_options[i].type),
          ),
          if (i < _options.length - 1) const SizedBox(height: 7),
        ],
        if (errorText != null) ErrorText(message: errorText!),
      ],
    );
  }
}

class _BusinessTypeData {
  const _BusinessTypeData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final BusinessType type;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _BusinessTypeOption extends StatelessWidget {
  const _BusinessTypeOption({
    required this.data,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final _BusinessTypeData data;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedOption : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.selectedOption : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.cardBorder.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                data.icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
