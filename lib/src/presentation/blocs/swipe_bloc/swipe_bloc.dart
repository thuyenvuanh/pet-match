import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';

part 'swipe_event.dart';
part 'swipe_state.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  SwipeBloc() : super(SwipeInitial()) {
    on<FetchNewProfiles>((event, emit) async {
      dev.log('fetching new profiles');
      await Future.delayed(const Duration(seconds: 10))
          .then((value) => emit(FetchNewProfilesOk(const [])));
    });
    on<SwipeLike>((event, emit) {
      dev.log('SwipeLike');
      emit(SwipeDone(Profile()));
    });
    on<SwipePass>((event, emit) {
      dev.log('SwipePass');
      emit(SwipeDone(Profile()));
    });
  }
}
