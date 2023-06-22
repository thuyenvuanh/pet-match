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

class ProfileLoggedIn extends ProfileState {
  final Profile activeProfile;
  const ProfileLoggedIn(this.activeProfile);
}

class CurrentProfileState extends ProfileState {
  final Profile profile;
  const CurrentProfileState(this.profile);
}

class ProfileLoggedOut extends ProfileState {}

class LoggingIntoProfile extends ProfileState {
  final Profile profile;
  const LoggingIntoProfile({required this.profile});
}

class LoginError extends ProfileState {}

class ProfileDetail extends ProfileState {
  final Profile profile;
  const ProfileDetail(this.profile);
}

class ProfileDetailLoading extends ProfileState {}

class ProfileDetailError extends ProfileState {
  final String message;
  const ProfileDetailError(this.message);
}

class ProfileSaveUpdateSuccess extends ProfileState {
  final Profile profile;
  const ProfileSaveUpdateSuccess(this.profile);
}

class ProfileSaveUpdateError extends ProfileState {
  final String message;
  const ProfileSaveUpdateError(this.message);
}
