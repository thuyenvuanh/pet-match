import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/views/create_profile/create_profile_screen.dart';
import 'package:pet_match/src/presentation/views/navigation.dart';
import 'package:pet_match/src/presentation/views/onboarding.dart';
import 'package:pet_match/src/presentation/views/phone_verification.dart';
import 'package:pet_match/src/presentation/views/select_profile_screen.dart';
import 'package:pet_match/src/presentation/views/sign_in.dart';
import 'package:pet_match/src/utils/error/error_screen.dart';

class RouteGenerator {
  static signInRoute() => CupertinoPageRoute(
        builder: (context) => const SignInScreen(),
      );

  static homeRoute() => CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => sl<HomeBloc>()..add(GetInitialData())),
            BlocProvider(create: (context) => sl<ProfileBloc>()),
            BlocProvider(create: (context) => sl<SwipeBloc>()),
          ],
          child: const HomeScreen(),
        ),
      );

  static onboardingRoute() => CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<OnboardingBloc>(),
          child: const OnboardingScreen(),
        ),
      );

  static selectProfileRoute() => CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<ProfileBloc>(),
          child: const ProfileSelectScreen(),
        ),
      );

  static phoneVerificationRoute() => CupertinoPageRoute(
        builder: (context) => const PhoneVerification(),
      );

  static createProfileRoute() => CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => CreateProfileBloc(
            sl<ProfileRepository>(),
            sl<StorageRepository>(),
          )..add(StartCreateProfile()),
          child: const CreateProfileScreen(),
        ),
      );

  static Route<dynamic> generateRoute(RouteSettings settings) {
    AppRoutes route = AppRoutes.fromString(settings.name);
    switch (route) {
      case AppRoutes.root:
        return homeRoute();
      case AppRoutes.onboarding:
        return onboardingRoute();
      case AppRoutes.signIn:
        return signInRoute();
      case AppRoutes.otp:
        return phoneVerificationRoute();
      case AppRoutes.createProfile:
        return createProfileRoute();
      case AppRoutes.profiles:
        return selectProfileRoute();
      default: // error routes.
        return CupertinoPageRoute(builder: (context) => const ErrorScreen());
    }
  }
}

enum AppRoutes implements Comparable<AppRoutes> {
  root("/"),
  onboarding("onboarding"),
  otp("/code"),
  signIn("sign-in"),
  error("error"),
  createProfile('profiles/create'),
  profiles("/profiles");

  final String name;

  const AppRoutes(this.name);

  static AppRoutes fromString(String? name) {
    try {
      if (name == null) throw TypeError();
      return AppRoutes.values.firstWhere((element) => element.name == name);
    } on ArgumentError {
      developer.log("Route with name $name now found return error routes");
      return AppRoutes.error;
    } on TypeError {
      developer.log("Empty route. return error routes");
      return AppRoutes.error;
    }
  }

  @override
  int compareTo(AppRoutes other) => name.compareTo(other.name);
}
