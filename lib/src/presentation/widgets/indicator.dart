import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    Key? key,
    required this.isActive,
  }) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Resource.primaryColor : Colors.black12,
      ),
    );
  }
}
