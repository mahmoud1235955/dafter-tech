import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daftar_tech/core/database/data_base_helper.dart';
import 'package:daftar_tech/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:daftar_tech/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:daftar_tech/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:daftar_tech/features/auth/domain/repositories/auth_repository.dart';
import 'package:daftar_tech/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:daftar_tech/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:daftar_tech/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daftar_tech/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:daftar_tech/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/search_customers_usecase.dart';
import '../../features/customers/domain/usecases/sync_customers_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/presentation/cubit/customer_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core & External
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ================= Auth Feature =================
  // DataSources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(registerUserUseCase: sl(), sendOtpUseCase: sl()),
  );

  // ================= Customers Feature =================
  // DataSources
  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));
  sl.registerLazySingleton(() => SearchCustomersUseCase(sl()));
  sl.registerLazySingleton(() => SyncCustomersUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => CustomerCubit(
      getCustomersUseCase: sl(),
      addCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
      searchCustomersUseCase: sl(),
      syncCustomersUseCase: sl(),
    ),
  );
}
