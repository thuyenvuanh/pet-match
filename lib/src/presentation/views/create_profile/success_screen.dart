import 'package:flutter/material.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/utils/constant.dart';

class CreateSuccessScreen extends StatelessWidget {
  const CreateSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Create Successful'),
          Button(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            label: 'Go to home',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.root.name, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
