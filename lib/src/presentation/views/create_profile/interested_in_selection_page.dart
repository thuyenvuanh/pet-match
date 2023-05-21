import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/mock_data/breed.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/utils/constant.dart';

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({
    super.key,
  });

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  //context variables
  late CreateProfileBloc _bloc;
  late StreamSubscription _blocListener;

  // UI state
  late Set<Breed>? _selectedInterests;
  bool _isSubmitting = false;

  //Styles
  final _defaultStyle = BoxDecoration(
    borderRadius: Resource.defaultBorderRadius,
    border: Border.all(
        color: const Color(0xFFE8E6EA),
        width: 2,
        strokeAlign: BorderSide.strokeAlignInside),
  );
  final _selectedStyle = BoxDecoration(
    borderRadius: Resource.defaultBorderRadius,
    color: Resource.primaryColor,
    boxShadow: const [
      BoxShadow(
        color: Color(0x33E94057),
        blurRadius: 15,
        offset: Offset(0, 15),
      )
    ],
  );

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<CreateProfileBloc>(context);
    _blocListener = _bloc.stream.listen((state) {
      if (state is InterestSaved) {
        setState(() {
          _selectedInterests = state.interests?.toSet();
        });
      }
      if (state is CreateProfileLoading) {
        setState(() {
          _isSubmitting = true;
        });
      }
      if (state is CreateProfileError) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
    _selectedInterests = _bloc.profile.interests?.toSet() ?? <Breed>{};
  }

  @override
  void dispose() {
    super.dispose();
    _blocListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      children: [
        Positioned.fill(
          bottom: 120,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Đối tượng',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Chọn một số thú cưng mong muốn ghép.',
                    style: TextStyle(height: 3.0, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisSpacing: 16,
                    childAspectRatio: 140 / 45,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    children: List.generate(
                      breeds.length,
                      (index) {
                        var temp = breeds[index];
                        return InkWell(
                          borderRadius: Resource.defaultBorderRadius,
                          onTap: () {
                            dev.log('${temp.name}');
                            setState(() {
                              if (!_selectedInterests!.contains(temp)) {
                                _selectedInterests?.add(temp);
                              } else {
                                _selectedInterests?.remove(temp);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            height: 58,
                            decoration: _selectedInterests!.contains(temp)
                                ? _selectedStyle
                                : _defaultStyle,
                            duration: const Duration(milliseconds: 250),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 14, right: 8),
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: _selectedInterests!.contains(temp)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  temp.name.toString(),
                                  style: TextStyle(
                                    color: _selectedInterests!.contains(temp)
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight:
                                        _selectedInterests!.contains(temp)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Button(
                label: "Tiep theo",
                onTap: () {
                  _bloc.add(SaveInterests(_selectedInterests));
                }),
          ),
        ),
      ],
    );
  }
}
