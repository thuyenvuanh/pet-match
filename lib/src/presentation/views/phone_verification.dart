import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/presentation/widgets/otp_input_layout.dart';
import 'package:pet_match/src/presentation/widgets/phone_input_layout.dart';
import 'package:pet_match/src/presentation/widgets/rounded_back_button.dart';
import 'package:pet_match/src/utils/constant.dart';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final PageController _controller = PageController();
  late final AuthBloc _authBloc;
  late final StreamSubscription _authStream;

  final bool _hideBackButton = false;
  String _verificationId = "";
  bool isLoading = false;

  Duration animDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _authStream = _authBloc.stream.listen((event) {
      switch (event.runtimeType) {
        case PhoneLinkLoading:
          setState(() {
            isLoading = true;
          });
          return;
        case PhoneNumberRequired:
          setState(() {
            _controller.animateToPage(
              0,
              duration: animDuration,
              curve: Curves.ease,
            );
          });
          break;
        case OtpRequired:
          setState(() {
            _verificationId = (event as OtpRequired).verifyId;
            _controller.animateToPage(
              1,
              duration: animDuration,
              curve: Curves.ease,
            );
          });
          break;
        case PhoneLinkCanceled:
          Navigator.pop(context);
          return;
        case PhoneVerificationSuccess:
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (context) => const SignUpSuccess(),
              ),
              (route) => false);
          break;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _authStream.cancel();
    super.dispose();
  }

  void clickBack() {
    if (_controller.page == 0) {
      _authBloc.add(OnCancelPhoneLink());
    } else {
      setState(() {
        _controller.animateToPage(
          0,
          duration: animDuration,
          curve: Curves.ease,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.center,
          children: [
            isLoading
                ? Positioned(
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Resource.defaultBorderRadius,
                        boxShadow: const [
                          BoxShadow(
                              spreadRadius: 2,
                              offset: Offset(5, 5),
                              color: Colors.black),
                        ],
                      ),
                      child: const LoadingIndicator(),
                    ),
                  )
                : const Positioned.fill(child: SizedBox()),
            Positioned.fill(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  PhoneInputLayout(
                    isLoading: isLoading,
                  ),
                  OtpInputLayout(
                    verificationId: _verificationId,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 40,
              top: 44,
              child: Offstage(
                offstage: _hideBackButton,
                child: RoundedBackButton(onTap: isLoading ? null : clickBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpSuccess extends StatelessWidget {
  const SignUpSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Stack(
          children: [
            Positioned.fill(
              top: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sign_up_success.png',
                    height: 360,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 30),
                    child: Text(
                      "Chúc mừng!",
                      style: TextStyle(
                        fontSize: 24,
                        color: Resource.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Chúc mừng bạn đã đăng kí tài khoản thành công! Hãy tìm một em ghệ cho thú cưng của bạn ngay thôi nào!',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      height: 1.5,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Button(
                label: "Bắt đầu khám phá",
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.root.name, (route) => false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
