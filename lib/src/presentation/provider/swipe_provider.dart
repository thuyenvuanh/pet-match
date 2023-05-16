import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';

enum SwipeStatus { like, pass, none }

class SwipeProvider extends ChangeNotifier {
  final SwipeBloc bloc;

  SwipeProvider(this.bloc) {
    _profiles = [
      "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
      "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445"
    ];
    notifyListeners();
    bloc.stream.listen((state) {
      switch (state.runtimeType) {
        case FetchNewProfilesOk:
          dev.log("Fetch OK from provider");
          break;
        case SwipeDone:
          dev.log("Swipe Done from provider");
          _nextCard();
          break;
        default:
          dev.log(state.runtimeType.toString());
          dev.log("Initial state");
      }
    });
  }

  Offset _position = Offset.zero;
  bool _isDragging = false;
  double _angle = 0;
  Size _screenSize = Size.zero;
  List<String> _profiles = [];

  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  Size get screenSize => _screenSize;
  List<String> get profiles => _profiles;

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
    dev.log(_angle.toString());
    dev.log(_position.dx.toString());
    notifyListeners();
  }

  onDragEnd(DragEndDetails details) {
    _isDragging = false;
    notifyListeners();
    switch (getSwipeStatus()) {
      case SwipeStatus.like:
        like();
        break;
      case SwipeStatus.pass:
        pass();
        break;
      default:
        reset();
        break;
    }
  }

  getSwipeStatus() {
    var delta = _position.dx;
    const double range = 200;
    if (delta > range) return SwipeStatus.like;
    if (delta < -range) return SwipeStatus.pass;
    return SwipeStatus.none;
  }

  like() {
    bloc.add(SwipeLike(Profile()));
    _angle = 20;
    _position += Offset(4 * _screenSize.width, 0);
    notifyListeners();
  }

  Future _nextCard() async {
    if (_profiles.length < 5) {
      bloc.add(FetchNewProfiles());
    }
    await Future.delayed(const Duration(seconds: 2));
    _profiles.removeLast();
    reset();
  }

  pass() {
    bloc.add(SwipePass(Profile()));
    _angle = 20;
    _position -= Offset(4 * _screenSize.width, 0);
    notifyListeners();
  }

  void reset() {
    _angle = 0;
    _position = Offset.zero;
    notifyListeners();
  }
}
