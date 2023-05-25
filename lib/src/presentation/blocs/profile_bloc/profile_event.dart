part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAvailableProfiles extends ProfileEvent {}

class GetCurrentProfile extends ProfileEvent {}

class LoginToProfile extends ProfileEvent {
  final Profile profile;

  LoginToProfile(this.profile);
}

class LogoutOfProfile extends ProfileEvent {}
