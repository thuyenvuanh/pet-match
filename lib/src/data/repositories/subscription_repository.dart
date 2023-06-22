import 'package:faker/faker.dart';
import 'package:pet_match/src/data/datasources/local/subscription_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/subscription_remote_datasource.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/repositories/subscription_repository.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, Subscription>> cacheSubscription(
      Subscription subscription) async {
    try {
      var data = await _localDataSource.cacheData(subscription);
      return Right(data);
    } catch (e) {
      return const Left(SharedPreferencesFailure(
          errorCode: "SAVE_FAILED", message: "Save failed"));
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionData(
      String userId) async {
    try {
      final localSub = _localDataSource.getSubscriptionData();
      final remoteSub = await _remoteDataSource.getSubscriptionData(userId);
      if (localSub == null || localSub != remoteSub) {
        return await cacheSubscription(remoteSub);
      }
      return Right(localSub);
    } catch (e) {
      return const Left(RequestFailure(
        code: "FAILED",
        reason: "Not implemented",
      ));
    }
  }

  @override
  Future<int> getRemainingSwipeOfDay() async {
    return await _localDataSource.getRemainsSwipe();
  }

  @override
  Future<void> subtractRemains() async {
    return await _localDataSource.subtractRemain();
  }

  @override
  Future<int> addMoreSwipe() async {
    return await _localDataSource.addMoreSwipes();
  }
}
