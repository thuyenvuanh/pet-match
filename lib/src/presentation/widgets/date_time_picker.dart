import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    Key? key,
    this.value,
    required this.onChange,
    required this.prefixIcon,
    required this.label,
    required this.errorMessage,
  }) : super(key: key);

  final DateTime? value;
  final Function(DateTime value) onChange;
  final Widget? prefixIcon;
  final Widget label;
  final String? errorMessage;

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  void pickDate() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarPicker(value: widget.value),
    ).then((dynamic value) => widget.onChange(value[0]));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: Resource.defaultBorderRadius,
            splashColor: Resource.primaryTintColor,
            overlayColor: MaterialStateColor.resolveWith(
              (states) => Resource.primaryTintColor,
            ),
            onTap: pickDate,
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
                  children: [
                    widget.prefixIcon ?? const SizedBox(),
                    SizedBox(width: widget.prefixIcon != null ? 12 : 0),
                    widget.value != null
                        ? Text(DateFormat("dd/MM/yyyy").format(widget.value!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Resource.primaryColor,
                            ))
                        : widget.label,
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

class CalendarPicker extends StatefulWidget {
  const CalendarPicker({Key? key, this.value}) : super(key: key);

  final DateTime? value;

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  final DateTime _firstDay = DateTime.fromMicrosecondsSinceEpoch(0);
  final DateTime _lastDay = DateTime.now();

  late DateTime _selected;

  // This field determine which month should be showed
  late DateTime _focused;

  late int scrollingMonth;
  late int scrollingYear;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? DateTime.now();
    _focused = _selected.copyWith();
    scrollingMonth = _selected.month;
    scrollingYear = _selected.year;
  }

  bool isGoPrevAvailable(bool isYearTriggered) {
    late DateTime prevDay;
    if (isYearTriggered) {
      prevDay = _focused.copyWith(year: _focused.year - 1);
    } else {
      prevDay = _focused.copyWith(month: _focused.month - 1);
    }
    return prevDay.isAfter(_firstDay);
  }

  bool isGoNextAvailable(bool isYearTriggered) {
    late DateTime prevDay;
    if (isYearTriggered) {
      prevDay = _focused.copyWith(year: _focused.year + 1);
    } else {
      prevDay = _focused.copyWith(month: _focused.month + 1);
    }
    return prevDay.isBefore(_lastDay);
  }

  void prevYear() {
    setState(() {
      _focused = DateTime(_focused.year - 1, _focused.month, _focused.day);
    });
  }

  void nextYear() {
    setState(() {
      _focused = DateTime(_focused.year + 1, _focused.month, _focused.day);
    });
  }

  void prevMonth() {
    setState(() {
      _focused = DateTime(_focused.year, _focused.month - 1, _focused.day);
    });
  }

  void nextMonth() {
    setState(() {
      _focused = DateTime(_focused.year, _focused.month + 1, _focused.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(44), topRight: Radius.circular(44)),
      ),
      padding: const EdgeInsets.all(40),
      height: context.screenSize.height * 0.75,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: isGoPrevAvailable(true) ? prevYear : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _focused.year.toString(),
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Resource.primaryColor),
                    ),
                    IconButton(
                        onPressed: isGoNextAvailable(true) ? nextYear : null,
                        icon: const Icon(Icons.chevron_right)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 29),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: isGoPrevAvailable(false) ? prevMonth : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        DateFormat("'Tháng' M").format(_focused),
                        style: const TextStyle(
                            fontSize: 24, color: Resource.primaryColor),
                      ),
                      IconButton(
                        onPressed: isGoNextAvailable(false) ? nextMonth : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                TableCalendar(
                  focusedDay: _focused,
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  headerVisible: false,
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    isTodayHighlighted: false,
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Resource.primaryColor,
                    ),
                  ),
                  onPageChanged: (focusedDay) =>
                      setState(() => _focused = focusedDay),
                  selectedDayPredicate: (day) => isSameDay(_selected, day),
                  onDaySelected: (selectedDay, focusedDay) => setState(() {
                    _selected = selectedDay;
                    _focused = focusedDay;
                  }),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Button(
              borderRadius: Resource.defaultBorderRadius,
              height: 59,
              width: context.screenSize.width - 80,
              label: 'Lưu',
              onTap: () => Navigator.pop(context, [_selected]),
            ),
          )
        ],
      ),
    );
  }
}
