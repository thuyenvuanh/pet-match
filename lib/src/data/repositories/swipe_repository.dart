import 'dart:developer' as dev;

import 'package:faker/faker.dart';
import 'package:pet_match/src/data/datasources/local/swipe_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/swipe_remote_datasource.dart';
import 'package:pet_match/src/domain/models/like.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/repositories/swipe_repository.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class SwipeRepositoryImpl implements SwipeRepository {
  final SwipeLocalDataSource _localDataSource;
  final SwipeRemoteDataSource _remoteDataSource;

  SwipeRepositoryImpl(SwipeLocalDataSource localDataSource,
      SwipeRemoteDataSource remoteDataSource)
      : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Like>>> getLikedProfile() async {
    try {
      final likedProfiles = _localDataSource.getLikedProfilesCached();
      return Right(likedProfiles);
    } on NotFoundException catch (e) {
      return Left(SharedPreferencesFailure.notFound(key: e.field));
    } on RefreshTokenInvalidException {
      return Left(RefreshTokenInvalidFailure());
    }
  }

  @override
  Future<Either<Failure, void>> likeProfile(Profile profile,
      [String? comment]) async {
    try {
      Like likedProfile = Like(
        id: faker.guid.guid(),
        comment: comment,
        profile: profile,
        createdTS: DateTime.now(),
        updatedTS: DateTime.now(),
      );
      _localDataSource.saveLikedProfile(likedProfile);
      return const Right(null);
    } on RefreshTokenInvalidException {
      return Left(RefreshTokenInvalidFailure());
    } catch (e) {
      dev.log(
          'unexpected error thrown when caching liked profile. Type: ${e.runtimeType}');
      return const Left(
        SharedPreferencesFailure(
            errorCode: 'SAVE_TO_STR', message: "Cannot save to local storage"),
      );
    }
  }

  @override
  Future<Either<Failure, Profile>> passProfile(Profile profile) async {
    //* not implemented yet
    throw UnimplementedError();
  }
}
