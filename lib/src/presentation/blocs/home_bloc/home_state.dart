part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class ActiveProfile extends HomeState {
  final Profile activeProfile;

  const ActiveProfile(this.activeProfile);

  @override
  List<Object?> get props => [];
}

class NoActiveProfile extends HomeState {
  @override
  List<Object?> get props => [];
}