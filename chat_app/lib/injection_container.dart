import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/network_info.dart';
import 'features/auth/data/datasources/local_data_source.dart';
import 'features/auth/data/datasources/remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/check_authenticated_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===================================================================
  // EXTERNAL PACKAGES (Foundation with no internal dependencies)
  // ===================================================================
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() {
    // Use a custom instance with a shorter timeout to avoid long waits on startup
    return InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 3), // Timeout for each check
      checkInterval: const Duration(seconds: 5), // Interval between checks
    );
  });
  sl.registerLazySingleton(
    () => const FlutterSecureStorage(),
  ); // <-- 2. REGISTER THE STORAGE

  // ===================================================================
  // CORE (Classes that provide cross-feature functionality)
  // Depends on: External Packages
  // ===================================================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ===================================================================
  // DATA LAYER (Handles data retrieval and storage)
  // Depends on: Core, External Packages
  // ===================================================================

  // Data Sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(
      storage: sl(),
    ), // Now this 'sl()' call will find FlutterSecureStorage
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ===================================================================
  // DOMAIN LAYER (Business logic and use cases)
  // Depends on: Data Layer (Repositories)
  // ===================================================================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthenticatedUseCase(sl()));

  // ===================================================================
  // PRESENTATION LAYER (BLoCs)
  // Depends on: Domain Layer (Use Cases)
  // ===================================================================
  sl.registerFactory(
    () => AuthBloc(
      signupUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthenticatedUseCase: sl(),
    ),
  );
}
