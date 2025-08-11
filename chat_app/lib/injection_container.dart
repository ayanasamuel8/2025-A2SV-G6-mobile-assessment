import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/auth/data/datasources/local_data_source.dart';
import 'features/auth/data/datasources/remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/check_authenticated_usecase.dart';
import 'features/auth/domain/usecases/get_me_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/data/datasources/chat_local_data_source.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/delete_chat_usecase.dart';
import 'features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'features/chat/domain/usecases/get_chats_usecase.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/initiate_chat_usecase.dart';
import 'features/chat/presentation/bloc/chat_list_bloc.dart';
import 'features/chat/presentation/bloc/chat_thread_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===================================================================
  // EXTERNAL PACKAGES
  // ===================================================================
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(
    () => InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 3),
      checkInterval: const Duration(seconds: 5),
    ),
  );
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ===================================================================
  // CORE
  // ===================================================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ===================================================================
  // DATA LAYER
  // ===================================================================
  // Data Sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: sl()),
  );
  // Note: ChatLocalDataSource is registered but not used by ChatRepositoryImpl in our current design. This is fine.
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // --- UPDATED ChatRepository REGISTRATION ---
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ===================================================================
  // DOMAIN LAYER (Use Cases)
  // ===================================================================
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthenticatedUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));

  // Chat
  sl.registerLazySingleton(() => GetChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetMessagesUsecase(sl()));
  sl.registerLazySingleton(() => InitiateChatUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChatUseCase(sl()));

  // ===================================================================
  // PRESENTATION LAYER (BLoCs)
  // ===================================================================
  // AuthBloc depends on its use cases. This is correct.
  sl.registerFactory(
    () => AuthBloc(
      chatRepository: sl(),
      signupUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthenticatedUseCase: sl(),
      getMeUseCase: sl(),
    ),
  );

  // ChatListBloc depends on its use cases. This is correct.
  sl.registerFactory(
    () => ChatListBloc(getChatsUseCase: sl(), deleteChatUseCase: sl()),
  );

  // --- UPDATED ChatThreadBloc REGISTRATION ---
  sl.registerFactory(
    () => ChatThreadBloc(
      // Use cases for historical data fetching
      getMessagesUseCase: sl(),
      getChatByIdUseCase: sl(),
      initiateChatUseCase: sl(),
      // Repository for real-time stream and sending messages
      chatRepository: sl(),
      // AuthBloc to get the current user's ID
      authBloc: sl(),
    ),
  );
}
