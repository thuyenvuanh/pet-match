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

class SwipeDone extends SwipeState {
  final Profile profile;

  SwipeDone(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FetchLikedProfileLoading extends FetchLikedProfilesState {
  @override
  List<Object?> get props => [];
}

class FetchLikedProfilesOK extends FetchLikedProfilesState {
  final List<Like> likedProfiles;
  FetchLikedProfilesOK(this.likedProfiles);
  @override
  List<Object?> get props => [likedProfiles];
}

class FetchLikedProfilesError extends FetchLikedProfilesState {
  final String message;
  FetchLikedProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}
