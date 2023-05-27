import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/views/select_profile_screen.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final StreamSubscription _profileListener;
  Profile? profile;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<SwipeBloc>(context).add(FetchLikedProfiles());
    _profileListener =
        BlocProvider.of<ProfileBloc>(context).stream.listen((state) {
      if (state is CurrentProfileState) {
        setState(() {
          profile = state.profile;
        });
      }
    });
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
            return const LoadingIndicator();
          }
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Text("Đã thích",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                BlocBuilder<SwipeBloc, SwipeState>(
                  buildWhen: (previous, current) =>
                      current is FetchLikedProfilesState,
                  builder: (context, state) {
                    if (state is FetchLikedProfilesOK) {
                      if (state.likedProfiles.isNotEmpty) {
                        return GridView(
                          padding: const EdgeInsets.all(40),
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
                                    onClick: () {},
                                    bloc: BlocProvider.of<ProfileBloc>(context),
                                  ))
                              .toList(),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.only(top: 200),
                          child: Center(
                            child: Text('Match a pet now'),
                          ),
                        );
                      }
                    }
                    if (state is FetchLikedProfilesError) {
                      return Text('Something went wrong!');
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
