import 'package:flutter/material.dart';
import 'package:pet_match/src/presentation/widgets/option.dart';

enum SelectMode { single, multiple }

class SelectController extends ChangeNotifier {
  String? _value;
  final SelectMode _selectMode;

  SelectController(this._value, this._selectMode);

  SelectMode get selectMode => _selectMode;

  String? get value => _value ?? "";

  set value(value) {
    _value = value;
    notifyListeners();
  }
}

class Select extends StatefulWidget {
  const Select({
    Key? key,
    required this.selectables,
    required this.controller,
    required this.onChange,
    this.otherOptionEnabled = false,
  }) : super(key: key);

  final List<String> selectables;
  final bool otherOptionEnabled;
  final SelectController controller;
  final Function(String value) onChange;

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  @override
  void initState() {
    super.initState();
  }

  void update(String value) {
    setState(() {
      widget.controller.value = value;
    });
    widget.onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.selectables
          .map((e) => Option(
                label: e,
                onTap: update,
                isSelected: e == widget.controller.value,
              ))
          .toList(),
    );
  }
}
