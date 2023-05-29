import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.loadingText});

  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    if (loadingText != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Resource.primaryColor),
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Text(
              loadingText!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Resource.primaryTextColor),
            ),
          ),
        ],
      );
    }
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation(Resource.primaryColor),
      ),
    );
  }
}
