import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';

enum ButtonVariant { primary, text }

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = ButtonVariant.primary,
    this.color,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.borderRadius,
    this.height = 56,
    this.width,
    this.padding,
    this.leadingIcon,
    this.textAlign,
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
  final Widget? leadingIcon;
  final TextAlign? textAlign;

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
        color: Colors.transparent,
        borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
        child: InkWell(
          // splashColor: Resource.primaryTintColor,
          overlayColor: MaterialStateColor.resolveWith(
            (states) {
              if (widget.variant == ButtonVariant.text) {
                return Resource.primaryTintColor;
              }
              return Colors.white.withOpacity(0.3);
            },
          ),
          onTap: widget.onTap,
          borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
          child: Ink(
            height: widget.height,
            width: widget.width ?? context.screenSize.width,
            decoration: BoxDecoration(
              color: widget.color ??
                  (widget.variant == ButtonVariant.primary
                      ? Resource.primaryColor
                      : Colors.white),
              borderRadius: widget.borderRadius ?? Resource.defaultBorderRadius,
            ),
            child: widget.leadingIcon == null
                ? Center(
                    child: Text(
                      widget.label,
                      style: widget.style,
                      textAlign: widget.textAlign,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.leadingIcon!,
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: widget.style,
                        textAlign: widget.textAlign,
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
