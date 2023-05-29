import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/utils/error/failure.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  late Profile profile;

  ProfileBloc(
      ProfileRepository profileRepository, AuthRepository authRepository)
      : _profileRepository = profileRepository,
        _authRepository = authRepository,
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
        emit(ProfileLoggedIn());
      } else {
        emit(LoginError());
      }
    });

    on<GetCurrentProfile>((event, emit) {
      var res = _profileRepository.getCurrentActiveProfile();
      res.fold((failure) {
        dev.log('error while get current profile');
      }, (profile) {
        emit(CurrentProfileState(profile));
      });
    });
    on<LogoutOfProfile>((event, emit) async {
      emit(ProfilesLoading());
      await _profileRepository.disableCurrentActiveProfile();
      emit(ProfileLoggedOut());
    });
  }
}
