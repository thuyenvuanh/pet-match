import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/text_divider.dart';
import 'package:pet_match/src/utils/constant.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var buttonStyle = ButtonStyle(
    overlayColor: MaterialStateColor.resolveWith(
      (states) => Resource.primaryTintColor,
    ),
  );

  late final AuthBloc _authBloc;
  late final StreamSubscription listener;
  @override
  void initState() {
    super.initState();
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _authBloc = BlocProvider.of<AuthBloc>(context);
    listener = _authBloc.stream.listen((event) {
      switch (event.runtimeType) {
        case PhoneNumberRequired:
          Navigator.pushNamed(context, AppRoutes.otp.name);
          break;
        case Authenticated:
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.root.name,
            (route) => false,
          );
          break;
        case AuthError:
          break;
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  void onSignInGoogle() => _authBloc.add(GoogleSignInRequest());

  void privacyPolicyView() {}

  void termAndConditionView() {}

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) => state is AuthError,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong! Please try again later'),
            duration: Duration(seconds: 3),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Resource.lightBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 76, bottom: 64),
                  child: Image.asset(
                    Resource.brandLogo,
                    height: 166,
                    width: 183,
                  ),
                ),
                const Text(
                  'Đăng nhập để tiếp tục.',
                  textAlign: TextAlign.center,
                ),
                Button(
                  label: 'Đăng nhập Gmail',
                  onTap: onSignInGoogle,
                  padding: const EdgeInsets.symmetric(horizontal: 40)
                      .copyWith(top: 32),
                  borderRadius: Resource.defaultBorderRadius,
                ),
              ],
            ),
            Column(
              children: [
                const TextDivider(
                  symmetricIndent: 40,
                  child: Text('Đăng nhập với'),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedIconButton(
                        onTap: () {},
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        borderRadius: Resource.defaultBorderRadius,
                        child: Image.asset(Resource.facebookIcon),
                      ),
                      RoundedIconButton(
                        onTap: () {},
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        borderRadius: Resource.defaultBorderRadius,
                        child: Image.asset(Resource.googleIcon),
                      ),
                      RoundedIconButton(
                        onTap: () {},
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        borderRadius: Resource.defaultBorderRadius,
                        child: Image.asset(Resource.instagramIcon),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: privacyPolicyView,
                  style: buttonStyle,
                  child: const Text(
                    'Chính sách riêng tư',
                    style: TextStyle(color: Resource.primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: termAndConditionView,
                  style: buttonStyle,
                  child: const Text(
                    'Điều khoản sử dụng',
                    style: TextStyle(color: Resource.primaryColor),
                  ),
                ),
                const SizedBox(height: 37)
              ],
            )
          ],
        ),
      ),
    );
  }
}
