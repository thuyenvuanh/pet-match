import 'dart:developer' as dev;

import 'package:faker/faker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/comment_model.dart';
import 'package:pet_match/src/domain/models/gender_model.dart';
import 'package:pet_match/src/domain/models/mock_data/breed.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:random_name_generator/random_name_generator.dart';
import 'package:random_string/random_string.dart';

part 'swipe_event.dart';
part 'swipe_state.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  //! TEST VARIABLE - REMOVE
  final RandomNames _randomNames;
  final List<String> images = [
    "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
    "https://www.cdc.gov/healthypets/images/pets/cute-dog-headshot.jpg?_=42445",
    "https://millenroadanimalhospital.com/wp-content/uploads/2019/03/Dogs.jpg",
    "https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_640.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/1200px-Cat_November_2010-1a.jpg"
  ];

  SwipeBloc()
      : _randomNames = RandomNames(Zone.us),
        super(SwipeInitial()) {
    on<FetchNewProfiles>((event, emit) async {
      dev.log('fetching new profiles');
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
      dev.log('new profile sent');
    });
    on<SwipeLike>((event, emit) {
      dev.log('SwipeLike');
      dev.log('mesage: ${event.comment}');
      emit(SwipeDone(Profile()));
    });
    on<SwipePass>((event, emit) {
      dev.log('SwipePass');
      emit(SwipeDone(Profile()));
    });
    on<FetchComments>((event, emit) {
      //! MOCK DATA REPLACE WITH THE REAL ONE
      final mockComments = List.generate(
        0,
        (index) => Comment(
          id: index.toString(),
          comment: randomString(50),
          profile: Profile(name: randomString(10)),
          createdTS: DateTime.now(),
        ),
      );
      dev.log('fetching comments');
      emit(FetchCommentsOK(mockComments));
    });
  }
}
