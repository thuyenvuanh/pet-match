import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:pet_match/src/utils/firebase_options.dart';
import 'package:pet_match/src/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _bloc;
  bool _isOnboarding = true;
  @override
  void initState() {
    super.initState();
    _bloc = sl<AuthBloc>();
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
    return BlocProvider(
      create: (context) => _bloc..add(GetAuthorizationStatus()),
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: _bloc,
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
