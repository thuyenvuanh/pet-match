import 'package:dartz/dartz.dart';
import 'package:pet_match/src/utils/error/failure.dart';

abstract class OnboardingRepository {
  Either<Failure, bool> getOnboardingEnableStatus();
  Either<Failure, void> disableOnboardingScreen();
}
