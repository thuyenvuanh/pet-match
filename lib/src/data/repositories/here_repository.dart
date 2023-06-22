import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/api/here_map_api.dart';
import 'package:pet_match/src/data/datasources/remote/here_datasource.dart';
import 'package:pet_match/src/domain/repositories/here_repository.dart';

import '../../utils/error/failure.dart';

class HereRepositoryImpl implements HereRepository {
  final HereDatasource hereMap;

  HereRepositoryImpl(this.hereMap);

  @override
  Future<Either<Failure, List<HereMapResponse>>> getHereMapAddresses(
      String address) async {
    try {
      var response = await hereMap.getAddressData(address);
      if (response.isEmpty) {
        return const Left(
            NotFoundFailure(object: "List<HereMapResponse>", value: "empty"));
      } else {
        return Right(response);
      }
    } catch (e) {
      log('[Here_repository] Failed to get addresses from HereMap');
      return const Left(RequestFailure(code: 'Unknown', reason: "Unknown"));
    }
  }
}
