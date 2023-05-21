import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class ProfileRepository {

  Either<Failure, Profile> getCurrentActiveProfile();

  Future<Either<Failure, bool>> cacheCurrentActiveProfile(Profile profile);

  Future<Either<Failure, bool>> disableCurrentActiveProfile();

  Future<Either<Failure, List<Profile>>> getProfiles(String accountId);

  Future<Either<Failure, Profile?>> getProfileById(String profileId);

  Future<Either<Failure, Profile>> newProfile(Profile profile);

  Future<Either<Failure, Profile>> updateProfile(Profile profile);

  Future<Either<Failure, Profile>> deleteProfile(String profileId);

}