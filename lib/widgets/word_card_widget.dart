import 'package:flutter/material.dart';

class WordCard extends StatefulWidget {
  WordCard({Key? key, required this.word, required this.example, required this.isQuestion, required this.isOddTHCard,})
      : super(key: key);

  final String word, example;
  final bool isQuestion, isOddTHCard;

  late void Function() animAppear;
  late void Function() animDisappear;
  late void Function() animSmall;
  late void Function() animMedium;
  late void Function() reset;
  late void Function() resetCenter;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard>
    with TickerProviderStateMixin {

  late Offset transformOffset;
  late double scaleFactor;
  late List<double> margins; // left, right, bottom, top
  late double opacity;

  // Some variables being responsible for animations
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late Animation<double> animation4;

  // Values for animation
  final int showingAnimDuration = 1000; // maybe configurable
  final int transitionalAnimDuration = 1000; // maybe configurable
  final Curve curveType = Curves.easeOutExpo; // maybe configurable

  @override
  void initState() {
    super.initState();

    margins = [10, 10, 0, 0];
    transformOffset = const Offset(1000, 0);
    scaleFactor = 1;
    opacity = 1;

    widget.animDisappear = animDisappear;
    widget.animAppear = animAppear;
    widget.animSmall = animSmall;
    widget.animMedium = animMedium;
    widget.reset = reset;
    widget.resetCenter = resetCenter;

    if(widget.isQuestion && widget.isOddTHCard) animAppear();
  }

  // Animation once called
  void animAppear() {
    if(!widget.isQuestion) return;

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller, curve: curveType);
    animation = Tween<double>(begin: 1000, end: 0).animate(curve);

    animation.addListener(() {
      transformOffset = Offset(0, animation.value);
      setState(() {});
    });
    controller.forward();
  }

  // Animation for question-card
  void animSmall() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: showingAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller, curve: curveType);
    animation = Tween<double>(begin: 10, end: 100).animate(curve); // scale side
    animation1 = Tween<double>(begin: 10, end: 170).animate(curve); // scale up, down
    animation2 = Tween<double>(begin: 1, end: 0.7).animate(curve); // scale
    animation3 = Tween<double>(begin: 0, end: -120).animate(curve); // x
    animation4 = Tween<double>(begin: 0, end: -200).animate(curve); // y

    animation.addListener(() {
      double left = animation.value;
      double right = animation.value;
      double bottom = animation1.value;
      double top = animation1.value;
      margins = [left, right, bottom, top];

      scaleFactor = animation2.value;

      transformOffset = Offset(animation3.value, animation4.value);
      setState(() {});
    });
    controller.forward();
  }

  // Animation for answer-card
  void animMedium() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: showingAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller, curve: curveType);
    animation = Tween<double>(begin: 10, end: 25).animate(curve); // scale side
    animation1 =
        Tween<double>(begin: 10, end: 50).animate(curve); // scale up,down
    animation2 = Tween<double>(begin: 1, end: 0.8).animate(curve); // scale
    animation3 = Tween<double>(begin: 0, end: 50).animate(curve); // x
    animation4 = Tween<double>(begin: 0, end: 90).animate(curve); // y

    animation.addListener(() {
      double left = animation.value;
      double right = animation.value;
      double bottom = animation1.value;
      double top = animation1.value;
      margins = [left, right, bottom, top];

      scaleFactor = animation2.value;

      transformOffset = Offset(animation3.value, animation4.value);

      setState(() {});
    });
    controller.forward();
  }

  // Animation for disposal
  void animDisappear() {
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
    CurvedAnimation(parent: controller, curve: curveType);

    // Animation setup
    animation = Tween<double>(begin: 1, end: 0).animate(curve);

    animation.addListener(() {
      opacity = animation.value;
      setState(() {});
    });
    controller.forward();
  }

  // Set state into default value, so that it places under main widget
  void reset() {
    setState(() {
      margins = [10, 10, 0, 0];
      transformOffset = const Offset(1000, 0);
      scaleFactor = 1;
      opacity = 1;
    });
  }

  // Set state into default value but locate it at the middle
  void resetCenter() {
    setState(() {
      margins = [10, 10, 0, 0];
      transformOffset = const Offset(0, 0);
      scaleFactor = 1;
      opacity = 1;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: transformOffset,
      child: Transform.scale(
        scale: scaleFactor,
        child: Opacity(
          opacity: opacity,
          child: Container(
            margin: EdgeInsets.only(
                left: margins[0],
                right: margins[1],
                bottom: margins[2],
                top: margins[3]),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.withOpacity(0.11),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(1),
                  offset: const Offset(4, 4),
                  blurRadius: 15,
                  spreadRadius: 1,
                  blurStyle: BlurStyle.normal,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(1),
                  offset: const Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.word,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  widget.example,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: animDisappear,
                      icon: const Icon(
                        Icons.audiotrack_rounded,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 30),
                    IconButton(
                      onPressed: widget.isQuestion ? animSmall : animMedium,
                      icon: const Icon(
                        Icons.audiotrack_rounded,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
