import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:pet_match/src/api/api_error.dart';
import 'package:pet_match/src/domain/models/token_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class RestClient {
  static const _host = "10.0.2.2";
  static const _port = 8080;
  static const _scheme = "http";

  static AuthorizationToken? _authentication;

  static set authenticationHeader(AuthorizationToken authorizationToken) =>
      _authentication = authorizationToken;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept-Charset': "UTF-8"
  };

  static Iterable<MapEntry<String, String>> _buildAuthorizationHeader() {
    return {'Authorization': 'Bearer $_authentication'}.entries;
  }

  /// do a get request
  ///
  /// **arguments**:
  ///
  ///     [path] - required
  ///     [headers] - optional
  ///     [queryParams] - optional
  ///
  /// **throws:**
  ///
  ///     [NetworkException]
  ///     [RequestException]

  Future<String> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var uri = Uri(
        host: _host,
        path: path,
        port: _port,
        queryParameters: queryParams,
        scheme: _scheme,
      );
      headers = {...defaultHeaders, ...(headers ?? {})};
      if (_authentication != null) {
        headers.addEntries(_buildAuthorizationHeader());
      }
      var res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        return utf8.decode(res.bodyBytes);
      } else {
        String body = utf8.decode(res.bodyBytes);
        ApiError error = ApiError.fromJson(json.decode(body));
        error.statusCode = res.statusCode;
        throw RequestException(error);
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on RequestException {
      rethrow;
    } catch (e) {
      dev.log(
          'error throw when send get request to $path. Type: ${e.runtimeType.toString()}');
      throw NetworkException('network error with: ${e.runtimeType.toString()}');
    }
  }

  /// do a post request
  ///
  /// **arguments:**
  ///
  ///     [path] - required
  ///     [body] - required
  ///     [headers] - optional
  /// **throws:**
  ///
  ///     [NetworkException]

  Future<String> post(
    String path, {
    required Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      var uri = Uri(
        host: _host,
        path: path,
        port: _port,
        scheme: _scheme,
      );
      headers = {...defaultHeaders, ...(headers ?? {})};
      if (_authentication != null) {
        headers.addEntries(_buildAuthorizationHeader());
      }
      var res = await http.post(uri, headers: headers, body: body);
      if (res.statusCode < 400 && res.statusCode >= 200) {
        return utf8.decode(res.bodyBytes);
      } else {
        String resBody = utf8.decode(res.bodyBytes);
        ApiError error = ApiError.fromJson(json.decode(resBody));
        throw RequestException(error);
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      dev.log(
          'error throw when send post request to $path. Type: ${e.runtimeType.toString()}');
      throw NetworkException('network error with: ${e.runtimeType.toString()}');
    }
  }
}
