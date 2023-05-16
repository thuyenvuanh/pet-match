import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class CustomColorCircularIndicator extends StatelessWidget {
  const CustomColorCircularIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Resource.primaryColor),
      ),
    );
  }
}
