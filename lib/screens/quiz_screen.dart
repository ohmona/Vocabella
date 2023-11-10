import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/managers/session_saver.dart';
import 'package:vocabella/models/session_data_model.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/widgets/input_checker_box_widget.dart';
import 'package:vocabella/widgets/progress_bar_widget.dart';
import 'package:vocabella/widgets/word_card_widget.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';

import '../models/wordpair_model.dart';

class QuizScreenParent extends StatelessWidget {
  const QuizScreenParent({Key? key}) : super(key: key);

  static const routeName = '/quiz';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QuizScreenArguments;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: QuizScreen(
        wordPack: args.wordPack,
        language1: args.language1,
        language2: args.language2,
        sessionData: args.sessionData,
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    Key? key,
    required this.wordPack,
    required this.language1,
    required this.language2,
    required this.sessionData,
  }) : super(key: key);

  // The list of words for quiz
  final List<WordPair> wordPack;

  static const routeName = '/quiz';

  final String language1;
  final String language2;

  final SessionDataModel sessionData;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables about gameplay
  bool bDontTypeAnswer = true;

  late String language1;
  late String language2;

  // Variables about questions
  late int count;
  late List<WordPair> listOfQuestions;
  late List<WordPair> listOfWrongs;
  late int questionsNumber;

  // Variables about quiz
  bool wasWrong = false;

  // Logics
  late bool isOddTHCard;
  late bool isShowingAnswer;
  bool isDone = false;

  // Variables about input
  final fieldText = TextEditingController();
  String inputValue = "";

  // Cards
  late WordCard questionCard;
  late WordCard answerCard;
  late WordCard questionCard2;
  late WordCard answerCard2;
  late Stack cardStack;
  late ProgressBar progressBar;

  late InputCheckerBox inputCheckerBox;

  // Timer
  late Timer transitionTimer;
  late Timer disposalTimer;

  // Progress
  late int
      absoluteProgress; // progress of all combined, including wrong answers and extension
  late int originalProgress; // progress of original cards
  late int wrongAnswers; // number of all wrong answers
  late int
      absoluteRepetitionProgress; // progress of extension, also wrong answers
  late int repetitionProgress; // progress of extension
  late bool hasRepetitionBegun;
  late int inFirstTry;
  late int inRepetitionFirstTry;
  late int stageCount;

  late SessionDataModel session;

  /// Once user has submitted the answer
  void onSummit(String text) {
    if (kDebugMode) {
      print("================================");
      print("Answer summited");
      print("================================");
    }

    // Make sure that the given answer was correct or wrong
    wasWrong = !isAnswerCorrect(text);

    // Apply given answer to checker
    inputCheckerBox.changeText(text);

    // Show answer initially
    showAnswer();

    // Print answer to check whether code works properly
    if (kDebugMode) {
      print("correct one : ${listOfQuestions[count - 1].word2}");
      print("given answer : $text");
      print("Was Correct? : ${isAnswerCorrect(text)}");
    }

    // Check if answer was correctly given or not
    if (isAnswerCorrect(text) == true) {
      // Count InFirstTry depending on it's repetition or not
      // InFirstTry means that user had given wrong answer at least once
      if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
          !hasRepetitionBegun) {
        // Pure InFirstTry count
        inFirstTry++;
      } else if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
          hasRepetitionBegun) {
        // InFirstTry but it's on revision
        inRepetitionFirstTry++;
      }
      progressBar.updateProgress(
          questionsNumber, inFirstTry + inRepetitionFirstTry);
    } else {
      // The given answer was wrong so the corresponding word will be
      // added into list and only if it's first time
      // For that it'll be compared if current word doesn't exist in the list
      if (!listOfWrongs.contains(listOfQuestions[count - 1])) {
        listOfWrongs.add(listOfQuestions[count - 1]);
      }
    }
    // Update widget
    setState(() {});
    fieldText.clear();

    // Print some values to check for debug
    if (kDebugMode) {
      print("================================");
      print("Printing wrong answers");
      print("================================");

      for (WordPair pair in listOfWrongs) {
        print(pair.word2);
      }
      print("================================");

      print("Some conditions ======================");
      print("Is done : ${count >= listOfQuestions.length}");
      print(">> To Compare : length ${listOfQuestions.length} // count $count");
      print("Has been wrong : ${listOfWrongs.isNotEmpty}");
      print("Was just correct : ${!wasWrong}");
    }

    // Check whether answer was correct and current stage is over
    if (!wasWrong && count >= listOfQuestions.length) {
      // If current session is done, check whether revision should take place or not
      // For revision, new list will be generated according to listOfWrongs
      // Unless, isDone will be set to true to finish the session
      if (listOfWrongs.isNotEmpty) {
        generateExtension();
      } else {
        isDone = true;
      }
    }

    // Depending on correctness, next step will be executed
    wasWrong ? repeatWord() : makeNextWord();
  }

  /// Once user pressed summit button
  void onSummitByButton() => onSummit(inputValue);

  /// Show correct answer by animating cards and play tts immediately
  void showAnswer() {
    // Check if the current sequence is "Question"
    // Unless, exit method to prevent from unexpected animation and sequencing
    if (checkIsNotSequence(Sequence.question)) return;

    // Remove focus from the keyboard
    if (FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    // Reset input
    fieldText.clear();

    // Answer is being shown now
    isShowingAnswer = true;

    // Show answer
    if (isOddTHCard) {
      // Change sequence of Cards
      questionCard.sequence = Sequence.showing;
      answerCard.sequence = Sequence.showing;

      // Animate cards
      questionCard.animSmall();
      answerCard.animMedium();

      // Play TTS
      answerCard.wordTTS.play();
    } else {
      // Change sequence of Cards
      questionCard2.sequence = Sequence.showing;
      answerCard2.sequence = Sequence.showing;

      // Animate cards
      questionCard2.animSmall();
      answerCard2.animMedium();

      // Play TTS
      answerCard2.wordTTS.play();
    }

    // show checker
    if (wasWrong) {
      inputCheckerBox.changeColor(Colors.redAccent);
    } else {
      inputCheckerBox.changeColor(Colors.green);
    }
    if (!bDontTypeAnswer) inputCheckerBox.animTrigger(CheckerBoxState.appear);
  }

  /// Show answer for Don't Type Answer mode
  void showAnswerOnly() {
    if (kDebugMode) {
      print("================================");
      print("Answer showing");
      print("================================");
    }

    // Reset Input Checker Box
    inputCheckerBox.changeText("");

    // Jump to showing process
    showAnswer();
  }

  /// Once "my answer was correct" button pressed during "don't type answer" process
  /// It looks similar to onSummit method
  void onWasCorrect() {
    // Check if the current sequence is "Answer"
    // Unless, exit method to prevent from unexpected animation and sequencing
    if (checkIsNotSequence(Sequence.answer)) return;

    // Answer was correct
    wasWrong = false;

    // Count InFirstTry depending on it's repetition or not
    // InFirstTry means that user had given wrong answer at least once
    if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
        !hasRepetitionBegun) {
      // Pure InFirstTry count
      inFirstTry++;
    } else if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
        hasRepetitionBegun) {
      // InFirstTry but it's on revision
      inRepetitionFirstTry++;
    }

    progressBar.updateProgress(
        questionsNumber, inFirstTry + inRepetitionFirstTry);

    // Jump to next process
    _afterSummitingCorrectness();
  }

  /// Once pressing "my answer was wrong" button during "don't type answer" process
  /// It looks similar to onSummit method
  void onWasWrong() {
    // Check if the current sequence is "Answer"
    // Unless, exit method to prevent from unexpected animation and sequencing
    if (checkIsNotSequence(Sequence.answer)) return;

    // Make sure that answer was wrong
    wasWrong = true;

    // The given answer was wrong so the corresponding word will be
    // added into list and only if it's first time
    // For that it'll be compared if current word doesn't exist in the list
    if (!listOfWrongs.contains(listOfQuestions[count - 1])) {
      listOfWrongs.add(listOfQuestions[count - 1]);
    }

    setState(() {});

    // Jump to next process
    _afterSummitingCorrectness();
  }

  // TODO Add comments
  /// Once the answer was wrong, make next card containing same word as before
  void repeatWord() {
    int index = count - 1;

    // Question part
    isOddTHCard
        ? questionCard2.setDisplayWordAndExample(
            newWord: listOfQuestions[index].word1,
            newExample: listOfQuestions[index].example1 ?? "",
          )
        : questionCard.setDisplayWordAndExample(
            newWord: listOfQuestions[index].word1,
            newExample: listOfQuestions[index].example1 ?? "",
          );

    // Answer part
    isOddTHCard
        ? answerCard2.setDisplayWordAndExample(
            newWord: listOfQuestions[index].word2,
            newExample: listOfQuestions[index].example2 ?? "",
          )
        : answerCard.setDisplayWordAndExample(
            newWord: listOfQuestions[index].word2,
            newExample: listOfQuestions[index].example2 ?? "",
          );

    if (!hasRepetitionBegun) wrongAnswers++;
    absoluteProgress++;
    if (hasRepetitionBegun) absoluteRepetitionProgress++;
    setState(() {});
  }

  // TODO Add comments
  /// Once answer was correct, make next card containing next word in the list
  void makeNextWord() {
    try {
      if (kDebugMode) {
        print("=======making new word========");
        print("Question part");
        print(">> ${listOfQuestions[count].word1}");
        print(">> ${listOfQuestions[count].example1}");
        print("Answer part");
        print(">> ${listOfQuestions[count].word2}");
        print(">> ${listOfQuestions[count].example2}");
      }

      isOddTHCard
          ? questionCard2.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word1,
              newExample: listOfQuestions[count].example1 ?? "",
            )
          : questionCard.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word1,
              newExample: listOfQuestions[count].example1 ?? "",
            );

      isOddTHCard
          ? answerCard2.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word2,
              newExample: listOfQuestions[count].example2 ?? "",
            )
          : answerCard.setDisplayWordAndExample(
              newWord: listOfQuestions[count].word2,
              newExample: listOfQuestions[count].example2 ?? "",
            );
    } catch (e) {
      if (kDebugMode) {
        print("It's most likely that you're done!");
        print("Congratulations!!!");
        print("To finish, press continue");
      }
    }

    count++;
    absoluteProgress++;
    if (!hasRepetitionBegun) originalProgress++;
    if (hasRepetitionBegun) absoluteRepetitionProgress++;
    if (hasRepetitionBegun) repetitionProgress++;

    if (kDebugMode) {
      print(
          "Next step index + 1 : $count, and is current step 2n+1 : $isOddTHCard");
    }

    setState(() {});
  }

  /// Show next cards by disposing (making invisible)
  /// previous cards and making next card appeared and
  /// play tts immediately if it exists
  void showNext() {
    // Check if the current sequence is Answer
    if (checkIsNotSequence(Sequence.answer)) return;

    // Animate cards of disappear
    onDisposalStarted();

    // Before executing "NextShowing" process, consider if it's unnecessary to
    // execute when the session is done.
    if (isDone) {
      // TODO Improve resulting system

      if (kDebugMode) {
        print("===============================================");
        print("===============================================");
        print("Result :");
        print(">> Number of all sessions : $absoluteProgress");
        print(">> Number of all words : $originalProgress");
        print(
            ">> Number of wrong answers in first try given (overlap-able) : $wrongAnswers");
        print(
            ">> Number of all sessions during repetition : $absoluteRepetitionProgress");
        print(
            ">> Number of all repeated words (overlap-able) : $repetitionProgress");
        print(">> In first try : $inFirstTry");
      }

      // Reset every lists of session to prevent unexpected cases of next session.
      listOfQuestions = [];
      listOfWrongs = [];

      // Reset all timers
      disposalTimer.cancel();
      transitionTimer.cancel();

      // Reset session data
      SessionSaver.session = SessionDataModel(existSessionData: false);

      // Display the result of the quiz by pushing user to ResultScreen screen.
      Navigator.pushNamed(
        context,
        ResultScreen.routeName,
        arguments: ResultScreenArguments(
            questionsNumber, inFirstTry / questionsNumber),
      );
      return; // In this line, the quiz is finished
    }

    // Make input checker box disappear
    if (!bDontTypeAnswer) {
      inputCheckerBox.animTrigger(CheckerBoxState.disappear);
    }

    // Dispose and appear cards (depending on isOddTHCard)
    if (isOddTHCard) {
      // Change sequence of Cards
      questionCard.sequence = Sequence.disappear;
      answerCard.sequence = Sequence.disappear;

      // Animate cards
      questionCard.animDisappear();
      answerCard.animDisappear();
      questionCard2.animAppear();

      // Move answer card
      onTransitionStarted();

      // Play TTS : Deactivated
      //questionCard2.wordTTS.play();
    } else {
      // Change sequence of Cards
      questionCard2.sequence = Sequence.disappear;
      answerCard2.sequence = Sequence.disappear;

      // Animate cards
      questionCard2.animDisappear();
      answerCard2.animDisappear();
      questionCard.animAppear();

      // Move answer card
      onTransitionStarted();

      // Play TTS : Deactivated
      //questionCard.wordTTS.play();
    }

    // Set values to current state for next step
    isOddTHCard = !isOddTHCard;
    isShowingAnswer = false;
    setState(() {});

    // After all, save the current session
    saveSession();
  }

  /// Make list for revision
  void generateExtension() {
    if (kDebugMode) {
      print("================================");
      print("Generate extension");
    }

    // Make sure that revision has begun and initialize progress values
    hasRepetitionBegun = true;
    if (repetitionProgress == 0) repetitionProgress = 1;
    if (absoluteRepetitionProgress == 0) absoluteRepetitionProgress = 1;

    // Initially, shuffle list of words to revise
    listOfWrongs.shuffle();

    // Print revising words for debug
    if (kDebugMode) {
      for (WordPair pair in listOfWrongs) {
        print("New extension : ${pair.word1}");
      }
    }

    // Add every wrong answers to queue
    for (WordPair word in listOfWrongs) {
      listOfQuestions.add(word);
    }

    // Reset wrong answer list
    listOfWrongs = [];

    // Add stage count
    stageCount += 1;
  }

  /// Check if the answer was correctly given
  bool isAnswerCorrect(String answer) {
    // TODO implement correction detection system

    if (kDebugMode) {
      print("======================================");
      print("Given answer : $answer");
      print("Given question : ${listOfQuestions[count - 1].word1}");
      print("Correct answer : ${listOfQuestions[count - 1].word2}");
      print("======================================");
    }

    var given = answer;
    var correct = listOfQuestions[count - 1].word2;

    // optional
    const bIgnoreCase = true;

    if (bIgnoreCase) {
      given = given.toLowerCase();
      correct = correct.toLowerCase();
      if (kDebugMode) {
        print("======================================");
        print("Given : $given");
        print("Correct : $correct");
      }
    }

    late int minOpeningBracketIndex;
    late int maxClosingBracketIndex;
    if (given.contains('[') && given.contains(']')) {
      minOpeningBracketIndex = given.indexOf('[');
      maxClosingBracketIndex = given.lastIndexOf(']');

      if (minOpeningBracketIndex < maxClosingBracketIndex) {
        given = given.replaceRange(
            minOpeningBracketIndex, maxClosingBracketIndex + 1, "");
      }

      if (kDebugMode) {
        print("======================================");
        print("Given : $given");
        print("Correct : $correct");
      }
    }

    if (correct.contains('[') && correct.contains(']')) {
      minOpeningBracketIndex = correct.indexOf('[');
      maxClosingBracketIndex = correct.lastIndexOf(']');

      if (minOpeningBracketIndex < maxClosingBracketIndex) {
        correct = correct.replaceRange(
            minOpeningBracketIndex, maxClosingBracketIndex + 1, "");
      }

      if (kDebugMode) {
        print("======================================");
        print("Given : $given");
        print("Correct : $correct");
      }
    }

    if (!given.contains('(') && !given.contains(')')) {
      if (kDebugMode) {
        print("======================================");
        print("Input doesn't have brackets");
      }
      minOpeningBracketIndex = correct.indexOf('(');
      maxClosingBracketIndex = correct.lastIndexOf(')');

      if (kDebugMode) {
        print("======================================");
        print("minOpeningBracketIndex : $minOpeningBracketIndex");
        print("maxClosingBracketIndex : $maxClosingBracketIndex");
      }

      if (minOpeningBracketIndex < maxClosingBracketIndex) {
        correct = correct.replaceRange(
            minOpeningBracketIndex, maxClosingBracketIndex + 1, '');

        if (kDebugMode) {
          print("======================================");
          print("correct : $correct");
        }
      }

      if (kDebugMode) {
        print("======================================");
        print("Given : $given");
        print("Correct : $correct");
      }
    }

    bool bContainSeparator = given.contains(';');
    if (bContainSeparator) {
      given = given.replaceAll(";", "/");
    }

    bContainSeparator = correct.contains(';');
    if (bContainSeparator) {
      correct = correct.replaceAll(";", "/");
    }

    if (kDebugMode) {
      print("======================================");
      print("Given : $given");
      print("Correct : $correct");
    }

    if (given.startsWith(" ")) given = given.trimLeft();
    if (given.endsWith(" ")) given = given.trimRight();
    if (correct.startsWith(" ")) correct = correct.trimLeft();
    if (correct.endsWith(" ")) correct = correct.trimRight();

    if (kDebugMode) {
      print("======================================");
      print("Given : $given");
      print("Correct : $correct");
    }

    bool bEqual = given == correct;
    return bEqual;
  }

  /// Update stored data for input TextBox
  void updateInputValue(String newInputValue) => inputValue = newInputValue;

  /// Check current sequence for multi purpose
  bool checkIsNotSequence(Sequence desired) {
    late bool trigger;
    Sequence requiredSequence = desired;
    // Check if sequence both of current cards aren't desired sequence
    if (isOddTHCard) {
      trigger = questionCard.sequence != requiredSequence &&
          answerCard.sequence != requiredSequence;
    } else {
      trigger = questionCard2.sequence != requiredSequence &&
          answerCard2.sequence != requiredSequence;
    }
    return trigger;
  }

  // Transition : Appearance of cards from bottom to top
  /// Body of transition timer
  void _onTransitionTick(Timer transitionTimer) {
    // Check if current process is Sequence.appear so that AnswerCard teleports
    // to behind of the QuestionCard. Card to move is chosen depending on isOddTHCard,
    // which means the stage is either 1st, 3rd, 5th... or 2nd, 4th, 6th...
    if (isOddTHCard
        ? questionCard.sequence == Sequence.appear
        : questionCard2.sequence == Sequence.appear) {
      setState(() {
        // Answer card is placed into center
        isOddTHCard ? answerCard.resetCenter() : answerCard2.resetCenter();
        transitionTimer.cancel(); // Stop the timer
      });
    } else {
      if (!isDone) {
        setState(() {});
      } else {
        transitionTimer.cancel();
      }
    }
  }

  /// Trigger of transition Timer
  void onTransitionStarted() {
    transitionTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      _onTransitionTick,
    );
  }

  /// Once user has submitted whether his/her answer was correct or not
  /// It looks similar to onSummit method
  void _afterSummitingCorrectness() {
    // Reset input
    fieldText.clear();

    // Print some values to check for debug
    if (kDebugMode) {
      print("================================");
      print("Printing wrong answers");
      print("================================");

      for (WordPair pair in listOfWrongs) {
        print(pair.word2);
      }
      print("================================");

      print("Some conditions ======================");
      print("Is done : ${count >= listOfQuestions.length}");
      print(">> To Compare : length ${listOfQuestions.length} // count $count");
      print("Has been wrong : ${listOfWrongs.isNotEmpty}");
      print("Was just correct : ${!wasWrong}");
    }

    // Check whether current stage is over
    if (count >= listOfQuestions.length) {
      // If current session is done, check whether revision should take place or not
      // For revision, new list will be generated according to listOfWrongs
      // Unless, isDone will be set to true to finish the session
      if (listOfWrongs.isNotEmpty) {
        generateExtension();
      } else {
        isDone = true;
      }
    }
    // Whatever the answer was, execute the next step
    makeNextWord();

    // Since showing next step should take place immediately after (not by "continue" button)
    // getting the correctness, a bit delay will be given
    Future.delayed(const Duration(milliseconds: 100), () => showNext());
  }

  // Disposal : Resetting previous cards into initial state
  /// Body of disposal timer
  void _onDisposalTick(Timer disposalTimer) {
    // Check if current process is Sequence.hidden so that Cards teleport
    // to initial location (bottom). Card to move is chosen depending on isOddTHCard,
    // which means the stage is either 1st, 3rd, 5th... or 2nd, 4th, 6th...
    if (isOddTHCard
        ? questionCard2.sequence == Sequence.hidden
        : questionCard.sequence == Sequence.hidden) {
      setState(() {
        // Corresponding cards are placed into initial location (bottom)
        isOddTHCard ? answerCard2.reset() : answerCard.reset();
        isOddTHCard ? questionCard2.reset() : questionCard.reset();
        disposalTimer.cancel(); // Stop the timer
      });
    }
  }

  /// Trigger of transition Timer
  void onDisposalStarted() {
    disposalTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      _onDisposalTick,
    );
  }

  void saveSession() {
    session = SessionDataModel(
      existSessionData: true,
      language1: language1,
      absoluteProgress: absoluteProgress,
      absoluteRepetitionProgress: absoluteRepetitionProgress,
      count: count,
      hasRepetitionBegun: hasRepetitionBegun,
      inFirstTry: inFirstTry,
      inRepetitionFirstTry: inRepetitionFirstTry,
      isOddTHCard: isOddTHCard,
      language2: language2,
      listOfQuestions: listOfQuestions,
      listOfWrongs: listOfWrongs,
      originalProgress: originalProgress,
      questionsNumber: questionsNumber,
      repetitionProgress: repetitionProgress,
      stageCount: stageCount,
      wrongAnswers: wrongAnswers,
    );
    SessionSaver.session = session;
  }

  @override
  void initState() {
    super.initState();

    // Initialise every variables
    absoluteProgress = 1;
    originalProgress = 1;
    wrongAnswers = 0;
    absoluteRepetitionProgress = 0;
    repetitionProgress = 0;
    hasRepetitionBegun = false;
    inFirstTry = 0;
    inRepetitionFirstTry = 0;
    stageCount = 1;

    count = 1;
    listOfWrongs = [];
    listOfQuestions = widget.wordPack;
    questionsNumber = listOfQuestions.length;

    // Create language variable to handle
    language1 = widget.language1;
    language2 = widget.language2;

    // Initialise some logic states and run first animation
    isOddTHCard = true;
    isShowingAnswer = false;

    session = widget.sessionData;
    if (session.existSessionData) {
      if (kDebugMode) {
        print("=============================");
        print("Restarting session...");
        session.printData();
      }
      listOfQuestions = session.listOfQuestions!;
      listOfWrongs = session.listOfWrongs!;
      count = session.count!;
      questionsNumber = session.questionsNumber!;
      language1 = session.language1!;
      language2 = session.language2!;
      isOddTHCard = session.isOddTHCard!;
      absoluteProgress = session.absoluteProgress!;
      originalProgress = session.originalProgress!;
      wrongAnswers = session.wrongAnswers!;
      absoluteRepetitionProgress = session.absoluteRepetitionProgress!;
      repetitionProgress = session.repetitionProgress!;
      hasRepetitionBegun = session.hasRepetitionBegun!;
      inFirstTry = session.inFirstTry!;
      inRepetitionFirstTry = session.inRepetitionFirstTry!;
      stageCount = session.stageCount!;
    } else {
      // Shuffle questions and update length of questions
      listOfQuestions.shuffle();
    }

    // Print subject information
    if (kDebugMode) {
      print("listOfQuestions : ${listOfQuestions.length}");
      for (WordPair str in listOfQuestions) {
        print(str.word1);
      }

      print("languages : ");
      print(language1);
      print(language2);
    }

    var count4first = isOddTHCard ? count - 1 : count;
    var count4second = isOddTHCard ? count : count - 1;

    if(count == listOfQuestions.length) {
      count4first = count - 1;
      count4second = count - 1;
    }

    // Initialise 4 cards for test
    questionCard = WordCard(
      isQuestion: true,
      isOddTHCard: isOddTHCard,
      word: listOfQuestions[count4first].word1,
      example: listOfQuestions[count4first].example1 ?? "",
      language: language1,
    );

    answerCard = WordCard(
      isQuestion: false,
      isOddTHCard: isOddTHCard,
      word: listOfQuestions[count4first].word2,
      example: listOfQuestions[count4first].example2 ?? "",
      language: language2,
    );

    questionCard2 = WordCard(
      isQuestion: true,
      isOddTHCard: !isOddTHCard,
      word: listOfQuestions[count4second].word1,
      example: listOfQuestions[count4second].example1 ?? "",
      language: language1,
    );

    answerCard2 = WordCard(
      isQuestion: false,
      isOddTHCard: !isOddTHCard,
      word: listOfQuestions[count4second].word2,
      example: listOfQuestions[count4second].example2 ?? "",
      language: language2,
    );

    answerCard.sequence = Sequence.hidden;
    questionCard.sequence = Sequence.hidden;
    answerCard2.sequence = Sequence.hidden;
    questionCard2.sequence = Sequence.hidden;

    inputCheckerBox = InputCheckerBox(
      color: Colors.white,
      text: "Nothing is here...",
    );

    // Initialise Stack Component
    cardStack = Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        answerCard,
        questionCard,
        answerCard2,
        questionCard2,
        inputCheckerBox,
      ],
    );

    progressBar = ProgressBar(
        total: questionsNumber, progress: inFirstTry + inRepetitionFirstTry);

    onTransitionStarted();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          elevation: 0,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /*ProgressBar(
              progress: inFirstTry + inRepetitionFirstTry,
              total: questionsNumber),*/
          progressBar,
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Stack(
              children: [
                cardStack,
                if (!isShowingAnswer)
                  Transform.translate(
                    offset: const Offset(10, -10),
                    child: Opacity(
                      opacity: 0.8,
                      child: FloatingActionButton(
                        onPressed: () {
                          bDontTypeAnswer = !bDontTypeAnswer;
                          setState(() {});
                        },
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(
                          !bDontTypeAnswer
                              ? Icons.control_point_outlined
                              : Icons.keyboard_alt_outlined,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              if (!isShowingAnswer) {
                if (bDontTypeAnswer) {
                  return GestureDetector(
                    onTap: showAnswerOnly,
                    child: ContinueButton(
                      color: Theme.of(context).cardColor,
                      correctState: CorrectState.correct,
                      text: "Reveal answer",
                    ),
                  );
                } else {
                  return InputBox(
                    answer: listOfQuestions[count - 1].word2,
                    fieldText: fieldText,
                    onSummit: onSummit,
                    onSummitByButton: onSummitByButton,
                    updateInputValue: updateInputValue,
                    showHint: listOfWrongs.contains(listOfQuestions[count - 1]),
                  );
                }
              } else {
                if (bDontTypeAnswer) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: onWasWrong,
                        child: const ContinueButton(
                          correctState: CorrectState.both,
                          color: Colors.deepOrangeAccent,
                          text: "revise",
                        ),
                      ),
                      GestureDetector(
                        onTap: onWasCorrect,
                        child: const ContinueButton(
                          correctState: CorrectState.both,
                          color: Colors.green,
                          text: "continue",
                        ),
                      ),
                    ],
                  );
                } else {
                  return ContinueBox(
                    onClicked: showNext,
                    correctState:
                        wasWrong ? CorrectState.wrong : CorrectState.correct,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
