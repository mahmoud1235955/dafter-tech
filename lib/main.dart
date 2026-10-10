import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/customers/presentation/cubit/customer_cubit.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/transactions/presentation/cubit/transaction_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. تحميل بيانات التنسيق المحلية (أسماء الشهور والأيام وفترات اليوم)
  //    حزمة intl تشحن بيانات en_US فقط بشكل افتراضي، وأي DateFormat بلغة أخرى
  //    يرمي LocaleDataException ما لم تُحمَّل البيانات أولاً — لذلك هذه الخطوة
  //    يجب أن تسبق أي كود يلمس DateFormatter في lib/core/utils/formatters.dart
  await initializeDateFormatting();
  Intl.defaultLocale = AppConstants.defaultLocale;

  // 1. تهيئة منصة Supabase السحابية (مع دعم العمل في حالة عدم وجود شبكة)
  try {
    await Supabase.initialize(
      url: AppConstants.defaultSupabaseUrl,
      anonKey: AppConstants.defaultSupabaseAnonKey,
    );
  } catch (_) {
    // في حالة عدم توفر اتصال بالإنترنت يستمر التطبيق بالعمل محلياً عبر SQLite
  }

  // 2. تهيئة حاوية حقن الاعتمادات (GetIt Dependency Injection)
  await di.initDependencies();

  runApp(const DaftarTechApp());
}

/// التطبيق الرئيسي «دفترتك | DaftarTech»
class DaftarTechApp extends StatelessWidget {
  const DaftarTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>(),
        ),
        BlocProvider<CustomerCubit>(
          create: (_) => di.sl<CustomerCubit>()..loadCustomers(),
        ),
        BlocProvider<TransactionCubit>(
          create: (_) => di.sl<TransactionCubit>()..loadDashboardData(),
        ),
      ],
      child: MaterialApp(
        title: '${AppConstants.appName} | ${AppConstants.appNameEn}',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // الترجمة المادية للودجت (أزرار التقويم/الشهور بالعربية) — مطلوبة لأن
        // showDatePicker تُستدعى بـ locale: Locale('ar') في شاشة إضافة العملية
        locale: const Locale(AppConstants.defaultLocale, AppConstants.defaultLocaleCountry),
        supportedLocales: const [
          Locale(AppConstants.defaultLocale, AppConstants.defaultLocaleCountry),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // دعم اتجاه اليمين لليسار (RTL) واللغة العربية كلغة افتراضية
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
