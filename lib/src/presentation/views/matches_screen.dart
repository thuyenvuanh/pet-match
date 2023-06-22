import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlng/latlng.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/views/profile_detail/profile_detail.dart';
import 'package:pet_match/src/presentation/views/select_profile_screen.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final StreamSubscription _profileListener;
  late final SwipeBloc _swipeBloc;
  Profile? profile;

  @override
  void initState() {
    super.initState();
    _swipeBloc = sl<SwipeBloc>();
    _profileListener =
        BlocProvider.of<ProfileBloc>(context).stream.listen((state) {
      if (state is CurrentProfileState || state is ProfileLoggedIn) {
        _swipeBloc.add(FetchLikedProfiles());
        setState(() {
          if (state is CurrentProfileState) {
            profile = state.profile;
          }
          if (state is ProfileLoggedIn) {
            profile = state.activeProfile;
          }
        });
      }
    });
    _swipeBloc.stream.listen((state) {});
  }

  @override
  void dispose() {
    _profileListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(builder: (context) {
          if (profile == null) {
            return const LoadingIndicator(
              loadingText: 'Loading profile',
            );
          }
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 40,
                    right: 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Đã thích",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    'Đây là danh sách những thú cưng đã thích bạn gần đây',
                    style: TextStyle(color: Resource.primaryTextColor),
                  ),
                ),
                BlocBuilder<SwipeBloc, SwipeState>(
                  bloc: _swipeBloc,
                  buildWhen: (previous, current) {
                    return current is FetchLikedProfilesState;
                  },
                  builder: (context, state) {
                    if (state is FetchLikedProfilesOK) {
                      if (state.likedProfiles.isNotEmpty) {
                        return GridView(
                          padding: const EdgeInsets.all(40).copyWith(top: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 180 / 255),
                          children: state.likedProfiles.reversed
                              .map((e) => ProfilePreview(
                                    profile: e.profile!,
                                    onClick: () {
                                      final args = ProfileDetailScreenArguments(
                                          profile: e.profile!,
                                          isMe: false,
                                          isLiked: true,
                                          bloc: _swipeBloc,
                                          point: profile?.address != null
                                              ? LatLng(
                                                  profile!.address!.latitude!,
                                                  profile!.address!.longitude!)
                                              : null);
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.profileDetails.name,
                                        arguments: args,
                                      );
                                    },
                                    bloc: BlocProvider.of<ProfileBloc>(context),
                                  ))
                              .toList(),
                        );
                      } else {
                        if (state is! FetchLikedProfileLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 200),
                            child: Center(
                              child:
                                  Text('Kết nối ngay với những thú cưng khác!'),
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              const Text(
                                  "Something went wrong. Please try again later"),
                              RoundedIconButton(
                                  onTap: () {
                                    _swipeBloc.add(FetchLikedProfiles());
                                  },
                                  child: const Icon(Icons.refresh_rounded)),
                            ],
                          );
                        }
                      }
                    }
                    if (state is FetchLikedProfilesError) {
                      return const Text(
                          'Ứng dụng gặp sự cố, vui lòng thử lại sau!');
                    }
                    return const LoadingIndicator();
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
