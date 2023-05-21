import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:pet_match/src/api/api_error.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class RestClient {
  static const _host = "10.0.2.2";
  static const _port = 8080;
  static const _scheme = "http";

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept-Charset': "UTF-8"
  };

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
    headers = {...defaultHeaders, ...(headers ?? {})};
    var res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      return Right(utf8.decode(res.bodyBytes));
    } else {
      String body = utf8.decode(res.bodyBytes);
      ApiError error = ApiError.fromJson(json.decode(body));
      return Left(RequestFailure(error.httpStatus!, error.message!));
    }
    // switch (res.statusCode) {
    //   case 200:
    //     return Right(utf8.decode(res.bodyBytes));
    //   case 401:
    //     return Left(RequestFailure(res.statusCode, "Unauthenticated"));
    //   case 403:
    //     return Left(RequestFailure(res.statusCode, "Forbidden"));
    //   case 404:
    //     return Left(RequestFailure(res.statusCode, "NotFound"));
    //   case 500:
    //     return Left(RequestFailure(res.statusCode, "Internal server error"));
    //   case 502:
    //     return Left(RequestFailure(res.statusCode, "Bad Gateway"));
    //   case 503:
    //     return left(
    //         RequestFailure(res.statusCode, "Server temporary unavailable"));
    //   default:
    //     return Left(RequestFailure(res.statusCode, "Not categorized"));
    // }
  }

  Future<Either<Failure, String>> post(
    String path, {
    required Object? body,
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
    headers = {...defaultHeaders, ...(headers ?? {})};
    var res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode < 400 && res.statusCode >= 200) {
      return Right(utf8.decode(res.bodyBytes));
    } else {
      ApiError error =
          ApiError.fromJson(json.decode(utf8.decode(res.bodyBytes)));
      return Left(RequestFailure(error.httpStatus!, error.message!));
    }
  }
}
