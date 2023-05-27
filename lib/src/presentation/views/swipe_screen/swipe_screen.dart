import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/provider/swipe_provider.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/circle_elevated_button.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/comment_section.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/presentation/widgets/swipeable_card.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:provider/provider.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late final SwipeBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<SwipeBloc>(context);
    _bloc.add(FetchNewProfiles());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            children: [
              const SizedBox(
                height: 52,
                child: Text("Khám phá",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ChangeNotifierProvider(
                  create: (context) => SwipeProvider(_bloc),
                  child: const SwipeStack(),
                ),
              ),
            ],
          ),
        ),
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
  @override
  void initState() {
    super.initState();
  }

  void commentAndLike(Profile profile, like) {
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
    ).then((dynamic value) {
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
    // final profiles = provider.profiles;
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: LoadingIndicator()),
              ...provider.profiles
                  .map<Widget>(
                    (e) => SwipeCard(
                      profile: e,
                      isFront: provider.profiles.last == e,
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        const SizedBox(height: 35),
        SizedBox(
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
                    : () => commentAndLike(Profile(), provider.like),
                style: ElevatedCircleButtonStyle.white,
                assetImage: "assets/images/svgs/chatbubble-outline.svg",
              )
            ],
          ),
        ),
      ],
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