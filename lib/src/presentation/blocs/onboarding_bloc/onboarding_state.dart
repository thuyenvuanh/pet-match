part of '../onboarding_bloc/onboarding_bloc.dart';

abstract class OnboardingState extends Equatable{}

class InitialState extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class OnboardingStatus extends OnboardingState {
  final bool status;
  OnboardingStatus(this.status);

  @override
  List<Object?> get props => [];
}

class OnboardingDisabledSuccesful extends OnboardingState {
  @override
  List<Object?> get props => [];
}