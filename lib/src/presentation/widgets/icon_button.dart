import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class RoundedIconButton extends StatefulWidget {
  const RoundedIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Resource.primaryColor,
    this.style = const TextStyle(color: Colors.white),
    this.borderRadius = BorderRadius.zero,
    this.height = 64,
    this.width = 64,
    this.margin,
  });

  final Widget child;
  final Color? color;
  final TextStyle? style;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? height;
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
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          child: Ink(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Resource.lightBackground,
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: const Color(0xFFE8E6EA),
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
