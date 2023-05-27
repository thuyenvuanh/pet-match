import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/utils/constant.dart';

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