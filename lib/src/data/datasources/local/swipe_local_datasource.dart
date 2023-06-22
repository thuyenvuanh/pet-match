import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pet_match/src/domain/models/reaction.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeLocalDataSource {
  final SharedPreferences _localStorage;
  static const String likedProfileKey = 'likedProfiles';

  SwipeLocalDataSource(SharedPreferences localStorage)
      : _localStorage = localStorage;

  List<Reaction> getLikedProfilesCached() {
    dev.log(
        '[swipe_local_datasource] getting liked profiles and comments in storage');
    String? encodedData = _localStorage.getFromSessionStorage(likedProfileKey);
    if (encodedData == null) throw NotFoundException(likedProfileKey);
    final listMappedProfiles = List.castFrom(json.decode(encodedData));
    if (listMappedProfiles.isEmpty) return [];
    final listProfiles =
        listMappedProfiles.map((e) => Reaction.fromJson(e)).toList();
    dev.log(
        '[swipe_local_datasource] found ${listProfiles.length} entities in storage');
    return listProfiles;
  }

  void saveLikedProfile(Reaction likedProfile) {
    dev.log('[swipe_local_datasource] saving new liked profile to storage');
    String encodedData =
        _localStorage.getFromSessionStorage(likedProfileKey) ?? "[]";
    final List<Map<String, dynamic>> listMappedProfiles =
        List.castFrom(json.decode(encodedData));
    listMappedProfiles.add(likedProfile.toJson());
    encodedData = json.encode(listMappedProfiles);
    dev.log('[swipe_local_datasource] saved successfully');
    _localStorage.addToSessionStorage(likedProfileKey, encodedData);
  }

  void saveLikedProfileList(List<Reaction> likedProfiles) {
    dev.log(
        '[swipe_local_datasource] saving new liked profile list to storage');
    _localStorage.removeFromSessionStorage(likedProfileKey);
    List<dynamic> encodedList = likedProfiles.map((e) => e.toJson()).toList();
    final encodedData = json.encode(encodedList);
    dev.log('[swipe_local_datasource] saved successfully');
    _localStorage.addToSessionStorage(likedProfileKey, encodedData);
  }

  void removeReaction(Reaction reaction) {
    dev.log('[swipe_local_datasource] saving new liked profile to storage');
    String encodedData =
        _localStorage.getFromSessionStorage(likedProfileKey) ?? "[]";
    final List<Map<String, dynamic>> listMappedProfiles =
        List.castFrom(json.decode(encodedData));
    listMappedProfiles.removeWhere(
        (element) => element['profile']['id'] == reaction.profile!.id);
    encodedData = json.encode(listMappedProfiles);
    dev.log('[swipe_local_datasource] saved successfully');
    _localStorage.addToSessionStorage(likedProfileKey, encodedData);
  }
}
