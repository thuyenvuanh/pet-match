import 'dart:developer' as dev;

import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/reaction.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/domain/repositories/profile_repository.dart';
import 'package:pet_match/src/domain/repositories/subscription_repository.dart';
import 'package:pet_match/src/domain/repositories/swipe_repository.dart';

part 'swipe_event.dart';
part 'swipe_state.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  final SwipeRepository _swipeRepository;
  final ProfileRepository _profileRepository;
  final SubscriptionRepository _subscriptionRepository;

  SwipeBloc(
    SwipeRepository swipeRepository,
    ProfileRepository profileRepository,
    SubscriptionRepository subscriptionRepository,
  )   : _swipeRepository = swipeRepository,
        _profileRepository = profileRepository,
        _subscriptionRepository = subscriptionRepository,
        super(SwipeInitial()) {
    on<FetchNewProfiles>((event, emit) async {
      dev.log('[swipe_bloc] fetching suggested profiles');
      emit(FetchingNewProfiles());
      final res = _profileRepository.getCurrentActiveProfile();
      Profile? profile;
      res.fold(
        (failure) {
          dev.log('Failed to fetch suggestion profiles');
          emit(FetchNewProfilesError(failure.runtimeType.toString()));
        },
        (activeProfile) => profile = activeProfile,
      );
      if (profile != null) {
        final profiles = await _swipeRepository.getSuggestions(profile!);
        profiles.fold((failure) {
          dev.log('Get profiles failed');
          emit(FetchNewProfilesError(failure.runtimeType.toString()));
        }, (suggestions) {
          emit(FetchNewProfilesOk(suggestions));
        });
      }
      dev.log('[swipe_bloc] new profiles sent');
    });
    on<SwipeLike>((event, emit) async {
      dev.log('[swipe_bloc] SwipeLike');
      final sub = await _subscriptionRepository
          .getSubscriptionData(FirebaseAuth.instance.currentUser!.uid);
      if (sub.isLeft()) {
        dev.log('cannot get subscription data');
        emit(SwipeFailed());
        return;
      }
      Subscription? data;
      if (sub.isRight()) {
        data = sub.getOrElse(() => throw Exception('Not going to happen'));
      }
      var isLimit = 0;
      if (!data!.isActive() && data.name != SubscriptionName.PREMIUM) {
        isLimit = await _subscriptionRepository.getRemainingSwipeOfDay();
        if (isLimit <= 0) {
          emit(SwipeGetLimitation());
          return;
        }
      }
      final activeProfile = _profileRepository.getCurrentActiveProfile();
      await activeProfile.fold((failure) {
        dev.log('cannot get active profile');
      }, (activeProfile) async {
        var res = await _swipeRepository.likeProfile(
          activeProfile,
          event.profile,
          event.comment,
        );
        res.fold((l) {
          dev.log(
              '[swipe_bloc] Something went wrong. The liked profile will not be saved');
        }, (r) {
          dev.log('[swipe_bloc] Profile and comment saved successfully');
        });
        emit(SwipeDone(
            remainingSwipes: isLimit == 0 ? 0 : isLimit - 1,
            subscription: data!));
        add(FetchLikedProfiles());
        await _subscriptionRepository.subtractRemains();
        emit(SwipeDone(subscription: data));
      });
    });
    on<SwipePass>((event, emit) async {
      dev.log('[swipe_bloc] SwipePass');
      final sub = await _subscriptionRepository
          .getSubscriptionData(FirebaseAuth.instance.currentUser!.uid);
      if (sub.isLeft()) {
        dev.log('cannot get subscription data');
        emit(SwipeFailed());
        return;
      }
      Subscription? data;
      if (sub.isRight()) {
        data = sub.getOrElse(() => throw Exception('Not going to happen'));
      }
      var isLimit = 0;
      if (!data!.isActive()) {
        isLimit = await _subscriptionRepository.getRemainingSwipeOfDay();
        if (isLimit == 0) {
          emit(SwipeGetLimitation());
          return;
        }
      }
      emit(SwipeDone(
          remainingSwipes: isLimit == 0 ? 0 : isLimit - 1, subscription: data));
      await _subscriptionRepository.subtractRemains();
      emit(SwipeDone(subscription: data));
    });
    on<FetchLikedProfiles>((event, emit) async {
      dev.log('[swipe_bloc] fetching likedProfiles');
      List<Reaction> likedProfiles = [];
      final activeProfile = _profileRepository.getCurrentActiveProfile();
      await activeProfile.fold((failure) {
        dev.log('cannot get active profile');
        emit(FetchLikedProfilesError("Something went wrong"));
      }, (profile) async {
        final res = await _swipeRepository.getLikedProfile(profile);
        res.fold((l) {
          dev.log('[swipe_bloc] fetch liked profiles error');
          emit(FetchLikedProfilesError(l.runtimeType.toString()));
        }, (likes) {
          dev.log(
              '[swipe_bloc] liked profiles founds with ${likes.length} entities');
          likedProfiles.addAll(likes);
          emit(FetchLikedProfilesOK(likedProfiles));
        });
      });
    });
    on<DontLikeBack>((event, emit) async {
      final activeProfile = _profileRepository.getCurrentActiveProfile();
      await activeProfile.fold((l) {
        dev.log("cannot find current Profile");
      }, (activeProfile) async {
        var res = await _swipeRepository.passProfile(
          event.profile,
          activeProfile,
        );
        await res.fold((l) {
          dev.log('remove profile failed');
        }, (r) async {
          dev.log('[bloc] remove profile success');
          final likedProfile =
              await _swipeRepository.getLikedProfile(activeProfile);
          emit(FetchLikedProfilesOK(likedProfile.getOrElse(() => [])));
        });
      });
    });
  }
}
