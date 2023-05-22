import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_datasource.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseDataSource _firebaseDataSource;

  AuthRepositoryImpl(this._firebaseDataSource);

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      final res = await _firebaseDataSource.sendOtp(
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
      var user = await _firebaseDataSource.signInGoogle();
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
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signUpWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> link(PhoneAuthCredential credential) async {
    try {
      return Right(await _firebaseDataSource.link(credential));
    } catch (e) {
      return const Left(AuthFailure(message: "Link failed"));
    }
  }

  @override
  Future<Either<Failure, String>> getUserId() async {
    var uid = _firebaseDataSource.userId;
    if (uid != null) {
      return Right(uid);
    } else {
      return const Left(AuthFailure(
          message:
              'You\'re not logged. Logged in first to view created profiles'));
    }
  }
}
