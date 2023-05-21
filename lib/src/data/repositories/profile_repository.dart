import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/data/datasources/local/profile_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
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
  Future<Either<Failure, Profile?>> getProfileById(String profileId) async {
    var res = await remoteDataSource.getProfileById(profileId);
    if (res.isRight()) {
      var profile = res.getOrElse(() => null);
      dev.log(profile == null
          ? "No Profile found"
          : 'Profile with id $profileId found');
      return Right(profile);
    } else {
      return res;
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfiles(String userId) async {
    var res = await remoteDataSource.getProfiles(userId);
    if (res.isRight()) {
      var profiles = res.getOrElse(() => []);
      dev.log('number of profiles found: ${profiles.length}');
      return Right(profiles);
    } else {
      return res;
    }
  }

  @override
  Future<Either<Failure, Profile>> newProfile(Profile profile) async {
    var res = await remoteDataSource.createProfile(profile);
    if (res.isRight()) {
      var profile = res.getOrElse(() => throw UnimplementedError());
      localDatasource.cacheActiveProfile(profile);
      return Right(profile);
    } else {
      return Left(ProfileFailure('Error while create profile'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> cacheCurrentActiveProfile(
      Profile profile) async {
    return await localDatasource.cacheActiveProfile(profile);
  }

  @override
  Either<Failure, Profile> getCurrentActiveProfile() {
    return localDatasource.getActiveProfile();
  }

  @override
  Future<Either<Failure, bool>> disableCurrentActiveProfile() async {
    return await Right(await localDatasource.disableActiveProfile());
  }
}
