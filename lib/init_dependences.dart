import 'package:flutter_clean_architecture/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_clean_architecture/featrures/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:flutter_clean_architecture/featrures/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_clean_architecture/featrures/auth/domain/repository/auth_repository.dart';
import 'package:flutter_clean_architecture/featrures/auth/domain/usecases/current_user.dart';
import 'package:flutter_clean_architecture/featrures/auth/domain/usecases/user_login.dart';
import 'package:flutter_clean_architecture/featrures/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter_clean_architecture/featrures/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_clean_architecture/featrures/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:flutter_clean_architecture/featrures/blog/data/repositories/blog_repository_impl.dart';
import 'package:flutter_clean_architecture/featrures/blog/domain/repositories/blog_repository.dart';
import 'package:flutter_clean_architecture/featrures/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/secrets/app_secrets.dart';
import 'featrures/blog/domain/usecases/upload_blog.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );
  serviceLocator.registerLazySingleton<SupabaseClient>(() => supabase.client);
  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
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
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator<BlogRemoteDataSource>(),
      ),
    )
    // UseCase
    ..registerFactory<UploadBlog>(
      () => UploadBlog(
        serviceLocator<BlogRepository>(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator<UploadBlog>(),
      ),
    );
}
