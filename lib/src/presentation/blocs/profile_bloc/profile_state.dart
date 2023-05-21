part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfilesLoading extends ProfileState {}

class FetchedSuccess extends ProfileState {
  final List<Profile> profiles;

  const FetchedSuccess(this.profiles);
}

class NoProfileFetched extends ProfileState {}

class FetchedError extends ProfileState {
  final String message;
  const FetchedError(this.message);
}

class ProfileLoggedIn extends ProfileState {}

class ProfileLoggedOut extends ProfileState {}

class LoggingIntoProfile extends ProfileState {
  final Profile profile;
  const LoggingIntoProfile({required this.profile});
}

class LoginError extends ProfileState {}