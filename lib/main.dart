import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Supabase أولاً قبل أي شيء
  await Supabase.initialize(
    url:
        'https://gkmswfzekvqxdcwyphot.supabase.co', // بدون /rest/v1 — Supabase بيضيفها تلقائياً
    anonKey:
        'sb_publishable_id75XirRunhYcp_8qwkcqg_6sSWsIYx', // ضع anon key من Supabase
  );

  // 2. تهيئة الـ GetIt Dependencies بعد نجاح تهيئة Supabase
  await di.initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthCubit>(
        create: (_) => di.sl<AuthCubit>(),
        child: const RegisterScreen(),
      ),
    );
  }
}
