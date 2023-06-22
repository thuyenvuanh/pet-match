import 'dart:io';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/token_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:pet_match/src/utils/firebase_options.dart';
import 'package:pet_match/src/injection_container.dart' as di;
import 'package:pet_match/src/utils/push_notification.dart';
import 'package:pet_match/src/utils/rest_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  HttpOverrides.global = DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MobileAds.instance.initialize();
  await PushNotification().initNotification();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  bool _isOnboarding = true;
  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    var localStorage = sl<SharedPreferences>();
    try {
      var data = localStorage.getFromAuthStorage('authToken');
      AuthorizationToken token = AuthorizationToken.fromJson(data);
      final decodedJwt = JwtDecoder.decode(token.refreshToken!);
      var exp = DateTime.fromMillisecondsSinceEpoch(decodedJwt['exp'] * 1000);
      exp = exp.subtract(const Duration(days: 1));
      if (exp.isBefore(DateTime.now()) ||
          exp
              .difference(DateTime.now())
              .compareTo(const Duration(days: 1))
              .isNegative) {
        _authBloc.add(SignOutRequest());
      }
    } catch (e) {
      dev.log('token not found');
    }
    final isOnboarding = sl<SharedPreferences>()
        .getFromGlobalStorage('onboardingEnabled') as bool?;
    if (isOnboarding != null) {
      setState(() {
        _isOnboarding = isOnboarding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _authBloc..add(GetAuthorizationStatus()),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: _authBloc,
        buildWhen: (_, state) =>
            state is Authenticated ||
            state is Unauthenticated ||
            state is GettingAuthorizationStatus,
        builder: (context, state) {
          var route = AppRoutes.root;
          if (state is Unauthenticated) {
            route = AppRoutes.signIn;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(useMaterial3: true).copyWith(
              splashColor: Resource.primaryTintColor,
              snackBarTheme: const SnackBarThemeData(
                actionTextColor: Resource.primaryColor,
              ),
              splashFactory: InkSparkle.splashFactory,
            ),
            title: 'PetMatch',
            initialRoute:
                _isOnboarding ? AppRoutes.onboarding.name : route.name,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget({
    super.key,
    required this.child,
    required this.authBloc,
  }) : super(child: child);

  final Widget child;
  final AuthBloc authBloc;
  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return authBloc.state != oldWidget.authBloc.state;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
