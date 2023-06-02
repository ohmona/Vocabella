import 'package:flutter/material.dart';
import 'package:vocabella/managers/tts_manager.dart';

enum Sequence {
  appear,
  question,
  showing,
  answer,
  disappear,
  hidden,
}

class WordCard extends StatefulWidget {
  WordCard({
    Key? key,
    required this.word,
    required this.example,
    required this.isQuestion,
    required this.isOddTHCard, required this.language,
  }) : super(key: key);

  final String word, example, language;
  final bool isQuestion, isOddTHCard;

  late void Function() animAppear;
  late void Function() animDisappear;
  late void Function() animSmall;
  late void Function() animMedium;
  late void Function() reset;
  late void Function() resetCenter;

  late void Function({required String newWord,required String newExample}) setDisplayWordAndExample;

  late Sequence sequence;

  late TTSButton wordTTS;
  late TTSButton exampleTTS;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> with TickerProviderStateMixin {

  late String displayWord;
  late String displayExample;

  // Variables for animation
  late Offset transformOffset;
  late double scaleFactor;
  late List<double> margins; // left, right, bottom, top
  late double opacity;

  // some constants
  final Offset mainOffset = const Offset(0,0);
  final Offset mainHiddenOffset = const Offset(0, 1000);
  final Offset smallOffset = const Offset(0,-200);
  final Offset mediumOffset = const Offset(0,110);

  final double oneOpacity = 1;
  final double zeroOpacity = 0;

  final List<double> defaultMargin = const [10, 10, 0, 0];
  final List<double> smallMargin = const [0, 0, 190, 190];
  final List<double> mediumMargin = const [0, 0, 190, 190];

  final double defaultScale = 1;
  final double smallScale = 0.8;
  final double mediumScale = 0.8;

  // Some variables being responsible for animations
  late AnimationController controller1;
  late AnimationController controller2;
  late AnimationController controller3;
  late AnimationController controller4;

  // Values for animation
  final int showingAnimDuration = 1000; // maybe configurable
  final int transitionalAnimDuration = 500; // maybe configurable
  final Curve curveType = Curves.easeOutExpo; // maybe configurable

  void updateTTS() {
    widget.wordTTS = TTSButton(
      textToRead: displayWord,
      language: widget.language,
    );

    widget.exampleTTS = TTSButton(
      textToRead: displayExample,
      language: widget.language,
    );

    setState(() {});
  }

  void _setDisplayWordAndExample({required String newWord, required String newExample}) {
    setState(() {
      displayWord = newWord;
      displayExample = newExample;
      updateTTS();
    });
  }

  @override
  void initState() {
    super.initState();

    displayWord = widget.word;
    displayExample = widget.example;

    widget.setDisplayWordAndExample = _setDisplayWordAndExample;

    margins = defaultMargin;
    transformOffset = mainHiddenOffset;
    scaleFactor = defaultScale;
    opacity = oneOpacity;

    widget.animDisappear = animDisappear;
    widget.animAppear = animAppear;
    widget.animSmall = animSmall;
    widget.animMedium = animMedium;
    widget.reset = reset;
    widget.resetCenter = resetCenter;

    if (widget.isQuestion && widget.isOddTHCard) animAppear();

    widget.wordTTS = TTSButton(
      textToRead: widget.word,
      language: widget.language,
    );

    widget.exampleTTS = TTSButton(
      textToRead: widget.example,
      language: widget.language,
    );
  }

  // Animation once called
  void animAppear() {
    if (widget.sequence != Sequence.hidden) return;

    if (!widget.isQuestion) {
      widget.sequence = Sequence.question;
      return;
    }

    // somehow i have to do this
    if (opacity != oneOpacity) {
      opacity = oneOpacity;
      margins = defaultMargin;
      transformOffset = mainHiddenOffset;
      scaleFactor = scaleFactor;
      setState(() {});
    }

    late Animation<double> animation;

    controller1 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller1, curve: curveType);
    animation = Tween<double>(begin: mainHiddenOffset.dy, end: mainOffset.dy).animate(curve);

    animation.addListener(() {
      transformOffset = Offset(0, animation.value);
      setState(() {});
    });

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        widget.sequence = Sequence.question;
      }
    });

    controller1.forward();
  }

  // Animation for question-card
  void animSmall() {
    if (widget.sequence != Sequence.showing) return;

    late Animation<double> animation;
    late Animation<double> animation1;
    late Animation<double> animation2;
    late Animation<double> animation3;
    late Animation<double> animation4;

    // somehow i have to do this
    if (opacity != 1) {
      opacity = 1;
      setState(() {});
    }

    controller2 = AnimationController(
        vsync: this, duration: Duration(milliseconds: showingAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller2, curve: curveType);
    animation = Tween<double>(begin: defaultMargin[0], end: smallMargin[0]).animate(curve); // scale side
    animation1 =
        Tween<double>(begin: defaultMargin[2], end: smallMargin[2]).animate(curve); // scale up, down
    animation2 = Tween<double>(begin: defaultScale, end: smallScale).animate(curve); // scale
    animation3 = Tween<double>(begin: mainOffset.dx, end: smallOffset.dx).animate(curve); // x
    animation4 = Tween<double>(begin: mainOffset.dy, end: smallOffset.dy).animate(curve); // y

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

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        widget.sequence = Sequence.answer;
      }
    });

    controller2.forward();
  }

  // Animation for answer-card
  void animMedium() {
    if (widget.sequence != Sequence.showing) return;

    late Animation<double> animation;
    late Animation<double> animation1;
    late Animation<double> animation2;
    late Animation<double> animation3;
    late Animation<double> animation4;

    // somehow i have to do this
    if (opacity != 1) {
      opacity = 1;
      setState(() {});
    }

    controller3 = AnimationController(
        vsync: this, duration: Duration(milliseconds: showingAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller3, curve: curveType);
    animation = Tween<double>(begin: defaultMargin[0], end: mediumMargin[0]).animate(curve); // scale side
    animation1 =
        Tween<double>(begin: defaultMargin[2], end: mediumMargin[2]).animate(curve); // scale up,down
    animation2 = Tween<double>(begin: defaultScale, end: mediumScale).animate(curve); // scale
    animation3 = Tween<double>(begin: mainOffset.dx, end: mediumOffset.dx).animate(curve); // x
    animation4 = Tween<double>(begin: mainOffset.dy, end: mediumOffset.dy).animate(curve); // y

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

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        widget.sequence = Sequence.answer;
      }
    });

    controller3.forward();
  }

  // Animation for disposal
  void animDisappear() {
    if (widget.sequence != Sequence.disappear) return;

    late Animation<double> animation;

    controller4 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller4, curve: curveType);

    // Animation setup
    animation = Tween<double>(begin: oneOpacity, end: zeroOpacity).animate(curve);

    animation.addListener(() {
      opacity = animation.value;
      setState(() {});
    });
    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        widget.sequence = Sequence.hidden;
      }
    });

    controller4.forward();
  }

  // Set state into default value, so that it places under main widget
  void reset() {
    setState(() {
      margins = defaultMargin;
      transformOffset = mainHiddenOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    });
  }

  // Set state into default value but locate it at the middle
  void resetCenter() {
    setState(() {
      margins = defaultMargin;
      transformOffset = mainOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
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
            clipBehavior: Clip.hardEdge,
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
                  displayWord,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 100,
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  displayExample,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.wordTTS,
                    const SizedBox(width: 30),
                    widget.exampleTTS,
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
