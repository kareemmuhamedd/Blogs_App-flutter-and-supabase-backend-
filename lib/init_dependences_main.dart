part of 'init_dependences.dart';
final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );
  serviceLocator.registerLazySingleton<SupabaseClient>(() => supabase.client);
  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(
      serviceLocator<InternetConnection>(),
    ),
  );
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));
  _initAuth();
  _initBlog();
}

void _initAuth() {
  // Data source
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
          () => AuthRemoteDataSourceImpl(
        serviceLocator<SupabaseClient>(),
      ),
    )
  // Repository
    ..registerFactory<AuthRepository>(
          () => AuthRepositoryImpl(
        serviceLocator<AuthRemoteDataSource>(),
        serviceLocator<ConnectionChecker>(),
      ),
    )
  // Usecases
    ..registerFactory(
          () => UserSignUp(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
          () => UserLogin(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
          () => CurrentUser(
        serviceLocator<AuthRepository>(),
      ),
    )
  // Bloc
    ..registerLazySingleton(
          () => AuthBloc(
        userSignUp: serviceLocator<UserSignUp>(),
        userLogin: serviceLocator<UserLogin>(),
        currentUser: serviceLocator<CurrentUser>(),
        appUserCubit: serviceLocator<AppUserCubit>(),
      ),
    );
}

void _initBlog() {
  // Datasource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
          () => BlogRemoteDataSourceImpl(
        serviceLocator<SupabaseClient>(),
      ),
    )
    ..registerFactory<BlogLocalDataSource>(
          () => BlogLocalDataSourceImpl(
        serviceLocator<Box>(),
      ),
    )
  // Repository
    ..registerFactory<BlogRepository>(
          () => BlogRepositoryImpl(
        serviceLocator<BlogRemoteDataSource>(),
        serviceLocator<BlogLocalDataSource>(),
        serviceLocator<ConnectionChecker>(),
      ),
    )
  // UseCase
    ..registerFactory<UploadBlog>(
          () => UploadBlog(
        serviceLocator<BlogRepository>(),
      ),
    )
    ..registerFactory<GetAllBlogs>(
          () => GetAllBlogs(
        serviceLocator<BlogRepository>(),
      ),
    )
  // Bloc
    ..registerLazySingleton(
          () => BlogBloc(
        uploadBlog: serviceLocator<UploadBlog>(),
        getAllBlogs: serviceLocator<GetAllBlogs>(),
      ),
    );
}
