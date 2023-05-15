import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/mock_data/breed.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/select.dart';

class BreedSelectionPage extends StatefulWidget {
  const BreedSelectionPage({
    required this.goNext,
    super.key,
  });

  final Function() goNext;

  @override
  State<BreedSelectionPage> createState() => _BreedSelectionPageState();
}

class _BreedSelectionPageState extends State<BreedSelectionPage> {
  late final CreateProfileBloc _bloc;
  late final StreamSubscription<CreateProfileState> _listener;
  late Breed? breed;
  late Profile profile;
  final List<Breed> breedOptions = breeds;
  late final SelectController _controller;
  String? errorMessage;

  setErrorMessage() =>
      setState(() => errorMessage = "Ban hay chon giong thu cung cua minh");

  resetErrorMessage() => setState(() => errorMessage = null);

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<CreateProfileBloc>(context);
    _listener = _bloc.stream.listen((event) {
      if (event is BreedSaved && event.breed != null) {
        widget.goNext();
      }
    });
    _controller =
        SelectController(_bloc.profile.breed?.name ?? "", SelectMode.single);
    breed = _bloc.profile.breed;
  }

  @override
  void dispose() {
    _listener.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Text(
                  "Thú cưng của tôi là",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  errorMessage ?? "",
                  style: const TextStyle(color: Colors.red),
                ),
                Select(
                  selectables: breedOptions.map((e) => e.name!).toList(),
                  controller: _controller,
                  onChange: (value) {
                    setState(() => errorMessage = null);
                    breed = breedOptions
                        .firstWhere((element) => element.name! == value);
                  },
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 40,
          right: 40,
          child: Button(
              label: "Tiep theo",
              onTap: () {
                if (breed == null) {
                  setErrorMessage();
                } else {
                  _bloc.add(SaveBreed(breed));
                }
              }),
        ),
      ],
    );
  }
}
