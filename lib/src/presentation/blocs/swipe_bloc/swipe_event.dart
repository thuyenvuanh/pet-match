part of 'swipe_bloc.dart';

@immutable
abstract class SwipeEvent extends Equatable {}

class FetchNewProfiles extends SwipeEvent {
  @override
  List<Object?> get props => [];
}

class SwipeLike extends SwipeEvent {
  final Profile profile;
  final String? comment;

  SwipeLike(this.profile, this.comment);

  @override
  List<Object?> get props => [profile.id];
}

class SwipePass extends SwipeEvent {
  final Profile profile;

  SwipePass(this.profile);

  @override
  List<Object?> get props => [profile.id];
}

class FetchLikedProfiles extends SwipeEvent {
  FetchLikedProfiles();

  @override
  List<Object?> get props => [];
}
