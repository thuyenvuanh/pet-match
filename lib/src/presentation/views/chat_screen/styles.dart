import 'package:flutter/material.dart';
import 'package:pet_match/src/utils/constant.dart';

class Styles {
  static TextStyle h1() {
    return const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white);
  }

  static friendsBox() {
    return const BoxDecoration(color: Colors.white);
  }

  static messagesCardStyle(check) {
    return BoxDecoration(
      borderRadius: Resource.defaultBorderRadius.copyWith(
        bottomLeft: !check ? const Radius.circular(0) : null,
        bottomRight: !check ? null : const Radius.circular(0),
      ),
      color: !check ? Resource.primaryTintColor : const Color(0xFFF3F3F3),
    );
  }

  static messageFieldCardStyle() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: _enableColor),
      borderRadius: Resource.defaultBorderRadius,
    );
  }

  static const _enableColor = Color(0x4D000000);
  static const enableBorderSide = BorderSide(color: _enableColor);
  static const errorBorderSide = BorderSide(color: Colors.red);

  static messageTextFieldStyle({required Function() onSubmit}) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: 'Enter Message',
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      suffixIcon: IconButton(onPressed: onSubmit, icon: const Icon(Icons.send)),
    );
  }

  static searchTextFieldStyle() {
    return InputDecoration(
      border: InputBorder.none,
      hintText: 'Enter Name',
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      suffixIcon:
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
    );
  }

  static searchField({Function(String)? onChange}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        onChanged: onChange,
        decoration: Styles.searchTextFieldStyle(),
      ),
      decoration: Styles.messageFieldCardStyle(),
    );
  }
}
