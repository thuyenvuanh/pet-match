import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, bool>> getInitAuthStatus();

  Future<Either<Failure, User>> signUpWithGoogle();

  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  });

  Future<Either<Failure, User>> link(PhoneAuthCredential credential);

  Future<Either<Failure, User>> signInWithFacebook();

  Future<Either<Failure, String>> getUserId();

  Future<void> signOut();
}
