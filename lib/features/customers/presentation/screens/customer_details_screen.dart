import 'package:daftar_tech/features/customers/domain/usecases/communication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import 'edit_customer_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'حذف حساب العميل',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            'هل أنت متأكد من حذف ${customer.name} من الدفتر تماماً؟ لا يمكن التراجع عن هذه الخطوة.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.moneyOut,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<CustomerCubit>().removeCustomer(customer.id);
              },
              child: const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is CustomerActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryDark,
            ),
          );
          if (state.message.contains('حذف')) {
            Navigator.pop(context);
          }
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.moneyOut,
            ),
          );
        }
      },
      builder: (context, state) {
        CustomerEntity currentCustomer = customer;
        if (state is CustomerLoaded) {
          final matched = state.customers.where((c) => c.id == customer.id);
          if (matched.isNotEmpty) {
            currentCustomer = matched.first;
          }
        }

        final bool hasDebt = currentCustomer.totalDebt > 0;
        final double creditUsageRatio = currentCustomer.creditLimit > 0
            ? (currentCustomer.totalDebt / currentCustomer.creditLimit).clamp(
                0.0,
                1.0,
              )
            : 0.0;
        final bool isOverLimit =
            currentCustomer.creditLimit > 0 &&
            currentCustomer.totalDebt >= currentCustomer.creditLimit;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: true,
              title: Text(
                currentCustomer.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'تعديل البيانات',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CustomerCubit>(),
                          child: EditCustomerScreen(customer: currentCustomer),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.moneyOut,
                  ),
                  tooltip: 'حذف العميل',
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. بطاقة الرصيد وسقف الائتمان
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOverLimit
                          ? AppColors.moneyOut.withOpacity(0.4)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        hasDebt
                            ? 'المبلغ المتبقي على العميل (دين)'
                            : 'الحساب خالص بالكامل',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${currentCustomer.totalDebt.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: hasDebt
                              ? AppColors.moneyOut
                              : AppColors.moneyIn,
                        ),
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'سقف الآجل: ${currentCustomer.creditLimit.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            currentCustomer.creditLimit > 0
                                ? 'استهلاك ${(creditUsageRatio * 100).toStringAsFixed(0)}%'
                                : 'غير محدد',
                            style: TextStyle(
                              color: isOverLimit
                                  ? AppColors.moneyOut
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentCustomer.creditLimit > 0
                            ? creditUsageRatio
                            : 0.0,
                        backgroundColor: AppColors.cardBorder,
                        color: isOverLimit
                            ? AppColors.moneyOut
                            : AppColors.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. أزرار التواصل المباشر السريع
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.moneyIn,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'تذكير واتساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          CommunicationService.sendWhatsAppReminder(
                            phone: currentCustomer.phone,
                            customerName: currentCustomer.name,
                            debtAmount: currentCustomer.totalDebt,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.call,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        label: const Text(
                          'اتصال هاتفي',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          CommunicationService.makePhoneCall(
                            currentCustomer.phone,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. بطاقة بيانات الاتصال والموقع
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            currentCustomer.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currentCustomer.isSynced
                                ? 'متزامن سحابياً'
                                : 'محفوظ محلياً',
                            style: TextStyle(
                              fontSize: 11,
                              color: currentCustomer.isSynced
                                  ? AppColors.moneyIn
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (currentCustomer.address != null &&
                          currentCustomer.address!.trim().isNotEmpty) ...[
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentCustomer.address!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. رأس قسم العمليات والمعاملات المالية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل العمليات والفواتير',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.print,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'كشف حساب PDF',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'سيتم ربط تصدير PDF مع اكتمال ميزة المعاملات',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 5. مساحة عرض المعاملات
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 42, color: AppColors.textMuted),
                      SizedBox(height: 10),
                      Text(
                        'لا توجد عمليات أو فواتير مسجلة لهذا العميل حالياً',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
