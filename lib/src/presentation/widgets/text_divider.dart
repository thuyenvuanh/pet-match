import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({super.key, required this.child, this.symmetricIndent = 0});
  final Widget child;
  final double symmetricIndent;
  final Color dividerColor = const Color(0x66000000);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: symmetricIndent),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: child,
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }
}
