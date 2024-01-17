import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:vocabella/widgets/tts_button.dart';
import 'package:vocabella/utils/animations.dart';
import 'package:vocabella/utils/short_languages.dart';

enum Sequence {
  appear,
  question,
  showing,
  answer,
  disappear,
  hidden,
}

enum DivisionMode {
  defaultPortrait,
  defaultLandscape,
  side,
}

class WordCard extends StatefulWidget {
  const WordCard({
    Key? key,
    required this.word,
    required this.example,
    required this.isQuestion,
    required this.isOddTHCard,
    required this.language,
    required this.swapZOrder,
  }) : super(key: key);

  final String word, example, language;
  final bool isQuestion, isOddTHCard;

  final void Function() swapZOrder;

  @override
  State<WordCard> createState() => WordCardState();
}

class WordCardState extends State<WordCard> with TickerProviderStateMixin {
  late Sequence _sequence;

  Sequence getSequence() => _sequence;

  void setSequence(Sequence sequence) {
    setState(() {
      _sequence = sequence;
    });
  }

  late String displayWord;
  late String displayExample;

  // Variables for animation
  late Offset transformOffset;
  late double scaleFactor;
  late double opacity;
  late double width;
  late double height;

  late AnimValueBase av;

  // some constants
  late Offset mainOffset;
  late Offset mainHiddenOffset;
  late Offset smallOffset;
  late Offset mediumOffset;

  late double oneOpacity;
  late double zeroOpacity;

  late double defaultWidth;
  late double smallWidth;
  late double mediumWidth;

  late double defaultHeight;
  late double smallHeight;
  late double mediumHeight;

  late double defaultScale;
  late double smallScale;
  late double mediumScale;

  // Some variables being responsible for animations
  late AnimationController controller1;
  late AnimationController controller2;
  late AnimationController controller3;
  late AnimationController controller4;

  // Values for animation
  final int showingAnimDuration = 700; // maybe configurable
  final int transitionalAnimDuration = 500; // maybe configurable
  final Curve curveType = Curves.easeOutExpo; // maybe configurable

  late DivisionMode divisionMode;

  // Change currently displaying text and update corresponding text-to-speech
  void setDisplayWordAndExample(
      {required String newWord, required String newExample}) {
    setState(() {
      displayWord = newWord;
      displayExample = newExample;
    });
  }

  @override
  void initState() {
    super.initState();

    _sequence = Sequence.hidden;

    controller1 = AnimationController(vsync: this);
    controller2 = AnimationController(vsync: this);
    controller3 = AnimationController(vsync: this);
    controller4 = AnimationController(vsync: this);

    displayWord = widget.word;
    displayExample = widget.example;
    divisionMode = DivisionMode.defaultPortrait;

    refreshAnimValue();
    initSize();
    if (widget.isQuestion && widget.isOddTHCard) animAppear();
  }

  void updateAnimValue() {
    mainOffset = av.mainOffset;
    mainHiddenOffset = av.mainHiddenOffset;
    smallOffset = av.smallOffset;
    mediumOffset = av.mediumOffset;

    oneOpacity = av.oneOpacity;
    zeroOpacity = av.zeroOpacity;

    defaultWidth = av.defaultWidth;
    smallWidth = av.smallWidth;
    mediumWidth = av.mediumWidth;

    defaultHeight = av.defaultHeight;
    smallHeight = av.smallHeight;
    mediumHeight = av.mediumHeight;

    defaultScale = av.defaultScale;
    smallScale = av.smallScale;
    mediumScale = av.mediumScale;
  }

  void initSize() {
    width = defaultWidth;
    height = defaultHeight;
    transformOffset = mainHiddenOffset;
    scaleFactor = defaultScale;
    opacity = oneOpacity;
  }

  // Animation once called
  void animAppear() {
    if (_sequence != Sequence.hidden) return;

    if (!widget.isQuestion) {
      _sequence = Sequence.question;
      return;
    }

    // somehow I have to do this
    if (opacity != oneOpacity) {
      opacity = oneOpacity;
      width = defaultWidth;
      height = defaultHeight;
      transformOffset = mainHiddenOffset;
      scaleFactor = defaultScale;
      setState(() {});
    }

    late Animation<double> animation;

    controller1 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller1, curve: curveType);
    animation = Tween<double>(begin: mainHiddenOffset.dy, end: mainOffset.dy)
        .animate(curve);

    animation.addListener(() {
      transformOffset = Offset(0, animation.value);
      setState(() {});
    });

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        _sequence = Sequence.question;
      }
    });

    controller1.forward();
  }

  void breakAnimAppear() {
    if (_sequence != Sequence.hidden) return;
    if (!controller1.isAnimating) return;

    setState(() {
      controller1.stop();
      controller1.reset();

      transformOffset = Offset(0, mainOffset.dy);

      _sequence = Sequence.question;
    });
  }

  // Animation for question-card
  void animSmall() {
    if (_sequence != Sequence.showing) return;

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
    animation = Tween<double>(begin: defaultWidth, end: smallWidth)
        .animate(curve); // scale side
    animation1 = Tween<double>(begin: defaultHeight, end: smallHeight)
        .animate(curve); // scale up, down
    animation2 = Tween<double>(begin: defaultScale, end: smallScale)
        .animate(curve); // scale
    animation3 = Tween<double>(begin: mainOffset.dx, end: smallOffset.dx)
        .animate(curve); // x
    animation4 = Tween<double>(begin: mainOffset.dy, end: smallOffset.dy)
        .animate(curve); // y

    animation.addListener(() {
      width = animation.value;
      height = animation1.value;
      scaleFactor = animation2.value;
      transformOffset = Offset(animation3.value, animation4.value);
      setState(() {});
    });

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        _sequence = Sequence.answer;
        widget.swapZOrder();
      }
    });

    controller2.forward();
  }

  void breakAnimSmall() {
    if (_sequence != Sequence.showing) return;
    if (!controller2.isAnimating) return;

    setState(() {
      controller2.stop();
      controller2.reset();
      width = smallWidth;
      height = smallHeight;
      scaleFactor = smallScale;
      transformOffset = Offset(smallOffset.dx, smallOffset.dy);
      _sequence = Sequence.answer;
    });
  }

  // Animation for answer-card
  void animMedium() {
    if (_sequence != Sequence.showing) return;

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
    animation = Tween<double>(begin: defaultWidth, end: mediumWidth)
        .animate(curve); // scale side
    animation1 = Tween<double>(begin: defaultHeight, end: mediumHeight)
        .animate(curve); // scale up,down
    animation2 = Tween<double>(begin: defaultScale, end: mediumScale)
        .animate(curve); // scale
    animation3 = Tween<double>(begin: mainOffset.dx, end: mediumOffset.dx)
        .animate(curve); // x
    animation4 = Tween<double>(begin: mainOffset.dy, end: mediumOffset.dy)
        .animate(curve); // y

    animation.addListener(() {
      width = animation.value;
      height = animation1.value;
      scaleFactor = animation2.value;
      transformOffset = Offset(animation3.value, animation4.value);

      setState(() {});
    });

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        _sequence = Sequence.answer;
      }
    });

    controller3.forward();
  }

  void breakAnimMedium() {
    if (_sequence != Sequence.showing) return;
    if (!controller3.isAnimating) return;

    setState(() {
      controller3.stop();
      controller3.reset();
      width = mediumWidth;
      height = mediumHeight;
      scaleFactor = mediumScale;
      transformOffset = Offset(mediumOffset.dx, mediumOffset.dy);
      _sequence = Sequence.answer;
    });
  }

  // Animation for disposal
  void animDisappear() {
    if (_sequence != Sequence.disappear) return;

    widget.swapZOrder();

    late Animation<double> animation;

    controller4 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: transitionalAnimDuration));
    final Animation<double> curve =
        CurvedAnimation(parent: controller4, curve: curveType);

    // Animation setup
    animation =
        Tween<double>(begin: oneOpacity, end: zeroOpacity).animate(curve);

    animation.addListener(() {
      opacity = animation.value;
      setState(() {});
    });
    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        _sequence = Sequence.hidden;
        transformOffset = mainHiddenOffset;
        setState(() {});
      }
    });

    controller4.forward();
  }

  void breakAnimDisappear() {
    if (_sequence != Sequence.disappear) return;
    if (!controller4.isAnimating) return;

    setState(() {
      controller4.stop();
      controller4.reset();
      opacity = zeroOpacity;
      transformOffset = mainHiddenOffset;
      _sequence = Sequence.hidden;
    });
  }

  // Set state into default value, so that it places under main widget
  void reset() {
    setState(() {
      width = defaultWidth;
      height = defaultHeight;
      transformOffset = mainHiddenOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    });
  }

  // Set state into default value but locate it at the middle
  void resetCenter() {
    setState(() {
      width = defaultWidth;
      height = defaultHeight;
      transformOffset = mainOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    });
  }

  @override
  void didUpdateWidget(WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Did Update Widget called");
    print("Did Update Widget called");
    print("Did Update Widget called");
    print("Did Update Widget called");
    print("Did Update Widget called");
    print("Did Update Widget called");
    print("Did Update Widget called");
  }

  @override
  void dispose() {
    super.dispose();

    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
  }

  void refreshAnimValue() {
    // refresh all value
    if (divisionMode == DivisionMode.defaultPortrait) {
      av = DefaultAnimValue();
    } else if (divisionMode == DivisionMode.defaultLandscape) {
      av = DefaultLandscapeAnimValue();
    }
    updateAnimValue();
  }

  Size _old = Size.zero;

  // Called on build() so setState is not allowed
  void onScreenSizeChanged() {
    refreshAnimValue();

    // Apply values to actual values will be applied
    if (_sequence == Sequence.question) {
      width = defaultWidth;
      height = defaultHeight;
      transformOffset = mainOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    } else if (_sequence == Sequence.answer) {
      width = widget.isQuestion ? smallWidth : mediumWidth;
      height = widget.isQuestion ? smallHeight : mediumHeight;
      transformOffset = widget.isQuestion ? smallOffset : mediumOffset;
      scaleFactor = widget.isQuestion ? smallScale : mediumScale;
      opacity = oneOpacity;
    } else if (_sequence == Sequence.hidden) {
      width = defaultWidth;
      height = defaultHeight;
      transformOffset = mainHiddenOffset;
      scaleFactor = defaultScale;
      opacity = oneOpacity;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size newSize = MediaQuery.of(context).size;
    if (_old != newSize) {
      if (newSize.width > newSize.height) {
        divisionMode = DivisionMode.defaultLandscape;
      } else if (newSize.width <= newSize.height) {
        divisionMode = DivisionMode.defaultPortrait;
      }

      onScreenSizeChanged();
    }
    _old = newSize;

    bool noEx = displayExample.isEmpty;

    return Transform.translate(
      offset: transformOffset,
      child: Transform.scale(
        scale: scaleFactor,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              clipBehavior: Clip.hardEdge,
              /*margin: EdgeInsets.only(
                    left: margins[0],
                    right: margins[1],
                    bottom: margins[2],
                    top: margins[3]),*/
              width: width,
              height: height,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    displayWord,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 100,
                          ),
                        ]),
                  ),
                  if (!noEx) const SizedBox(height: 30),
                  if (!noEx)
                    Text(
                      displayExample,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if(widget.isQuestion) Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TTSButton(
                          textToRead: formatText(displayWord),
                          language: widget.language),
                      if (!noEx) const SizedBox(width: 30),
                      if (!noEx)
                        TTSButton(
                            textToRead: displayExample,
                            language: widget.language),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
