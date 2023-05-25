part of 'swipe_bloc.dart';

@immutable
abstract class SwipeState extends Equatable {}

abstract class FetchProfilesStates extends SwipeState {}

abstract class CommentStates extends SwipeState {}

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

class FetchCommentsOK extends CommentStates {
  final List<Comment> comments;
  FetchCommentsOK(this.comments);
  @override
  List<Object?> get props => [comments];
}

class FetchCommentError extends CommentStates {
  final String message;
  FetchCommentError(this.message);
  
  @override
  List<Object?> get props => [message];
}
