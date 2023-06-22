part of 'swipe_bloc.dart';

@immutable
abstract class SwipeState extends Equatable {}

abstract class FetchProfilesStates extends SwipeState {}

abstract class FetchLikedProfilesState extends SwipeState {}

class SwipeInitial extends SwipeState {
  @override
  List<Object?> get props => [];
}

class FetchNewProfilesOk extends FetchProfilesStates {
  final List<Profile> profiles;

  FetchNewProfilesOk(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class FetchNewProfilesError extends FetchProfilesStates {
  final String message;
  FetchNewProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FetchingNewProfiles extends FetchProfilesStates {
  @override
  List<Object?> get props => [];
}

class SwipeDone extends SwipeState {
  final int? remainingSwipes;
  final Subscription subscription;

  SwipeDone({this.remainingSwipes, required this.subscription});

  @override
  List<Object?> get props => [faker.guid.guid()];
}

class SwipeFailed extends SwipeState {
  @override
  List<Object?> get props => [];
}

class SwipeGetLimitation extends SwipeState {
  @override
  List<Object?> get props => [faker.guid.guid()];
}

class FetchLikedProfileLoading extends FetchLikedProfilesState {
  @override
  List<Object?> get props => [];
}

class FetchLikedProfilesOK extends FetchLikedProfilesState {
  final List<Reaction> likedProfiles;
  FetchLikedProfilesOK(this.likedProfiles);
  @override
  List<Object?> get props => [faker.guid.guid()];
}

class FetchLikedProfilesError extends FetchLikedProfilesState {
  final String message;
  FetchLikedProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}
