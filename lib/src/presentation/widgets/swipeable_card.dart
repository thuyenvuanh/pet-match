import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlng/latlng.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/provider/swipe_provider.dart';
import 'package:pet_match/src/presentation/views/profile_detail/profile_detail.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({
    Key? key,
    required this.profile,
    required this.isFront,
  }) : super(key: key);

  final Profile profile;
  final bool isFront;

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  late final Profile currentProfile;
  double? distance;
  @override
  void initState() {
    super.initState();
    currentProfile = Profile.fromJson(
        sl<SharedPreferences>().getFromSessionStorage('activeProfile'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LatLng? point1;
      if (currentProfile.address != null) {
        point1 = LatLng(currentProfile.address!.latitude!,
            currentProfile.address!.longitude!);
      }
      LatLng? point2;
      if (widget.profile.address != null) {
        point2 = LatLng(widget.profile.address!.latitude!,
            widget.profile.address!.longitude!);
      }
      if (point1 != null && point2 != null) {
        distance = point1.calculateDistance(point2);
      }
      final size = context.screenSize;
      final provider = Provider.of<SwipeProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFront ? buildFrontCard() : buildCard();
  }

  Widget buildFrontCard() => GestureDetector(
        onTap: () {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          final args = ProfileDetailScreenArguments(
              isMe: false,
              profile: widget.profile,
              isLiked: false,
              point: currentProfile.address != null
                  ? LatLng(currentProfile.address!.latitude!,
                      currentProfile.address!.longitude!)
                  : null);
          Navigator.pushNamed(
            context,
            AppRoutes.profileDetails.name,
            arguments: args,
          ).then((dynamic value) async {
            if (value == null) return;
            await Future.delayed(const Duration(milliseconds: 400));
            final returnable = value[0] as ProfileDetailReturnable;
            if (returnable.returnType == ReturnType.like) {
              provider.like(returnable.comment);
            }
            if (returnable.returnType == ReturnType.pass) {
              provider.pass();
            }
          });
        },
        onPanStart: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onStartDrag(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onDragUpdate(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onDragEnd(details);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = Provider.of<SwipeProvider>(context);
            final position = provider.position;
            final maxHeight = constraints.maxHeight;
            final maxWidth = constraints.maxWidth;
            final animDur = provider.isDragging ? 0 : 400;
            var transform = Matrix4.identity()
              ..translate(maxWidth / 2, maxHeight)
              ..rotateZ(provider.angle * pi / 180)
              ..translate(-(maxWidth / 2), -(maxHeight));

            return AnimatedContainer(
              duration: Duration(milliseconds: animDur),
              curve: Curves.easeInOut,
              transform: transform..translate(position.dx, 0),
              child: Stack(
                children: [
                  buildCard(),
                  buildOverlay(),
                  buildStamps(),
                ],
              ),
            );
          },
        ),
      );

  Widget buildOverlay() {
    final provider = Provider.of<SwipeProvider>(context);
    var color = Colors.transparent;
    if (provider.angle > 0) {
      color = Resource.primaryTintColor;
    } else if (provider.angle < 0) {
      color = Colors.grey.withOpacity(0.5);
    }
    return Positioned.fill(
      child: Opacity(
        opacity: provider.stampOpacity,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget buildStamps() {
    final provider = Provider.of<SwipeProvider>(context);
    final status = provider.getSwipeStatus();
    switch (status) {
      case SwipeStatus.like:
        return buildLikeStamp(provider.angle, provider.stampOpacity);
      case SwipeStatus.pass:
        return buildPassStamp(provider.angle, provider.stampOpacity);
      default:
        return const SizedBox();
    }
  }

  Widget buildLikeStamp(double angle, double opacity) {
    return Positioned(
      top: 50,
      left: 50,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: -pi / 6,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 50,
                    offset: Offset(0, 20),
                  )
                ]),
            child: Center(
              child: SvgPicture.asset("assets/images/svgs/stamp-heart.svg"),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPassStamp(double angle, double opacity) {
    return Positioned(
      right: 50,
      top: 50,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: 30,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 50,
                    offset: Offset(0, 20),
                  )
                ]),
            child: Center(
              child: SvgPicture.asset("assets/images/svgs/stamp-pass.svg"),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          dev.log('do to detail profile');
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.network(
                  widget.profile.avatar!,
                  errorBuilder: (context, error, stackTrace) {
                    return const LoadingIndicator();
                  },
                  fit: BoxFit.fitHeight,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 83,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 83,
                  child: ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.profile.name}, ${(DateTime.now().difference(widget.profile.birthday!).inDays / 365).floor()} years",
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              widget.profile.breed!.name!,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 25,
                child: distance == null
                    ? const SizedBox()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                    "assets/images/svgs/location.svg"),
                                Text(
                                  "${distance!.floor()} km",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
