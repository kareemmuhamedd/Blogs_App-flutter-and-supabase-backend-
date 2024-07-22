import 'package:flutter_clean_architecture/core/error/exception.dart';
import 'package:flutter_clean_architecture/core/error/failures.dart';
import 'package:flutter_clean_architecture/core/common/entities/user.dart';
import 'package:flutter_clean_architecture/core/network/connection_checker.dart';
import 'package:flutter_clean_architecture/featrures/auth/data/models/user_model.dart';
import 'package:flutter_clean_architecture/featrures/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure(message: 'User no logged in'));
        }
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(
          Failure(message: 'User no logged in'),
        );
      } else {
        return right(user);
      }
    } on ServerException catch (e) {
      return left(
        Failure(
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async {
        return await remoteDataSource.loginWithEmailPassword(
          email: email,
          password: password,
        );
      },
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async {
        return await remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password,
        );
      },
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection!'));
      }
      final user = await fn();
      return right(user);
    } on sb.AuthException catch (e) {
      return left(
        Failure(
          message: e.message,
        ),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
