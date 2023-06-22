import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/firebase_options.dart';

enum DialogPlace {
  swipe,
  otherProfileComments,
  myProfileComments,
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog(
      {super.key,
      this.place = DialogPlace.otherProfileComments,
      required this.subscriptionBloc});

  final DialogPlace? place;
  final SubscriptionBloc subscriptionBloc;

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  static const _blackText = TextStyle(
    color: Colors.black,
    height: 1.5,
  );
  static const _highlightText =
      TextStyle(color: Resource.primaryColor, fontWeight: FontWeight.bold);

  final adUnitId =
      DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.android
          ? 'ca-app-pub-3922734288276135~7049829082'
          : 'ca-app-pub-3922734288276135~3641067111';

  /// Loads a rewarded ad.
  void loadAd() {
    showDialog(
        context: context, builder: (context) => const LoadingIndicator());
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {
                dev.log('ad clicked');
              },
            );
            ad.show(
              onUserEarnedReward: (ad, reward) {
                widget.subscriptionBloc.add(AddMoreSwipeAfterAd());
                Navigator.pop(context);
              },
            );
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 40),
      surfaceTintColor: Colors.white,
      title: const Text(
        'Đăng kí',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF1b4695),
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
      ),
      children: [
        const SizedBox(height: 40),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Đăng kí ',
                style: _blackText,
              ),
              TextSpan(
                text: 'Premium ',
                style: _highlightText,
              ),
              TextSpan(
                text: 'để mở thêm nhiều tính năng',
                style: _blackText,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.comment,
              color: Color(0xFFE29033),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: _blackText,
                  children: [
                    TextSpan(text: 'Xem '),
                    TextSpan(
                      text: 'bình luận ',
                      style: TextStyle(
                        color: Color(0xFFE29033),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: 'của người lạ')
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.eye,
              color: Color(0xFF8CD2B6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: _blackText,
                  children: [
                    TextSpan(
                      text: 'Xem ',
                      style: TextStyle(
                          color: Color(0xFF8CD2B6),
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'những người đã thích mình',
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              color: Color(0xFF1B4695),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: _blackText,
                  children: [
                    TextSpan(text: 'Xem '),
                    TextSpan(
                      text: 'lịch sử ',
                      style: TextStyle(
                        color: Color(0xFF1B4695),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: 'người đã lướt')
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Button(
            label: 'Đăng kí ngay',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.premiumRegister.name)),
        widget.place == DialogPlace.swipe
            ? Button(
                padding: const EdgeInsets.only(top: 10),
                label: 'Thêm 1 lượt nữa',
                onTap: loadAd,
                style: const TextStyle(color: Colors.black),
                variant: ButtonVariant.text,
                leadingIcon: const FaIcon(
                  FontAwesomeIcons.rectangleAd,
                ),
              )
            : const SizedBox(),
        const SizedBox(height: 32),
      ],
    );
  }
}
