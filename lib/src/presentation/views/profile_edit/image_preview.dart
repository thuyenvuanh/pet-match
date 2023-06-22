import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    this.file,
    this.isPlaceholder = false,
    this.onRemoveImage,
    this.onAddImage,
  });

  final File? file;
  final bool isPlaceholder;
  final Function(List<File> file)? onAddImage;
  final Function(File file)? onRemoveImage;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  static final _defaultBorderRadius = BorderRadius.circular(5);
  static final picker = ImagePicker();

  Future<void> _pickImage() async {
    List<XFile> images = await picker.pickMultiImage();
    final map = images.map((e) => File(e.path)).toList();
    widget.onAddImage!(map);
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _defaultBorderRadius,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 127,
        width: 96,
        child: AspectRatio(
          aspectRatio: 96 / 127,
          child: widget.isPlaceholder
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: _defaultBorderRadius,
                    splashColor: Resource.primaryTintColor,
                    overlayColor: MaterialStateColor.resolveWith(
                      (states) => Resource.primaryTintColor,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                          borderRadius: _defaultBorderRadius,
                          color: Resource.primaryTintColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              'assets/images/svgs/images_icon.svg'),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Thêm ảnh',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Resource.primaryColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : widget.file == null
                  ? const LoadingIndicator()
                  : Stack(children: [
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          child: Image.file(widget.file!, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            widget.onRemoveImage!(widget.file!);
                          },
                          child: SvgPicture.asset(
                            "assets/images/svgs/close-circle.svg",
                            height: 24,
                          ),
                        ),
                      )
                    ]),
        ),
      ),
    );
  }
}
