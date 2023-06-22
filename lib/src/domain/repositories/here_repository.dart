import 'package:dartz/dartz.dart';
import 'package:pet_match/src/api/here_map_api.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class HereRepository {
  Future<Either<Failure, List<HereMapResponse>>> getHereMapAddresses(
      String address);
}
