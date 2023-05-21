import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';
import 'package:pet_match/src/utils/rest_helper.dart';

class ProfileRemoteDataSource {
  final RestClient restClient;

  static const String _getProfilesNP = '/pet-match/v1/profiles/user/';
  static const String _getProfileById = '/pet-match/v1/profiles/';
  static const String _createProfile = "/pet-match/v1/profiles";

  ProfileRemoteDataSource(this.restClient);

  Future<Either<Failure, List<Profile>>> getProfiles(String userId) async {
    try {
      final res = await restClient.get(_getProfilesNP + userId, headers: {});
      if (res.isRight()) {
        String val = res.getOrElse(() => "[]");
        List body = List.castFrom(json.decode(val));
        return Right([...body.map((e) => Profile.fromShortJson(e)).toList()]);
      } else {
        return (res as Left).value;
      }
    } on Exception {
      return Left(NetworkFailure('Connection refused'));
    }
  }

  Future<Either<Failure, Profile?>> getProfileById(String profileId) async {
    try {
      final res = await restClient.get(
        _getProfileById + profileId,
        headers: {},
      );
      if (res.isRight()) {
        String val = res.getOrElse(() => "{}");
        Profile profile = Profile.fromJson(json.decode(val));
        return Right(profile);
      } else {
        return (res as Left).value;
      }
    } on Exception {
      return Left(NetworkFailure('Connection refused'));
    }
  }

  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    throw UnimplementedError();
  }

  Future<Either<Failure, Profile>> createProfile(Profile profile) async {
    try {
      var jsonData = json.encode(profile.toJson());
      final res = await restClient.post(_createProfile, body: jsonData);
      if (res.isRight()) {
        String val = res.getOrElse(() => "{}");
        Profile body = Profile.fromJson(json.decode(val));
        return Right(body);
      } else {
        return (res as Left).value;
      }
    } catch (e) {
      return Left(NetworkFailure('Connection refused'));
    }
  }

  Future<Either<Failure, Profile>> deleteProfile(String profileId) async {
    throw UnimplementedError();
  }
}
