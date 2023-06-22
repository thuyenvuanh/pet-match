part of 'subscription_bloc.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

abstract class SubscriptionUIState extends SubscriptionState {}

abstract class SubscriptionListenerState extends SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class GetSubscriptionSuccess extends SubscriptionState {
  final Subscription subscription;
  final bool showRegisterDialog;
  final DialogPlace? place;
  final int? remaining;
  const GetSubscriptionSuccess(
    this.subscription, [
    this.showRegisterDialog = false,
    this.place,
    this.remaining
  ]);
}

class RemainingSwipe extends SubscriptionState {
  final int swipes;
  const RemainingSwipe(this.swipes);

  @override
  List<Object> get props => [faker.guid.guid()];
}

class GetSubscriptionError extends SubscriptionState {}
