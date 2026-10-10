import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/cubit/customer_cubit.dart';
import '../../../customers/presentation/cubit/customer_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

/// شاشة إضافة معاملة مالية جديدة (Add Transaction Screen)
class AddTransactionScreen extends StatefulWidget {
  final CustomerEntity? preselectedCustomer;
  final String? initialCustomerName;
  final double? initialAmount;
  final String? initialNotes;
  final TransactionType? initialType;

  const AddTransactionScreen({
    super.key,
    this.preselectedCustomer,
    this.initialCustomerName,
    this.initialAmount,
    this.initialNotes,
    this.initialType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  CustomerEntity? _selectedCustomer;
  late TransactionType _selectedType;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  String? _receiptImagePath;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.preselectedCustomer;
    _selectedType = widget.initialType ?? TransactionType.goodsDelivered;

    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(0)
          : '1500',
    );

    _notesController = TextEditingController(
      text: widget.initialNotes ?? 'بضاعة بقالة',
    );

    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showCustomerPicker(List<CustomerEntity> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر العميل من الدفتر',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return ListTile(
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c.phone),
                      trailing: Text(
                        CurrencyFormatter.format(c.totalDebt),
                        style: TextStyle(
                          color: c.totalDebt > 0 ? AppColors.moneyOut : AppColors.moneyIn,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedCustomer = c);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخل مبلغ صحيح أكبر من الصفر')),
      );
      return;
    }

    final customerId = _selectedCustomer?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}';
    final customerName = _selectedCustomer?.name ?? widget.initialCustomerName ?? 'أحمد محمد';

    final transaction = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      type: _selectedType,
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      receiptImageUrl: _receiptImagePath,
      transactionDate: _selectedDate,
      isVerified: true,
      isSynced: false,
    );

    context.read<TransactionCubit>().createTransaction(transaction);
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = _selectedType == TransactionType.goodsDelivered;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text('تسجيل عملية جديدة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.moneyIn,
                ),
              );
              Navigator.pop(context);
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.moneyOut,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TransactionLoading;

            return SafeArea(
              child: ResponsiveHelper.maxContentWidth(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.adaptivePadding(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. بطاقة العميل المستهدف (Target Client Card)
                        _buildTargetClientCard(),
                        const SizedBox(height: 16),

                        // 2. زر التبديل بين (عليه دين) و (له سداد)
                        _buildTypeToggle(isDebit),
                        const SizedBox(height: 18),

                        // 3. بطاقة إدخال المبلغ وتفاصيل المعاملة
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المبلغ (ج.م)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // حقل المبلغ الكبير
                              TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isDebit ? AppColors.moneyOut : AppColors.moneyIn,
                                ),
                                decoration: InputDecoration(
                                  hintText: '1,500',
                                  suffixText: 'ج.م',
                                  suffixStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.monetization_on_rounded,
                                    color: isDebit ? AppColors.moneyOut : AppColors.moneyIn,
                                  ),
                                  fillColor: isDebit ? AppColors.moneyOutLight : AppColors.moneyInLight,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'من فضلك أدخل المبلغ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // بيان المعاملة
                              TextFormField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  labelText: 'بيان المعاملة أو الصنف',
                                  hintText: 'مثال: بضاعة بقالة، شراء مواد، دفعة كاش',
                                  prefixIcon: Icon(Icons.description_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // طريقة الدفع
                              DropdownButtonFormField<PaymentMethod>(
                                value: _selectedPaymentMethod,
                                decoration: const InputDecoration(
                                  labelText: 'طريقة الدفع / المعاملة',
                                  prefixIcon: Icon(Icons.payment_rounded),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: PaymentMethod.cash,
                                    child: Text('نقداً (كاش)'),
                                  ),
                                  DropdownMenuItem(
                                    value: PaymentMethod.instaPay,
                                    child: Text('انستاباي InstaPay'),
                                  ),
                                  DropdownMenuItem(
                                    value: PaymentMethod.vodafoneCash,
                                    child: Text('فودافون كاش / محفظة إلكترونية'),
                                  ),
                                  DropdownMenuItem(
                                    value: PaymentMethod.bankTransfer,
                                    child: Text('تحويل بنكي مباشر'),
                                  ),
                                  DropdownMenuItem(
                                    value: PaymentMethod.other,
                                    child: Text('أخرى'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedPaymentMethod = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. خيارات التاريخ وإرفاق الإيصال
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              // منتقي التاريخ
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'تاريخ المعاملة:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormatter.formatFull(_selectedDate),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 20),

                              // إرفاق صورة الإيصال (اختياري)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _receiptImagePath = 'mock_receipt_image.jpg';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إرفاق صورة إيصال المعاملة 📷'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'إرفاق صورة الإيصال / الفاتورة:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _receiptImagePath != null ? 'تم الإرفاق ✓' : 'إضافة صورة +',
                                        style: TextStyle(
                                          color: _receiptImagePath != null ? AppColors.moneyIn : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),

                        // 5. زر الحفظ والمزامنة الرئيسي (Primary CTA)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.submitButton,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
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
                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'حفظ ومزامنة العملية',
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
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

  Widget _buildTargetClientCard() {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        List<CustomerEntity> customers = [];
        if (state is CustomerLoaded) {
          customers = state.customers;
        }

        final clientName = _selectedCustomer?.name ?? widget.initialCustomerName ?? 'أحمد محمد';
        final clientPhone = _selectedCustomer?.phone ?? '01012345678';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العميل: $clientName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clientPhone,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showCustomerPicker(customers),
                child: const Text('تغيير العميل'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeToggle(bool isDebit) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // خيار (عليه - دين)
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedType = TransactionType.goodsDelivered),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDebit ? AppColors.moneyOut : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: isDebit ? Colors.white : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'عليه (دين)',
                      style: TextStyle(
                        color: isDebit ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // خيار (له - سداد)
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedType = TransactionType.paymentReceived),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isDebit ? AppColors.moneyIn : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: !isDebit ? Colors.white : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'له (سداد)',
                      style: TextStyle(
                        color: !isDebit ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
