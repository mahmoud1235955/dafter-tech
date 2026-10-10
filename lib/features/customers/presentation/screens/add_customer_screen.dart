import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/customer_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

/// شاشة إضافة عميل جديد إلى الدفتر
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _initialDebtController = TextEditingController();
  final _creditLimitController = TextEditingController();

  bool _isDebtor = true; // هل الرصيد المبدئي دين عليه أو سداد له

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _initialDebtController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final initialAmount = double.tryParse(_initialDebtController.text.trim()) ?? 0.0;
    final totalDebt = _isDebtor ? initialAmount : -initialAmount;
    final creditLimit = double.tryParse(_creditLimitController.text.trim()) ?? 0.0;

    final customer = CustomerEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      totalDebt: totalDebt,
      creditLimit: creditLimit,
      lastTransactionAt: DateTime.now(),
      isSynced: false,
    );

    context.read<CustomerCubit>().createCustomer(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة عميل جديد'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<CustomerCubit, CustomerState>(
          listener: (context, state) {
            if (state is CustomerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.moneyIn,
                ),
              );
              Navigator.pop(context);
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
            final isLoading = state is CustomerLoading;

            return SafeArea(
              child: ResponsiveHelper.maxContentWidth(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.adaptivePadding(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بطاقة البيانات الأساسية
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'البيانات الشخصية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // اسم العميل
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'اسم العميل / المحل *',
                                  hintText: 'مثال: أحمد محمد علي',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'من فضلك أدخل اسم العميل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // رقم الهاتف
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الهاتف (واتساب) *',
                                  hintText: '01012345678',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: Validators.validatePhone,
                              ),
                              const SizedBox(height: 14),

                              // العنوان
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'العنوان أو المنطقة (اختياري)',
                                  hintText: 'مثال: شارع السوق، المحلة',
                                  prefixIcon: Icon(Icons.place_outlined),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // بطاقة الرصيد الافتتاحي وسقف الائتمان
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الحساب المالي الأولي',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // نوع الرصيد الأولي (عليه دين أو له رصيد)
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _isDebtor = true),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _isDebtor ? AppColors.moneyOut.withValues(alpha: 0.1) : AppColors.fieldFill,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isDebtor ? AppColors.moneyOut : AppColors.cardBorder,
                                            width: _isDebtor ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'عليه دين سابق (لك)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _isDebtor ? AppColors.moneyOut : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _isDebtor = false),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !_isDebtor ? AppColors.moneyIn.withValues(alpha: 0.1) : AppColors.fieldFill,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: !_isDebtor ? AppColors.moneyIn : AppColors.cardBorder,
                                            width: !_isDebtor ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'له رصيد / مسدد مقدماً',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: !_isDebtor ? AppColors.moneyIn : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // المبلغ المبدئي
                              TextFormField(
                                controller: _initialDebtController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'الرصيد المبدئي (ج.م)',
                                  hintText: '0.00',
                                  prefixIcon: Icon(Icons.attach_money_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // سقف الآجل
                              TextFormField(
                                controller: _creditLimitController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'سقف الدين المسموح (سقف الآجل)',
                                  hintText: 'مثال: 5000',
                                  prefixIcon: Icon(Icons.speed_rounded),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // زر الحفظ
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'حفظ العميل في الدفتر',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
