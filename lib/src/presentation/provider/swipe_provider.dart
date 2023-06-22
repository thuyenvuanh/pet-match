import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/blocs/subscription_bloc/subscription_bloc.dart';
import 'package:pet_match/src/presentation/blocs/swipe_bloc/swipe_bloc.dart';
import 'package:pet_match/src/presentation/widgets/register_dialog.dart';

enum SwipeStatus { like, pass, none }

class SwipeProvider extends ChangeNotifier {
  final SwipeBloc bloc;
  final SubscriptionBloc subscriptionBloc;
  final ProfileBloc profileBloc;
  final double range = 150;

  SwipeProvider(
    this.bloc,
    this.subscriptionBloc,
    this.profileBloc,
  ) {
    notifyListeners();
    profileBloc.stream.listen((state) {
      if (state is ProfileLoggedIn || state is ProfileLoggedOut) {
        _backupList = [];
        _profiles = [];
      }
    });
    bloc.stream.listen((state) {
      switch (state.runtimeType) {
        case FetchNewProfilesOk:
          dev.log("Fetch OK from provider");
          var newProfiles = (state as FetchNewProfilesOk).profiles;
          _backupList.addAll(newProfiles);
          _profiles.insertAll(
              0, _backupList.sublist(0, min(10, _backupList.length)).reversed);
          _backupList.removeRange(0, min(10, _backupList.length));
          _isFetching = false;
          _resetDrag();
          break;
        case SwipeDone:
          state as SwipeDone;
          if (state.subscription.name! != SubscriptionName.PREMIUM) {
            subscriptionBloc.add(GetRemainingSwipes(
              cache: state.remainingSwipes,
            ));
          }
          if (state.remainingSwipes == null) {
            _nextCard();
          }
          break;
        case SwipeGetLimitation:
          subscriptionBloc.add(const GetSubscriptionData(
            showPremiumDialog: true,
            dialogPlace: DialogPlace.swipe,
          ));

          _resetDrag();
          break;
      }
    });
  }

  Offset _position = Offset.zero;
  bool _isDragging = false;
  double _angle = 0;
  Size _screenSize = Size.zero;
  List<Profile> _profiles = [];
  List<Profile> _backupList = [];
  bool _isFetching = false;
  bool _isButtonsDisabled = false;
  bool _hapticTrack = false;

  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  Size get screenSize => _screenSize;
  List<Profile> get profiles => _profiles;

  double get stampOpacity => min(_position.dx.abs() / range, 1);
  bool get isAnimating => _isButtonsDisabled;

  setScreenSize(Size size) {
    _screenSize = size;
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
      if (_hapticTrack) {
        _hapticTrack = false;
        dev.log("haptic track cancelled");
      }
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

  like([String? comment]) {
    _isButtonsDisabled = true;
    bloc.add(SwipeLike(_profiles.last, comment));
    _angle = 20;
    _position += Offset(_screenSize.width * 1.5, 0);
    notifyListeners();
  }

  pass() {
    _isButtonsDisabled = true;
    bloc.add(SwipePass(_profiles.last));
    _angle = -20;
    _position -= Offset(_screenSize.width * 1.5, 0);
    notifyListeners();
  }

  Future _nextCard() async {
    if (_profiles.isEmpty) return;
    if (_backupList.length < 5 && !_isFetching) {
      _isFetching = true;
      bloc.add(FetchNewProfiles());
    }
    await Future.delayed(const Duration(milliseconds: 400));
    _profiles.removeLast();
    if (_profiles.length == 2) {
      _profiles.insertAll(
          0, _backupList.sublist(0, min(8, _backupList.length)).reversed);
      _backupList.removeRange(0, min(8, _backupList.length));
    }
    _resetDrag();
  }

  void _resetDrag() {
    _isButtonsDisabled = false;
    _angle = 0;
    _position = Offset.zero;
    notifyListeners();
  }
}
