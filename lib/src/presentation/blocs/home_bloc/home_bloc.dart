import 'dart:developer' as dev;

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
      dev.log('[home_bloc] get initial data');
      var res = profileRepository.getCurrentActiveProfile();
      res.fold((failure) {
        emit(NoActiveProfile());
      }, (profile) {
        try {
          activeProfile = profile;
          emit(ActiveProfile(activeProfile));
          add(FetchNewData());
        } on Exception {
          dev.log("[home_bloc] Something went wrong!");
          emit(NoActiveProfile());
        }
      });
    });
    on<FetchNewData>((event, emit) async {
      dev.log('[home_bloc] Fetching new data');
      if (activeProfile.id == null) {
        dev.log('[home_bloc] no active profile found to fetch new data');
      } else {
        var res =
            await profileRepository.getProfileById(activeProfile.id!, true);
        res.fold((failure) {
          dev.log("[home_bloc] Get profile data error");
        }, (profile) {
          activeProfile = profile!;
          profileRepository.cacheCurrentActiveProfile(profile);
          emit(ActiveProfile(activeProfile));
        });
      }
    });
  }
}
