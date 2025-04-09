import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/get_post_details.dart';
import '../../domain/usecases/get_posts.dart';
import '../../presentation/blocs/post/post_bloc.dart';
import '../../presentation/blocs/post_details/post_details_bloc.dart';
import '../network/network_info.dart';
import '../routes/app_router.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Features - Posts
  // Bloc
  sl.registerFactory(
    () => PostBloc(getPosts: sl()),
  );

  sl.registerFactory(
    () => PostDetailsBloc(getPostDetails: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPosts(repository: sl()));
  sl.registerLazySingleton(() => GetPostDetails(repository: sl()));

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton(() => ApiClient(client: sl()));
  sl.registerLazySingleton(() => AppDatabase());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => AppRouter());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Register Hive boxes
  await AppDatabase.registerAdapters();
}
