import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
