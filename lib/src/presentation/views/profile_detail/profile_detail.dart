// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:latlng/latlng.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/views/chat_screen/chat_screen.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/circle_elevated_button.dart';
import 'package:pet_match/src/presentation/views/swipe_screen/comment_section.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/register_dialog.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:pet_match/src/injection_container.dart';

class ProfileDetailScreenArguments {
  final bool isMe;
  final bool isLiked;
  final Profile profile;
  final LatLng? point;
  final SwipeBloc? bloc;

  ProfileDetailScreenArguments(
      {this.isMe = true,
      required this.profile,
      this.isLiked = true,
      this.point,
      this.bloc});
}

enum ReturnType { back, pass, like }

class ProfileDetailReturnable {
  final ReturnType returnType;
  final String? comment;

  ProfileDetailReturnable({this.returnType = ReturnType.back, this.comment});
}

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key, required this.args});

  final ProfileDetailScreenArguments args;

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  static const _avatarHeight = 450.0;
  static const _headingTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    height: 1.5,
    fontSize: 16,
  );

  late Profile profile;
  late String ageString;
  double distance = double.negativeInfinity;
  late final ProfileBloc _profileBloc;
  late final SubscriptionBloc _subBloc;
  late final StreamSubscription _listener;
  @override
  void initState() {
    profile = widget.args.profile;
    _profileBloc = BlocProvider.of<ProfileBloc>(context)
      ..add(GetProfileDetailById(profile.id!));
    _subBloc = BlocProvider.of<SubscriptionBloc>(context);
    _listener = _profileBloc.stream.listen((state) {
      if (state is ProfileDetail) {
        profile = state.profile;
        if (profile.address != null && widget.args.point != null) {
          setState(() {
            distance = widget.args.point!
                .calculateDistance(LatLng(
                    profile.address!.latitude!, profile.address!.longitude!))
                .abs();
          });
        }
      }
      if (state is ProfileDetailError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              showCloseIcon: false,
              closeIconColor: Resource.primaryColor,
              elevation: 10,
              backgroundColor: Colors.white,
              duration: Duration(seconds: 5),
              content: Text(
                "Some thing went wrong. Please try again later.",
                style: TextStyle(color: Resource.primaryTextColor),
              )),
        );
      }
    });
    final delta = DateUtils.monthDelta(profile.birthday!, DateTime.now()).abs();
    if (delta < DateTime.monthsPerYear) {
      ageString = "$delta tháng tuổi";
    } else {
      ageString = "${(delta / DateTime.monthsPerYear).floor()} tuổi";
    }
    super.initState();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  edit() {
    Navigator.pushNamed(
      context,
      AppRoutes.profileEdit.name,
      arguments: profile,
    ).then((dynamic value) {
      if (value[0] != null) {
        setState(() {
          profile = value[0];
        });
      }
    });
  }

  _commentLikeAndBack() {
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
        widget.args.bloc!.add(SwipeLike(widget.args.profile, comment));
        final _localStorage = sl<SharedPreferences>();
        var currentProfile = Profile.fromJson(
            _localStorage.getFromSessionStorage("activeProfile"));
        var args = ChatScreenArguments(
          myId: currentProfile.id!,
          friendId: widget.args.profile.id!,
          friendName: widget.args.profile.name!,
          initialMessage: comment,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.chat.name,
            arguments: args);
      } else {
        dev.log('nothing to send');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              height: _avatarHeight,
              width: context.screenSize.width,
              child: GestureDetector(
                onTap: () {
                  dev.log('view avatar');
                },
                child: CachedNetworkImage(
                  imageUrl: profile.avatar!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: _avatarHeight - 30),
              padding: const EdgeInsets.all(40)
                  .copyWith(top: widget.args.isMe ? 35 : 70),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.name!}, $ageString',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                              fontSize: 24,
                            ),
                          ),
                          Text(profile.breed!.name!),
                        ],
                      ),
                      !widget.args.isMe
                          ? const SizedBox()
                          : BlocListener<SubscriptionBloc, SubscriptionState>(
                              listenWhen: (_, state) {
                                if (widget.args.isLiked && !widget.args.isMe) {
                                  return state is GetSubscriptionSuccess &&
                                      state.showRegisterDialog &&
                                      state.place ==
                                          DialogPlace.otherProfileComments;
                                } else {
                                  return state is GetSubscriptionSuccess &&
                                      state.showRegisterDialog &&
                                      state.place ==
                                          DialogPlace.myProfileComments;
                                }
                              },
                              listener: (context, state) {
                                state as GetSubscriptionSuccess;
                                if (state.subscription.isActive()) {
                                  openCommentPage();
                                } else {
                                  showRegisterModal();
                                }
                              },
                              child: RoundedIconButton(
                                child: SvgPicture.asset(
                                  'assets/images/svgs/chatbubble-outline.svg',
                                  color: Resource.primaryColor,
                                ),
                                onTap: () {
                                  final myProfile =
                                      !widget.args.isLiked && widget.args.isMe;
                                  _subBloc.add(GetSubscriptionData(
                                      showPremiumDialog: true,
                                      dialogPlace: myProfile
                                          ? DialogPlace.myProfileComments
                                          : DialogPlace.otherProfileComments));
                                },
                              ),
                            )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          //! replace
                          children: [
                            const Text(
                              'Địa điểm',
                              style: _headingTextStyle,
                            ),
                            Flexible(
                              child: Text(
                                profile.address?.address ??
                                    "Chưa điền thông tin",
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      widget.args.isMe || distance.isNegative
                          ? const SizedBox()
                          : Container(
                              clipBehavior: Clip.hardEdge,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Resource.primaryTintColor,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/svgs/location.svg",
                                    color: Resource.primaryColor,
                                  ),
                                  Text(
                                    "${distance.floor()} km",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Resource.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Giới thiệu', style: _headingTextStyle),
                  profile.description != null
                      ? ExpandableText(
                          profile.description!,
                          expandText: "Xem thêm",
                          collapseText: "Thu gọn",
                          animation: true,
                          animationCurve: Curves.easeInOut,
                          animationDuration: const Duration(milliseconds: 400),
                          linkEllipsis: false,
                          maxLines: 5,
                          linkStyle: const TextStyle(
                            color: Resource.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          "Người chủ chưa cập nhật thông tin",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  const SizedBox(height: 30),
                  const Text(
                    'Đối tượng',
                    style: _headingTextStyle,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: profile.interests
                            ?.map((e) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Resource.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.symmetric(
                                            horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          color: Resource.primaryColor,
                                        ),
                                        Text(
                                          e.name ?? '',
                                          style: const TextStyle(
                                            color: Resource.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList() ??
                        [],
                  ),
                  const SizedBox(height: 30),
                  const Text('Thư viện', style: _headingTextStyle),
                  const SizedBox(height: 5),
                  buildGalleryLayout(profile.gallery),
                ],
              ),
            ),
            Positioned(
              top: 40 + context.screenPadding.top,
              left: 40,
              child: RoundedIconButton(
                color: Colors.white.withOpacity(0.3),
                onTap: () {
                  final returnable = ProfileDetailReturnable();
                  Navigator.pop(context, [returnable]);
                },
                child: SvgPicture.asset(
                  'assets/images/svgs/right.svg',
                  // ignore: deprecated_member_use
                  color: Colors.white,
                ),
              ),
            ),
            !widget.args.isMe
                ? const SizedBox()
                : Positioned(
                    top: 40 + context.screenPadding.top,
                    right: 40,
                    child: RoundedIconButton(
                      color: Colors.white.withOpacity(0.3),
                      onTap: edit,
                      child: SvgPicture.asset(
                        'assets/images/svgs/edit.svg',
                        height: 18,
                      ),
                    ),
                  ),
            widget.args.isMe
                ? const SizedBox()
                : Positioned(
                    top: _avatarHeight - 60 - context.screenPadding.top,
                    left: 40,
                    right: 40,
                    child: SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedCircleButton(
                            onTap: () {
                              widget.args.bloc!
                                  .add(DontLikeBack(widget.args.profile));
                              Navigator.pop(context);
                            },
                            style: ElevatedCircleButtonStyle.white,
                            assetImage: "assets/images/svgs/swipe_pass.svg",
                          ),
                          ElevatedCircleButton(
                            onTap: () {
                              widget.args.bloc!
                                  .add(SwipeLike(widget.args.profile, null));
                              final _localStorage = sl<SharedPreferences>();
                              var currentProfile = Profile.fromJson(
                                  _localStorage
                                      .getFromSessionStorage("activeProfile"));
                              FirebaseFirestore.instance
                                  .collection('Rooms')
                                  .add({
                                "users": [
                                  widget.args.profile.id,
                                  currentProfile.id,
                                ]
                              });
                            },
                            size: 99,
                            style: ElevatedCircleButtonStyle.primary,
                            assetImage: "assets/images/svgs/swipe_like.svg",
                          ),
                          ElevatedCircleButton(
                            onTap: _commentLikeAndBack,
                            style: ElevatedCircleButtonStyle.white,
                            assetImage:
                                "assets/images/svgs/chatbubble-outline.svg",
                            assetColor: const Color(0xFF1c4795),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _openGallery(image) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        // DisplayGesture is just debug, please remove it when use
        builder: (BuildContext context) => InteractiveviewerGallery<String>(
          sources: profile.gallery!,
          initIndex: profile.gallery!.indexOf(image),
          itemBuilder: itemBuilder,
          onPageChanged: (int pageIndex) {
            dev.log("nell-pageIndex:$pageIndex");
          },
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    String sourceEntity = profile.gallery![index];
    return ImageItem(sourceEntity);
  }

  final double _galleryHeight = 400;

  Widget buildGalleryLayout(List<String>? galleries) {
    Widget layout = const Center(
        child: Text(
      'Chưa có ảnh nào.',
      style: TextStyle(
        color: Resource.primaryTextColor,
        fontWeight: FontWeight.bold,
      ),
    ));
    if (galleries != null) {
      switch (galleries.length) {
        case 0:
          break;
        case 1:
          layout = buildWith1Image(galleries);
          break;
        case 2:
          layout = buildWith2Images(galleries);
          break;
        case 3:
          layout = buildWith3Images(galleries);
          break;
        case 4:
          layout = buildWith4Images(galleries);
          break;
        default:
          layout = buildDefaultLayout(galleries);
      }
    }
    return Container(
      height: galleries == null || galleries.isEmpty ? 200 : _galleryHeight,
      width: context.screenSize.width,
      decoration: BoxDecoration(
        color: galleries == null || galleries.isEmpty
            ? Resource.primaryTintColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: layout,
    );
  }

  Widget buildWith1Image(List<String> galleries) {
    return SizedBox(
      height: _galleryHeight,
      child: GalleryImage(
        imageUrl: galleries[0],
        aspectRatio: 1 / 1,
        onTap: _openGallery,
      ),
    );
  }

  Widget buildWith2Images(List<String> galleries) {
    return SizedBox(
      height: _galleryHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GalleryImage(
              imageUrl: galleries[0],
              aspectRatio: 1 / 2,
              onTap: _openGallery,
            ),
          ),
          const SizedBox(height: galleryImageSpacing),
          Expanded(
            child: GalleryImage(
              imageUrl: galleries[1],
              aspectRatio: 1 / 2,
              onTap: _openGallery,
            ),
          ),
        ],
      ),
    );
  }

  static const galleryImageSpacing = 8.0;

  Widget buildWith3Images(List<String> galleries) {
    return SizedBox(
      height: _galleryHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GalleryImage(
              imageUrl: galleries[0],
              aspectRatio: 1 / 2,
              onTap: _openGallery,
            ),
          ),
          const SizedBox(height: galleryImageSpacing),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[1],
                    aspectRatio: 1 / 2,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(width: galleryImageSpacing),
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[2],
                    aspectRatio: 1 / 2,
                    onTap: _openGallery,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildWith4Images(List<String> galleries) {
    return SizedBox(
      height: _galleryHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[0],
                    aspectRatio: 2 / 1,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(height: galleryImageSpacing),
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[2],
                    aspectRatio: 2 / 1,
                    onTap: _openGallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: galleryImageSpacing),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[1],
                    aspectRatio: 2 / 1,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(height: galleryImageSpacing),
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[3],
                    aspectRatio: 2 / 1,
                    onTap: _openGallery,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildDefaultLayout(List<String> galleries) {
    return SizedBox(
      height: _galleryHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[0],
                    aspectRatio: 1 / 2,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(width: galleryImageSpacing),
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[1],
                    aspectRatio: 1 / 2,
                    onTap: _openGallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: galleryImageSpacing),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[2],
                    aspectRatio: 1 / 3,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(width: galleryImageSpacing),
                Expanded(
                  child: GalleryImage(
                    imageUrl: galleries[3],
                    aspectRatio: 1 / 3,
                    onTap: _openGallery,
                  ),
                ),
                const SizedBox(width: galleryImageSpacing),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GalleryImage(
                      imageUrl: galleries[4],
                      aspectRatio: 1 / 3,
                      onTap: _openGallery,
                      overlay: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Resource.primaryTextColor.withAlpha(100),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              '+${min(99, galleries.length - 4)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void openCommentPage() {}

  void showRegisterModal() {
    showDialog(context: context, builder: (context) => RegisterDialog(subscriptionBloc: _subBloc,));
  }
}

class GalleryImage extends StatelessWidget {
  const GalleryImage(
      {super.key,
      required this.imageUrl,
      required this.aspectRatio,
      this.onTap,
      this.overlay});

  final String imageUrl;
  final Function(String source)? onTap;
  final Widget? overlay;

  ///ratio of width to height: w / h
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.hardEdge,
      child: Hero(
        tag: imageUrl,
        placeholderBuilder: (context, heroSize, child) => child,
        child: GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!(imageUrl);
            } else {
              dev.log('onTap function not passed');
            }
            dev.log('view image');
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.network(
                    imageUrl,
                    // height: 500,
                    fit: BoxFit.cover,
                    // fit: aspectRatio == 1
                    //     ? BoxFit.cover
                    //     : aspectRatio > 1
                    //         ? BoxFit.fitWidth
                    //         : BoxFit.fitHeight,
                  ),
                ),
              ),
              overlay ??
                  Container(
                    color: Colors.transparent,
                  )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageItem extends StatefulWidget {
  final String source;

  const ImageItem(this.source);

  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  void initState() {
    super.initState();
    dev.log('initState: ${widget.source}');
  }

  @override
  void dispose() {
    super.dispose();
    dev.log('dispose: ${widget.source}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Hero(
          tag: widget.source,
          child: CachedNetworkImage(
            imageUrl: widget.source,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class DemoVideoItem extends StatefulWidget {
  final String source;
  final bool? isFocus;

  DemoVideoItem(this.source, {this.isFocus});

  @override
  _DemoVideoItemState createState() => _DemoVideoItemState();
}

class _DemoVideoItemState extends State<DemoVideoItem> {
  VideoPlayerController? _controller;
  late VoidCallback listener;
  String? localFileName;

  _DemoVideoItemState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    dev.log('initState: ${widget.source}');
    init();
  }

  init() async {
    _controller = VideoPlayerController.network(widget.source);
    // loop play
    _controller!.setLooping(true);
    await _controller!.initialize();
    setState(() {});
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    dev.log('dispose: ${widget.source}');
    _controller!.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant DemoVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus! && !widget.isFocus!) {
      // pause
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Hero(
                  tag: widget.source,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
              _controller!.value.isPlaying == true
                  ? const SizedBox()
                  : const IgnorePointer(
                      ignoring: true,
                      child: Icon(
                        Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ],
          )
        : Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    const CupertinoThemeData(brightness: Brightness.dark)),
            child: const CupertinoActivityIndicator(radius: 30),
          );
  }
}
