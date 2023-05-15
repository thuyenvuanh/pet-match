import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/numpad.dart';
import 'package:pet_match/src/utils/constant.dart';

//style definitions
final defaultBoxDecoration = BoxDecoration(
  border: Border.all(color: Resource.disabledColor),
  borderRadius: Resource.defaultBorderRadius,
);
final atIndexDecoration = BoxDecoration(
  border: Border.all(color: Resource.primaryColor),
  borderRadius: Resource.defaultBorderRadius,
);
final filledBoxDecoration = BoxDecoration(
  color: Resource.primaryColor,
  borderRadius: Resource.defaultBorderRadius,
);
const defaultTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 28,
  color: Resource.disabledColor,
);
const atIndexTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 28,
  color: Resource.primaryTintColor,
);
const filledTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 28,
  color: Colors.white,
);
const timerTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 34,
);

class OtpInputLayout extends StatefulWidget {
  const OtpInputLayout({
    Key? key,
    required this.isLoading,
    required this.verificationId,
  }) : super(key: key);

  final String verificationId;
  final bool isLoading;
  @override
  State<OtpInputLayout> createState() => _OtpInputLayoutState();
}

class _OtpInputLayoutState extends State<OtpInputLayout> {
  late final AuthBloc _authBloc;
  final _otpCodeLength = 6;
  var _otp = "";
  String? _errorMessage;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
  late final CountdownTimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CountdownTimerController(endTime: endTime);
    _authBloc = BlocProvider.of<AuthBloc>(context);
  }

  void onReset() {
    setState(() {
      _otp = "";
    });
  }

  void onResendOtp() {
    developer.log("Validate OTP: $_otp");
  }

  BoxDecoration getDecoration(int index) {
    if (_otp.length == index) return atIndexDecoration;
    if (_otp.length > index) return filledBoxDecoration;
    return defaultBoxDecoration;
  }

  TextStyle getTextStyle(int index) {
    if (_otp.length == index) return atIndexTextStyle;
    if (_otp.length > index) return filledTextStyle;
    return defaultTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CountdownTimer(
          controller: _controller,
          endTime: endTime,
          widgetBuilder: (context, time) {
            String min = time?.min?.toString() ?? "00";
            min = min.length == 1 ? "0$min" : min;
            String sec = time?.sec?.toString() ?? "00";
            sec = sec.length == 1 ? "0$sec" : sec;
            return Text('$min : $sec', style: timerTextStyle);
          },
          endWidget: const Text('00 : 00', style: timerTextStyle),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
          child: Text(
            'Nhập mã xác thực chúng tôi đã gửi cho bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 51,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _otpCodeLength,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      decoration: getDecoration(index),
                      duration: const Duration(milliseconds: 350),
                      child: Center(
                        child: Text(
                          _otp.length > index
                              ? _otp.substring(index, index + 1)
                              : "0",
                          style: getTextStyle(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        BlocListener(
          bloc: _authBloc,
          listener: (BuildContext context, state) {
            if (state is InvalidOtpCode) {
              setState(() => _errorMessage = "OTP is incorrect");
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage ?? '',
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        NumPad(
          onPressed: onNumpadClick,
          isClearDisabled: false,
          onReset: onReset,
        ),
        Button(
          variant: ButtonVariant.text,
          label: 'Gửi lại',
          width: 100,
          onTap: widget.isLoading ? null : onResendOtp,
          padding:
              const EdgeInsets.symmetric(horizontal: 40).copyWith(bottom: 46),
          borderRadius: Resource.defaultBorderRadius,
          style: const TextStyle(
            color: Resource.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  onNumpadClick(value) {
    setState(() {
      _otp += value.toString();
    });
    if (_otp.length == _otpCodeLength) {
      _authBloc.add(
        VerifyOtpRequest(
          otpCode: _otp,
          verificationId: widget.verificationId,
        ),
      );
    }
  }
}
