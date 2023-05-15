import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/utils/firebase_options.dart';
import 'package:pet_match/src/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetMatch',
      initialRoute: AppRoutes.root.name,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
