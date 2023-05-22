import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/utils/error/failure.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  String? _phoneNumber;

  String? get phoneNumber => _phoneNumber;

  AuthBloc(AuthRepository authRepository)
      : _authRepository = authRepository,
        super(Unauthenticated()) {
    on<GoogleSignInRequest>((event, emit) async {
      emit(PhoneLinkLoading());
      var res = await _authRepository.signInWithGoogle();
      res.fold(
        (authFailure) {
          authFailure as AuthFailure;
          developer.log('Auth Failed with message: ${authFailure.message}');
          emit(AuthError(authFailure.message));
        },
        (user) {
          if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
            developer.log("Phone number not found");
            emit(PhoneNumberRequired(user));
          } else {
            developer.log("Authentication success");
            emit(Authenticated());
          }
        },
      );
    });

    on<SignOutRequest>((event, emit) async {
      await FirebaseAuth.instance.signOut();
      developer.log('signed out');
      emit(Unauthenticated());
    });

    on<SendOtpRequest>((event, emit) async {
      emit(PhoneLinkLoading());
      _phoneNumber = event.phoneNumber;
      var isValid = validate(_phoneNumber);
      if (!isValid) {
        emit(InvalidPhoneNumber());
        return;
      }
      var phone = event.phoneNumber.startsWith("0")
          ? event.phoneNumber.substring(1)
          : event.phoneNumber;
      phone = "+84$phone";
      var res = await _authRepository.sendOtp(
        phoneNumber: phone,
        codeSent: codeSent,
        verificationCompleted: verificationCompleted,
        verificationFailed: (exception) {},
        codeAutoRetrievalTimeout: (id) {},
      );
      res.fold((failure) {
        failure as AuthFailure;
        developer.log("Start verify failed");
        emit(AuthError(failure.message));
      }, (_) {});
    });
    on<OnCodeSent>((event, emit) {
      emit(OtpRequired(event.verificationId));
    });
    on<VerifyOtpRequest>((event, emit) {
      emit(PhoneLinkLoading());
      var credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otpCode,
      );
      add(OnVerificationComplete(credential));
    });
    on<OnVerificationComplete>((event, emit) async {
      var res = await _authRepository.link(event.phoneAuthCredential);
      res.fold((failure) {
        failure as AuthFailure;
        emit(InvalidOtpCode());
      }, (user) {
        emit(PhoneVerificationSuccess());
      });
    });
    on<OnCancelPhoneLink>((event, emit) {
      add(SignOutRequest());
      emit(PhoneLinkCanceled());
    });
  }

  codeSent(verificationId, forceResendingToken) {
    developer
        .log("Started verify flow with verification Code: $verificationId");
    add(OnCodeSent(verificationId));
    developer.log(verificationId);
    developer.log(forceResendingToken.toString());
  }

  verificationCompleted(phoneAuthCredential) {
    add(OnVerificationComplete(phoneAuthCredential));
  }

  bool validate(String? phoneNumber) {
    if (phoneNumber == null) {
      return false;
    }
    if (phoneNumber.length < 9 || phoneNumber.length > 10) {
      return false;
    } else {
      if (phoneNumber.length == 9 && phoneNumber.startsWith("0")) {
        return false;
      }
      if (phoneNumber.length == 10 && !phoneNumber.startsWith("0")) {
        return false;
      }
      return true;
    }
  }
}
