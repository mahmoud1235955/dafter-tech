import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/transactions/presentation/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Supabase أولاً قبل أي شيء
  await Supabase.initialize(
    url: 'https://gkmswfzekvqxdcwyphot.supabase.co',
    anonKey: 'sb_publishable_id75XirRunhYcp_8qwkcqg_6sSWsIYx',
  );

  // 2. تهيئة الـ GetIt Dependencies بعد نجاح تهيئة Supabase
  await di.initDependencies();

  // 3. لو المستخدم داخل قبل كده (جلسة سارية أو حساب متخزن محلياً)
  //    ندخله على الداشبورد مباشرة من غير ما يمر على شاشة التسجيل.
  //    بنعملها قبل runApp علشان شاشة البداية الأصلية تفضل ظاهرة.
  final currentUserResult = await di.sl<GetCurrentUserUseCase>()();
  final isLoggedIn = currentUserResult.fold(
    (_) => false,
    (user) => user != null,
  );

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthCubit>(
        create: (_) => di.sl<AuthCubit>(),
        child: isLoggedIn ? const DashboardScreen() : const RegisterScreen(),
      ),
    );
  }
}
