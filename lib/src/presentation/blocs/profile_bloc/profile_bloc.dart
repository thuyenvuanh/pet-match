import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/auth_repository.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

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
        if (either.isRight()) {
          var profiles = List<Profile>.from((either as Right).value);
          if (profiles.isEmpty) {
            emit(NoProfileFetched());
          } else {
            emit(FetchedSuccess(profiles));
          }
        } else {
          emit(const FetchedError(
              'Failed to fetch profiles. Please try again later'));
        }
      } else {
        emit(const FetchedError('You\'re not logged in. Log in first.'));
      }
    });
    on<LoginToProfile>((event, emit) async {
      emit(LoggingIntoProfile(profile: event.profile));
      var res = await _profileRepository.getProfileById(event.profile.id!);
      var profile = res.getOrElse(() => null);
      if (profile != null) {
        _profileRepository.cacheCurrentActiveProfile(profile);
        emit(ProfileLoggedIn());
      } else {
        emit(LoginError());
      }
    });
    on<LogoutOfProfile>((event, emit) async {
      emit(ProfilesLoading());
      await _profileRepository.disableCurrentActiveProfile();
      emit(ProfileLoggedOut());
    });
  }
}
