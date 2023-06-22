import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/views/chat_screen/chat_screen.dart';
import 'package:pet_match/src/presentation/views/create_profile/create_profile_screen.dart';
import 'package:pet_match/src/presentation/views/navigation.dart';
import 'package:pet_match/src/presentation/views/onboarding.dart';
import 'package:pet_match/src/presentation/views/phone_verification.dart';
import 'package:pet_match/src/presentation/views/premium_register/premium_register.dart';
import 'package:pet_match/src/presentation/views/profile_detail/profile_detail.dart';
import 'package:pet_match/src/presentation/views/profile_edit/profile_edit.dart';
import 'package:pet_match/src/presentation/views/select_profile_screen.dart';
import 'package:pet_match/src/presentation/views/sign_in.dart';
import 'package:pet_match/src/utils/error/error_screen.dart';

class RouteGenerator {
  static signInRoute() => CupertinoPageRoute(
        builder: (context) => const SignInScreen(),
      );

  static onboardingRoute() => CupertinoPageRoute(
        builder: (context) => BlocProvider.value(
          value: sl<OnboardingBloc>(),
          child: const OnboardingScreen(),
        ),
      );

  static phoneVerificationRoute() => CupertinoPageRoute(
        builder: (context) => const PhoneVerification(),
      );

  static createProfileRoute() => CupertinoPageRoute(
        builder: (context) => BlocProvider.value(
          value: sl<CreateProfileBloc>()..add(StartCreateProfile()),
          child: const CreateProfileScreen(),
        ),
      );

  static profileDetailRoute(RouteSettings settings) => CupertinoPageRoute(
        builder: (context) {
          final args = settings.arguments as ProfileDetailScreenArguments;
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<ProfileBloc>()),
              BlocProvider.value(value: sl<SwipeBloc>()),
              BlocProvider.value(value: sl<SubscriptionBloc>()),
            ],
            child: ProfileDetailScreen(args: args),
          );
        },
      );

  static profileEditRoute(RouteSettings settings) {
    final args = settings.arguments as Profile;
    return CupertinoPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<ProfileBloc>()),
            BlocProvider.value(value: sl<SwipeBloc>()),
          ],
          child: EditProfileDetailScreen(profile: args),
        );
      },
    );
  }

  static createChatScreenRoute(RouteSettings settings) {
    final args = settings.arguments as ChatScreenArguments;
    return CupertinoPageRoute(builder: (context) {
      return ChatScreen(
        args: args,
      );
    });
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    AppRoutes route = AppRoutes.fromString(settings.name);
    switch (route) {
      case AppRoutes.root:
        return CupertinoPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              // BlocProvider.value(value: sl<HomeBloc>()..add(GetInitialData())),
              BlocProvider.value(value: sl<AuthBloc>()),
              BlocProvider.value(value: sl<ProfileBloc>()),
              BlocProvider.value(value: sl<SwipeBloc>()),
              BlocProvider.value(value: sl<SubscriptionBloc>()),
            ],
            child: const HomeScreen(),
          ),
        );
      case AppRoutes.onboarding:
        return onboardingRoute();
      case AppRoutes.signIn:
        return signInRoute();
      case AppRoutes.chat:
        return createChatScreenRoute(settings);
      case AppRoutes.otp:
        return phoneVerificationRoute();
      case AppRoutes.createProfile:
        return createProfileRoute();
      case AppRoutes.profiles:
        return CupertinoModalPopupRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<ProfileBloc>()),
              BlocProvider.value(value: sl<AuthBloc>()),
            ],
            child: const ProfileSelectScreen(),
          ),
        );
      case AppRoutes.profileDetails:
        return profileDetailRoute(settings);
      case AppRoutes.profileEdit:
        return profileEditRoute(settings);
      case AppRoutes.premiumRegister:
        return CupertinoPageRoute(
          builder: (context) => BlocProvider.value(
            value: sl<SubscriptionBloc>(),
            child: const PremiumRegisterScreen(),
          ),
        );
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
  profiles("profiles"),
  profileDetails("/profile-detail"),
  profileEdit("/profile-detail/edit"),
  chat("/chat"),
  premiumRegister("premium");

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
