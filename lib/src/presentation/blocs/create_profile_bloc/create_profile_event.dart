part of 'create_profile_bloc.dart';

abstract class CreateProfileEvent extends Equatable {
  const CreateProfileEvent();
}

class StartCreateProfile extends CreateProfileEvent {
  @override
  List<Object?> get props => [];
}

class SaveBreed extends CreateProfileEvent {
  final Breed? breed;

  const SaveBreed(this.breed);

  @override
  List<Object?> get props => [];
}

class SaveBasicInformation extends CreateProfileEvent {
  final File? avatar;
  final String? name;
  final String? gender;
  final double? height;
  final double? weight;
  final DateTime? birthday;

  const SaveBasicInformation({
    this.avatar,
    this.name,
    this.gender,
    this.height,
    this.weight,
    this.birthday,
  });

  @override
  List<Object?> get props => [avatar, name, height, weight, birthday];
}

class SaveInterests extends CreateProfileEvent {
  final Set<Breed>? interests;
  const SaveInterests(this.interests);

  @override
  List<Object?> get props => [interests];
}

class SubmitProfile extends CreateProfileEvent {
  final Profile profile;

  const SubmitProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
