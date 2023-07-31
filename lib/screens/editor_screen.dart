import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/arguments.dart';
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
      child: EditorScreen(data: args.data),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key, required this.data}) : super(key: key);

  final SubjectDataModel data;

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
    for (var element in subjectData.wordlist!) {
      if (element.name == name) {
        return subjectData.wordlist!.indexOf(element);
      }
    }
    return -1;
  }

  int getChapterIndex(Chapter chapter) =>
      subjectData.wordlist!.indexOf(chapter);

  int getCurrentChapterIndex() => subjectData.wordlist!.indexOf(currentChapter);

  /// find the index of desired WordPair by general index
  int getWordPairIndex(int index) => index ~/ 2;

  // check whether the index is targeting a question or an answer
  bool isTargetingQuestion(int index) => index % 2 == 0;

  /// returns the text of targeting index
  String getTextOf(int index) {
    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

    WordPair target = currentChapter.words[wordPairIndex];

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
  String getChapterName(int index) => subjectData.wordlist![index].name;

  /// updates the text of targeting index
  void updateWord(String newText, int index) {
    /* About how the index here means :
    *  Let's imagine that words from the SubjectDataModel is placed into table
    *  just like the view. Then we count grids from left-top to right-bottom.
    *  The order of grids is meant to be this index
    */

    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

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
  }

  void addWord(WordPair wordPair) {
    setState(() {
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
    });
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

    if (currentChapter.name == newName) return;

    int oldChapterIndex = getCurrentChapterIndex();
    // Find the index of the desired chapter by its name
    int newChapterIndex = getChapterIndexByName(newName);

    // Check if the new chapter is found
    if (newChapterIndex != -1) {
      setState(() {
        // Save changes of the current chapter into subject data
        subjectData.wordlist![getCurrentChapterIndex()] = currentChapter;

        // Load the desired chapter from subject data
        currentChapter = subjectData.wordlist![newChapterIndex];
      });
    }

    // Remove chapter if the list is empty
    if (subjectData.wordlist![oldChapterIndex].words.isEmpty) {
      setState(() {
        subjectData.wordlist!.removeAt(oldChapterIndex);
      });
    }
  }

  void addChapter(String newName) {
    setState(() {
      List<WordPair> words = [
        WordPair(word1: "Type your word", word2: "Type your word")
      ];
      Chapter newChapter = Chapter(name: newName, words: words);
      subjectData.wordlist!.add(newChapter);
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
        subjectData.subjects![index] = newSubject;
        subjectData.languages![index] = newLanguage;
      });
    }
  }

  /// Save all data to local storage
  void saveData() {
    if (focusedIndex == null) return;

    if (getTextOf(focusedIndex!).isNotEmpty) {
      for (SubjectDataModel sub in SubjectDataModel.subjectList) {
        // Find the correct data
        if (sub.title == subjectData.title) {
          // Find the index of the subject
          int index = SubjectDataModel.subjectList.indexOf(sub);
          print("==========================================");
          print("Saving...");
          subjectData.printData();
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

  void changeFocus(int newIndex) {
    if (focusedIndex != null) {
      if (getTextOf(focusedIndex!).isEmpty) return;
    }

    setState(() {
      focusedIndex = newIndex;
      textEditingController.text = getTextOf(newIndex);
      bottomBarFocusNode.requestFocus();
      scrollToFocus();
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
    });
  }

  void scrollToFocus() {
    int currentPosition = scrollController.position.pixels.toInt();
    int targetPosition = ((focusedIndex! /~ 2) * 60).toInt();

    int minRange = currentPosition;
    int maxRange = currentPosition + 12 * 60;

    if(targetPosition < minRange && targetPosition > maxRange) {
      scrollController.animateTo(
          targetPosition.toDouble(),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  Future<void> openWordAdder(BuildContext context) {
    String text1 = "";
    String text2 = "";

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type new words"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: "first word",
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    text1 = value;
                  },
                  onSubmitted: (value) {
                    text1 = value;
                    wordAdderFocusNode.requestFocus();
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "second word",
                  ),
                  focusNode: wordAdderFocusNode,
                  onChanged: (value) {
                    text2 = value;
                  },
                  onSubmitted: (value) {
                    wordAdderFocusNode.unfocus();
                    // apply new text
                    setState(() {
                      if (text1.isNotEmpty && text2.isNotEmpty) {
                        WordPair wordPair =
                            WordPair(word1: text1, word2: text2);
                        addWord(wordPair);
                        Navigator.of(context).pop();
                        changeFocus(getWordsCount() + 1);
                        bottomBarFocusNode.requestFocus();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                // apply new text
                setState(() {
                  if (text1.isNotEmpty && text2.isNotEmpty) {
                    WordPair wordPair = WordPair(word1: text1, word2: text2);
                    addWord(wordPair);
                    Navigator.of(context).pop();
                    scrollController.animateTo(
                        getWordsCount() < 12 ? 0 : 60 * (getWordsCount() / 2) - 60 * 11,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  }
                });
              },
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  void changeThumbnail(String path) {
    setState(() {
      subjectData.thumb = path;
    });
    saveData();
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
    print("===============================++");
    subjectData.printData();

    // initialize some values
    currentChapter = subjectData.wordlist![0];
    bShowingWords = true;
    focusedIndex = 0;

    // activate auto-save
    autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "auto saving...",
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          elevation: 10,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("====================================");
    print("thumbnail path from editor screen side : ${subjectData.thumb}");

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
      drawer: ChapterSelectionDrawer(
        changeChapter: changeChapter,
        currentChapterIndex: getCurrentChapterIndex(),
        getChapterName: getChapterName,
        subjectData: subjectData,
        addChapter: addChapter,
        saveData: saveData,
        changeThumbnail: changeThumbnail,
      ),
      body: Column(
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
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: scrollController,
                        itemCount: getWordsCount() + 2,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: calcRatio(context),
                        ),
                        itemBuilder: ((context, index) {
                          bool bValid = index + 1 <= getWordsCount();
                          return WordGridTile(
                            text: bValid ? getTextOf(index) : "",
                            index: index,
                            saveText: updateWord,
                            bShowingWords: bShowingWords,
                            currentChapter: currentChapter,
                            addWord: addWord,
                            bDeleteMode: bDeleteMode,
                            deleteWord: removeWord,
                            changeFocus: changeFocus,
                            bFocused: index == focusedIndex,
                            openWordAdder: openWordAdder,
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
                ),
              ],
            ),
          ),
          AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 20),
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
                          setState(() {
                            updateWord(value, focusedIndex!);
                            textEditingController.text = "";
                            if (focusedIndex! < getWordsCount() - 1) {
                              changeFocus(focusedIndex! + 1);
                            } else if (focusedIndex! >= getWordsCount() - 1) {
                              openWordAdder(context);
                            }
                          });
                        }
                      },
                      onTap: () {
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
    );
  }

  double calcRatio(BuildContext context) {
    late double val;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (height > 720) {
      if (width / height < 1.2 && width / height > 0.5) {
        val = (width / 2) / (height / 25);
      } else if (width / height > 1.2 && width / height <= 2.5) {
        val = (width / 3) / (height / 25);
      } else if (width / height > 2.5) {
        val = (width / 10) / (height / 25);
      } else if (width / height <= 0.5) {
        val = (width / 1) / (height / 8);
      } else {
        val = 1;
      }
    } else if (height > 360) {
      if (width / height < 1.2 && width / height > 0.5) {
        val = (width / 4) / (height / 25);
      } else if (width / height > 1.2 && width / height <= 2.5) {
        val = (width / 4) / (height / 25);
      } else if (width / height > 2.5) {
        val = (width / 10) / (height / 25);
      } else if (width / height <= 0.5) {
        val = (width / 1) / (height / 8);
      } else {
        val = 1;
      }
    } else {
      if (width / height < 1.2 && width / height > 0.5) {
        val = (width / 4) / (height / 25);
      } else if (width / height > 1.2 && width / height <= 2.5) {
        val = (width / 6) / (height / 25);
      } else if (width / height > 2.5) {
        val = (width / 10) / (height / 25);
      } else if (width / height <= 0.5) {
        val = (width / 1) / (height / 8);
      } else {
        val = 1;
      }
    }
    return val;
  }
}
