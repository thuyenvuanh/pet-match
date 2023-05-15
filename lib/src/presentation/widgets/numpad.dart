import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/utils/constant.dart';

class NumPad extends StatefulWidget {
  const NumPad(
      {Key? key,
      required this.onPressed,
      required this.onReset,
      this.isClearDisabled = true})
      : super(key: key);

  final Function(int value) onPressed;
  final Function() onReset;
  final bool isClearDisabled;

  @override
  State<NumPad> createState() => _NumPadState();
}

class _NumPadState extends State<NumPad> {
  final TextStyle textStyle =
      const TextStyle(fontSize: 24, color: Colors.black);

  final ButtonStyle buttonStyle = ButtonStyle(
    shape: MaterialStateProperty.resolveWith((states) => const CircleBorder()),
    overlayColor:
        MaterialStateColor.resolveWith((states) => Resource.primaryTintColor),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 29),
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(1),
                      style: buttonStyle,
                      child: Text(
                        '1',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(2),
                      style: buttonStyle,
                      child: Text(
                        '2',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(3),
                      style: buttonStyle,
                      child: Text(
                        '3',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(4),
                      style: buttonStyle,
                      child: Text(
                        '4',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(5),
                      style: buttonStyle,
                      child: Text(
                        '5',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(6),
                      style: buttonStyle,
                      child: Text(
                        '6',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(7),
                      style: buttonStyle,
                      child: Text(
                        '7',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(8),
                      style: buttonStyle,
                      child: Text(
                        '8',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(9),
                      style: buttonStyle,
                      child: Text(
                        '9',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () => widget.onPressed(0),
                      style: buttonStyle,
                      child: Text(
                        '0',
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: !widget.isClearDisabled
                        ? IconButton(
                            splashRadius: 24,
                            iconSize: 20,
                            color: Colors.black,
                            onPressed: widget.onReset,
                            style: buttonStyle,
                            splashColor: Resource.primaryTintColor,
                            highlightColor: Resource.primaryTintColor,
                            icon: SvgPicture.asset(
                                'assets/images/svgs/Backspace.svg'),
                          )
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
