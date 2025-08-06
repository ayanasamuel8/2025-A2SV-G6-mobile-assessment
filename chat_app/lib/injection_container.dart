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
  // PRESENTATION LAYER (BLoCs)
  // Depends on: Use Cases
  // ===================================================================
  sl.registerFactory(
    () => AuthBloc(
      signupUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthenticatedUseCase: sl(),
    ),
  );
  // ===================================================================
  // DOMAIN LAYER (USE CASES)
  // Depends on: Repositories
  // ===================================================================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthenticatedUseCase(sl()));
  // ===================================================================
  // DATA LAYER
  // Depends on: Data Sources, Core Services
  // ===================================================================
  //repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  //data Source
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(storage: sl()),
  );

  // ===================================================================
  // CORE
  // Depends on: External Packages
  // ===================================================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ===================================================================
  // EXTERNAL PACKAGES (Foundation with no dependencies)
  // ===================================================================
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
