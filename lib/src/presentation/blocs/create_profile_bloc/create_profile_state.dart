part of 'create_profile_bloc.dart';

abstract class CreateProfileState {
  const CreateProfileState();
}

class CreateProfileInitial extends CreateProfileState {}

class BreedSaved extends CreateProfileState {
  final Breed? breed;

  const BreedSaved(this.breed);
}

class BasicInformationSaved extends CreateProfileState {
  final Profile onGoingProfile;

  const BasicInformationSaved(this.onGoingProfile);
}

class InterestSaved extends CreateProfileState {

  final Set<Breed>? interests;

  const InterestSaved(this.interests);
}

class CreateProfileSuccess extends CreateProfileState {
  final Profile profile;

  const CreateProfileSuccess(this.profile);
}

class CreateProfileLoading extends CreateProfileState {}

class CreateProfileError extends CreateProfileState {
  final String message;

  const CreateProfileError(this.message);

  List<Object?> get props => [message];
}
