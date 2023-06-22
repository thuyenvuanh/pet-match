import 'dart:async';
import 'dart:developer' as dev;

import 'package:pet_match/src/data/datasources/local/swipe_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/swipe_remote_datasource.dart';
import 'package:pet_match/src/domain/models/reaction.dart';
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
  Future<Either<Failure, List<Reaction>>> getLikedProfile(
      Profile profile) async {
    try {
      var likedProfiles = _localDataSource.getLikedProfilesCached();
      return Right(likedProfiles);
    } on NotFoundException {
      try {
        final likedProfiles = await _remoteDataSource.getLikedProfiles(profile);
        _localDataSource.saveLikedProfileList(likedProfiles);
        return Right(likedProfiles);
      } on RequestException catch (e) {
        dev.log('${e.error.debugMessage}');
        return Left(RequestFailure(
          code: e.error.httpStatus ?? "",
          reason: e.error.message ?? "",
        ));
      }
    } on RefreshTokenInvalidException {
      return Left(RefreshTokenInvalidFailure());
    }
  }

  @override
  Future<Either<Failure, void>> likeProfile(Profile from, Profile to,
      [String? comment]) async {
    try {
      Reaction likedProfile =
          await _remoteDataSource.sendLike(from, to, comment);
      // _localDataSource.saveLikedProfile(likedProfile);
      return const Right(null);
    } on RefreshTokenInvalidException {
      dev.log('[swipe_repository] Refresh token expired. Sign out to continue');
      return Left(RefreshTokenInvalidFailure());
    } catch (e) {
      dev.log('[swipe_repository] unexpected error, type: ${e.runtimeType}');
      return const Left(
        SharedPreferencesFailure(
          errorCode: 'SAVE_TO_STR',
          message: "Cannot save to local storage",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Profile>> passProfile(
      Profile createdBy, Profile profile) async {
    try {
      Reaction reaction = await _remoteDataSource.sendPass(createdBy, profile);
      _localDataSource.removeReaction(reaction);
      dev.log('pass successful');
      return Right(profile);
    } on NetworkException {
      dev.log('[swipe_repository] Failed to send like');
      return const Left(
          RequestFailure(code: 'swipe pass failed', reason: 'unknown'));
    } on TimeoutException {
      dev.log('[swipe_repository] Server take too long to response');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getSuggestions(Profile profile) async {
    try {
      final res = await _remoteDataSource.getSuggestion(profile);
      return Right(res);
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
}
