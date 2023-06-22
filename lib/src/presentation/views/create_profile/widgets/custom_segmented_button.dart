import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/gender_model.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';

class CustomSegmentedButton extends StatefulWidget {
  const CustomSegmentedButton({
    Key? key,
    required this.onChange,
    required this.selected,
  }) : super(key: key);

  final void Function(String value) onChange;
  final String selected;

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
    static const male = "Male";
    static const female = "Female";
    static const other = "Other";
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      width: context.screenSize.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: Resource.defaultBorderRadius,
        border: Border.all(color: const Color(0x4D000000)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Flexible(
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              child: InkWell(
                onTap: () => widget.onChange("Male"),
                child: Ink(
                  decoration: BoxDecoration(
                    color: widget.selected.toLowerCase() == male.toLowerCase()
                        ? Resource.primaryColor
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      Gender.male.vietnameseName,
                      style: widget.selected.toLowerCase() == male.toLowerCase()
                          ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                          : const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => widget.onChange(female),
                child: Ink(
                  decoration: BoxDecoration(
                      color: widget.selected.toLowerCase() == female.toLowerCase()
                          ? Resource.primaryColor
                          : Colors.white,
                      border: const Border.symmetric(
                          vertical: BorderSide(color: Color(0x4D000000)))),
                  child: Center(
                    child: Text(Gender.female.vietnameseName,
                        style: widget.selected.toLowerCase() == female.toLowerCase()
                            ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                            : const TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: InkWell(
                onTap: () => widget.onChange(other),
                child: Ink(
                  decoration: BoxDecoration(
                    color: widget.selected.toLowerCase() == other.toLowerCase()
                        ? Resource.primaryColor
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(Gender.other.vietnameseName,
                        style: widget.selected.toLowerCase() == other.toLowerCase()
                            ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                            : const TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
