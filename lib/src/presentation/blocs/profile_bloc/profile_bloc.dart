import 'dart:developer' as dev;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/address_model.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/gender_model.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';
import 'package:pet_match/src/utils/error/failure.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;
  final FirebaseAuth auth = FirebaseAuth.instance;

  ProfileBloc(ProfileRepository profileRepository,
      AuthRepository authRepository, StorageRepository storageRepository)
      : _profileRepository = profileRepository,
        _authRepository = authRepository,
        _storageRepository = storageRepository,
        super(ProfileInitial()) {
    on<FetchAvailableProfiles>((event, emit) async {
      emit(ProfilesLoading());
      var res = await _authRepository.getUserId();
      if (res.isRight()) {
        var uid = (res as Right).value;
        var either = await _profileRepository.getProfiles(uid);
        either.fold(
          (failure) {
            if (failure.runtimeType == TimeoutFailure) {
              failure as TimeoutFailure;
              emit(FetchedError(failure.message));
            } else {
              emit(FetchedError(
                  'fetched error with type: ${failure.runtimeType}'));
            }
          },
          (profiles) {
            if (profiles.isEmpty) {
              emit(NoProfileFetched());
            } else {
              emit(FetchedSuccess(profiles));
            }
          },
        );
        // if (either.isRight()) {
        //   var profiles = List<Profile>.from((either as Right).value);
        //   if (profiles.isEmpty) {
        //     emit(NoProfileFetched());
        //   } else {
        //     emit(FetchedSuccess(profiles));
        //   }
      } else {
        emit(const FetchedError('You\'re not logged in. Log in first.'));
      }
    });
    on<LoginToProfile>((event, emit) async {
      emit(LoggingIntoProfile(profile: event.profile));
      var res =
          await _profileRepository.getProfileById(event.profile.id!, true);
      var profile = res.getOrElse(() => null);
      if (profile != null) {
        _profileRepository.cacheCurrentActiveProfile(profile);
        emit(ProfileLoggedIn(profile));
      } else {
        emit(LoginError());
      }
    });
    on<GetProfileDetailById>((event, emit) async {
      emit(ProfileDetailLoading());
      var res = await _profileRepository.getProfileById(event.uuid, true);
      res.fold((failure) {
        dev.log("[profile_bloc] Cannot get profile detail of id ${event.uuid}");
        emit(ProfileDetailError(failure.runtimeType.toString()));
      }, (profile) {
        dev.log("[profile_bloc] Get profile detail successful");
        emit(ProfileDetail(profile!));
      });
    });
    on<GetCurrentProfile>((event, emit) {
      var res = _profileRepository.getCurrentActiveProfile();
      res.fold((failure) {
        dev.log('error while get current profile');
        emit(ProfileLoggedOut());
      }, (profile) {
        emit(CurrentProfileState(profile));
      });
    });
    on<LogoutOfProfile>((event, emit) async {
      emit(ProfilesLoading());
      await _profileRepository.disableCurrentActiveProfile();
      emit(ProfileLoggedOut());
    });
    on<UpdateProfileDetail>(
      (event, emit) async {
        emit(ProfilesLoading());
        var fbStorage = FirebaseStorage.instance;
        //get images location
        var avatarRef = fbStorage.refFromURL(event.oldProfile.avatar!);
        var galleryRef = avatarRef.parent!.parent!.child('galleries');
        try {
          await galleryRef.delete();
        } on FirebaseException {
          dev.log('no gallery found, no deletion performed');
        }
        Profile profile = Profile(
            avatar: await _storageRepository.uploadImage(
                event.avatar, avatarRef.parent!.fullPath),
            name: event.name,
            id: event.id,
            height: event.height,
            weight: event.weight,
            breed: event.breed,
            gender: event.gender.name,
            birthday: event.birthday,
            address: event.address,
            description: event.description,
            interests: event.interests,
            gallery: await storageRepository.uploadMultipleImages(
                event.galleries, galleryRef.fullPath));
        final res = await _profileRepository.updateProfile(
            profile, auth.currentUser!.uid);
        await res.fold((failure) {
          dev.log('[profile_bloc] save failed');
          emit(const ProfileSaveUpdateError('Something went wrong'));
        }, (res) async {
          profile = res;
          await profileRepository.cacheCurrentActiveProfile(profile);
          emit(ProfileSaveUpdateSuccess(profile));
        });
      },
    );
  }
}
