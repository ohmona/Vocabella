import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/widgets/progress_bar_widget.dart';
import 'package:vocabella/widgets/word_card_widget.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables about input
  final fieldText = TextEditingController();
  String inputValue = "";

  // Variables about words
  String answer = "Datei";

  // Variables about quiz
  bool wasWrong = false;

  // Cards
  late WordCard questionCard;
  late WordCard answerCard;
  late WordCard questionCard2;
  late WordCard answerCard2;
  late Stack cardStack;

  // Bottom Bar
  late BottomBox inputBox;
  late BottomBox continueBox;

  // Logics
  late bool isOddTHCard;
  late bool isShowingAnswer;

  // Timer
  late Timer transitionTimer;
  late Timer disposalTimer;
  late Timer showingTimer;
  final int timerScale = 300;

  // Runs when user gives enter
  void onSummit(String text) {
    if (text == answer) {
      wasWrong = false;
    } else {
      wasWrong = true;
      fieldText.clear();
      setState(() {});
    }
    questionCard.animSmall;
    answerCard.animMedium;
  }

  // Runs when user presses summit button
  void onSummitByButton() {
    onSummit(inputValue);
  }

  // Update stored data for input TextBox
  void updateInputValue(String newInputValue) {
    inputValue = newInputValue;
  }

  /*
  *   Transition : Appearance of cards from bottom to top
   */
  // Timer variables
  bool isTransitionRunning = false;
  int transitionTime = 0;

  // Body of transition timer
  void onTransitionTick(Timer transitionTimer) {
    if (transitionTime == timerScale) {
      setState(() {
        // answer card should be placed here
        isOddTHCard ? answerCard.resetCenter() : answerCard2.resetCenter();
        transitionTimer.cancel();
        isTransitionRunning = false;
        transitionTime = 0;
      });
    } else {
      setState(() {
        transitionTime++;
      });
    }
  }

  // Trigger of transition Timer
  void onTransitionStarted() {
    transitionTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      onTransitionTick,
    );
    setState(() {
      isTransitionRunning = true;
    });
  }

  /*
  *   Disposal : Resetting previous cards into initial state
   */
  // Timer variables
  bool isDisposalRunning = false;
  int disposalTime = 0;

  // Body of disposal timer
  void onDisposalTick(Timer disposalTimer) {
    if (disposalTime == timerScale) {
      setState(() {
        // answer card should be placed here
        isOddTHCard ? answerCard2.reset() : answerCard.reset();
        isOddTHCard ? questionCard2.reset() : questionCard.reset();
        disposalTimer.cancel();
        isDisposalRunning = false;
        disposalTime = 0;
      });
    } else {
      setState(() {
        disposalTime++;
      });
    }
  }

  // Trigger of transition Timer
  void onDisposalStarted() {
    disposalTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      onDisposalTick,
    );
    setState(() {
      isDisposalRunning = true;
    });
  }

  /*
  *   Showing : Delay to answer showed
   */
  // Timer variables
  bool isShowingRunning = false;
  int showingTime = 0;

  // Body of showing timer
  void onShowingTick(Timer showingTimer) {
    if (showingTime == timerScale) {
      setState(() {
        showingTimer.cancel();
        isShowingRunning = false;
        showingTime = 0;
      });
    } else {
      setState(() {
        showingTime++;
      });
    }
  }

  // Trigger of showing timer
  void onShowingStarted() {
    showingTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      onShowingTick,
    );
    setState(() {
      isShowingRunning = true;
    });
  }

  // Show correct answer by animating cards sidewards
  void showAnswer() {
    if(isShowingRunning) {
      return;
    }
    else if(isShowingAnswer) {
      return;
    }
    else if(isTransitionRunning) {
      return;
    }

    onShowingStarted();
    isShowingAnswer = true;
    if(isOddTHCard) {
      questionCard.animSmall();
      answerCard.animMedium();
    }
    else {
      questionCard2.animSmall();
      answerCard2.animMedium();
    }
  }

  /* Show next cards by disposing (making invisible)
  *  previous cards and making next card appeared */
  void showNext() {
    if(isTransitionRunning) {
      return;
    } else if(isDisposalRunning) {
      return;
    } else if(isShowingRunning) {
      return;
    } else if(!isShowingAnswer) {
      return;
    }

    onDisposalStarted();
    if(isOddTHCard) {
      questionCard.animDisappear();
      answerCard.animDisappear();
      questionCard2.animAppear();
      onTransitionStarted();
    }
    else {
      questionCard2.animDisappear();
      answerCard2.animDisappear();
      questionCard.animAppear();
      onTransitionStarted();
    }
    isOddTHCard = !isOddTHCard;
    isShowingAnswer = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Initialise 4 cards for test
    questionCard = WordCard(
      isQuestion: true,
      isOddTHCard: true,
      word: "data",
      example: "Data fechted! Let's go",
    );

    answerCard = WordCard(
      isQuestion: false,
      isOddTHCard: true,
      word: "Datei",
      example: "Für Datenschutz muss man Datei schützen",
    );

    questionCard2 = WordCard(
      isQuestion: true,
      isOddTHCard: false,
      word: "apple",
      example: "",
    );

    answerCard2 = WordCard(
      isQuestion: false,
      isOddTHCard: false,
      word: "Apfel",
      example: "",
    );

    // Initialise InputTextBox
    inputBox = BottomBox(
      child: InputBox(
        answer: answer,
        inputValue: inputValue,
        fieldText: fieldText,
        onSummit: onSummit,
        onSummitByButton: onSummitByButton,
        updateInputValue: updateInputValue,
      ),
    );

    // Initialise ContinueBox
    continueBox = BottomBox(
      child: ContinueBox(),
    );

    // Initialise Stack Component
    cardStack = Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        answerCard,
        questionCard,
        answerCard2,
        questionCard2,
      ],
    );

    // Initialise some logic states and run first animation
    isOddTHCard = true;
    isShowingAnswer = false;
    onTransitionStarted();
  }

  void removeContinueBox() {
    //TODO solve issue that Bottombox doesn't disappear once function is called
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
          ),
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          const ProgressBar(), // TODO
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: cardStack,
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              inputBox,
              continueBox,
              FloatingActionButton(onPressed: isShowingAnswer? showNext : showAnswer, child: Icon(Icons.add_circle)),
            ],
          ),
        ],
      ),
    );
  }
}