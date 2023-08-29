import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/constants.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/widgets/chapter_selection_drawer_widget.dart';
import 'package:vocabella/widgets/editor_screen_appbar_widget.dart';
import 'package:vocabella/widgets/language_bar_widget.dart';

import 'package:vocabella/widgets/word_grid_tile_widget.dart';

import '../managers/data_handle_manager.dart';
import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

class EditorScreenParent extends StatelessWidget {
  const EditorScreenParent({Key? key}) : super(key: key);

  static const routeName = '/edit';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as EditorScreenArguments;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: EditorScreen(
        data: args.data,
        refresh: args.refresh,
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key, required this.data, required this.refresh})
      : super(key: key);

  final SubjectDataModel data;
  final void Function() refresh;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  /// Where the text should be changed
  int? focusedIndex;

  /// 1. Contains data from loaded one
  /// 2. Should be updated once edited
  late SubjectDataModel subjectData;

  /// 1. Enables finding correct path
  /// 2. (later) name will be editable
  late Chapter currentChapter;

  late bool bShowingWords;

  bool bDeleteMode = false;

  ScrollController scrollController = ScrollController();

  TextEditingController textEditingController = TextEditingController();
  FocusNode bottomBarFocusNode = FocusNode();
  FocusNode wordAdderFocusNode = FocusNode();

  late Timer autoSaveTimer;

  /// find the total number of contents
  int getWordsCount() => currentChapter.words.length * 2;

  /// find the correct Chapter
  int getChapterIndexByName(String name) {
    for (var element in subjectData.wordlist) {
      if (element.name == name) {
        return subjectData.wordlist.indexOf(element);
      }
    }
    return -1;
  }

  int getChapterIndex(Chapter chapter) =>
      subjectData.wordlist.indexOf(chapter);

  int getCurrentChapterIndex() => subjectData.wordlist.indexOf(currentChapter);

  /// find the index of desired WordPair by general index
  int getWordPairIndex(int index) => index ~/ 2;

  // check whether the index is targeting a question or an answer
  bool isTargetingQuestion(int index) => index % 2 == 0;

  bool isValidIndex(int index) => index < getWordsCount();

  bool bAddingNewWord = false;

  WordPair wordAdditionBuffer = WordPair(word1: "", word2: "");

  late String textBeforeEdit;

  /// returns the text of targeting index
  String getTextOf(int index) {
    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

    WordPair target;
    if (isValidIndex(index)) {
      target = currentChapter.words[wordPairIndex];
    } else if (bAddingNewWord) {
      print("=============================");
      print(wordAdditionBuffer.word1);
      print(wordAdditionBuffer.word2);
      target = wordAdditionBuffer;
    } else {
      return "";
    }

    if (bShowingWords) {
      if (bQuestionTargeting) return target.word1;
      if (!bQuestionTargeting) return target.word2;
    } else {
      if (bQuestionTargeting) return target.example1 ?? "";
      if (!bQuestionTargeting) return target.example2 ?? "";
    }

    return "";
  }

  /// get the name of desired chapter
  String getChapterName(int index) => subjectData.wordlist[index].name;

  /// updates the text of targeting index
  void updateWord(String newText, int index) {
    /* About how the index here means :
    *  Let's imagine that words from the SubjectDataModel is placed into table
    *  just like the view. Then we count grids from left-top to right-bottom.
    *  The order of grids is meant to be this index
    */

    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

    if (!bAddingNewWord) {
      // copy the targeting WordPair
      WordPair target = currentChapter.words[wordPairIndex];

      // check whether words should be changed or examples
      if (bShowingWords) {
        // change then depending on its index
        if (bQuestionTargeting) target.word1 = newText;
        if (!bQuestionTargeting) target.word2 = newText;
      } else {
        // change then depending on its index
        if (bQuestionTargeting) target.example1 = newText;
        if (!bQuestionTargeting) target.example2 = newText;
      }

      // apply to actual data
      currentChapter.words[wordPairIndex] = target;
    } else {
      if (bQuestionTargeting) {
        wordAdditionBuffer.word1 = newText;
      } else {
        wordAdditionBuffer.word2 = newText;
      }
    }
  }

  void addWord(WordPair wordPair) {
    currentChapter.wordCount = currentChapter.words.length;
    wordPair.id = currentChapter.wordCount! + 1;
    wordPair.globalId =
        makeWordPairId(id: wordPair.id!, name: currentChapter.name);

    setState(() {
      bool fine = false;
      while (!fine) {
        if (!wordPair.word1.endsWith(" ")) {
          fine = true;
        } else {
          wordPair.word1 =
              wordPair.word1.substring(0, wordPair.word1.length - 1);
        }
      }
      fine = false;
      while (!fine) {
        if (!wordPair.word2.endsWith(" ")) {
          fine = true;
        } else {
          wordPair.word2 =
              wordPair.word2.substring(0, wordPair.word2.length - 1);
        }
      }

      wordPair.printWord();
      currentChapter.words.add(wordPair);
    });
  }

  void removeWord(WordPair wordPair) {
    setState(() {
      int targetIndex = currentChapter.words.indexOf(wordPair);
      currentChapter.words.removeAt(targetIndex);
    });
  }

  void toggleWords() {
    setState(() {
      bDeleteMode = false;
      bShowingWords = !bShowingWords;
      updateWord(getTextOf(focusedIndex!), focusedIndex!);
    });
    textEditingController.text = getTextOf(focusedIndex!);
    changeFocus(focusedIndex!);
  }

  void toggleDeleteMode() {
    setState(() {
      bDeleteMode = !bDeleteMode;
    });
  }

  /// Change selected chapter
  void changeChapter(String newName) {
    // Reset to initial state
    bShowingWords = true;
    bDeleteMode = false;
    focusedIndex = 0;

    if (currentChapter.name == newName) return;

    int oldChapterIndex = getCurrentChapterIndex();
    // Find the index of the desired chapter by its name
    int newChapterIndex = getChapterIndexByName(newName);

    // Check if the new chapter is found
    if (newChapterIndex != -1) {
      setState(() {
        // Save changes of the current chapter into subject data
        subjectData.wordlist[getCurrentChapterIndex()] = currentChapter;

        // Load the desired chapter from subject data
        currentChapter = subjectData.wordlist[newChapterIndex];
      });
    }

    if (oldChapterIndex != -1) {
      // Remove chapter if the list is empty
      if (subjectData.wordlist[oldChapterIndex].words.isEmpty) {
        setState(() {
          subjectData.wordlist.removeAt(oldChapterIndex);
        });
      }
    }
  }

  void addChapter(String newName) {
    if(existChapterNameAlready(newName)) {
      return;
    }

    setState(() {
      List<WordPair> words = [
        WordPair(word1: "Type your word", word2: "Type your word")
      ];
      Chapter newChapter = Chapter(
        name: newName,
        words: words,
        id: subjectData.chapterCount + 1,
      );
      subjectData.chapterCount += 1;
      newChapter.wordCount = 1;
      subjectData.wordlist.add(newChapter);
    });
    changeChapter(newName);
  }

  /// Change subject name and language
  void changeSubject({
    required String newSubject,
    required String newLanguage,
    required int index,
  }) {
    if (index == 0 || index == 1) {
      setState(() {
        subjectData.subjects[index] = newSubject;
        subjectData.languages[index] = newLanguage;
      });
    }
  }

  bool ableToSave() {
    return true;
  }

  /// Save all data to local storage
  void saveData() {
    if (focusedIndex == null) return;

    if (ableToSave()) {
      for (SubjectDataModel sub in SubjectDataModel.subjectList) {
        // Find the correct data
        if (sub.id == subjectData.id) {
          // Find the index of the subject
          int index = SubjectDataModel.subjectList.indexOf(sub);
          // Then replace the data with the edited one
          SubjectDataModel.subjectList[index] = subjectData;
        }

        // Finally we have to save data to the local no matter it should be
        DataReadWriteManager.writeData(
            SubjectDataModel.listToJson(SubjectDataModel.subjectList));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "saving failed",
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          elevation: 10,
        ),
      );
    }
  }

  void terminateWordAddition() {
    bAddingNewWord = false;
    if (wordAdditionBuffer.word1.isNotEmpty &&
        wordAdditionBuffer.word2.isNotEmpty) {
      addWord(wordAdditionBuffer);
      saveData();
    }

    wordAdditionBuffer = WordPair(word1: "", word2: "");
  }

  void changeFocus(int newIndex) {
    // Make sure that user doesn't make silly issue
    if (newIndex >= getWordsCount() + 2) return;
    if (!isValidIndex(newIndex) && !bShowingWords) return;

    if (focusedIndex != null) {
      if (getTextOf(focusedIndex!).isEmpty && bShowingWords) {
        updateWord(textBeforeEdit, focusedIndex!);
      }
    }

    // Word addition begins here
    if (!bAddingNewWord && !isValidIndex(newIndex)) {
      bAddingNewWord = true;
      wordAdditionBuffer = WordPair(word1: "", word2: "");
    }

    if (bAddingNewWord && isValidIndex(newIndex)) {
      terminateWordAddition();
    }

    setState(() {
      focusedIndex = newIndex;
      textEditingController.text = getTextOf(newIndex);
      bottomBarFocusNode.requestFocus();
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
      textBeforeEdit = getTextOf(newIndex);
    });
  }

  void scrollToFocus() {
    int currentPosition = scrollController.position.pixels.toInt();
    int targetPosition = ((focusedIndex! / ~2) * 60).toInt();

    int minRange = currentPosition;
    int maxRange = currentPosition + 12 * 60;

    if (targetPosition < minRange && targetPosition > maxRange) {
      scrollController.animateTo(targetPosition.toDouble(),
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  void changeThumbnail(String path) {
    setState(() {
      subjectData.thumb = path;
    });
    saveData();
  }

  void changeSubjectName(String newName) {
    setState(() {
      subjectData.title = newName;
    });
    saveData();
  }

  void changeChapterName(String newName) {
    setState(() {
      currentChapter.name = newName;
      for (var element in currentChapter.words) {
        element.updateGlobalId(newName);
      }

      changeChapter(newName);
    });
    saveData();
  }

  void scrollToFocused() {
    double fi = focusedIndex! / 2;
    int fii = fi.toInt();

    var targetOffset = fii * 56.0;

    if (fii > (getWordsCount() / 2) - 3) {
      targetOffset = targetOffset - 56 * 3;
    }

    scrollController.jumpTo(targetOffset);
  }

  void reorderChapter(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item =
      subjectData.wordlist.removeAt(oldIndex);
      subjectData.wordlist.insert(newIndex, item);
    });
  }

  bool existChapterNameAlready(String name) {
    for (var element in subjectData.wordlist) {
      if(element.name == name) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    bottomBarFocusNode.dispose();
    autoSaveTimer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // copy the data which is going to be edited
    subjectData = widget.data;

    // initialize some values
    currentChapter = subjectData.wordlist[0];
    bShowingWords = true;
    focusedIndex = 0;

    textBeforeEdit = getTextOf(focusedIndex!);

    // activate auto-save
    autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      saveData();
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "auto saving...",
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          elevation: 10,
        ),
      );*/
    });
  }

  @override
  Widget build(BuildContext context) {
    if (focusedIndex != null) {
      textEditingController.text = getTextOf(focusedIndex!);
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
    }

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
      drawer: ChapterSelectionDrawer(
        changeChapter: changeChapter,
        currentChapterIndex: getCurrentChapterIndex(),
        getChapterName: getChapterName,
        subjectData: subjectData,
        addChapter: addChapter,
        saveData: saveData,
        changeThumbnail: changeThumbnail,
        changeSubjectName: changeSubjectName,
        reorderChapter: reorderChapter,
        existChapterNameAlready: existChapterNameAlready,
      ),
      body: WillPopScope(
        onWillPop: () async {
          widget.refresh();
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 105,
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: (getWordsCount() / 2 + 1).toInt(),
                          dragStartBehavior: DragStartBehavior.start,
                          onReorder: (oldIndex, newIndex) {
                            final maxIndex = getWordsCount() ~/ 2;
                            final currentIndexNormalized = focusedIndex! ~/ 2;

                            if(oldIndex >= maxIndex || newIndex > maxIndex) {
                              return;
                            }

                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final item =
                                  currentChapter.words.removeAt(oldIndex);
                              currentChapter.words.insert(newIndex, item);
                              currentChapter.updateAllId();

                              if(oldIndex == currentIndexNormalized) {
                                focusedIndex = isTargetingQuestion(focusedIndex!) ?
                                    newIndex * 2 :
                                    newIndex * 2 + 1;
                              }
                              else if(currentIndexNormalized < oldIndex) {
                                if(currentIndexNormalized >= newIndex) {
                                  focusedIndex = focusedIndex! + 2;
                                }
                              }
                              else if(currentIndexNormalized > oldIndex) {
                                if(currentIndexNormalized <= newIndex) {
                                  focusedIndex = focusedIndex! - 2;
                                }
                              }
                            });
                          },
                          itemBuilder: ((context, index) {
                            bool bValid = index < getWordsCount() ~/ 2 + 1;
                            final displayingText1 =
                                bValid ? getTextOf(2 * index) : "";
                            final displayingText2 =
                                bValid ? getTextOf(2 * index + 1) : "";

                            return Row(
                              key: Key("$index"),
                              children: [
                                WordGridTile(
                                  text: displayingText1,
                                  index: 2 * index,
                                  saveText: updateWord,
                                  bShowingWords: bShowingWords,
                                  currentChapter: currentChapter,
                                  addWord: addWord,
                                  bDeleteMode: bDeleteMode,
                                  deleteWord: removeWord,
                                  changeFocus: changeFocus,
                                  bFocused: 2 * index == focusedIndex,
                                  wordAdditionBuffer: wordAdditionBuffer,
                                ),
                                WordGridTile(
                                  text: displayingText2,
                                  index: 2 * index + 1,
                                  saveText: updateWord,
                                  bShowingWords: bShowingWords,
                                  currentChapter: currentChapter,
                                  addWord: addWord,
                                  bDeleteMode: bDeleteMode,
                                  deleteWord: removeWord,
                                  changeFocus: changeFocus,
                                  bFocused: 2 * index + 1 == focusedIndex,
                                  wordAdditionBuffer: wordAdditionBuffer,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, 60),
                    child: Row(
                      children: [
                        LanguageBar(
                          subjectData: subjectData,
                          index: 0,
                          changeSubject: changeSubject,
                        ),
                        Container(
                          width: 2,
                          height: 50,
                          color: Colors.grey,
                        ),
                        LanguageBar(
                          subjectData: subjectData,
                          index: 1,
                          changeSubject: changeSubject,
                        ),
                      ],
                    ),
                  ),
                  EditorScreenAppbar(
                    currentChapter: currentChapter,
                    bShowingWords: bShowingWords,
                    toggleWords: toggleWords,
                    bDeleteMode: bDeleteMode,
                    toggleDeleteMode: toggleDeleteMode,
                    changeChapterName: changeChapterName,
                  ),
                ],
              ),
            ),
            AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 1),
              child: Container(
                // Input Box Container
                decoration: BoxDecoration(
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      blurStyle: BlurStyle.normal,
                    ),
                  ],
                ),
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(60 * 0.1),
                  child: Container(
                    // Input Box
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Transform.translate(
                      offset: (MediaQuery.of(context).size.height < 600)
                          ? const Offset(0, -6)
                          : const Offset(0, 3),
                      child: TextField(
                        focusNode: bottomBarFocusNode,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          suffixIcon: Transform.translate(
                            offset: (MediaQuery.of(context).size.height < 600)
                                ? const Offset(0, 3)
                                : const Offset(0, 0),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.grey.withOpacity(0.5),
                              onPressed: () {},
                            ),
                          ),
                          prefixIcon: Transform.translate(
                            offset: (MediaQuery.of(context).size.height < 600)
                                ? const Offset(0, 3)
                                : const Offset(0, 0),
                            child: Icon(
                              Icons.keyboard_alt_outlined,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: (MediaQuery.of(context).size.height < 600)
                              ? 12
                              : 16,
                          fontWeight: FontWeight.w400,
                        ),
                        controller: textEditingController,
                        cursorColor: Colors.grey.withOpacity(0.5),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          if (focusedIndex != null) {
                            setState(() {
                              updateWord(value, focusedIndex!);
                            });
                          }
                        },
                        onSubmitted: (value) {
                          if (focusedIndex != null) {
                            if (!bAddingNewWord) {
                              setState(() {
                                updateWord(value, focusedIndex!);
                                textEditingController.text = "";
                                changeFocus(focusedIndex! + 1);
                              });
                            } else {
                              setState(() {
                                updateWord(value, focusedIndex!);
                                textEditingController.text = "";

                                if (wordAdditionBuffer.word1.isNotEmpty &&
                                    wordAdditionBuffer.word2.isNotEmpty) {
                                  terminateWordAddition();
                                  changeFocus(focusedIndex! + 1);
                                  return;
                                }

                                if (isTargetingQuestion(focusedIndex!)) {
                                  if (wordAdditionBuffer.word2.isEmpty ||
                                      wordAdditionBuffer.word1.isNotEmpty) {
                                    changeFocus(focusedIndex! + 1);
                                  } else {
                                    changeFocus(focusedIndex!);
                                  }
                                } else {
                                  if (wordAdditionBuffer.word1.isEmpty ||
                                      wordAdditionBuffer.word2.isNotEmpty) {
                                    changeFocus(focusedIndex! - 1);
                                  } else {
                                    changeFocus(focusedIndex!);
                                  }
                                }
                              });
                            }
                          }
                        },
                        onTap: () {
                          scrollToFocused();
                          if (focusedIndex == null) {
                            bottomBarFocusNode.unfocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  double calcRatio(BuildContext context) =>
      (MediaQuery.of(context).size.width / 2) / 50;
}
