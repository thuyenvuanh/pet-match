import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/data/datasources/local/auth_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_datasource.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDatasource;

  AuthRepositoryImpl(this._authRemoteDataSource, this._authLocalDatasource);

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      final res = await _authRemoteDataSource.sendOtp(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      return Right(res);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      var user = await _authRemoteDataSource.signInGoogle();
      if (user != null) {
        return Right(user);
      } else {
        return const Left(AuthFailure(message: 'Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? "Message not provided"));
    } on Exception catch (e) {
      dev.log(e.runtimeType.toString());
      return const Left(AuthFailure(message: "Unknown exception"));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authLocalDatasource.signOut();
      await _authRemoteDataSource.signOut();
    } catch (e) {
      dev.log('sign out failed with error: ${e.runtimeType}');
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> link(PhoneAuthCredential credential) async {
    try {
      return Right(await _authRemoteDataSource.link(credential));
    } catch (e) {
      return const Left(AuthFailure(message: "Link failed"));
    }
  }

  @override
  Future<Either<Failure, String>> getUserId() async {
    var uid = _authRemoteDataSource.userId;
    if (uid != null) {
      return Right(uid);
    } else {
      return const Left(AuthFailure(
          message:
              'You\'re not logged. Logged in first to view created profiles'));
    }
  }

  ///Authenticated criteria:
  ///- Firebase Instance signed in
  ///- Have accessToken and refreshToken
  ///- Refresh token duration > 1 day
  ///
  @override
  Future<Either<Failure, bool>> getInitAuthStatus() async {
    try {
      bool isAuthOk = _authLocalDatasource.getCurrentAuthStatus();
      isAuthOk = _authRemoteDataSource.fi.currentUser != null;
      if (isAuthOk) {
        return const Right(true);
      } else {
        _authLocalDatasource.signOut();
        _authRemoteDataSource.signOut();
        return const Right(false);
      }
    } catch (e) {
      dev.log(
          'Error thrown when get init auth state with type: ${e.runtimeType}');
      return Left(AuthFailure(message: e.runtimeType.toString()));
    }
  }
}
