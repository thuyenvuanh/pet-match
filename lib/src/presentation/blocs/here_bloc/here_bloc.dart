import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_match/src/api/here_map_api.dart';
import 'package:pet_match/src/domain/repositories/here_repository.dart';

part 'here_event.dart';
part 'here_state.dart';

class HereBloc extends Bloc<HereEvent, HereState> {
  final HereRepository repository;

  HereBloc(this.repository) : super(HereInitial()) {
    on<SearchAddress>((event, emit) async {
      emit(HereSearching());
      var data = await repository.getHereMapAddresses(event.address);
      data.fold((failure) {
        log('[here_bloc] Failed to search address');
        emit(const HereSearchFailed('Failed to search'));
      }, (addresses) {
        log('[here_bloc] search success with ${addresses.length} results');
        emit(HereSearchSuccess(addresses));
      });
    });
  }
}
