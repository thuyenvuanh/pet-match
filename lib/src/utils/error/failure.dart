import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
}

class AuthFailure implements Failure {
  final String code;
  final String message;

  AuthFailure({required this.code, required this.message});

  @override
  List<Object?> get props => [code, message];

  @override
  bool? get stringify => false;
}

class RequestFailure implements Failure {
  final int code;
  final String reason;

  const RequestFailure(this.code, this.reason);

  @override
  List<Object?> get props => [code, reason];

  @override
  bool? get stringify => false;
}

class SharedPreferencesFailure implements Failure {
  final String message;
  final String errorCode;

  SharedPreferencesFailure.empty()
      : message = "",
        errorCode = "";

  SharedPreferencesFailure(this.errorCode, this.message);

  SharedPreferencesFailure.notFound(Type type)
      : errorCode = "NOT_FOUND",
        message = '${type.toString()} Not Found';

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}
