import 'dart:developer' as dev;

import 'package:faker/faker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/like.dart';
import 'package:pet_match/src/domain/models/gender_model.dart';
import 'package:pet_match/src/domain/models/mock_data/breed.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/swipe_repository.dart';
import 'package:random_name_generator/random_name_generator.dart';
import 'package:random_string/random_string.dart';

part 'swipe_event.dart';
part 'swipe_state.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  final SwipeRepository _swipeRepository;

  //! TEST VARIABLE - REMOVE
  final RandomNames _randomNames;
  final List<String> images = [
    "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
    "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445",
    "https://millenroadanimalhospital.com/wp-content/uploads/2019/03/Dogs.jpg",
    // "https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_640.jpg",
    // "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/1200px-Cat_November_2010-1a.jpg",
    "https://cdn.tgdd.vn/Files/2021/04/12/1342796/15-giong-cho-canh-dep-de-cham-soc-pho-bien-tai-viet-nam-202104121501444654.jpg",
  ];

  SwipeBloc(
    SwipeRepository swipeRepository,
  )   : _swipeRepository = swipeRepository,
        _randomNames = RandomNames(Zone.us),
        super(SwipeInitial()) {
    on<FetchNewProfiles>((event, emit) async {
      dev.log('[swipe_bloc] fetching suggested profiles');
      //! REPLACE WITH FETCHING FUNCTIONS
      var profiles = List.generate(
          10,
          (index) => Profile(
                id: randomString(12),
                birthday: faker.date.dateTimeBetween(
                  DateTime(2015),
                  DateTime.now(),
                ),
                breed: breeds.elementAt(
                    int.parse(randomNumeric(2)).floor() % breeds.length),
                name: _randomNames.name(),
                description: randomString(100),
                gallery: [],
                gender: Gender.male.name,
                height: double.parse(randomNumeric(3)),
                weight: double.parse(randomNumeric(2)),
                interests: [],
                avatar: images
                    .elementAt(int.parse(randomNumeric(4)) % images.length),
              ));
      await Future.delayed(const Duration(seconds: 1))
          .then((value) => emit(FetchNewProfilesOk(profiles)));
      dev.log('[swipe_bloc] new profiles sent');
    });
    on<SwipeLike>((event, emit) async {
      dev.log('[swipe_bloc] SwipeLike');
      var res =
          await _swipeRepository.likeProfile(event.profile, event.comment);
      res.fold((l) {
        dev.log(
            '[swipe_bloc] Something went wrong. The liked profile will not be saved');
      }, (r) {
        dev.log('[swipe_bloc] Profile and comment saved successfully');
      });
      emit(SwipeDone(Profile()));
      add(FetchLikedProfiles());
    });
    on<SwipePass>((event, emit) {
      dev.log('[swipe_bloc] SwipePass');
      emit(SwipeDone(Profile()));
    });
    on<FetchLikedProfiles>((event, emit) async {
      dev.log('[swipe_bloc] fetching likedProfiles');
      List<Like> likedProfiles = [];
      final res = await _swipeRepository.getLikedProfile();
      res.fold((l) {
        dev.log('[swipe_bloc] fetch liked profiles error');
        emit(FetchLikedProfilesError(l.runtimeType.toString()));
      }, (likes) {
        dev.log(
            '[swipe_bloc] liked profiles founds with ${likes.length} entities');
        likedProfiles.addAll(likes);
      });
      emit(FetchLikedProfilesOK(likedProfiles));
    });
  }
}
