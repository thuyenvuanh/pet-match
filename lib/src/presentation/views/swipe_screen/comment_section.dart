import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/utils/constant.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  static const _enableColor = Color(0x4D000000);
  static const enableBorderSide = BorderSide(color: _enableColor);
  static const errorBorderSide = BorderSide(color: Colors.red);

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void sendComment([String? value]) {
    //? value is not need because we have controller
    if (_commentController.text.isEmpty) {
      dev.log('nothing to send');
    } else {
      dev.log('sending: ${_commentController.text}');
    }
    Navigator.pop(context, [_commentController.text]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              onSubmitted: sendComment,
              controller: _commentController,
              autofocus: true,
              maxLines: null, // Set this
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                hintText: "Viết tin nhắn",
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: errorBorderSide,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: Resource.defaultBorderRadius,
                  borderSide: errorBorderSide,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: Resource.defaultBorderRadius,
                  borderSide: enableBorderSide,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: Resource.defaultBorderRadius,
                  borderSide: enableBorderSide,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          RoundedIconButton(
            color: Colors.transparent,
            borderColor: _enableColor,
            onTap: sendComment,
            child: SizedBox(
              height: 28,
              width: 28,
              child: SvgPicture.asset(
                'assets/images/svgs/send-comment.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}