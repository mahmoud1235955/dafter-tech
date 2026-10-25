import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../../customers/presentation/cubit/customer_cubit.dart';
import '../../../customers/presentation/screens/add_customer_screen.dart';
import '../../../customers/presentation/screens/customers_list_screen.dart';
import '../../domain/entities/transaction_entity.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import 'add_transaction_screen.dart';

/// الشاشة الرئيسية (Dashboard Screen)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadDashboardData();
    context.read<CustomerCubit>().loadCustomers();
  }

  /// تأكيد ثم تنفيذ تسجيل الخروج والعودة لشاشة التسجيل.
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'بياناتك محفوظة على الجهاز، وتقدر تسجّل دخول تاني في أي وقت.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthCubit>().signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
      (route) => false,
    );
  }

  void _onVoiceAssistantTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildVoiceAssistantModal(ctx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          title: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final user = authState is AuthSuccess
                  ? authState.user
                  : authState is AuthAuthenticated
                      ? authState.user
                      : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.phone ?? AppConstants.appName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user != null
                        ? '${user.businessType.labelAr} • ${AppConstants.appName}'
                        : AppConstants.appSlogan,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
              tooltip: 'الإشعارات والتنبيهات',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لا توجد تنبيهات جديدة في الوقت الحالي'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              tooltip: 'الحساب',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textPrimary,
              ),
              onSelected: (value) {
                if (value == 'logout') _confirmSignOut();
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('تسجيل الخروج'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveHelper.maxContentWidth(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<TransactionCubit>().loadDashboardData();
                if (mounted) {
                  await context.read<CustomerCubit>().loadCustomers();
                }
              },
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  double totalDebt = 0;
                  double totalCredit = 0;
                  int customerCount = 0;
                  List<TransactionEntity> recentTransactions = [];

                  if (state is TransactionLoaded) {
                    totalDebt = state.totalDebt;
                    totalCredit = state.totalCredit;
                    customerCount = state.customerCount;
                    recentTransactions = state.recentTransactions;
                  }

                  return ListView(
                    padding: ResponsiveHelper.adaptivePadding(context),
                    children: [
                      // 1. بطاقة الرصيد وإجمالي الديون الكبرى (Gradient Balance Card)
                      _buildBalanceCard(totalDebt, totalCredit, customerCount),
                      const SizedBox(height: 18),

                      // 2. بطاقة المساعد الصوتي الذكي السريع
                      _buildVoiceAssistantBanner(),
                      const SizedBox(height: 18),

                      // 3. الإجراءات السريعة (Quick Actions)
                      const Text(
                        'إجراءات سريعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              title: 'إضافة عميل',
                              subtitle: 'تسجيل دفتر جديد',
                              icon: Icons.person_add_alt_1_rounded,
                              color: AppColors.primary,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddCustomerScreen(),
                                  ),
                                ).then((_) {
                                  context.read<TransactionCubit>().loadDashboardData();
                                  context.read<CustomerCubit>().loadCustomers();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              title: 'تسجيل عملية',
                              subtitle: 'دين أو سداد فوري',
                              icon: Icons.post_add_rounded,
                              color: AppColors.moneyIn,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddTransactionScreen(),
                                  ),
                                ).then((_) {
                                  context.read<TransactionCubit>().loadDashboardData();
                                  context.read<CustomerCubit>().loadCustomers();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. رأس قسم آخر المعاملات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'آخر المعاملات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomersListScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'عرض دفتر العملاء',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 5. قائمة آخر المعاملات
                      _buildRecentTransactionsList(recentTransactions),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBalanceCard(double totalDebt, double totalCredit, int customerCount) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardBalanceGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0265B8).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'إجمالي الديون المستحقة (لك)',
                    style: TextStyle(color: Colors.white70, fontSize: 13.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '$customerCount عميل',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(totalDebt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'المزامنة السحابية: متصل نشط 🟢',
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ],
              ),
              Text(
                'الآجل: ${CurrencyFormatter.format(totalCredit)}',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAssistantBanner() {
    return InkWell(
      onTap: _onVoiceAssistantTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'المساعد الصوتي الذكي 🎙️',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'سجل الديون صوتياً: "سجل دين على أحمد 500 جنيه"',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyTransactionsCard();
    }

    return Column(
      children: transactions.map((tx) => _buildTransactionCard(tx)).toList(),
    );
  }

  /// حالة «لا توجد معاملات» — بدل عرض بيانات وهمية في دفتر حقيقي.
  Widget _buildEmptyTransactionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: AppColors.textSecondary,
            size: 34,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد معاملات بعد',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'ابدأ بتسجيل أول عملية من «إجراءات سريعة» في الأعلى',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionEntity tx) {
    final isDebt = tx.type == TransactionType.goodsDelivered;
    final badgeColor = isDebt ? AppColors.moneyOut : AppColors.moneyIn;
    final badgeBg = isDebt ? AppColors.moneyOut.withValues(alpha: 0.1) : AppColors.moneyIn.withValues(alpha: 0.1);
    final sign = isDebt ? 'دين (عليه)' : 'سداد (له)';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: badgeBg,
            child: Icon(
              isDebt ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
              color: badgeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.customerName ?? 'عميل الدفتر',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tx.notes ?? sign,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebt ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: badgeColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormatter.formatSmart(tx.transactionDate),
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAssistantModal(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'المساعد الصوتي الذكي لدفترتك',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تحدث بصوتك وسنقوم بتسجيل المعاملة واستخراج اسم العميل والمبلغ آلياً',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // رسم الموجات الصوتية المتوهجة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 20),

            // بطاقة المعاينة للذكاء الاصطناعي
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم التعرف على الصوت:',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '"سجل دين على أحمد محمد بقيمة 1,500 جنيه بضاعة بقالة"',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  );
                },
                child: const Text('تأكيد والانتقال لحفظ المعاملة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomersListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'العملاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'معاملة جديدة',
          ),
        ],
      ),
    );
  }
}
