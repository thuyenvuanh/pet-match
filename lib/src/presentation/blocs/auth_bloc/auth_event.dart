part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class GoogleSignInRequest extends AuthEvent {}

class SignOutRequest extends AuthEvent {}

class SendOtpRequest extends AuthEvent {
  final String phoneNumber;
  final String nationCode;

  const SendOtpRequest({required this.phoneNumber, this.nationCode = "+84"});
}

class OnVerificationComplete extends AuthEvent {
  final PhoneAuthCredential phoneAuthCredential;
  const OnVerificationComplete(this.phoneAuthCredential);
}

class OnCodeSent extends AuthEvent {
  final String verificationId;
  const OnCodeSent(this.verificationId);
}

class OnCancelPhoneLink extends AuthEvent {}

class OnInvalidPhoneNumber extends AuthEvent {}

class VerifyOtpRequest extends AuthEvent {
  final String otpCode;
  final String verificationId;
  const VerifyOtpRequest({
    required this.otpCode,
    required this.verificationId,
  });
}
