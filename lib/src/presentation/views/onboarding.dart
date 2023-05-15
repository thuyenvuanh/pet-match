
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/carousel.dart';
import 'package:pet_match/src/utils/constant.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<OnboardingBloc>(context)
      ..stream.listen((event) {
        if (event is OnboardingStatus && event.status == false) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.root.name,
            (route) => false,
          );
        }
      });
  }

  void signIn() {
    _bloc.add(DisableOnboardingScreen());
  }

  void createNewAccount() {
    _bloc.add(DisableOnboardingScreen());
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.root.name, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            const Carousel(),
            Button(
              label: "Tạo tài khoản",
              onTap: createNewAccount,
              borderRadius: BorderRadius.circular(15),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Bạn đã có tài khoản? ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Đăng nhập',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Resource.primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = signIn,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class Routes {}
