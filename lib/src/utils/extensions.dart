import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension PetMatchDateConverter on DateFormat {
  DateTime parsePetMatch(String data) =>
      DateFormat('dd/MM/yyyy HH:mm:ss').parse(data);
  String formatPetMatch(DateTime data) =>
      DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
}

extension MediaQueryExtension on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  EdgeInsets get screenViewInsets => MediaQuery.of(this).viewInsets;

  double? get iconSize => IconTheme.of(this).size;
}
