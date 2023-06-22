part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class GetSubscriptionData extends SubscriptionEvent {
  final bool showPremiumDialog;
  final DialogPlace? dialogPlace;
  const GetSubscriptionData({this.showPremiumDialog = false, this.dialogPlace});
}

class GetRemainingSwipes extends SubscriptionEvent {
  final int? cache;

  const GetRemainingSwipes({this.cache});
  
  @override
  List<Object> get props => [faker.guid.guid()];
}

class AddMoreSwipeAfterAd extends SubscriptionEvent {}
