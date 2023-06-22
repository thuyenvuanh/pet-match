import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/reaction.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class SwipeRepository {
  Future<Either<Failure, List<Reaction>>> getLikedProfile(Profile profile);

  Future<Either<Failure, void>> likeProfile(Profile from, Profile to,
      [String? comment]);

  Future<Either<Failure, Profile>> passProfile(Profile createdBy, Profile profile);

  Future<Either<Failure, List<Profile>>> getSuggestions(Profile profile);
}
