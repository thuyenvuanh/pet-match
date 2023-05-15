import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/views/create_profile/basic_information_page.dart';
import 'package:pet_match/src/presentation/views/create_profile/breed_selection_page.dart';
import 'package:pet_match/src/presentation/views/create_profile/interested_in_selection_page.dart';
import 'package:pet_match/src/presentation/views/create_profile/success_screen.dart';
import 'package:pet_match/src/presentation/widgets/rounded_back_button.dart';
import 'package:pet_match/src/utils/constant.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final PageController _controller = PageController();
  final Duration animeDuration = const Duration(milliseconds: 250);
  bool isSkipVisible = false;
  late final CreateProfileBloc _bloc;
  late final StreamSubscription _blocListener;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        isSkipVisible =
            _controller.positions.isNotEmpty ? _controller.page == 2 : false;
      });
    });
    _bloc = BlocProvider.of<CreateProfileBloc>(context);
    _blocListener = _bloc.stream.listen((state) {
      if (state is CreateProfileSuccess) {
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
                builder: (context) => const CreateSuccessScreen()),
            (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goNext() =>
      _controller.nextPage(duration: animeDuration, curve: Curves.ease);

  void goBack() =>
      _controller.previousPage(duration: animeDuration, curve: Curves.ease);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.page!.toInt() != 0) {
          goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Resource.lightBackground,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                bottom: 0,
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    BreedSelectionPage(goNext: goNext),
                    BasicInformationPage(goNext: goNext),
                    const InterestSelectionPage(),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                left: 40,
                child: Material(
                  color: Colors.transparent,
                  child: RoundedBackButton(onTap: () {
                    if (_controller.page!.toInt() == 0) {
                      Navigator.pop(context);
                    } else {
                      goBack();
                    }
                  }),
                ),
              ),
              Positioned(
                top: 52,
                right: 40,
                child: Visibility(
                  visible: isSkipVisible,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Resource.primaryTintColor,
                    ),
                    child: const Text(
                      "Bỏ qua",
                      style: TextStyle(color: Resource.primaryColor),
                    ),
                    onPressed: () {
                      _bloc.add(SubmitProfile(_bloc.profile));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
