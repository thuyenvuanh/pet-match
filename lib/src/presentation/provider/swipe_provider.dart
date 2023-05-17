import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';

enum SwipeStatus { like, pass, none }

class SwipeProvider extends ChangeNotifier {
  final SwipeBloc bloc;
  final double range = 100;

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
          var newProfiles = [
            "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445",
            "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
            "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445",
            "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
            "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445",
            "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
          ].reversed.toList();
          _profiles = [...newProfiles, ...profiles];
          _isFetching = false;
          _resetDrag();
          break;
        case SwipeDone:
          dev.log("Swipe Done from provider");
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
  bool _isFetching = false;
  bool _isButtonsDisabled = false;
  bool _hapticTrack = false;

  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  Size get screenSize => _screenSize;
  List<String> get profiles => _profiles;
  double get stampOpacity => min(_position.dx.abs() / range, 1);
  bool get isAnimating => _isButtonsDisabled;

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
    if (_position.dx > range || _position.dx < -range) {
      if (!_hapticTrack) {
        HapticFeedback.lightImpact();
        dev.log('haptic played');
      }
      _hapticTrack = true;
    } else {
      _hapticTrack = false;
      dev.log("haptic track cancelled");
    }
    notifyListeners();
  }

  onDragEnd(DragEndDetails details) {
    _isDragging = false;
    notifyListeners();
    switch (getSwipeStatus(true)) {
      case SwipeStatus.like:
        like();
        break;
      case SwipeStatus.pass:
        pass();
        break;
      default:
        _resetDrag();
        break;
    }
  }

  SwipeStatus getSwipeStatus([force = false]) {
    final delta = _position.dx;
    if (force) {
      if (delta > range) return SwipeStatus.like;
      if (delta < -range) return SwipeStatus.pass;
      return SwipeStatus.none;
    } else {
      var range = 1;
      if (delta > range) return SwipeStatus.like;
      if (delta < -range) return SwipeStatus.pass;
      return SwipeStatus.none;
    }
  }

  like() {
    _isButtonsDisabled = true;
    bloc.add(SwipeLike(Profile()));
    _angle = 20;
    _position += Offset(_screenSize.width * 1.5, 0);
    _nextCard();
    notifyListeners();
  }

  pass() {
    _isButtonsDisabled = true;
    bloc.add(SwipePass(Profile()));
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);
    _nextCard();
    notifyListeners();
  }

  Future _nextCard() async {
    if (_profiles.isEmpty) return;
    if (_profiles.length < 5 && !_isFetching) {
      _isFetching = true;
      bloc.add(FetchNewProfiles());
    }
    await Future.delayed(const Duration(milliseconds: 400));
    _profiles.removeLast();
    _resetDrag();
  }

  void _resetDrag() {
    _isButtonsDisabled = false;
    _angle = 0;
    _position = Offset.zero;
    notifyListeners();
  }
}
