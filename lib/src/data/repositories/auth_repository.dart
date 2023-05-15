import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_datasource.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
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
      return Right(await _firebaseDataSource.sendOtp(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      ));
    } on Exception catch (e) {
      return Left(AuthFailure(code: e.toString(), message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    // TODO: implement signInWithFacebook
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      var userCredential = await _firebaseDataSource.signInGoogle();
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        code: e.code,
        message: e.message ?? "Message not provided",
      ));
    } on Exception {
      return Left(AuthFailure(
        code: "Unknown",
        message: "Unknown exception",
      ));
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signUpWithGoogle() {
    // TODO: implement signUpWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> link(PhoneAuthCredential credential) async {
    try {
      return Right(await _firebaseDataSource.link(credential));
    } catch (e) {
      return Left(AuthFailure(code: "LINK_FAILED", message: "Link failed"));
    }
  }
}
