import 'package:flutter/material.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Profile selection"),
          Button(
              label: "Create New Profile",
              padding: const EdgeInsets.symmetric(horizontal: 40),
              onTap: () {

                Navigator.pushNamed(context, AppRoutes.createProfile.name);
              }),
        ],
      ),
    );
  }
}
