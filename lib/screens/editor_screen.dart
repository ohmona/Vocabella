import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/widgets/chapter_selection_drawer_widget.dart';
import 'package:vocabella/widgets/editor_screen_appbar_widget.dart';

import 'package:vocabella/widgets/word_grid_tile_widget.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

/// 1. confirm new text
/// 2. add this to data
/// 3.

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key, required this.data}) : super(key: key);

  final SubjectDataModel data;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  /// 1. Contains data from loaded one
  /// 2. Should be updated once edited
  late SubjectDataModel subjectData;

  /// 1. Enables finding correct path
  /// 2. (later) name will be editable
  late Chapter currentChapter;

  late bool bShowingWords;

  ScrollController controller = ScrollController();

  /// find the total number of contents
  int getWordsCount() {
    return currentChapter.words.length * 2;
  }

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
  int getWordPairIndex(int index) {
    return index ~/ 2;
  }

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

  bool bDeleteMode = false;


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
    if(subjectData.wordlist![oldChapterIndex].words.isEmpty) {
      setState(() {
        subjectData.wordlist!.removeAt(oldChapterIndex);
      });
    }
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

  void removeWord(WordPair wordPair) {
    setState(() {
      int targetIndex = currentChapter.words.indexOf(wordPair);
      currentChapter.words.removeAt(targetIndex);
    });
  }

  @override
  void initState() {
    super.initState();

    subjectData = widget.data;
    currentChapter = subjectData.wordlist![0];

    bShowingWords = true;
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
      drawer: ChapterSelectionDrawer(
        changeChapter: changeChapter,
        currentChapterIndex: getCurrentChapterIndex(),
        getChapterName: getChapterName,
        subjectData: subjectData,
        addChapter: addChapter,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          EditorScreenAppbar(
            currentChapter: currentChapter,
            bShowingWords: bShowingWords,
            toggleWords: toggleWords,
            bDeleteMode: bDeleteMode,
            toggleDeleteMode: toggleDeleteMode,
          ),
          Expanded(
            child: GridView.builder(
              controller: controller,
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
                );
              }),
            ),
          ),
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
