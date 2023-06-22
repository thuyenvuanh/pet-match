import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension PetMatchDateConverter on DateFormat {
  DateTime parsePetMatch(String data) =>
      DateFormat('dd/MM/yyyy HH:mm:ss').parse(data);
  String formatPetMatch(DateTime data) =>
      DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
}

extension MediaQueryExtension on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  EdgeInsets get screenViewInsets => MediaQuery.of(this).viewInsets;

  double? get iconSize => IconTheme.of(this).size;
}

extension CheckDateTime on DateTime {
  /// [today] == [0]
  /// [yesterday] == [-1]
  /// [tomorrow] == [1]
  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  bool isToday() {
    return calculateDifference(this) == 0;
  }
}

extension GlobalStorage on SharedPreferences {
  static const String _globalKey = 'global';
  static const String _sessionKey = 'session';
  static const String _authKey = 'auth';

  Map<String, dynamic> _getGlobal() {
    String globalString = getString(_globalKey) ?? "{}";
    return json.decode(globalString) as Map<String, dynamic>;
  }

  Future<void> _setGlobal(dynamic globalMap) async {
    String encodedGlobalMap = json.encode(globalMap);
    await setString(_globalKey, encodedGlobalMap);
  }

  dynamic getFromGlobalStorage(String key) {
    var globalMap = _getGlobal();
    return globalMap[key];
  }

  bool removeFromGlobalStorage(String key) {
    var globalMap = _getGlobal();
    if (globalMap.containsKey(key)) {
      globalMap.remove(key);
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> addToGlobalStorage(String key, dynamic object) async {
    var globalMap = _getGlobal();
    globalMap[key] = object;
    await _setGlobal(globalMap);
  }

  Future<bool> resetGlobalStorage() async {
    return await setString(_globalKey, "{}");
  }

  Map<String, dynamic> _getSession() {
    String sessionString = getString(_sessionKey) ?? "{}";
    return json.decode(sessionString) as Map<String, dynamic>;
  }

  Future<void> _setSession(dynamic newMap) async {
    String encodedSessionMap = json.encode(newMap);
    await setString(_sessionKey, encodedSessionMap);
  }

  dynamic getFromSessionStorage(String key) {
    var sessionMap = _getSession();
    return sessionMap[key];
  }

  bool removeFromSessionStorage(String key) {
    var sessionMap = _getSession();
    if (sessionMap.containsKey(key)) {
      sessionMap.remove(key);
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> addToSessionStorage(String key, dynamic object) async {
    var sessionMap = _getSession();
    sessionMap[key] = object;
    await _setSession(sessionMap);
  }

  Future<bool> resetSessionStorage() async {
    return await setString(_sessionKey, "{}");
  }

  Map<String, dynamic> _getAuthStorage() {
    String authString = getString(_authKey) ?? "{}";
    return json.decode(authString) as Map<String, dynamic>;
  }

  Future<void> _setAuthAttribute(dynamic authMap) async {
    String encodedAuthMap = json.encode(authMap);
    await setString(_authKey, encodedAuthMap);
  }

  dynamic getFromAuthStorage(String key) {
    var authMap = _getAuthStorage();
    return authMap[key];
  }

  bool removeFromAuthStorage(String key) {
    var authMap = _getAuthStorage();
    if (authMap.containsKey(key)) {
      authMap.remove(key);
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> addToAuthStorage(String key, dynamic object) async {
    var authMap = _getAuthStorage();
    authMap[key] = object;
    await _setAuthAttribute(authMap);
  }

  Future<bool> resetAuthStorage() async {
    return await setString(_authKey, "{}");
  }
}

extension DistanceUtils on LatLng {
  double calculateDistance(LatLng point) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((point.latitude - latitude) * p) / 2 +
        c(latitude * p) *
            c(point.latitude * p) *
            (1 - c((point.longitude - longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }
}
