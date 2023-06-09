import 'dart:async';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/data/datasources/local/profile_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDatasource localDatasource;

  ProfileRepositoryImpl(this.remoteDataSource, this.localDatasource);

  @override
  Future<Either<Failure, Profile>> deleteProfile(String profileId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Profile?>> getProfileById(
    String profileId, [
    bool force = false,
  ]) async {
    var localProfile = localDatasource.getActiveProfile();
    if (localProfile == null || force) {
      var profile = await remoteDataSource.getProfileById(profileId);
      if (profile == null) {
        dev.log('[profile_repository] Profile not found with ID: $profileId');
        return Left(NotFoundFailure(object: 'Profile', value: profileId));
      } else {
        dev.log("[profile_repository] Profile found");
        return Right(profile);
      }
    } else {
      if (localProfile.id == profileId) {
        return Right(localProfile);
      } else {
        return Left(NotFoundFailure(object: 'Profile', value: profileId));
      }
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfiles(String userId) async {
    try {
      var profiles = await remoteDataSource.getProfiles(userId);
      return Right(profiles);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException {
      return Left(TimeoutFailure('userId: $userId, Server take too long'));
    }
  }

  @override
  Future<Either<Failure, Profile>> newProfile(
      Profile profile, String userId) async {
    var res = await remoteDataSource.createProfile(profile, userId);
    if (res == null) {
      return const Left(ProfileFailure('Error while create profile'));
    } else {
      // localDatasource.cacheActiveProfile(profile);
      return Right(res);
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(
      Profile profile, String userId) async {
    try {
      var res = await remoteDataSource.updateProfile(profile, userId);
      if (res == null) {
        return const Left(ProfileFailure('Error while updating profile'));
      } else {
        // localDatasource.cacheActiveProfile(profile);
        return Right(res);
      }
    } catch (e) {
      dev.log('Something went wrong. Type: ${e.runtimeType}');
      return const Left(RequestFailure(code: "Unknown", reason: "Unknown"));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheCurrentActiveProfile(
      Profile profile) async {
    var res = await localDatasource.cacheActiveProfile(profile);
    if (res) {
      return Right(res);
    } else {
      return const Left(SharedPreferencesFailure(
          errorCode: 'WRITE_FAILED',
          message: "Cannot write to Shared Preferences"));
    }
  }

  @override
  Either<Failure, Profile> getCurrentActiveProfile() {
    var res = localDatasource.getActiveProfile();
    if (res != null) {
      return Right(res);
    } else {
      return const Left(SharedPreferencesFailure(
          errorCode: 'NOT_FOUND', message: 'data not found in local'));
    }
  }

  @override
  Future<Either<Failure, bool>> disableCurrentActiveProfile() async {
    return Right(await localDatasource.disableActiveProfile());
  }
}
