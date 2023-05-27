import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences _localStorage;

  static const List<String> keys = ['activeProfile', 'likedProfiles'];

  AuthLocalDataSource(SharedPreferences sharedPreferences)
      : _localStorage = sharedPreferences;

  /// remove everything related to user instance out of local storage
  Future<void> signOut() async {
    for (var key in keys) {
      _localStorage.remove(key);
    }
  }
}
