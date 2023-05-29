import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/views/matches_screen.dart';
import 'package:pet_match/src/presentation/views/message_screen.dart';
import 'package:pet_match/src/presentation/views/user_screen.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/swipe_screen.dart';
import 'package:pet_match/src/utils/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialRoutes = AppRoutes.root});

  final AppRoutes initialRoutes;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  late final StreamSubscription _homeListener, _authListener;
  Profile? _profile;
  @override
  void initState() {
    super.initState();
    _homeListener = BlocProvider.of<HomeBloc>(context).stream.listen((state) {
      if (state is NoActiveProfile) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.profiles.name, (route) => false);
      }
      if (state is ActiveProfile) {
        _profile = state.activeProfile;
      }
    });
    _authListener = BlocProvider.of<AuthBloc>(context).stream.listen((state) {
      if (state is Unauthenticated) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.signIn.name, (route) => false);
      }
    });
    switch (widget.initialRoutes) {
      case AppRoutes.root:
        _currentIndex = 0;
        break;
      case AppRoutes.profiles:
        _currentIndex = 3;
        break;
      default:
        _currentIndex = 0;
        dev.log("Invalid route");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _homeListener.cancel();
    _authListener.cancel();
  }

  void selectTab(value) => setState(() {
        _currentIndex = value;
        dev.log("current index: $_currentIndex");
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      resizeToAvoidBottomInset: false,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: selectTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 4,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/svgs/cards.svg"),
            activeIcon: SvgPicture.asset("assets/images/svgs/cards-active.svg"),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/svgs/heart.svg"),
            activeIcon: SvgPicture.asset("assets/images/svgs/heart-active.svg"),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/svgs/message.svg"),
            activeIcon:
                SvgPicture.asset("assets/images/svgs/message-active.svg"),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/images/svgs/people.svg"),
            activeIcon:
                SvgPicture.asset("assets/images/svgs/people-active.svg"),
            label: "",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Offstage(
            offstage: _currentIndex != 0,
            child: const SwipeScreen(),
          ),
        ),
        Positioned.fill(
          child: Offstage(
            offstage: _currentIndex != 1,
            child: const MatchesScreen(),
          ),
        ),
        Positioned.fill(
          child: Offstage(
            offstage: _currentIndex != 2,
            child: const MessageScreen(),
          ),
        ),
        Positioned.fill(
          child: Offstage(
            offstage: _currentIndex != 3,
            child: const UserScreen(),
          ),
        ),
      ],
    );
  }
}
