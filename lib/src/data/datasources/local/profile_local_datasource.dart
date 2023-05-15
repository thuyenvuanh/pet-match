import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/error/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDatasource {

  final SharedPreferences localStorage;
  final String activeProfile = "activeProfile";

  ProfileLocalDatasource(this.localStorage);

  Either<Failure, bool> cacheActiveProfile(Profile profile) {
    try {
      profile.id = "0";
      var profileEncoded = json.encode(profile.toJson());
      localStorage.setString(activeProfile, profileEncoded);
      return const Right(true);
    } on Exception {
      return Left(SharedPreferencesFailure.empty());
    }
  }

  Either<Failure, Profile> getActiveProfile() {
    try {
      var profileEncoded = localStorage.getString(activeProfile);
      if (profileEncoded == null || profileEncoded == 'null') throw NotFoundException();
      Profile profile = Profile.fromJson(json.decode(profileEncoded) ?? {});
      return Right(profile);
    } on NotFoundException {
      return Left(SharedPreferencesFailure.notFound(Profile().runtimeType));
    } on Exception {
      return Left(SharedPreferencesFailure.empty());
    }
  }
}