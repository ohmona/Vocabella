import 'package:flutter/material.dart';

const double _widgetHeight = 60;

class InputBox extends StatelessWidget {
  const InputBox({
    Key? key,
    required this.answer,
    required this.fieldText,
    required this.onSummit,
    required this.onSummitByButton,
    required this.updateInputValue,
    required this.showHint,
  }) : super(key: key);

  final String answer;
  final TextEditingController fieldText;
  final void Function() onSummitByButton;
  final void Function(String) onSummit, updateInputValue;
  final bool showHint;

  static const double defaultTextSize = 16;
  static const double smallTextSize = 12;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 20),
      child: Container(
        // Input Box Container
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
        height: _widgetHeight,
        child: Padding(
          padding: const EdgeInsets.all(_widgetHeight * 0.1),
          child: Container(
            // Input Box
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Transform.translate(
              offset: (MediaQuery.of(context).size.height < 600)
                  ? const Offset(0, -6)
                  : const Offset(0, 3),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  hintText: showHint ? answer : "",
                  suffixIcon: Transform.translate(
                    offset: (MediaQuery.of(context).size.height < 600)
                        ? const Offset(0, 3)
                        : const Offset(0, 0),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.grey.withOpacity(0.5),
                      onPressed: onSummitByButton,
                    ),
                  ),
                  prefixIcon: Transform.translate(
                    offset: (MediaQuery.of(context).size.height < 600)
                        ? const Offset(0, 3)
                        : const Offset(0, 0),
                    child: Icon(
                      Icons.keyboard_alt_outlined,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.height < 600)
                      ? smallTextSize
                      : defaultTextSize,
                  fontWeight: FontWeight.w400,
                ),
                controller: fieldText,
                cursorColor: Colors.grey.withOpacity(0.5),
                textAlign: TextAlign.center,
                onChanged: updateInputValue,
                onSubmitted: onSummit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum CorrectState { correct, wrong, both }

// Used only in few case
class ContinueBox extends StatelessWidget {
  const ContinueBox(
      {Key? key, required this.onClicked, required this.correctState})
      : super(key: key);

  final void Function() onClicked;

  final CorrectState correctState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClicked,
      child: (correctState == CorrectState.wrong)
          ? ContinueButton(
              correctState: correctState,
              color: Colors.redAccent,
              text: "revise",
            )
          : ContinueButton(
              correctState: correctState,
              color: Colors.green,
              text: "continue",
            ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  const ContinueButton(
      {Key? key,
      required this.correctState,
      required this.color,
      required this.text})
      : super(key: key);

  final CorrectState correctState;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: correctState == CorrectState.both
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width,
      // Input Box Container
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
          ),
        ],
      ),
      height: _widgetHeight,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.white,
                  blurRadius: 10,
                ),
              ]),
        ),
      ),
    );
  }
}
