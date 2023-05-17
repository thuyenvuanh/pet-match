import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.root.name,
            (route) => false,
          );
          return;
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
              child: RoundedBackButton(onTap: isLoading ? null : clickBack),
            ),
          ],
        ),
      ),
    );
  }
}
