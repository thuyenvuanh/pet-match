import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pet_match/src/domain/models/token_model.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _authKey = 'authToken';
  final SharedPreferences _localStorage;

  AuthLocalDataSource(SharedPreferences sharedPreferences)
      : _localStorage = sharedPreferences;

  /// remove everything related to user instance out of local storage
  Future<void> signOut() async {
    _localStorage.resetSessionStorage();
    _localStorage.resetAuthStorage();
  }

  /// return [true] if tokens is present in local storage and refresh token duration
  /// greater than 1 day. Otherwise, return [false]
  bool getCurrentAuthStatus() {
    var authState = _localStorage.getFromAuthStorage(_authKey);
    if (authState == null) return false;
    var token = AuthorizationToken.fromJson(authState);
    if (token.refreshToken == null || token.refreshToken!.isEmpty) return false;
    var map = JwtDecoder.decode(token.refreshToken!);
    var expiredDate = DateTime.fromMillisecondsSinceEpoch(map['exp'] * 1000);
    if (expiredDate.subtract(const Duration(days: 1)).isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}
