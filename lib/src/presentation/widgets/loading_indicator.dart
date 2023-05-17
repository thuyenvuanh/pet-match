import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation(Resource.primaryColor),
      ),
    );
  }
}
