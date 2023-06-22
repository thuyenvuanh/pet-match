import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pet_match/src/domain/models/address_model.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/gender_model.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/views/create_profile/widgets/custom_segmented_button.dart';
import 'package:pet_match/src/presentation/views/profile_edit/image_preview.dart';
import 'package:pet_match/src/presentation/widgets/address_input_field.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/date_time_picker.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';

class EditProfileDetailScreen extends StatefulWidget {
  const EditProfileDetailScreen({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  State<EditProfileDetailScreen> createState() =>
      _EditProfileDetailScreenState();
}

class _EditProfileDetailScreenState extends State<EditProfileDetailScreen> {
  static const _avatarHeight = 450.0;
  final picker = ImagePicker();
  final _form = GlobalKey<FormState>();
  static const birthdayPlaceholder = "Chọn ngày sinh";
  static const _nameLabel = "Tên";
  static const _weightLabel = "Cân nặng";
  static const _heightLabel = "Chiều cao";
  static const _descriptionLabel = "Giới thiệu";

  static const _enableColor = Color(0x4D000000);
  static const enableBorderSide = BorderSide(color: _enableColor);
  static const errorBorderSide = BorderSide(color: Colors.red);

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _descriptionController;
  late final ProfileBloc _profileBloc;
  late final StreamSubscription _listener;

  File? avatar;
  List<File>? gallery;
  DateTime? _birthday;
  Breed? _breed;
  String _gender = "Male";
  Address? _address;

  String? _birthdayErrorMessage;
  String? _addressErrorMessage;
  String? _galleriesErrorMessage;
  bool _avatarError = false;
  List<Breed> _interests = [];
  late List<File?> galleries;

  Future<File> getFileFromUrl(String url) async {
    url = url.substring(0, url.lastIndexOf('=media') + 6);
    final http.Response responseData = await http.get(Uri.parse(url));
    final uint8list = responseData.bodyBytes;
    final buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    final res = await http.get(Uri.parse(url.replaceAll("?alt=media", "")));
    String body = utf8.decode(res.bodyBytes);
    Map<String, dynamic> metadata = json.decode(body);
    String name = metadata['name']!;
    name = name.substring(name.lastIndexOf('/') + 1);
    name = name.substring(name.lastIndexOf('%2F') + 1);
    dev.log(name);
    final file = File('${tempDir.path}/img/$name')..create(recursive: true);
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  void fillFields() {
    getFileFromUrl(widget.profile.avatar!).then((value) {
      avatar = value;
    });
    galleries =
        List.generate(widget.profile.gallery?.length ?? 0, (index) => null);
    Iterable<Future<File>> mappedFile =
        widget.profile.gallery?.map((e) async => await getFileFromUrl(e)) ??
            Iterable.generate(0);
    Future.wait(mappedFile).then((value) {
      setState(() {
        galleries = value;
      });
    });
    _interests = widget.profile.interests ?? [];
    _gender = widget.profile.gender ?? "Male";
    _nameController = TextEditingController(text: widget.profile.name);
    _breed = widget.profile.breed;
    _heightController =
        TextEditingController(text: widget.profile.height.toString());
    _weightController =
        TextEditingController(text: widget.profile.weight.toString());
    _descriptionController =
        TextEditingController(text: widget.profile.description);
    _birthday = widget.profile.birthday!;
    _address = widget.profile.address;
  }

  @override
  void initState() {
    fillFields();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _listener = _profileBloc.stream.listen((state) {
      if (state is ProfilesLoading) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const SimpleDialog(
              elevation: 0.0,
              backgroundColor:
                  Colors.transparent, // can change this to your preferred color
              children: [LoadingIndicator()],
            );
          },
        );
      }
      if (state is ProfileSaveUpdateSuccess) {
        Navigator.pop(context);
        Navigator.pop(context, [state.profile]);
      }
    });
    super.initState();
  }

  Future<void> _pickAvatar() async {
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        avatar = File(image.path);
      });
    }
  }

  setAddress(Address? address) {
    if (address != null) {
      setState(() {
        _address = address;
        _addressErrorMessage = null;
      });
    }
  }

  addImagesToGallery(List<File> file) {
    setState(() {
      galleries.addAll(file);
      _galleriesErrorMessage = null;
    });
    _validateGalleries();
  }

  removeImage(file) {
    setState(() {
      galleries.remove(file);
      _galleriesErrorMessage = null;
    });
    _validateGalleries();
  }

  String? _required(String? value) =>
      value == null || value.isEmpty ? "Bắt buộc" : null;

  String? _positive(String? value) {
    var number = double.tryParse(value!);
    if (number == null || number.isNegative) return "Invalid number";
    return null;
  }

  _validateBirthday() {
    if (_birthday == null) {
      setState(() {
        _birthdayErrorMessage = "Bắt buộc";
      });
      return false;
    }
    return true;
  }

  _validateAddress() {
    if (_address?.address == null) {
      setState(() {
        _addressErrorMessage = "Bắt buộc";
      });
      return false;
    }
    return true;
  }

  _validateAvatar() {
    setState(() {
      _avatarError = (avatar == null);
    });
    return !_avatarError;
  }

  _validateGalleries() {
    if (galleries.isEmpty) {
      setState(() {
        _galleriesErrorMessage = "Bắt buộc";
      });
      return false;
    }
    if (galleries.length < 3) {
      setState(() {
        _galleriesErrorMessage = "Yêu cầu tối thiểu 3 ảnh";
      });
      return false;
    }
    return true;
  }

  void submit() {
    bool result = _form.currentState!.validate();
    result = _validateAddress() && result;
    result = _validateBirthday() && result;
    result = _validateAvatar() && result;
    result = _validateGalleries() && result;
    if (result) {
      dev.log('All good. Submitting');
      _profileBloc.add(
        UpdateProfileDetail(
          oldProfile: widget.profile,
          avatar: avatar!,
          breed: _breed!,
          id: widget.profile.id!,
          address: _address!,
          birthday: _birthday!,
          description: _descriptionController.text,
          galleries: galleries.map<File>((e) => e!).toList(),
          gender: Gender.fromString(_gender),
          height: double.parse(_heightController.text),
          interests: _interests,
          name: _nameController.text,
          weight: double.parse(_weightController.text),
        ),
      );
    }
  }

  Future<bool?> _showPopup() async {
    return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: Resource.defaultBorderRadius,
            ),
            title: const Text(
              "Confirm",
              style: TextStyle(
                fontSize: 20,
                color: Resource.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text("Changes will not be saved. Still exit?"),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: MaterialStateColor.resolveWith(
                        (states) => Resource.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Vẫn thoát'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                  foregroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.white),
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Resource.primaryColor),
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.white.withOpacity(0.25)),
                ),
                child: const Text('Ở lại'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              height: _avatarHeight,
              width: context.screenSize.width,
              child: GestureDetector(
                onTap: _pickAvatar,
                child: avatar == null
                    ? SizedBox(
                        height: _avatarHeight,
                        width: context.screenSize.width,
                        child: const LoadingIndicator(),
                      )
                    : AspectRatio(
                        aspectRatio: context.screenSize.width / _avatarHeight,
                        child: Image.file(
                          avatar!,
                          height: _avatarHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: _avatarHeight - 30),
              padding: const EdgeInsets.all(40).copyWith(top: 35),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thông tin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _nameController,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              validator: (val) =>
                                  _required(val) ?? _positive(val),
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
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              validator: (val) =>
                                  _required(val) ?? _positive(val),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(20),
                                suffixText: "kg",
                                label: const Text(
                                  _weightLabel,
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
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomSegmentedButton(
                          onChange: (String val) {
                            dev.log(val);
                            setState(() => _gender = val);
                          },
                          selected: _gender),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DateTimePicker(
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
                          theme: const SvgTheme(
                              currentColor: Resource.primaryColor),
                        ),
                        label: const Text(
                          birthdayPlaceholder,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Resource.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AddressInputField(
                        address: _address!,
                        setAddress: setAddress,
                        errorMessage: _addressErrorMessage,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: _descriptionController,
                        validator: (val) => _required(val),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        minLines: 6,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20),
                          alignLabelWithHint: true,
                          hintText:
                              'Hãy điền thông tin giới thiệu của thú cưng tại đây',
                          hintStyle: const TextStyle(color: Color(0x40000000)),
                          label: const Text(
                            _descriptionLabel,
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
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đối tượng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: [
                          ..._interests.map((e) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Resource.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        color: Resource.primaryColor,
                                      ),
                                      Text(
                                        e.name!,
                                        style: const TextStyle(
                                          color: Resource.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Thay đổi",
                                style: TextStyle(
                                    color: Resource.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Ảnh',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...galleries.map(
                            (e) => ImagePreview(
                                file: e, onRemoveImage: removeImage),
                          ),
                          ImagePreview(
                            isPlaceholder: true,
                            onAddImage: addImagesToGallery,
                          )
                        ],
                      ),
                    ),
                    _galleriesErrorMessage == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              _galleriesErrorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Button(
                        variant: ButtonVariant.primary,
                        label: 'Lưu',
                        onTap: submit,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40 + context.screenPadding.top,
              left: 40,
              child: RoundedIconButton(
                color: Colors.white.withOpacity(0.3),
                onTap: () {
                  _showPopup().then((value) {
                    if (value != null && value == true) {
                      Navigator.pop(context);
                    }
                  });
                },
                child: SvgPicture.asset(
                  'assets/images/svgs/right.svg',
                  // ignore: deprecated_member_use
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
