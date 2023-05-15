import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

enum ButtonVariant { primary, text }

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = ButtonVariant.primary,
    this.color = Colors.white,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.borderRadius,
    this.height = 56,
    this.width,
    this.padding,
  });

  final ButtonVariant variant;
  final String label;
  final Color? color;
  final TextStyle? style;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final EdgeInsets? padding;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: Material(
        elevation: 0,
        borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
          child: Ink(
            height: widget.height,
            width: widget.width ?? MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: widget.variant == ButtonVariant.primary
                  ? Resource.primaryColor
                  : Colors.white,
              borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
            ),
            child: Center(
              child: Text(widget.label, style: widget.style),
            ),
          ),
        ),
      ),
    );
  }
}
