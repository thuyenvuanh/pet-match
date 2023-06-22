import 'dart:developer' show log;

import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/domain/repositories/subscription_repository.dart';
import 'package:pet_match/src/presentation/widgets/register_dialog.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Subscription? _subscription;

  Subscription? get subscription => _subscription;

  SubscriptionBloc(SubscriptionRepository repository)
      : _repository = repository,
        super(SubscriptionInitial()) {
    on<GetSubscriptionData>((event, emit) async {
      emit(SubscriptionLoading());
      var res = await _repository.getSubscriptionData(auth.currentUser!.uid);
      var remaining = await _repository.getRemainingSwipeOfDay();
      Subscription sub = Subscription();
      await res.fold((failure) {
        log('Fail to get subscription');
        emit(GetSubscriptionError());
      }, (subscription) async {
        sub = subscription;
        _subscription = subscription;
        await _repository.cacheSubscription(sub);
        emit(GetSubscriptionSuccess(
          sub,
          event.showPremiumDialog,
          event.dialogPlace,
          remaining,
        ));
      });
    });
    on<GetRemainingSwipes>((event, emit) async {
      if (event.cache != null) {
        emit(RemainingSwipe(event.cache!));
        return;
      }
      var res = await _repository.getRemainingSwipeOfDay();
      emit(RemainingSwipe(res));
    });
    on<AddMoreSwipeAfterAd>((event, emit) async {
      var res = await _repository.addMoreSwipe();
      emit(RemainingSwipe(res));
    });
  }
}
