import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/domain/models/address_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/here_bloc/here_bloc.dart';
import 'package:pet_match/src/presentation/views/user_screen.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';

class AddressInputField extends StatefulWidget {
  const AddressInputField({
    super.key,
    required this.address,
    required this.setAddress,
    this.errorMessage,
  });

  final Address address;
  final Function(Address? address) setAddress;
  final String? errorMessage;

  @override
  State<AddressInputField> createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  showAddressInputField() {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      enableDrag: true,
      constraints: BoxConstraints.tight(
        Size(
          context.screenSize.width,
          context.screenSize.height * 0.80,
        ),
      ),
      builder: (context) => const SearchAddressView(),
    ).then((dynamic value) {
      if (value != null) {
        Address address = value[0] as Address;
        widget.setAddress(address);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: Resource.defaultBorderRadius,
            overlayColor: MaterialStateColor.resolveWith(
              (states) => Resource.primaryTintColor,
            ),
            splashColor: Resource.primaryColor,
            onTap: showAddressInputField,
            child: Ink(
              height: 59,
              width: context.screenSize.width,
              decoration: BoxDecoration(
                borderRadius: Resource.defaultBorderRadius,
                color: Resource.primaryTintColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SvgPicture.asset("assets/images/svgs/compass-outline.svg"),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.address.address == null
                            ? 'Thay đổi vị trí'
                            : widget.address.address!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Resource.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.errorMessage != null && widget.errorMessage!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class SearchAddressView extends StatefulWidget {
  const SearchAddressView({super.key});

  @override
  State<SearchAddressView> createState() => _SearchAddressViewState();
}

class _SearchAddressViewState extends State<SearchAddressView> {
  final TextEditingController _addressSearch = TextEditingController();
  static const _enableColor = Color(0x4D000000);
  static const enableBorderSide = BorderSide(color: _enableColor);
  static const errorBorderSide = BorderSide(color: Colors.red);
  String? _required(String? value) =>
      value == null || value.isEmpty ? "Bắt buộc" : null;

  late final HereBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<HereBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Nhập địa chỉ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Resource.primaryColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressSearch,
                      validator: (val) => _required(val),
                      style: const TextStyle(fontSize: 16),
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.search,
                      autofocus: true,
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _bloc.add(SearchAddress(value));
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        label: const Text(
                          "Tìm kiếm địa chỉ",
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
                  const SizedBox(width: 10),
                  RoundedIconButton(
                    color: Resource.primaryColor,
                    onTap: triggerSearch,
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              BlocBuilder<HereBloc, HereState>(
                bloc: _bloc,
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (_, constraints) {
                      if (state is HereSearchSuccess) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: state.hereData
                                .map((e) => CustomListTile(
                                      leading: SvgPicture.asset(
                                        'assets/images/svgs/location.svg',
                                        height: 32,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xFF1c4795),
                                      ),
                                      isThreeLine: true,
                                      title: Text(
                                        '${e.address?.houseNumber ?? ""} ${e.address!.street}'
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subTitle: Text(
                                        '${e.address?.city ?? ""} ${e.address?.county ?? ""} ${e.address?.city ?? ""}'
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context,
                                            [(Address.fromHereMapApi(e))]);
                                      },
                                    ))
                                .toList(),
                          ),
                        );
                      }
                      if (state is HereSearching) {
                        return Container(
                            constraints: BoxConstraints.loose(Size(
                                constraints.minHeight, constraints.maxWidth)),
                            child: const LoadingIndicator());
                      }
                      return Container(
                        constraints: BoxConstraints.loose(
                            Size(constraints.minHeight, constraints.maxWidth)),
                        child: const Center(
                          child: Text('Nhập địa chỉ để tìm kiếm sau đó chọn'),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void triggerSearch() {
    if (_addressSearch.text.isNotEmpty) {
      _bloc.add(SearchAddress(_addressSearch.text));
    }
  }
}
