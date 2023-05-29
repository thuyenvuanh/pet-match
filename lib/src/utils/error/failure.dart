import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

class AuthFailure extends Failure {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class RequestFailure extends Failure {
  final String code;
  final String reason;

  const RequestFailure({required this.code, required this.reason});

  @override
  List<Object?> get props => [code, reason];
}

class SharedPreferencesFailure extends Failure {
  final String message;
  final String errorCode;

  const SharedPreferencesFailure.empty()
      : message = "",
        errorCode = "";

  const SharedPreferencesFailure(
      {required this.errorCode, required this.message});

  SharedPreferencesFailure.notFound({Type? type, String? key})
      : errorCode = "NOT_FOUND",
        message = '${type?.toString() ?? key} Not Found';
}

class ProfileFailure extends Failure {
  final String message;
  const ProfileFailure(this.message);
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({required this.message});
}

class TimeoutFailure extends Failure {
  final String message;

  const TimeoutFailure(this.message);
}

class NotFoundFailure extends Failure {
  final String object;
  final String value;
  const NotFoundFailure({required this.object, required this.value});
}

class RefreshTokenInvalidFailure extends Failure {}
