import 'package:flutter/material.dart';
import 'package:vocabella/models/event_data_model.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/utils/chrono.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/screens/word_selection_screen.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';
import 'package:vocabella/widgets/session_creator_widget.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

// Reminder, this screen gets subject-data as parameter
// 1. routeName static const routeName = '/chapters';
// 2. args final args = ModalRoute.of(context)!.settings.arguments as ChapterSelectionScreenArguments;
/* To next screen
Navigator.pushNamed(
              context,
              WordSelectionScreen.routeName,
              arguments: WordSelectionScreenArguments(
                chapterList.getChapters(), <- selected chpaters
                args.subject.languages!, <- for tts
              ),
            );
 */
// 3. Should be able to pass selected chapters for the next screen

class ChapterSelectionScreenParent extends StatelessWidget {
  const ChapterSelectionScreenParent({Key? key}) : super(key: key);

  static const routeName = '/chapters';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)!
        .settings
        .arguments
    as ChapterSelectionScreenArguments;

    return ChapterSelectionScreen(subjectData: args.subject);
  }
}

class ChapterSelectionScreen extends StatefulWidget {
  const ChapterSelectionScreen({
    Key? key,
    required this.subjectData,
  }) : super(key: key);

  final SubjectDataModel subjectData;

  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  late Map<int, EditedChapter> selectedChapters; // original index, data

  late final List<Chapter> originalChapters;

  void applyEdit(int originalIndex, List<int> excludedIndex) {
    final bool wasSelected = selectedChapters.containsKey(originalIndex);

    if (excludedIndex.length == originalChapters[originalIndex].words.length) {
      setState(() {
        if (wasSelected) selectedChapters.remove(originalIndex);
      });
      return;
    }

    setState(() {
      if (!wasSelected) {
        selectedChapters[originalIndex] =
            EditedChapter.copyFrom(originalChapters[originalIndex]);
      }

      selectedChapters[originalIndex]!.excludedIndex = excludedIndex;
    });
  }

  void onTileTap(int index) {
    setState(() {
      if (!selectedChapters.containsKey(index)) {
        // if chapter hasn't been selected, add it to selected
        selectedChapters[index] =
            EditedChapter.copyFrom(originalChapters[index]);
      } else {
        selectedChapters.remove(index);
      }
    });
  }

  void onTileHold(int index) {
    setState(() {
      EditedChapter passingChapter =
      EditedChapter.copyFrom(originalChapters[index]);
      if (selectedChapters.containsKey(index)) {
        passingChapter = selectedChapters[index]!;
      }

      final bool selected = selectedChapters.containsKey(index);

      Navigator.pushNamed(
        context,
        WordSelectionScreenParent.routeName,
        arguments: WordSelectionScreenArguments(
          passingChapter,
          selected,
          applyEdit,
          index,
        ),
      );
    });
  }

  int getSelectedWordCount() {
    int count = 0;
    selectedChapters.forEach((key, value) {
      count += value.words.length - value.excludedIndex.length;
    });
    return count;
  }

  List<WordPair> generateWordList() {
    List<WordPair> wordList = [];
    selectedChapters.forEach((key, value) {
      for (int i = 0; i < value.words.length; i++) {
        if (!value.excludedIndex.contains(i)) {
          wordList.add(value.words[i]);
        }
      }
    });
    return wordList;
  }

  void onTapContinue() {
    Navigator.pushNamed(
      context,
      ModeSelectionScreenParent.routeName,
      arguments: ModeSelectionScreenArguments(
          generateWordList(), widget.subjectData.languages, widget.subjectData),
    );
  }

  void onPressSaveSession() {
    showDialog<void>(
        context: context,
        builder: (context) {
          return SessionCreator(wordPack: generateWordList(), subjectData: widget.subjectData);
        }
    );
  }

  @override
  void initState() {
    super.initState();

    originalChapters = widget.subjectData.wordlist;
    selectedChapters = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select practicing chapters"),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [
              firstBgColor.withOpacity(0.3),
              secondBgColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: originalChapters.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery
                      .of(context)
                      .size
                      .width ~/ 150,
                  childAspectRatio: 1 / 1,
                ),
                itemBuilder: (context, index) {
                  bool bSelected = selectedChapters.containsKey(index);

                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        onTileTap(index);
                      },
                      onLongPress: () {
                        onTileHold(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                          color: bSelected
                              ? Color.lerp(
                            firstBgColor,
                            secondBgColor,
                            index / originalChapters.length,
                          )
                              : Color.lerp(
                            firstBgColor.withOpacity(0.3),
                            secondBgColor.withOpacity(0.3),
                            index / originalChapters.length,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: bSelected
                                  ? Color.lerp(
                                firstBgColor,
                                secondBgColor,
                                index / originalChapters.length,
                              )!
                                  : Color.lerp(
                                firstBgColor.withOpacity(0.3),
                                secondBgColor.withOpacity(0.3),
                                index / originalChapters.length,
                              )!,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                originalChapters[index].name,
                                style: TextStyle(
                                  color: bSelected
                                      ? Colors.black
                                      : Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.white,
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            bSelected
                                ? Text(
                              "${originalChapters[index].words.length -
                                  selectedChapters[index]!.excludedIndex
                                      .length} / ${originalChapters[index].words
                                  .length}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                shadows: (selectedChapters[index]!
                                    .excludedIndex
                                    .isEmpty)
                                    ? [
                                  const Shadow(
                                    color: Colors.white,
                                    blurRadius: 15,
                                  ),
                                ]
                                    : [],
                              ),
                            )
                                : Text(
                              "Not selected",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (getSelectedWordCount() >= 3)
              Row(
                children: [
                  GestureDetector(
                    onTap: onPressSaveSession,
                    child: const ContinueButton(
                      color: Colors.orangeAccent,
                      text: "Create Schedule",
                      correctState: CorrectState.both,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTapContinue,
                    child: ContinueButton(
                      color: Colors.green,
                      text:
                      "Continue (${getSelectedWordCount()} words selected) ",
                      correctState: CorrectState.both,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
