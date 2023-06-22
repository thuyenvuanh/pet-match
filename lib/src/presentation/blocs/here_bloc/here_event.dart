part of 'here_bloc.dart';

abstract class HereEvent extends Equatable {
  const HereEvent();

  @override
  List<Object> get props => [];
}

class SearchAddress extends HereEvent {
  final String address;
  const SearchAddress(this.address);
}
