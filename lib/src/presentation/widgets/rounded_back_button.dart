import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/utils/constant.dart';

class RoundedBackButton extends StatelessWidget {
  const RoundedBackButton({Key? key, this.onTap}) : super(key: key);

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return RoundedIconButton(
      onTap: onTap,
      borderRadius: Resource.defaultBorderRadius,
      child: SvgPicture.asset('assets/images/svgs/right.svg'),
    );
  }
}
