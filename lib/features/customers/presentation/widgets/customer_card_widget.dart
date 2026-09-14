import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerCardWidget extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onTap;
  final VoidCallback onWhatsAppTap;

  const CustomerCardWidget({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = customer.totalDebt > 0;
    final bool isOverLimit =
        customer.creditLimit > 0 && customer.totalDebt >= customer.creditLimit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverLimit
              ? AppColors.moneyOut.withOpacity(0.3)
              : AppColors.cardBorder,
          width: isOverLimit ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // 1. صورة أو أول حرف من اسم العميل
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                child: Text(
                  customer.name.trim().isNotEmpty
                      ? customer.name.trim().characters.first
                      : '؟',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. اسم العميل والملاحظة البسيطة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. المبلغ الصافي والزر السريع
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.totalDebt.toStringAsFixed(0)} ج.م',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: hasDebt ? AppColors.moneyOut : AppColors.moneyIn,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasDebt
                          ? AppColors.moneyOut.withOpacity(0.1)
                          : AppColors.moneyIn.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasDebt ? 'مطلوب سداد' : 'خالص الحساب',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasDebt ? AppColors.moneyOut : AppColors.moneyIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // 4. زر الواتساب المباشر
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.moneyIn,
                  size: 22,
                ),
                onPressed: onWhatsAppTap,
                tooltip: 'تذكير واتساب',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
