import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pet_match/src/api/api_error.dart';
import 'package:pet_match/src/domain/models/token_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestClient {
  static const _host = "10.0.2.2";
  static const _port = 8080;
  static const _scheme = "http";

  static const _authKey = 'authToken';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept-Charset': "UTF-8"
  };

  final SharedPreferences localStorage;

  const RestClient(this.localStorage);

  Future<AuthorizationToken?> _isTokenExpired(AuthorizationToken token) async {
    final decodedToken = JwtDecoder.decode(token.accessToken!);
    int exp = decodedToken['exp'];
    if (DateTime.fromMillisecondsSinceEpoch(exp * 1000)
        .isAfter(DateTime.now())) {
      return null;
    } else {
      const path = '/pet-match/api/v1/auth/refresh-token';
      try {
        final resBody = await post(path, authorization: false, headers: {
          'Authorization': 'Bearer ${token.refreshToken!}',
        });
        return AuthorizationToken.fromJson(json.decode(resBody));
      } on RequestException catch (e) {
        dev.log("refresh-token invalid or expired. Signing out");
        throw RefreshTokenInvalidException();
      }
    }
  }

  Future<Map<String, String>> _buildAuthorizationHeader() async {
    var token =
        AuthorizationToken.fromJson(localStorage.getFromAuthStorage(_authKey)!);
    var newToken = await _isTokenExpired(token);

    if (newToken != null) {
      dev.log("Token expired and received new token");
      token = newToken;
      localStorage.addToAuthStorage(_authKey, token.toJson());
    }
    return {'Authorization': 'Bearer ${token.accessToken}'};
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
    bool authorization = true,
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
      if (authorization) {
        headers.addAll(await _buildAuthorizationHeader());
      }
      var res = await http.get(uri, headers: headers);
      if (res.statusCode >= 200 && res.statusCode < 400) {
        return utf8.decode(res.bodyBytes);
      } else {
        String body = utf8.decode(res.bodyBytes);
        if (body.isEmpty) {
          //in some case return unauthorize 401 with blank res body
          throw RequestException(ApiError(statusCode: res.statusCode));
        }
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
    Object? body,
    bool authorization = true,
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
      if (authorization) {
        headers.addAll(await _buildAuthorizationHeader());
      }
      var res = await http.post(uri, headers: headers, body: body);
      if (res.statusCode < 400 && res.statusCode >= 200) {
        return utf8.decode(res.bodyBytes);
      } else {
        String resBody = utf8.decode(res.bodyBytes);
        if (resBody.isEmpty) {
          //in some case return unauthorize 401 with blank res body
          throw RequestException(ApiError(statusCode: res.statusCode));
        }
        ApiError error = ApiError.fromJson(json.decode(resBody));
        error.statusCode = res.statusCode;
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
