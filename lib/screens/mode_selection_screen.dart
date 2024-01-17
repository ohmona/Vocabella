import 'package:flutter/material.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/models/session_data_model.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/screens/quiz_screen.dart';

import '../managers/data_handle_manager.dart';
import '../models/wordpair_model.dart';

enum QuestionMode {
  normal,
  reverse,
  both,
}

class ModeSelectionScreenParent extends StatelessWidget {
  const ModeSelectionScreenParent({Key? key}) : super(key: key);

  static const routeName = '/mode';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as ModeSelectionScreenArguments;

    return ModeSelectionScreen(
      subjectData: args.data,
      wordPack: args.wordPack,
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen(
      {super.key, required this.subjectData, required this.wordPack});

  final SubjectDataModel subjectData;
  final List<WordPair> wordPack;

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  QuestionMode mode = QuestionMode.normal;

  void onPressContinue(BuildContext context) {
    final emptySession = SessionDataModel(existSessionData: false);

    if (mode == QuestionMode.normal) {
      Navigator.pushNamed(
        context,
        QuizScreenParent.routeName,
        arguments: QuizScreenArguments(
          widget.wordPack,
          widget.subjectData.languages[0],
          widget.subjectData.languages[1],
          emptySession,
          widget.subjectData.id!,
        ),
      );
    } else if (mode == QuestionMode.reverse) {
      List<WordPair> newList = [];
      for (WordPair wordPair in widget.wordPack) {
        WordPair reversed = WordPair(
          word1: wordPair.word2,
          word2: wordPair.word1,
          example1: wordPair.example2,
          example2: wordPair.example1,
          created: wordPair.created,
          lastEdit: wordPair.lastEdit,
          salt: wordPair.salt,
        );
        newList.add(reversed);
      }

      Navigator.pushNamed(
        context,
        QuizScreenParent.routeName,
        arguments: QuizScreenArguments(
          newList,
          widget.subjectData.languages[1],
          widget.subjectData.languages[0],
          emptySession,
          widget.subjectData.id!,
        ),
      );
    } else if (mode == QuestionMode.both) {
      if (widget.subjectData.languages[0] == widget.subjectData.languages[1]) {
        List<WordPair> newList = [];
        newList.addAll(widget.wordPack);
        for (WordPair wordPair in widget.wordPack) {
          WordPair reversed = WordPair(
            word1: wordPair.word2,
            word2: wordPair.word1,
            example1: wordPair.example2,
            example2: wordPair.example1,
            created: wordPair.created,
            lastEdit: wordPair.lastEdit,
            salt: wordPair.salt,
          );
          newList.add(reversed);
        }

        Navigator.pushNamed(
          context,
          QuizScreenParent.routeName,
          arguments: QuizScreenArguments(
            newList,
            widget.subjectData.languages[0],
            widget.subjectData.languages[1],
            emptySession,
            widget.subjectData.id!,
          ),
        );
      } else {
        sendToastMessage(
          context: context,
          msg:
              "You can only do 'both' mode when the asking language is same as the answering language",
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm your exercise'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: bgGradient,
        ),
        child: Builder(builder: (context) {
          if (isPortraitMode(width: width, height: height)) {
            return Column(
              children: [
                SizedBox(
                  height: height * 0.6,
                  child: Row(
                    children: [
                      SizedBox(
                        width: width * 0.3,
                        height: height * 0.6,
                        child: buildModeButtons(width, height),
                      ),
                      buildThumbnail(width * 0.7, height * 0.6),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                buildInfoText(),
                buildPlayButton(context, width * 0.34),
              ],
            );
          } else {
            return Row(
              children: [
                SizedBox(
                  width: width * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width * 0.7,
                        height: height * 0.3,
                        child: buildModeButtons(width, height),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildPlayButton(context, width * 0.25),
                          Column(
                            children: [
                              buildInfoText(),
                              SizedBox(
                                height: height * 0.05,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildThumbnail(width * 0.3, height * 0.85),
              ],
            );
          }
        }),
      ),
    );
  }

  Row buildPlayButton(BuildContext context, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            onPressContinue(context);
          },
          child: Container(
            margin: const EdgeInsets.all(30),
            height: width,
            width: width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_right,
              color: Colors.black,
              size: 100,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row buildInfoText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.subjectData.title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            Text(
              "Total ${widget.wordPack.length} words of ${widget.subjectData.getWordCount()} words",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Column buildThumbnail(double width, double height) {
    return Column(
      children: [
        FutureBuilder(
          future: DataReadWriteManager.loadExistingImage(
              widget.subjectData.thumb ?? ""),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: width,
                height: height,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 1,
                      color: Colors.white,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image(
                  image: FileImage(snapshot.data!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    const Image dummyImage = Image(
                      image: AssetImage('assets/400x400.jpg'),
                      width: 300,
                      fit: BoxFit.cover,
                    );
                    return dummyImage;
                  },
                ),
              );
            }
            return Image(
              image: const AssetImage("assets/400x400.jpg"),
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
          },
        ),
      ],
    );
  }

  void switchMode() {
    switch (mode) {
      case QuestionMode.normal:
        mode = QuestionMode.reverse;
        break;
      case QuestionMode.reverse:
        mode = QuestionMode.both;
        break;
      case QuestionMode.both:
        mode = QuestionMode.normal;
        break;
    }
    setState(() {});
  }

  Widget buildModeButtons(double width, double height) {
    if (isPortraitMode(width: width, height: height)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: buildButtons(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: buildButtons(),
      );
    }
  }

  List<Widget> buildButtons() {
    if (mode == QuestionMode.normal) {
      return [
        InfoButton(
          icon: Icons.language,
          text: "Mode",
          onTap: switchMode,
        ),
        InfoButton(
          icon: Icons.question_mark,
          text: widget.subjectData.subjects[0],
          onTap: () {},
        ),
        InfoButton(
          icon: Icons.question_answer_outlined,
          text: widget.subjectData.subjects[1],
          onTap: () {},
        ),
      ];
    } else if (mode == QuestionMode.reverse) {
      return [
        InfoButton(
          icon: Icons.change_circle_outlined,
          text: "Mode",
          onTap: switchMode,
        ),
        InfoButton(
          icon: Icons.question_answer_outlined,
          text: widget.subjectData.subjects[0],
          onTap: () {},
        ),
        InfoButton(
          icon: Icons.question_mark,
          text: widget.subjectData.subjects[1],
          onTap: () {},
        ),
      ];
    } else {
      return [
        InfoButton(
          icon: Icons.all_inclusive,
          text: "Mode",
          onTap: switchMode,
        ),
        InfoButton(
          icon: Icons.question_answer,
          text: widget.subjectData.subjects[0],
          onTap: () {},
        ),
        InfoButton(
          icon: Icons.question_answer,
          text: widget.subjectData.subjects[1],
          onTap: () {},
        ),
      ];
    }
  }
}

class InfoButton extends StatelessWidget {
  const InfoButton(
      {Key? key, required this.icon, required this.text, required this.onTap})
      : super(key: key);

  final IconData icon;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
