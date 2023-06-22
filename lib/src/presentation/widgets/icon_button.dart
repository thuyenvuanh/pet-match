import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class RoundedIconButton extends StatefulWidget {
  const RoundedIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Resource.lightBackground,
    this.style = const TextStyle(color: Colors.white),
    this.borderRadius,
    this.height = 64,
    this.borderColor,
    this.width = 64,
    this.margin,
  });

  final Widget child;
  final Color? color;
  final TextStyle? style;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? height;
  final Color? borderColor;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  State<RoundedIconButton> createState() => _RoundedIconButtonState();
}

class _RoundedIconButtonState extends State<RoundedIconButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? const EdgeInsets.all(0),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
        child: InkWell(
          splashColor: Resource.primaryTintColor,
          overlayColor: MaterialStateColor.resolveWith(
              (states) => Resource.primaryTintColor),
          onTap: widget.onTap,
          borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
          child: Ink(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.color ?? Resource.lightBackground,
              borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
              border: Border.all(
                color: widget.borderColor ?? const Color(0xFFE8E6EA),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
