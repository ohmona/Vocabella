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
  // Body of transition timer
  void onTransitionTick(Timer transitionTimer) {
    if (isOddTHCard
        ? questionCard.sequence == Sequence.appear
        : questionCard2.sequence == Sequence.appear) {
      setState(() {
        // answer card should be placed here
        isOddTHCard ? answerCard.resetCenter() : answerCard2.resetCenter();
        transitionTimer.cancel();
      });
    } else {
      setState(() {});
    }
  }

  // Trigger of transition Timer
  void onTransitionStarted() {
    transitionTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      onTransitionTick,
    );
    setState(() {});
  }

  /*
  *   Disposal : Resetting previous cards into initial state
   */
  // Body of disposal timer
  void onDisposalTick(Timer disposalTimer) {
    if (isOddTHCard
        ? questionCard2.sequence == Sequence.hidden
        : questionCard.sequence == Sequence.hidden) {
      setState(() {
        // answer card should be placed here
        isOddTHCard ? answerCard2.reset() : answerCard.reset();
        isOddTHCard ? questionCard2.reset() : questionCard.reset();

        disposalTimer.cancel();
      });
    }
  }

  // Trigger of transition Timer
  void onDisposalStarted() {
    disposalTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      onDisposalTick,
    );
  }

  // Show correct answer by animating cards sidewards
  void showAnswer() {
    late bool trigger;
    if (isOddTHCard) {
      trigger = questionCard.sequence != Sequence.question &&
          answerCard.sequence != Sequence.question;
    } else {
      trigger = questionCard2.sequence != Sequence.question &&
          answerCard2.sequence != Sequence.question;
    }
    if (trigger) {
      return;
    }

    isShowingAnswer = true;
    if (isOddTHCard) {
      questionCard.sequence = Sequence.showing;
      answerCard.sequence = Sequence.showing;

      questionCard.animSmall();
      answerCard.animMedium();
    } else {
      questionCard2.sequence = Sequence.showing;
      answerCard2.sequence = Sequence.showing;

      questionCard2.animSmall();
      answerCard2.animMedium();
    }
  }

  /* Show next cards by disposing (making invisible)
  *  previous cards and making next card appeared */
  void showNext() {
    late bool trigger;
    Sequence requiredSequence = Sequence.answer;
    if (isOddTHCard) {
      trigger = questionCard.sequence != requiredSequence &&
          answerCard.sequence != requiredSequence;
    } else {
      trigger = questionCard2.sequence != requiredSequence &&
          answerCard2.sequence != requiredSequence;
    }
    if (trigger) {
      return;
    }

    onDisposalStarted();
    if (isOddTHCard) {
      questionCard.sequence = Sequence.disappear;
      answerCard.sequence = Sequence.disappear;

      questionCard.animDisappear();
      answerCard.animDisappear();
      questionCard2.animAppear();
      onTransitionStarted(); // Transition for behind card
    } else {
      questionCard2.sequence = Sequence.disappear;
      answerCard2.sequence = Sequence.disappear;

      questionCard2.animDisappear();
      answerCard2.animDisappear();
      questionCard.animAppear();
      onTransitionStarted(); // Transition for behind card
    }
    isOddTHCard = !isOddTHCard;
    isShowingAnswer = false;
    setState(() {});
  }

  void generateNewWord() {
    // TODO choice of random words
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

    answerCard.sequence = Sequence.hidden;
    questionCard.sequence = Sequence.hidden;
    answerCard2.sequence = Sequence.hidden;
    questionCard2.sequence = Sequence.hidden;

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
              FloatingActionButton(
                  onPressed: isShowingAnswer ? showNext : showAnswer,
                  child: const Icon(Icons.add_circle)),
            ],
          ),
        ],
      ),
    );
  }
}
