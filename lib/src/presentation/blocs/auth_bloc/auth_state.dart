part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class InitialState extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {}

class GettingAuthorizationStatus extends AuthState {}

class PhoneNumberRequired extends AuthState {
  final User user;

  const PhoneNumberRequired(this.user);

  @override
  List<Object> get props => [user];
}

class OtpRequired extends AuthState {
  final String verifyId;
  const OtpRequired(this.verifyId);
}

class PhoneLinkCanceled extends AuthState {}

class PhoneLinkLoading extends AuthState {}

class InvalidOtpCode extends AuthState {}

class PhoneVerificationSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

class InvalidPhoneNumber extends AuthState {}
