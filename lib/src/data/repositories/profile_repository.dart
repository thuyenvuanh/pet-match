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
  Future<Either<Failure, Profile>> getProfileById(String profileId) async {
    // TODO: implement getProfileById
    return Left(SharedPreferencesFailure.empty());
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfiles(String accountId) {
    // TODO: implement getProfiles
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Profile>> newProfile(Profile profile) async {
    dev.log("Mock return success");
    if(localDatasource.getActiveProfile().isLeft()) {
      localDatasource.cacheActiveProfile(profile);
    }
    return Right(profile);
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Either<Failure, bool> cacheCurrentActiveProfile(Profile profile) {
    return localDatasource.cacheActiveProfile(profile);
  }

  @override
  Either<Failure, Profile> getCurrentActiveProfile() {
    return localDatasource.getActiveProfile();
  }

}