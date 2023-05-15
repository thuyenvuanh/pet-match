import 'package:get_it/get_it.dart';
import 'package:pet_match/src/data/datasources/local/onboarding_local_datasource.dart';
import 'package:pet_match/src/data/datasources/local/profile_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
import 'package:pet_match/src/data/repositories/auth_repository.dart';
import 'package:pet_match/src/data/repositories/onboarding_repository.dart';
import 'package:pet_match/src/data/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/onboarding_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //future instances - ensure to be initialized
  sl.registerLazySingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());
  await sl.isReady<SharedPreferences>();
  //! blocs
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => OnboardingBloc(sl())..add(ReadOnboardingStatus()));
  sl.registerFactory(() => CreateProfileBloc(sl()));
  sl.registerFactory(() => HomeBloc(sl()));

  //! repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl(), sl()));

  //! Data sources
  sl.registerLazySingleton(() => FirebaseDataSource());
  sl.registerLazySingleton(() => OnboardingLocalDatasource(sl()));
  sl.registerLazySingleton(() => ProfileLocalDatasource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteDataSource());
}
