import 'package:dartz/dartz.dart';
import 'package:pet_match/src/data/datasources/local/onboarding_local_datasource.dart';
import 'package:pet_match/src/domain/repositories/onboarding_repository.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {

  final OnboardingLocalDatasource localDatasource;

  OnboardingRepositoryImpl(this.localDatasource);

  @override
  Either<Failure, void> disableOnboardingScreen() {
    try {
      return Right(localDatasource.disableOnboardingScreen());
    } on Exception {
      return Left(SharedPreferencesFailure.empty());
    }
  }

  @override
  Either<Failure, bool> getOnboardingEnableStatus() {
    try {
      return Right(localDatasource.isOnboardingEnable);
    } on Exception {
      return Left(SharedPreferencesFailure.empty());
    }
  }

}