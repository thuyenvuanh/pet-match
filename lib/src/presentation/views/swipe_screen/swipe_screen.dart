import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/provider/swipe_provider.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/circle_elevated_button.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/comment_section.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/presentation/widgets/register_dialog.dart';
import 'package:pet_match/src/presentation/widgets/swipeable_card.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:provider/provider.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late final SwipeBloc _swipeBloc;
  late final ProfileBloc _profileBloc;
  // late final HomeBloc _homeBloc;
  late final SubscriptionBloc _subscriptionBloc;
  Subscription? subscription;
  @override
  void initState() {
    _swipeBloc = BlocProvider.of<SwipeBloc>(context);
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    // _homeBloc = BlocProvider.of<HomeBloc>(context);
    _profileBloc.stream.listen((state) {
      if (state is ProfileLoggedIn || state is CurrentProfileState) {
        _swipeBloc.add(FetchNewProfiles());
      }
    });
    _subscriptionBloc = BlocProvider.of<SubscriptionBloc>(context)
      ..add(const GetSubscriptionData());
    super.initState();
  }

  showRegisterDialog() {
    showDialog(
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (context) => RegisterDialog(
        place: DialogPlace.swipe,
        subscriptionBloc: _subscriptionBloc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocListener<SubscriptionBloc, SubscriptionState>(
          bloc: _subscriptionBloc,
          listenWhen: (_, state) =>
              state is GetSubscriptionSuccess &&
              state.showRegisterDialog &&
              state.place == DialogPlace.swipe,
          listener: (context, state) => showRegisterDialog(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ChangeNotifierProvider(
              create: (context) =>
                  SwipeProvider(_swipeBloc, _subscriptionBloc, _profileBloc),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: buildSwipeCount(),
                      ),
                      const Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Text(
                          "Khám phá",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Center(
                            // child: RoundedIconButton(
                            //   child: SvgPicture.asset(
                            //     'assets/images/svgs/filter.svg',
                            //   ),
                            //   onTap: () {},
                            // ),
                            child: SizedBox(),
                          ))
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SwipeStack(),
                  const SizedBox(height: 35),
                  const SwipeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget buildRemainingSwipes() {
  //   return BlocBuilder<SubscriptionBloc, SubscriptionState>(
  //     bloc: _subscriptionBloc,
  //     buildWhen: (_, state) => _ is RemainingSwipe,
  //     builder: (context, state) {
  //       if (state is! RemainingSwipe) {
  //         return const SizedBox();
  //       }
  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           const Text(
  //             "Hôm nay còn",
  //             style: TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.w300,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           Text(
  //             "${state.swipes} lượt",
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w700,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget buildSwipeCount() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        BlocBuilder<SubscriptionBloc, SubscriptionState>(
          bloc: _subscriptionBloc,
          buildWhen: (previous, current) {
            if (previous is SubscriptionInitial &&
                current is SubscriptionLoading) {
              return true;
            }
            if (current is GetSubscriptionSuccess) return true;
            if (current is RemainingSwipe) return true;
            return false;
          },
          builder: (context, state) {
            if (state is GetSubscriptionSuccess || state is RemainingSwipe) {
              if (state is GetSubscriptionSuccess &&
                  state.subscription.isActive()) {
                return const PremiumBadge();
              } else {
                int swipe = 0;
                if (state is GetSubscriptionSuccess) {
                  swipe = state.remaining!;
                }
                if (state is RemainingSwipe) {
                  swipe = state.swipes;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Hôm nay còn",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "$swipe lượt",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }
            }
            if (state is GetSubscriptionError) {
              return const Text("Error");
            }
            if (state is SubscriptionLoading) {
              return const Text("Loading...");
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          FaIcon(
            FontAwesomeIcons.crown,
            color: Color(0xFFe29033),
          ),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFe29033),
            ),
          ),
        ],
      ),
    );
  }
}

class SwipeButton extends StatelessWidget {
  const SwipeButton({super.key});

  void commentAndLike(Profile profile, like, context) {
    showModalBottomSheet(
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.screenViewInsets.bottom),
          child: const CommentBottomSheet(),
        );
      },
    ).then((dynamic value) async {
      await Future.delayed(const Duration(milliseconds: 400));
      String? comment = value[0];
      if (comment != null && comment.isNotEmpty) {
        like(comment);
      } else {
        dev.log('nothing to send');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SwipeProvider>(context);
    return SizedBox(
      height: 99,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedCircleButton(
            onTap: provider.isAnimating ? null : provider.pass,
            style: ElevatedCircleButtonStyle.white,
            assetImage: "assets/images/svgs/swipe_pass.svg",
          ),
          ElevatedCircleButton(
            size: 99,
            style: ElevatedCircleButtonStyle.primary,
            assetImage: "assets/images/svgs/swipe_like.svg",
            onTap: provider.isAnimating || provider.profiles.isEmpty
                ? null
                : provider.like,
          ),
          ElevatedCircleButton(
            onTap: provider.isAnimating || provider.profiles.isEmpty
                ? null
                //! NEED TO REPLACE
                : () => commentAndLike(
                      provider.profiles.last,
                      provider.like,
                      context,
                    ),
            style: ElevatedCircleButtonStyle.white,
            assetImage: "assets/images/svgs/chatbubble-outline.svg",
            assetColor: const Color(0xFF1c4795),
          )
        ],
      ),
    );
  }
}

class SwipeStack extends StatefulWidget {
  const SwipeStack({super.key});

  @override
  State<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<SwipeStack> {
  late final SwipeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SwipeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SwipeProvider>(context);
    return Expanded(
      child: BlocBuilder<SwipeBloc, SwipeState>(
          bloc: _bloc,
          buildWhen: (_, state) => state is FetchProfilesStates,
          builder: (context, state) {
            Widget adaptiveWidget =
                const Positioned.fill(child: LoadingIndicator());
            if (state is FetchNewProfilesError) {
              adaptiveWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Something went wrong. Please try again later",
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Button(
                  //   label: 'Refresh',
                  //   onTap: () {
                  //     _bloc.add(FetchNewProfiles());
                  //   },
                  //   color: Colors.transparent,
                  // ),
                  RoundedIconButton(
                      child: const Icon(Icons.refresh),
                      onTap: () {
                        _bloc.add(FetchNewProfiles());
                      }),
                ],
              );
            }
            if (state is FetchLikedProfilesOK) {
              adaptiveWidget = const SizedBox();
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                adaptiveWidget,
                ...provider.profiles
                    .map<Widget>(
                      (e) => SwipeCard(
                        profile: e,
                        isFront: provider.profiles.last == e,
                      ),
                    )
                    .toList(),
              ],
            );
          }),
    );
  }
}

// List comments
// Expanded(
        //   child: BlocBuilder<SwipeBloc, SwipeState>(
        //     bloc: widget.swipeBloc,
        //     buildWhen: (previous, current) => current is CommentStates,
        //     builder: (context, state) {
        //       if (state is FetchCommentsOK) {
        //         if (state.comments.isNotEmpty) {
        //           return SingleChildScrollView(
        //             padding: const EdgeInsets.all(40).copyWith(top: 10),
        //             physics: const ClampingScrollPhysics(),
        //             child: Column(
        //               //comment
        //               children: state.comments.map(
        //                 (e) {
        //                   const avatarRadius = 24.0;
        //                   return Padding(
        //                     padding: const EdgeInsets.symmetric(vertical: 10),
        //                     child: Row(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         const CircleAvatar(radius: avatarRadius),
        //                         const SizedBox(width: 5),
        //                         Container(
        //                           width: context.screenSize.width * 0.65,
        //                           clipBehavior: Clip.antiAlias,
        //                           padding: const EdgeInsets.all(16),
        //                           decoration: BoxDecoration(
        //                             color: Resource.primaryTintColor,
        //                             borderRadius: Resource.defaultBorderRadius,
        //                           ),
        //                           child: Column(
        //                             crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                             children: [
        //                               Text(
        //                                 '${e.profile!.name}   ${DateFormat().formatPetMatch(e.createdTS!).split(' ').last}',
        //                                 style: const TextStyle(fontSize: 12),
        //                               ),
        //                               Text(
        //                                 e.comment!,
        //                                 softWrap: true,
        //                                 maxLines: 4,
        //                                 overflow: TextOverflow.ellipsis,
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   );
        //                 },
        //               ).toList(),
        //             ),
        //           );
        //         } else {
        //           return const Padding(
        //             padding: EdgeInsets.only(top: 40),
        //             child: Text('Nhắn tin kết nối với thú cưng khác'),
        //           );
        //         }
        //       } else if (state is FetchCommentError) {
        //         return Center(
        //           child: Text(state.message),
        //         );
        //       } else {
        //         return const LoadingIndicator();
        //       }
        //     },
        //   ),
        // ),
        // const Padding(
        //   padding: EdgeInsets.only(top: 40),
        //   child: Text(
        //     'Bình luận',
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 24,
        //     ),
        //   ),
        // )