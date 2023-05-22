import 'package:pet_match/src/api/api_error.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class UriParseException implements Exception {}

class NotFoundException implements Exception {
  final String field;
  NotFoundException(this.field);
}

class RequestException implements Exception {
  final ApiError error;

  const RequestException(this.error);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}
