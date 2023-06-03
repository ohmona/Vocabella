import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/classes.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/widgets/progress_bar_widget.dart';
import 'package:vocabella/widgets/word_card_widget.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    Key? key,
    required this.wordPack,
  }) : super(key: key);

  final List<WordPair> wordPack;

  //final String language1;
  //final String language2;
  //TODO make language selectable when it's created

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables about input
  final fieldText = TextEditingController();
  String inputValue = "";

  // Variables about questions
  int count = 1;
  late List<WordPair> listOfQuestions;
  late List<WordPair> listOfWrongs = [];

  //TODO it's just for test
  String language1 = "en-US";
  String language2 = "de-DE";

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

  bool isAnswerCorrect(String answer) {
    // TODO implement correction detection system
    return answer == listOfQuestions[count - 1].word2;
  }

  // Runs when user gives enter
  void onSummit(String text) {
    showAnswer();

    print("correct one : ${listOfQuestions[count - 1].word2}");
    print("given answer : " + text);
    print("Was Correct? : ${isAnswerCorrect(text)}");
    if (isAnswerCorrect(text)) {
      // Answer was correct
      wasWrong = false;
    } else {
      // Answer was wrong
      // so we have to put this word at the wrong list
      if (count != 0) {}
      listOfWrongs.add(listOfQuestions[count - 1]);
      wasWrong = true;
    }
    setState(() {});

    fieldText.clear();
    questionCard.animSmall;
    answerCard.animMedium;

    makeNextWord();
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

  // Show correct answer by animating cards sidewards and play tts immediately
  void showAnswer() {
    /* Check whether sequence of cards (depending of isOddTHCard) are
    *  in sequence of question, if true blocks further commands
    */
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

    if (FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    fieldText.clear();

    // answer is now being shown
    isShowingAnswer = true;

    /* Change sequence of Cards (depending of isOddTHCard), then animate them
    * and run tts */
    if (isOddTHCard) {
      questionCard.sequence = Sequence.showing;
      answerCard.sequence = Sequence.showing;

      questionCard.animSmall();
      answerCard.animMedium();

      answerCard.wordTTS.play();
    } else {
      questionCard2.sequence = Sequence.showing;
      answerCard2.sequence = Sequence.showing;

      questionCard2.animSmall();
      answerCard2.animMedium();

      answerCard2.wordTTS.play();
    }
  }

  /* Show next cards by disposing (making invisible)
  *  previous cards and making next card appeared and
  *  play tts immediately if it exists */
  void showNext() {
    print("showNext");

    // Check if the current sequence is Answer
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
      print("this shall not happen");
      return;
    }

    // Check if it's done
    if (count > listOfQuestions.length) {
      // TODO finish session
      print("LIST DONE!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("LIST DONE!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("LIST DONE!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("LIST DONE!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("LIST DONE!!!!!!!!!!!!!!!!!!!!!!!!!");
    }

    // Animate cards to disappear
    onDisposalStarted();

    if (isOddTHCard) {
      questionCard.sequence = Sequence.disappear;
      answerCard.sequence = Sequence.disappear;

      questionCard.animDisappear();
      answerCard.animDisappear();
      questionCard2.animAppear();
      onTransitionStarted(); // Transition for behind card

      questionCard2.wordTTS.play();
    } else {
      questionCard2.sequence = Sequence.disappear;
      answerCard2.sequence = Sequence.disappear;

      questionCard2.animDisappear();
      answerCard2.animDisappear();
      questionCard.animAppear();
      onTransitionStarted(); // Transition for behind card

      questionCard.wordTTS.play();
    }
    isOddTHCard = !isOddTHCard;
    isShowingAnswer = false;
    setState(() {});
  }

  void makeNextWord() {
    print("=======making new word========");

    print("Question part");
    print(listOfQuestions[count].word1);
    print(listOfQuestions[count].example1);
    print("Answer part");
    print(listOfQuestions[count].word2);
    print(listOfQuestions[count].example2);

    if (count > 1) {
      print('COUNT LAGER 1');
      // Update hidden Card for next one

      // Question part
      isOddTHCard
          ? questionCard2.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word1,
              newExample: listOfQuestions[count].example1 ?? "",
            )
          : questionCard.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word1,
              newExample: listOfQuestions[count].example1 ?? "",
            );

      // Answer part
      isOddTHCard
          ? answerCard2.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word2,
              newExample: listOfQuestions[count].example2 ?? "",
            )
          : answerCard.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word2,
              newExample: listOfQuestions[count].example2 ?? "",
            );
    }
    count++;
    print(
        "Next card index + 1 : $count, and is current card 2n+1 : $isOddTHCard");

    setState(() {});
  }

  void makeList() {
    // Initialise list
    listOfQuestions = widget.wordPack;

    // Shuffle list randomly
    listOfQuestions.shuffle();
  }

  @override
  void initState() {
    super.initState();

    listOfQuestions = widget.wordPack;
    print("listOfQuestions : ${listOfQuestions.length}");
    for (WordPair str in listOfQuestions) print(str.word1);

    // Initialise 4 cards for test
    questionCard = WordCard(
      isQuestion: true,
      isOddTHCard: true,
      word: listOfQuestions[0].word1,
      example: listOfQuestions[0].example1 ?? "",
      language: language1,
    );

    answerCard = WordCard(
      isQuestion: false,
      isOddTHCard: true,
      word: listOfQuestions[0].word2,
      example: listOfQuestions[0].example2 ?? "",
      language: language2,
    );

    questionCard2 = WordCard(
      isQuestion: true,
      isOddTHCard: false,
      word: listOfQuestions[1].word1,
      example: listOfQuestions[1].example1 ?? "",
      language: language1,
    );

    answerCard2 = WordCard(
      isQuestion: false,
      isOddTHCard: false,
      word: listOfQuestions[1].word2,
      example: listOfQuestions[1].example2 ?? "",
      language: language2,
    );

    // Initialise InputTextBox
    inputBox = BottomBox(
      child: InputBox(
        answer: listOfQuestions[count - 1].word2,
        inputValue: inputValue,
        fieldText: fieldText,
        onSummit: onSummit,
        onSummitByButton: onSummitByButton,
        updateInputValue: updateInputValue,
      ),
    );

    /*// Initialise ContinueBox
    continueBox = BottomBox(
      child: ContinueBox(
        onLeftClicked: () {},
        onRightClicked: showNext,
      ),
    );*/

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
              !isShowingAnswer
                  ? inputBox
                  : ContinueBox(
                    onClicked: showNext,
                    correctState: wasWrong
                        ? CorrectState.wrong
                        : CorrectState.correct,
                  ),
              FloatingActionButton(
                  onPressed: () {
                    print("loading set Correct state...");
                    print("loading set Correct state finished!");
                  },
                  child: const Icon(Icons.add_circle)),
            ],
          ),
        ],
      ),
    );
  }
}
