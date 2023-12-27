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
    required this.focusNode,
  }) : super(key: key);

  final String answer;
  final TextEditingController fieldText;
  final void Function() onSummitByButton;
  final void Function(String) onSummit, updateInputValue;
  final bool showHint;

  static const double defaultTextSize = 16;
  static const double smallTextSize = 12;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 20),
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 2,
              color: Colors.grey,
            ),
            bottom: BorderSide(
              width: 2,
              color: Colors.grey,
            ),
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            hintText: showHint ? answer : "",
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Colors.black.withOpacity(0.8),
              onPressed: onSummitByButton,
            ),
            prefixIcon: Transform.translate(
              offset: (MediaQuery.of(context).size.height < 600)
                  ? const Offset(0, 3)
                  : const Offset(0, 0),
              child: Icon(
                Icons.keyboard_alt_outlined,
                color: Colors.black.withOpacity(0.8),
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
          focusNode: focusNode,
          cursorColor: Colors.black.withOpacity(0.1),
          textAlign: TextAlign.center,
          onChanged: updateInputValue,
          onSubmitted: onSummit,
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
            ],
          ),
        ),
      ),
    );
  }
}
