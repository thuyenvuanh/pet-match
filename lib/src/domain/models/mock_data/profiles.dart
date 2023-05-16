import 'dart:io';

import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/location_model.dart';
import 'package:pet_match/src/domain/models/mock_data/breed.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';

Profile createdProfile = Profile(
  id: "1",
  name: "Luna",
  height: 120,
  weight: 12,
  gender: "Female",
  birthday: DateTime(2020, 10, 12),
  avatarFile: File(
      "https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg?crop=0.752xw:1.00xh;0.175xw,0&resize=1200:*"),
  breed: breeds.first,
  cover: "",
  gallery: [],
  interests: [
    Breed(id: '100', name: 'Chihuahua'),
    Breed(id: '101', name: 'Shiba Inu'),
  ],
  introduction: "Hobby is running outside",
  location: Location(lat: 100, long: 100),
);
