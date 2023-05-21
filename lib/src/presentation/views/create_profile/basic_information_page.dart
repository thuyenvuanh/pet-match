import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/presentation/blocs/create_profile_bloc/create_profile_bloc.dart';
import 'package:pet_match/src/presentation/views/create_profile/widgets/custom_segmented_button.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/date_time_picker.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:badges/badges.dart' as badges;

class BasicInformationPage extends StatefulWidget {
  const BasicInformationPage({
    super.key,
    required this.goNext,
  });

  final Function() goNext;

  @override
  State<BasicInformationPage> createState() => _BasicInformationPageState();
}

class _BasicInformationPageState extends State<BasicInformationPage> {
  final picker = ImagePicker();
  late final CreateProfileBloc _bloc;
  final _form = GlobalKey<FormState>();
  late final List<Breed> breedOptions;
  late final StreamSubscription _blocListener;
  final _nameEditController = TextEditingController();
  final _heightEditController = TextEditingController();
  final _weightEditController = TextEditingController();

  var _gender = "Male";
  DateTime? _birthday;
  String? _birthdayErrorMessage;
  File? _avatar;
  bool _avatarError = false;

  static const birthdayPlaceholder = "Chọn ngày sinh";
  static const _nameLabel = "Tên";
  static const _weightLabel = "Cân nặng";
  static const _heightLabel = "Chiều cao";

  static const _enableColor = Color(0x4D000000);
  static const enableBorderSide = BorderSide(color: _enableColor);
  static const errorBorderSide = BorderSide(color: Colors.red);

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<CreateProfileBloc>(context);
    _blocListener = _bloc.stream.listen((event) {
      if (event is BasicInformationSaved) {
        widget.goNext();
      }
    });
    // _avatar = _bloc.profile.avatarFile;
    _birthday = _bloc.profile.birthday;
    _nameEditController.text = _bloc.profile.name ?? "";
    _weightEditController.text = _bloc.profile.weight?.toString() ?? "";
    _heightEditController.text = _bloc.profile.height?.toString() ?? "";
    _gender = _bloc.profile.gender ?? _gender;
  }

  @override
  void dispose() {
    super.dispose();
    _blocListener.cancel();
    _nameEditController.dispose();
    _heightEditController.dispose();
    _weightEditController.dispose();
  }

  String? _required(String? value) =>
      value == null || value.isEmpty ? "Required" : null;

  String? _positive(String? value) {
    var number = double.tryParse(value!);
    if (number == null || number.isNegative) return "Invalid number";
    return null;
  }

  Future<void> _pickAvatar() async {
    if (_avatar != null) {
      setState(() => _avatar = null);
    } else {
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatar = File(image.path);
          _avatarError = false;
        });
      }
    }
  }

  _validateBirthday() {
    if (_birthday == null) {
      setState(() {
        _birthdayErrorMessage = "Required";
      });
      return false;
    }
    return true;
  }

  _validateAvatar() {
    setState(() {
      _avatarError = (_avatar == null);
    });
    return !_avatarError;
  }

  void submit() {
    if (_form.currentState!.validate() &&
        _validateBirthday() &&
        _validateAvatar()) {
      _bloc.add(SaveBasicInformation(
        avatar: _avatar,
        name: _nameEditController.text,
        height: double.parse(_heightEditController.text),
        weight: double.parse(_weightEditController.text),
        birthday: _birthday,
        gender: _gender,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  const Text(
                    "Thông tin thú cưng",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  badges.Badge(
                    badgeStyle: const badges.BadgeStyle(
                        badgeColor: Resource.primaryColor),
                    position: badges.BadgePosition.bottomEnd(),
                    badgeAnimation: const badges.BadgeAnimation.scale(
                      curve: Curves.easeOut,
                      animationDuration: Duration(milliseconds: 350),
                      loopAnimation: false,
                      toAnimate: true,
                    ),
                    badgeContent: Icon(
                      !_avatarError
                          ? Icons.image_rounded
                          : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        height: 100,
                        width: 100,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Resource.primaryTintColor,
                          borderRadius: Resource.defaultBorderRadius,
                        ),
                        child: _avatar == null
                            ? Center(
                                child: Image.asset(
                                  "assets/images/pet_image_placeholder.png",
                                  height: 50,
                                  width: 50,
                                ),
                              )
                            : Image.file(_avatar!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameEditController,
                    validator: (val) => _required(val),
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      label: const Text(
                        _nameLabel,
                        style: TextStyle(color: _enableColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: errorBorderSide,
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: errorBorderSide),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: enableBorderSide),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: enableBorderSide),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightEditController,
                    validator: (val) => _required(val) ?? _positive(val),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      suffixText: "cm",
                      label: const Text(
                        _heightLabel,
                        style: TextStyle(color: _enableColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: enableBorderSide,
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: errorBorderSide),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: enableBorderSide),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: enableBorderSide),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightEditController,
                    validator: (val) => _required(val) ?? _positive(val),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      label: const Text(
                        _weightLabel,
                        style: TextStyle(color: _enableColor),
                      ),
                      suffixText: 'kg',
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: errorBorderSide,
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: Resource.defaultBorderRadius,
                          borderSide: errorBorderSide),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: Resource.defaultBorderRadius,
                          borderSide: enableBorderSide),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: Resource.defaultBorderRadius,
                          borderSide: enableBorderSide),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomSegmentedButton(
                      onChange: (String val) {
                        dev.log(val);
                        setState(() => _gender = val);
                      },
                      selected: _gender),
                  const SizedBox(height: 16),
                  DateTimePicker(
                    value: _birthday,
                    errorMessage: _birthdayErrorMessage,
                    onChange: (DateTime? value) {
                      setState(() {
                        _birthdayErrorMessage =
                            (value != null) ? null : _birthdayErrorMessage;
                        _birthday = value;
                      });
                    },
                    prefixIcon: SvgPicture.asset(
                      'assets/images/svgs/Calendar.svg',
                      theme:
                          const SvgTheme(currentColor: Resource.primaryColor),
                    ),
                    label: const Text(
                      birthdayPlaceholder,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Resource.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Button(label: "Tiep theo", onTap: submit),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
