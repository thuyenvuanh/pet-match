import 'package:get_it/get_it.dart';
import 'package:pet_match/src/data/datasources/local/auth_local_datasource.dart';
import 'package:pet_match/src/data/datasources/local/onboarding_local_datasource.dart';
import 'package:pet_match/src/data/datasources/local/profile_local_datasource.dart';
import 'package:pet_match/src/data/datasources/local/subscription_local_datasource.dart';
import 'package:pet_match/src/data/datasources/local/swipe_local_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/here_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/subscription_remote_datasource.dart';
import 'package:pet_match/src/data/datasources/remote/swipe_remote_datasource.dart';
import 'package:pet_match/src/data/repositories/auth_repository.dart';
import 'package:pet_match/src/data/repositories/here_repository.dart';
import 'package:pet_match/src/data/repositories/onboarding_repository.dart';
import 'package:pet_match/src/data/repositories/profile_repository.dart';
import 'package:pet_match/src/data/repositories/storage_repository.dart';
import 'package:pet_match/src/data/repositories/subscription_repository.dart';
import 'package:pet_match/src/data/repositories/swipe_repository.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/here_repository.dart';
import 'package:pet_match/src/domain/repositories/onboarding_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';
import 'package:pet_match/src/domain/repositories/subscription_repository.dart';
import 'package:pet_match/src/domain/repositories/swipe_repository.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/here_bloc/here_bloc.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/utils/rest_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //future instances - ensure to be initialized
  sl.registerLazySingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());
  await sl.isReady<SharedPreferences>();
  //* blocs
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerFactory(() => OnboardingBloc(sl())..add(ReadOnboardingStatus()));
  sl.registerFactory(() => CreateProfileBloc(sl(), sl()));
  sl.registerFactory(() => HomeBloc(sl()));
  sl.registerFactory(() => SwipeBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ProfileBloc(sl(), sl(), sl()));
  sl.registerFactory(() => HereBloc(sl()));
  sl.registerFactory(() => SubscriptionBloc(sl()));

  //* repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<StorageRepository>(
      () => StorageRepositoryImpl(sl()));
  sl.registerLazySingleton<SwipeRepository>(
      () => SwipeRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<HereRepository>(() => HereRepositoryImpl(sl()));
  sl.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl(), sl()));

  //* Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl(), sl()));
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => OnboardingLocalDatasource(sl()));
  sl.registerLazySingleton(() => ProfileLocalDatasource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteDataSource(sl()));
  sl.registerLazySingleton(() => FirebaseStorageDataSource());
  sl.registerLazySingleton(() => SwipeLocalDataSource(sl()));
  sl.registerLazySingleton(() => SwipeRemoteDataSource(sl()));
  sl.registerLazySingleton(() => HereDatasource());
  sl.registerLazySingleton(() => SubscriptionRemoteDataSource(sl()));
  sl.registerLazySingleton(() => SubscriptionLocalDataSource(sl()));
  //others
  sl.registerLazySingleton(() => RestClient(sl()));
}
