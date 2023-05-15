part of 'onboarding_bloc.dart';

@immutable
abstract class OnboardingEvent extends Equatable {}

class ReadOnboardingStatus extends OnboardingEvent {
  @override
  List<Object?> get props => [];
}

class DisableOnboardingScreen extends OnboardingEvent{
  @override
  List<Object?> get props => [];
}