import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/like.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class SwipeRepository {
  Future<Either<Failure, List<Like>>> getLikedProfile();

  Future<Either<Failure, void>> likeProfile(Profile profile, [String? comment]);

  Future<Either<Failure, Profile>> passProfile(Profile profile);
}
