part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetProfileDetailById extends ProfileEvent {
  final String uuid;
  GetProfileDetailById(this.uuid);
}

class FetchAvailableProfiles extends ProfileEvent {}

class GetCurrentProfile extends ProfileEvent {}

class LoginToProfile extends ProfileEvent {
  final Profile profile;

  LoginToProfile(this.profile);
}

class LogoutOfProfile extends ProfileEvent {}

class UpdateProfileDetail extends ProfileEvent {
  final File avatar;
  final String name;
  final double height;
  final double weight;
  final String id;
  final Gender gender;
  final Breed breed;
  final DateTime birthday;
  final Address address;
  final String description;
  final List<Breed> interests;
  final List<File> galleries;
  final Profile oldProfile;
  UpdateProfileDetail({
    required this.avatar,
    required this.name,
    required this.id,
    required this.height,
    required this.weight,
    required this.breed,
    required this.gender,
    required this.birthday,
    required this.address,
    required this.description,
    required this.interests,
    required this.galleries,
    required this.oldProfile,
  });
}

class SubmitSave extends ProfileEvent {
  final Profile profile;
  SubmitSave(this.profile);
}
