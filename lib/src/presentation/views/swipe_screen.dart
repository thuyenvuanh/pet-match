import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/provider/swipe_provider.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/presentation/widgets/swipeable_card.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:provider/provider.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          children: [
            const SizedBox(
              height: 52,
              child: Text("Khám phá",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ChangeNotifierProvider(
                create: (context) => SwipeProvider(sl<SwipeBloc>()),
                child: const SwipeStack(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ElevatedCircleButtonStyle {
  white,
  primary;
}

class ElevatedCircleButton extends StatelessWidget {
  const ElevatedCircleButton({
    super.key,
    this.size,
    required this.style,
    required this.assetImage,
    this.onTap,
  });

  //parameters
  final double? size;
  final ElevatedCircleButtonStyle style;
  final String assetImage;
  final Function()? onTap;

  //UI styles
  static final whiteCircleButton = BoxDecoration(
    color: Resource.lightBackground,
    borderRadius: BorderRadius.circular(78),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.07),
          offset: const Offset(0, 20),
          blurRadius: 20)
    ],
  );
  static final redCircleButton = BoxDecoration(
    color: Resource.primaryColor,
    borderRadius: BorderRadius.circular(99),
    boxShadow: const [
      BoxShadow(
          color: Resource.primaryTintColor,
          offset: Offset(0, 15),
          blurRadius: 15)
    ],
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size ?? 78),
      splashColor: style == ElevatedCircleButtonStyle.white
          ? Resource.primaryTintColor
          : Colors.white.withOpacity(0.5),
      highlightColor: Colors.transparent,
      child: Container(
        height: size ?? 78,
        width: size ?? 78,
        decoration: style == ElevatedCircleButtonStyle.white
            ? whiteCircleButton
            : ElevatedCircleButton.redCircleButton,
        child: Center(
          child: SvgPicture.asset(assetImage),
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
                      url: e,
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
                    : () => dev.log('comment'),
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
