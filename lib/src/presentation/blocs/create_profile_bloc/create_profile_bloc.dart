import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';

part 'create_profile_event.dart';

part 'create_profile_state.dart';

class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final ProfileRepository repository;
  final StorageRepository storageRepository;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var breedRequired = "Required";
  var basicRequired = "Required";
  File? avatarImage;
  Profile newProfile;

  Profile get profile => newProfile;

  CreateProfileBloc(this.repository, this.storageRepository)
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
        avatarImage = event.avatar;
        newProfile.name = event.name;
        newProfile.height = event.height;
        newProfile.weight = event.weight;
        newProfile.birthday = event.birthday;
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
      if (event.profile.avatar == null) {
        emit(CreateProfileLoading());
        newProfile = event.profile;
        storageRepository.uploadImage(
          avatarImage!,
          '${auth.currentUser!.uid}/profiles',
          onSuccess: (url) {
            newProfile.avatar = url;
            add(SubmitProfile(newProfile));
          },
          onError: () {
            emit(const CreateProfileError('Upload avatar failed'));
          },
        );
      } else {
        var res =
            await repository.newProfile(newProfile, auth.currentUser!.uid);
        if (res.isRight()) {
          var profile = res.getOrElse(() => throw UnimplementedError());
          emit(CreateProfileSuccess(profile));
        } else {
          emit(const CreateProfileError("Something went wrong"));
        }
      }
    });
  }
}
