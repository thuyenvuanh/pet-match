import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pet_match/src/domain/models/like.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeLocalDataSource {
  final SharedPreferences _localStorage;
  final String key = 'likedProfiles';

  SwipeLocalDataSource(SharedPreferences localStorage)
      : _localStorage = localStorage;

  List<Like> getLikedProfilesCached() {
    dev.log('getting liked profiles and comments in storage');
    String? encodedData = _localStorage.getString(key);
    if (encodedData == null) throw NotFoundException(key);
    final listMappedProfiles = List.castFrom(json.decode(encodedData));
    if (listMappedProfiles.isEmpty) return [];
    final listProfiles =
        listMappedProfiles.map((e) => Like.fromJson(e)).toList();
    dev.log('found ${listProfiles.length} entities in storage');
    return listProfiles;
  }

  void saveLikedProfile(Like likedProfile) {
    dev.log('saving new liked profile to storage');
    String encodedData = _localStorage.getString(key) ?? "[]";
    final List<Map<String, dynamic>> listMappedProfiles =
        List.castFrom(json.decode(encodedData));
    listMappedProfiles.add(likedProfile.toJson());
    encodedData = json.encode(listMappedProfiles);
    dev.log('saved successfully');
    _localStorage.setString(key, encodedData);
  }
}
