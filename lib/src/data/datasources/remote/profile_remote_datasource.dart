import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class ProfileRemoteDataSource {
  Future<Either<Failure, Profile>> getProfiles(String userId) async {
    throw UnimplementedError();
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
