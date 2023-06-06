import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/classes.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/widgets/progress_bar_widget.dart';
import 'package:vocabella/widgets/word_card_widget.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';

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
      child: QuizScreen(wordPack: args.wordPack, language1: args.language1, language2 :args.language2),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    Key? key,
    required this.wordPack, required this.language1, required this.language2,
  }) : super(key: key);

  final List<WordPair> wordPack;

  static const routeName = '/quiz';

  final String language1;
  final String language2;
  //TODO make language selectable when it's created

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables about gameplay
  bool bDontTypeAnswer = true;

  // Variables about input
  final fieldText = TextEditingController();
  String inputValue = "";

  // Variables about questions
  int count = 1;
  late List<WordPair> listOfQuestions;
  late List<WordPair> listOfWrongs = [];
  late int questionsNumber;

  // Variables about quiz
  bool wasWrong = false;

  // Cards
  late WordCard questionCard;
  late WordCard answerCard;
  late WordCard questionCard2;
  late WordCard answerCard2;
  late Stack cardStack;

  // Logics
  late bool isOddTHCard;
  late bool isShowingAnswer;
  bool isDone = false;

  // Timer
  late Timer transitionTimer;
  late Timer disposalTimer;

  // Progress
  int absoluteProgress =
      1; // progress of all combined, including wrong answers and extension
  int originalProgress = 1; // progress of original cards
  int wrongAnswers = 0; // number of all wrong answers
  int absoluteRepetitionProgress =
      0; // progress of extension, also wrong answers
  int repetitionProgress = 0; // progress of extension
  bool hasRepetitionBegun = false;
  int inFirstTry = 0;
  int inRepetitionFirstTry = 0;

  bool isAnswerCorrect(String answer) {
    // TODO implement correction detection system
    return answer == listOfQuestions[count - 1].word2;
  }

  // Runs when user gives enter
  void onSummit(String text) {
    print("================================");
    print("Answer summited");
    print("================================");

    showAnswer();

    print("correct one : ${listOfQuestions[count - 1].word2}");
    print("given answer : " + text);
    print("Was Correct? : ${isAnswerCorrect(text)}");
    if (isAnswerCorrect(text)) {
      // Answer was correct
      wasWrong = false;

      if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
          !hasRepetitionBegun) {
        inFirstTry++;
      } else if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
          hasRepetitionBegun) {
        inRepetitionFirstTry++;
      }
    } else {
      // Answer was wrong
      // so we have to put this word at the wrong list
      if (!listOfWrongs.contains(listOfQuestions[count - 1])) {
        listOfWrongs.add(listOfQuestions[count - 1]);
      } else {
        print("You've got wrong again! lol");
      }
      wasWrong = true;
    }
    setState(() {});

    fieldText.clear();

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

    // repeat wrong answers if all words are done, there's at least one wrong answer
    // and session should be continued
    if (count >= listOfQuestions.length &&
        listOfWrongs.isNotEmpty &&
        !wasWrong) {
      generateExtension();
    } else if (count >= listOfQuestions.length &&
        listOfWrongs.isEmpty &&
        !wasWrong) {
      isDone = true;
    }

    wasWrong ? repeatWord() : makeNextWord();
  }

  // Runs when user presses summit button
  void onSummitByButton() {
    onSummit(inputValue);
  }

  // Update stored data for input TextBox
  void updateInputValue(String newInputValue) {
    inputValue = newInputValue;
  }

  void generateExtension() {
    print("================================");
    print("Generate extension");

    hasRepetitionBegun = true;
    if (repetitionProgress == 0) repetitionProgress = 1;
    if (absoluteRepetitionProgress == 0) absoluteRepetitionProgress = 1;

    // shuffle all wrong answers firstly
    listOfWrongs.shuffle();
    for (WordPair pair in listOfWrongs) {
      print("New extension : ${pair.word1}");
    }

    // add every wrong answers to queue
    for (WordPair word in listOfWrongs) {
      listOfQuestions.add(word);
    }

    // reset list of wrong answers
    listOfWrongs = [];
  }

  void showAnswerOnly() {
    print("================================");
    print("Answer showing");
    print("================================");

    showAnswer();
  }

  void onWasWrong() {
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
      return;
    }

    print('Wrong');
    // Answer was wrong
    // so we have to put this word at the wrong list
    if (!listOfWrongs.contains(listOfQuestions[count - 1])) {
      listOfWrongs.add(listOfQuestions[count - 1]);
    } else {
      print("You've got wrong again! lol");
    }
    wasWrong = true;

    _afterSummitingCorrectness();
  }

  void onWasCorrect() {
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
      return;
    }

    print("Correct");
    // Answer was correct
    wasWrong = false;

    if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
        !hasRepetitionBegun) {
      inFirstTry++;
    } else if (!listOfWrongs.contains(listOfQuestions[count - 1]) &&
        hasRepetitionBegun) {
      inRepetitionFirstTry++;
    }

    _afterSummitingCorrectness();
  }

  void _afterSummitingCorrectness() {
    print("after summitting");
    fieldText.clear();

    // repeat wrong answers if all words are done, there's at least one wrong answer
    // and session should be continued
    if (count >= listOfQuestions.length &&
        listOfWrongs.isNotEmpty &&
        !wasWrong) {
      generateExtension();
    } else if (count >= listOfQuestions.length &&
        listOfWrongs.isEmpty &&
        !wasWrong) {
      isDone = true;
    }

    wasWrong ? repeatWord() : makeNextWord();

    Future.delayed(const Duration(milliseconds: 100), () {
      showNext();
    });
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
    if (isDone) {
      // TODO Improve resulting system
      print("===============================================");
      print("===============================================");
      print("Result :");
      print(">> Number of all sessions : ${absoluteProgress}");
      print(">> Number of all words : ${originalProgress}");
      print(
          ">> Number of wrong answers in first try given (overlap-able) : ${wrongAnswers}");
      print(
          ">> Number of all sessions during repetition : ${absoluteRepetitionProgress}");
      print(
          ">> Number of all repeated words (overlap-able) : ${repetitionProgress}");
      print(">> In first try : ${inFirstTry}");

      listOfQuestions = [];
      listOfWrongs = [];

      Navigator.pushNamed(
        context,
        ResultScreen.routeName,
        arguments: ResultScreenArguments(
            questionsNumber, inFirstTry / questionsNumber),
      );
      return;
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

  void repeatWord() {
    int step = count - 1;

    // Question part
    isOddTHCard
        ? questionCard2.setDisplayWordAndExample(
            newWord: listOfQuestions[step].word1,
            newExample: listOfQuestions[step].example1 ?? "",
          )
        : questionCard.setDisplayWordAndExample(
            newWord: listOfQuestions[step].word1,
            newExample: listOfQuestions[step].example1 ?? "",
          );

    // Answer part
    isOddTHCard
        ? answerCard2.setDisplayWordAndExample(
            newWord: listOfQuestions[count - 1].word2,
            newExample: listOfQuestions[count].example2 ?? "",
          )
        : answerCard.setDisplayWordAndExample(
            newWord: listOfQuestions[count - 1].word2,
            newExample: listOfQuestions[count - 1].example2 ?? "",
          );

    if (!hasRepetitionBegun) wrongAnswers++;
    absoluteProgress++;
    if (hasRepetitionBegun) absoluteRepetitionProgress++;
    setState(() {});
  }

  void makeNextWord() {
    try {
      print("=======making new word========");

      print("Question part");
      print(">> ${listOfQuestions[count].word1}");
      print(">> ${listOfQuestions[count].example1}");
      print("Answer part");
      print(">> ${listOfQuestions[count].word2}");
      print(">> ${listOfQuestions[count].example2}");

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
    } catch (e) {
      print("It's most likely that you're done!");
      print("Congratulations!!!");
      print("To finish, press continue");
    }

    count++;
    absoluteProgress++; // basically syncs with count but
    if (!hasRepetitionBegun) originalProgress++; // basically syncs with count
    if (hasRepetitionBegun) absoluteRepetitionProgress++;
    if (hasRepetitionBegun) repetitionProgress++;
    print(
        "Next step index + 1 : $count, and is current step 2n+1 : $isOddTHCard");

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
    questionsNumber = listOfQuestions.length;
    print("listOfQuestions : ${listOfQuestions.length}");
    for (WordPair str in listOfQuestions) print(str.word1);

    print("languages : ");
    print(widget.language1);
    print(widget.language2);

    // Initialise 4 cards for test
    questionCard = WordCard(
      isQuestion: true,
      isOddTHCard: true,
      word: listOfQuestions[0].word1,
      example: listOfQuestions[0].example1 ?? "",
      language: widget.language1,
    );

    answerCard = WordCard(
      isQuestion: false,
      isOddTHCard: true,
      word: listOfQuestions[0].word2,
      example: listOfQuestions[0].example2 ?? "",
      language: widget.language2,
    );

    questionCard2 = WordCard(
      isQuestion: true,
      isOddTHCard: false,
      word: listOfQuestions[1].word1,
      example: listOfQuestions[1].example1 ?? "",
      language: widget.language1,
    );

    answerCard2 = WordCard(
      isQuestion: false,
      isOddTHCard: false,
      word: listOfQuestions[1].word2,
      example: listOfQuestions[1].example2 ?? "",
      language: widget.language2,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProgressBar(
              progress: inFirstTry + inRepetitionFirstTry,
              total: questionsNumber),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Stack(
              children: [
                cardStack,
                if (!isShowingAnswer)
                  Transform.translate(
                    offset: Offset(10, -10),
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
          if (!isShowingAnswer)
            bDontTypeAnswer
                ? GestureDetector(
                    onTap: showAnswerOnly,
                    child: ContinueButton(
                      color: Theme.of(context).cardColor,
                      correctState: CorrectState.correct,
                      text: "Reveal answer",
                    ),
                  )
                : InputBox(
                    answer: listOfQuestions[count - 1].word2,
                    fieldText: fieldText,
                    onSummit: onSummit,
                    onSummitByButton: onSummitByButton,
                    updateInputValue: updateInputValue,
                    showHint: listOfWrongs.contains(listOfQuestions[count - 1]),
                  ),
          if (isShowingAnswer)
            bDontTypeAnswer
                ? Row(
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
                  )
                : ContinueBox(
                    onClicked: showNext,
                    correctState:
                        wasWrong ? CorrectState.wrong : CorrectState.correct,
                  ),
        ],
      ),
    );
  }
}
