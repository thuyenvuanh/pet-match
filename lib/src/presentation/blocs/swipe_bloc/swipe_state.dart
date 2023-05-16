part of 'swipe_bloc.dart';

@immutable
abstract class SwipeState extends Equatable {}

class SwipeInitial extends SwipeState {
  @override
  List<Object?> get props => [];
}

class FetchNewProfilesOk extends SwipeState {
  final List<Profile> profiles;

  FetchNewProfilesOk(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class SwipeDone extends SwipeState {
  final Profile profile;

  SwipeDone(this.profile);

  @override
  List<Object?> get props => [profile];
}
