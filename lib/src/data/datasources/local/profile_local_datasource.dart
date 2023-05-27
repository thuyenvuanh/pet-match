import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDatasource {
  final SharedPreferences localStorage;
  final String activeProfile = "activeProfile";
  final String likedProfiles = 'likedProfiles';

  ProfileLocalDatasource(this.localStorage);

  Future<bool> cacheActiveProfile(Profile profile) async {
    try {
      var profileEncoded = json.encode(profile.toJson());
      await localStorage.setString(activeProfile, profileEncoded);
      return true;
    } on Exception {
      dev.log('Unknown exception when save data to local storage');
      return false;
    }
  }

  Profile? getActiveProfile() {
    try {
      var profileEncoded = localStorage.getString(activeProfile);
      if (profileEncoded == null || profileEncoded == 'null') {
        throw NotFoundException('activeProfile');
      }
      Profile profile = Profile.fromJson(json.decode(profileEncoded) ?? {});
      return profile;
    } on NotFoundException {
      dev.log('Not found exception for key: $activeProfile');
      return null;
    } on Exception {
      dev.log('Unknown exception thrown');
      return null;
    }
  }

  Future<bool> disableActiveProfile() async {
    dev.log('removing active Profile');
    var res = await localStorage.remove(activeProfile);
    await localStorage.remove(likedProfiles);
    if (res) {
      dev.log("$activeProfile removed");
    } else {
      dev.log('$activeProfile not found');
    }
    return res;
  }
}
