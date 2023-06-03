import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  InputBox(
      {Key? key,
        required this.answer,
        required this.inputValue,
        required this.fieldText,
        required this.onSummit,
        required this.onSummitByButton,
        required this.updateInputValue})
      : super(key: key);

  final String answer, inputValue;
  final TextEditingController fieldText;
  final void Function() onSummitByButton;
  final void Function(String) onSummit, updateInputValue;

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const double defaultTextSize = 20;
  static const double smallTextSize = 15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: MediaQuery.of(context).size.height * 0.09,
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
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
                : const Offset(0, 1),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                hintText: widget.answer,
                suffixIcon: Transform.translate(
                  offset: (MediaQuery.of(context).size.height < 600)
                      ? const Offset(0, 3)
                      : const Offset(0, 0),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.grey.withOpacity(0.5),
                    onPressed: widget.onSummitByButton,
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
                fontSize: (MediaQuery.of(context).size.height < 600) ? smallTextSize : defaultTextSize,
                fontWeight: FontWeight.w400,
              ),
              controller: widget.fieldText,
              cursorColor: Colors.grey.withOpacity(0.5),
              textAlign: TextAlign.center,
              onChanged: widget.updateInputValue,
              onSubmitted: widget.onSummit,
            ),
          ),
        ),
      ),
    );
  }
}

enum CorrectState { correct, wrong, both }

class ContinueBox extends StatelessWidget {
  const ContinueBox({Key? key, required this.onClicked, required this.correctState}) : super(key: key);

  final void Function() onClicked;

  final CorrectState correctState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClicked,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(correctState == CorrectState.wrong || correctState == CorrectState.both) Container(
            width: correctState == CorrectState.wrong ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2,
            // Input Box Container
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 10,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.09,
            child: const Text("left"),
          ),
          if(correctState == CorrectState.correct || correctState == CorrectState.both) Container(
            width: correctState == CorrectState.correct ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2,
            // Input Box Container
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 10,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.09,
            child: const Text("right"),
          ),
        ],
      ),
    );
  }
}

class BottomBox extends StatefulWidget {
  BottomBox({Key? key, required this.child}) : super(key: key);

  final Widget child;

  late void Function() animAppear;
  late void Function() animDisappear;

  @override
  State<BottomBox> createState() => _BottomBoxState();
}

class _BottomBoxState extends State<BottomBox> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  double opacity = 1;

  //double position = 0;

  final int animDuration = 2000;
  final Curve curveType = Curves.easeOutExpo;

  // Animation when appear
  void animAppear() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDuration));
    final Animation<double> curve =
    CurvedAnimation(parent: controller, curve: curveType);
    animation = Tween<double>(begin: 0, end: 1).animate(curve);
    //animation = Tween<double>(begin: 0, end: 1).animate(curve);

    animation.addListener(() {
      opacity = animation.value;
      //position = animation.value;
      setState(() {});
    });
    controller.forward();
  }

  // Animation when disappear
  void animDisappear() async {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDuration));
    final Animation<double> curve =
    CurvedAnimation(parent: controller, curve: curveType);
    animation = Tween<double>(begin: 1, end: 0).animate(curve);
    //animation = Tween<double>(begin: 1, end: 0).animate(curve);

    animation.addListener(() {
      opacity = animation.value;
      //position = animation.value;
      setState(() {});
    });
    await controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);

    widget.animAppear = animAppear;
    widget.animDisappear = animDisappear;

    /*if (widget.child is ContinueBox) {
      (widget.child as ContinueBox).onLeftClicked = animDisappear;
      (widget.child as ContinueBox).onRightClicked = animAppear;
    }*/
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    print("dispose from bottombox");
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      //offset: Offset(0, position),
      offset: Offset(0, 0),
      child: Opacity(
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}
