import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late Profile activeProfile;
  final ProfileRepository profileRepository;

  HomeBloc(this.profileRepository) : super(HomeInitial()) {
    on<GetInitialData>((event, emit) {
      var res = profileRepository.getCurrentActiveProfile();
      res.fold((failure) {
        emit(NoActiveProfile());
      }, (profile) {
        try {
          activeProfile = profile;
          emit(ActiveProfile(activeProfile));
          add(FetchNewData());
        } on Exception {
          developer.log("active profile is null");
          emit(NoActiveProfile());
        }
      });
    });
    on<FetchNewData>((event, emit) async {
      if (activeProfile.id == null) {
        emit(NoActiveProfile());
      } else {
        var res = await profileRepository.getProfileById(activeProfile.id!);
        res.fold((failure) {
          developer.log("Get profile data error");
        }, (profile) {
          activeProfile = profile!;
          profileRepository.cacheCurrentActiveProfile(profile);
          emit(ActiveProfile(activeProfile));
        });
      }
    });
  }
}
