
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:pet_match/src/utils/error/failure.dart';

class RestClient {
  static const _host = "localhost";
  static const _port = 8080;
  static const _scheme = "https";

  Future<Either<Failure, String>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    var uri = Uri(
      host: _host,
      path: path,
      port: _port,
      queryParameters: queryParams,
      scheme: _scheme,
    );
    var res = await http.get(uri, headers: headers);
    switch (res.statusCode) {
      case 200:
        return Right(res.body);
      case 401:
        return Left(RequestFailure(res.statusCode, "Unauthenticated"));
      case 403:
        return Left(RequestFailure(res.statusCode, "Forbidden"));
      case 404:
        return Left(RequestFailure(res.statusCode, "NotFound"));
      case 500:
        return Left(RequestFailure(res.statusCode, "Internal server error"));
      case 502:
        return Left(RequestFailure(res.statusCode, "Bad Gateway"));
      case 503:
        return left(
            RequestFailure(res.statusCode, "Server temporary unavailable"));
      default:
        return Left(RequestFailure(res.statusCode, "Not categorized"));
    }
  }
}
