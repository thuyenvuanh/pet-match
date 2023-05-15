part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class GetInitialData extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class FetchNewData extends HomeEvent {
  @override
  List<Object?> get props => [];
}
