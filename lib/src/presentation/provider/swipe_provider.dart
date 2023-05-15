import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class SwipeProvider extends ChangeNotifier {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  double _angle = 0;
  Size _screenSize = Size.zero;

  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  Size get screenSize => _screenSize;

  setScreenSize(Size size) {
    _screenSize = size;
    dev.log("${size.width} ${size.height}");
    notifyListeners();
  }

  onStartDrag(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  onDragUpdate(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 30 * x / _screenSize.width;
    notifyListeners();
  }

  onDragEnd(DragEndDetails details) {
    _angle = 0;
    _position = Offset.zero;
    _isDragging = false;
    notifyListeners();
  }
}
