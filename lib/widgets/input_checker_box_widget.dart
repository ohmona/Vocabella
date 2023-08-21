import 'package:flutter/material.dart';

enum CheckerBoxState {
  hidden,
  appear,
  disappear,
}

class InputCheckerBox extends StatefulWidget {
  InputCheckerBox({Key? key, required this.color, required this.text})
      : super(key: key);

  final Color color;
  final String text;

  late void Function(CheckerBoxState) animTrigger;
  late void Function(Color) changeColor;
  late void Function(String) changeText;

  @override
  State<InputCheckerBox> createState() => _InputCheckerBoxState();
}

class _InputCheckerBoxState extends State<InputCheckerBox>
    with TickerProviderStateMixin {
  late String text;
  late Color color;

  late Offset transform;
  late double opacity;
  late AnimationController animationController;

  static const Offset defaultOffset = Offset(0, finalPosition);
  static const double defaultOpacity = 0;
  //static const double initialPosition = 1000;
  static const double finalPosition = 600;

  void animTrigger(CheckerBoxState state) {
    if (state == CheckerBoxState.appear) {
      opacity = 1;
      animAppear();
    }
    if (state == CheckerBoxState.disappear) {
      animDisappear();
    }
  }

  void changeColor(Color color) {
    setState(() {
      this.color = color;
    });
  }

  void changeText(String text) {
    setState(() {
      this.text = text;
    });
  }

  void animAppear() {
    late Animation<double> animation;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final Animation<double> curve =
    CurvedAnimation(parent: animationController, curve: Curves.easeOutExpo);
    animation = Tween<double>(begin: 0, end: 1).animate(curve);

    animation.addListener(() {
      setState(() {
        opacity = animation.value;
      });
    });

    animation.addStatusListener((status) {
      if(animation.isCompleted) {
        transform = defaultOffset;
      }
    });

    animationController.forward();
  }

  void animDisappear() {
    late Animation<double> animation;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final Animation<double> curve =
    CurvedAnimation(parent: animationController, curve: Curves.easeOutExpo);
    animation = Tween<double>(begin: 1, end: 0).animate(curve);

    animation.addListener(() {
      setState(() {
        opacity = animation.value;
      });
    });

    animation.addStatusListener((status) {
      if(animation.isCompleted) {
        transform = defaultOffset;
      }
    });

    animationController.forward();
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);

    text = widget.text;
    color = widget.color;

    widget.animTrigger = animTrigger;
    widget.changeColor = changeColor;
    widget.changeText = changeText;

    opacity = defaultOpacity;
    transform = defaultOffset;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: transform,
        child: Container(
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: color,
              width: 3,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(45),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: color,
                  blurRadius: 10,
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
