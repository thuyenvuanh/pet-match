import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';
import 'package:pet_match/src/utils/rest_helper.dart';

class ProfileRemoteDataSource {
  final RestClient restClient;

  ProfileRemoteDataSource(this.restClient);

  Future<Either<Failure, List<Profile>>> getProfiles(String userId) async {
    var res = await restClient.get('/v1/profiles/user/$userId', headers: {});

    if (res.isRight()) {
      String val = res.getOrElse(() => throw UnimplementedError());
      List body = List.castFrom(json.decode(val));
      return Right([...body.map((e) => Profile.fromShortJson(e)).toList()]);
    } else {
      return (res as Left).value;
    }
  }

  Future<Either<Failure, Profile>> getProfileById(String profileId) async {
    throw UnimplementedError();
  }

  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    throw UnimplementedError();
  }

  Future<Either<Failure, Profile>> createProfile(Profile profile) async {
    throw UnimplementedError();
  }

  Future<Either<Failure, Profile>> deleteProfile(String profileId) async {
    throw UnimplementedError();
  }
}
