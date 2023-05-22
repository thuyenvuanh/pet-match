import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/rest_helper.dart';

class ProfileRemoteDataSource {
  final RestClient restClient;

  static const String _getProfilesNP = '/pet-match/api/v1/profiles/user/';
  static const String _getProfileById = '/pet-match/api/v1/profiles/';
  static const String _createProfile = "/pet-match/api/v1/profiles";

  ProfileRemoteDataSource(this.restClient);

  Future<List<Profile>> getProfiles(String userId) async {
    try {
      final res = await restClient.get(_getProfilesNP + userId, headers: {});
      List body = List.castFrom(json.decode(res));
      return [...body.map((e) => Profile.fromShortJson(e)).toList()];
    } on NetworkException {
      dev.log('cannot get profiles of $userId');
      rethrow;
    }
  }

  Future<Profile?> getProfileById(String profileId) async {
    try {
      final path = _getProfileById + profileId;
      final res = await restClient.get(path, headers: {});
      Profile profile = Profile.fromJson(json.decode(res));
      return profile;
    } on NetworkException {
      dev.log("Cannot get profile with id: $profileId");
      rethrow;
    } on RequestException catch (ex) {
      dev.log('Request get failed with status code ${ex.error.statusCode}');
      if (ex.error.statusCode == 404) {
        dev.log('Profile not found');
        return null;
      }
    } on Exception catch (ex) {
      dev.log("Unknown exception thrown: ${ex.runtimeType}");
      rethrow;
    }
    return null;
  }

  Future<Profile> updateProfile(Profile profile) async {
    throw UnimplementedError();
  }

  Future<Profile?> createProfile(Profile profile) async {
    try {
      var jsonData = json.encode(profile.toJson());
      final res = await restClient.post(_createProfile, body: jsonData);
      Profile body = Profile.fromJson(json.decode(res));
      return body;
    } on NetworkException {
      dev.log("Cannot create profile with name: ${profile.name}");
      rethrow;
    } on RequestException catch (ex) {
      dev.log('Request get failed with status code ${ex.error.statusCode}');
      if (ex.error.statusCode == 404) {
        dev.log('Profile not found');
        return null;
      }
    } on Exception catch (ex) {
      dev.log("Unknown exception thrown: ${ex.runtimeType}");
      rethrow;
    }
    return null;
  }

  Future<Profile> deleteProfile(String profileId) async {
    throw UnimplementedError();
  }
}
