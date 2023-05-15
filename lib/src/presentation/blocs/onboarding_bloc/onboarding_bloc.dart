import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/domain/repositories/onboarding_repository.dart';

part 'onboarding_event.dart';

part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  late final OnboardingRepository repository;

  OnboardingBloc(this.repository) : super(InitialState()) {
    on<ReadOnboardingStatus>((event, emit) {
      var res = repository.getOnboardingEnableStatus().getOrElse(() => true);
      emit(OnboardingStatus(res));
    });

    on<DisableOnboardingScreen>((event, emit) {
      var res = repository.disableOnboardingScreen();
      res.fold((failure) {
        //! if fail to get value from share preference then show onboarding as default
        emit(OnboardingStatus(true));
      }, (_) {
        emit(OnboardingDisabledSuccesful());
      });
    });
  }
}
