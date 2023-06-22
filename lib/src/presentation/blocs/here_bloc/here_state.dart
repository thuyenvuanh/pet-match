part of 'here_bloc.dart';

abstract class HereState extends Equatable {
  const HereState();

  @override
  List<Object> get props => [];
}

class HereInitial extends HereState {}

class HereSearchSuccess extends HereState {
  final List<HereMapResponse> hereData;
  const HereSearchSuccess(this.hereData);
}

class HereSearching extends HereState {}

class HereSearchFailed extends HereState {
  final String message;
  const HereSearchFailed(this.message);
}
