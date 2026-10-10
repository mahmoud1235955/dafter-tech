import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/communication_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../transactions/presentation/screens/debt_details_screen.dart';
import '../../domain/entities/customer_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import 'add_customer_screen.dart';

/// شاشة قائمة العملاء والديون (Customers List Screen)
class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0 = الكل, 1 = عليهم ديون, 2 = مسددين / لهم

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerEntity> _applyFilter(List<CustomerEntity> customers) {
    if (_selectedFilterIndex == 1) {
      return customers.where((c) => c.totalDebt > 0).toList();
    } else if (_selectedFilterIndex == 2) {
      return customers.where((c) => c.totalDebt <= 0).toList();
    }
    return customers;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text('العملاء'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'مزامنة السحابة',
              onPressed: () {
                context.read<CustomerCubit>().syncData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جارٍ مزامنة بيانات العملاء مع السحابة...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveHelper.maxContentWidth(
            child: Column(
              children: [
                // 1. شريط البحث وأزرار التصفية
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // حقل البحث
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          context.read<CustomerCubit>().searchCustomer(val);
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث عن عميل بالاسم أو الرقم...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<CustomerCubit>().searchCustomer('');
                                  },
                                )
                              : const Icon(Icons.filter_list_rounded, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.scaffoldBackground,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // أزرار التبويب (الكل / عليهم ديون / مسددين)
                      Row(
                        children: [
                          _buildFilterChip('الكل', 0),
                          const SizedBox(width: 8),
                          _buildFilterChip('عليهم ديون', 1),
                          const SizedBox(width: 8),
                          _buildFilterChip('مسددين', 2),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. قائمة العملاء
                Expanded(
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is CustomerError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.moneyOut),
                                const SizedBox(height: 12),
                                Text(state.message, textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<CustomerCubit>().loadCustomers(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      List<CustomerEntity> customers = [];
                      if (state is CustomerLoaded) {
                        customers = _applyFilter(state.filteredCustomers);
                      }

                      if (customers.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.people_outline_rounded,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'لا يوجد عملاء مطابقين للبحث',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'أضف عميل جديد لتبدأ بتسجيل الديون والمعاملات',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => context.read<CustomerCubit>().loadCustomers(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: customers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return _buildCustomerCard(context, customer);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          label: const Text(
            'إضافة عميل جديد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String title, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerEntity customer) {
    final hasDebt = customer.totalDebt > 0;
    final isCredit = customer.totalDebt < 0;

    final badgeColor = hasDebt
        ? AppColors.moneyOut
        : isCredit
            ? AppColors.moneyIn
            : AppColors.textSecondary;

    final badgeBg = hasDebt
        ? AppColors.moneyOut.withValues(alpha: 0.1)
        : isCredit
            ? AppColors.moneyIn.withValues(alpha: 0.1)
            : AppColors.scaffoldBackground;

    final debtLabel = hasDebt
        ? 'عليه ${CurrencyFormatter.format(customer.totalDebt)}'
        : isCredit
            ? 'له ${CurrencyFormatter.format(customer.totalDebt.abs())}'
            : 'خالص (متوازن)';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DebtDetailsScreen(customer: customer),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // الصورة الرمزية للعميل
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                customer.name.isNotEmpty ? customer.name[0] : '؟',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // الاسم ورقم الهاتف
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // شارة الرصيد
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    debtLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormatter.formatSmart(customer.lastTransactionAt),
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
