import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';

part 'create_profile_event.dart';

part 'create_profile_state.dart';

class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final ProfileRepository repository;
  var breedRequired = "Required";
  var basicRequired = "Required";
  Profile newProfile;

  Profile get profile => newProfile;

  CreateProfileBloc(this.repository)
      : newProfile = Profile(),
        super(CreateProfileInitial()) {
    on<StartCreateProfile>((event, emit) {
      Breed breed = Breed(id: "", name: "");
      emit(const BreedSaved(null));
    });
    on<SaveBreed>((event, emit) {
      if (event.breed == null) {
        emit(CreateProfileError(breedRequired));
      } else {
        newProfile.breed = event.breed;
        Breed breed = Breed(id: event.breed!.id, name: event.breed!.name);
        emit(BreedSaved(breed));
      }
    });
    on<SaveBasicInformation>((event, emit) {
      if (event.name == null ||
          event.name!.isEmpty ||
          event.height == null ||
          event.weight == null ||
          event.birthday == null ||
          event.gender == null) {
        emit(CreateProfileError(basicRequired));
      } else {
        newProfile.name = event.name;
        newProfile.height = event.height;
        newProfile.weight = event.weight;
        newProfile.birthday = event.birthday;
        newProfile.avatarFile = event.avatar;
        newProfile.gender = event.gender;
        emit(BasicInformationSaved(newProfile));
      }
    });
    on<SaveInterests>((event, emit) {
      profile.interests = event.interests?.toList() ?? [];
      emit(InterestSaved(profile.interests?.toSet() ?? <Breed>{}));
      add(SubmitProfile(profile));
    });
    on<SubmitProfile>((event, emit) async {
      emit(CreateProfileLoading());
      newProfile = event.profile;
      var res = await repository.newProfile(newProfile);
      res.fold((failure) {
        emit(const CreateProfileError("Something went wrong"));
      }, (profile) {
        emit(CreateProfileSuccess(profile));
      });
    });
  }
}
