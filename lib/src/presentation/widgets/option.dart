import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class Option extends StatelessWidget {
  Option({
    Key? key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  final String label;
  final bool isSelected;
  final Function(String value) onTap;

  final defaultBoxDecoration = BoxDecoration(
    border: Border.all(color: Resource.disabledColor),
    borderRadius: Resource.defaultBorderRadius,
  );

  final selectedBoxDecoration = BoxDecoration(
    color: Resource.primaryColor,
    borderRadius: Resource.defaultBorderRadius,
  );

  static const selectedTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const defaultTextStyle = TextStyle(color: Colors.black, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(label),
          borderRadius: Resource.defaultBorderRadius,
          child: Ink(
            width: MediaQuery.of(context).size.width,
            height: 58,
            decoration: isSelected ? selectedBoxDecoration : defaultBoxDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: isSelected ? selectedTextStyle : defaultTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
