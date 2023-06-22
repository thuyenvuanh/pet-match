import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, Subscription>> getSubscriptionData(String userId);

  Future<Either<Failure, Subscription>> cacheSubscription(
      Subscription subscription);

  Future<int> getRemainingSwipeOfDay();
  Future<void> subtractRemains();
  Future<int> addMoreSwipe();
}
