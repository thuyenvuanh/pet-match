import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/numpad.dart';
import 'package:pet_match/src/utils/constant.dart';

class PhoneInputLayout extends StatefulWidget {
  const PhoneInputLayout({
    Key? key,
    this.phoneNumber,
    required this.isLoading,
  }) : super(key: key);
  final String? phoneNumber;
  final bool isLoading;
  @override
  State<PhoneInputLayout> createState() => _PhoneInputLayoutState();
}

class _PhoneInputLayoutState extends State<PhoneInputLayout> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final AuthBloc _authBloc;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _controller.text = widget.phoneNumber!;
    }
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _controller.text = _authBloc.phoneNumber ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Text(
            'Nhập số điện thoại để chúng tôi gửi mã xác thực cho bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: InternationalPhoneNumberInput(
              onInputChanged: (value) {
                developer.log(value.toString());
              },
              textFieldController: _controller,
              spaceBetweenSelectorAndTextField: 16,
              countrySelectorScrollControlled: false,
              countries: const ["VN"],
              selectorConfig: const SelectorConfig(
                showFlags: false,
                trailingSpace: false,
              ),
              isEnabled: false,
              selectorTextStyle: const TextStyle(fontSize: 20),
              textStyle: const TextStyle(fontSize: 20),
              autoFocus: true,
              maxLength: 10,
              keyboardType: TextInputType.none,
              inputBorder: InputBorder.none,
            ),
          ),
        ),
        BlocListener(
          bloc: _authBloc,
          listener: (BuildContext context, state) {
            if (state is InvalidPhoneNumber) {
              setState(() => _errorMessage = "Invalid phone number");
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
          onPressed: (value) {
            setState(() {
              _controller.text += value.toString();
              if (_errorMessage != null) _errorMessage = null;
            });
          },
          isClearDisabled: _controller.text.isEmpty,
          onReset: () {
            if (_controller.text.isNotEmpty) {
              setState(() {
                _controller.text =
                    _controller.text.substring(0, _controller.text.length - 1);
                if (_errorMessage != null) _errorMessage = null;
              });
            }
          },
        ),
        Button(
          label: 'Gửi mã',
          onTap: widget.isLoading
              ? null
              : () {
                  final phoneNumber = _controller.value.text;
                  _authBloc.add(SendOtpRequest(phoneNumber: phoneNumber));
                },
          padding:
              const EdgeInsets.symmetric(horizontal: 40).copyWith(bottom: 46),
          borderRadius: Resource.defaultBorderRadius,
        ),
      ],
    );
  }
}
