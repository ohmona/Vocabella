import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_utils/keyboard_aware/keyboard_aware.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:keyboard_utils/keyboard_listener.dart' as keyboard_listener;
import 'package:vocabella/overlays/loading_scene_overlay.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/utils/configuration.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/managers/double_backup.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/utils/random.dart';
import 'package:vocabella/widgets/chapter_selection_drawer_widget.dart';
import 'package:vocabella/widgets/editor_screen_appbar_widget.dart';
import 'package:vocabella/widgets/language_bar_widget.dart';

import 'package:vocabella/widgets/word_grid_tile_widget.dart';

import '../managers/data_handle_manager.dart';
import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';
import '../utils/modal.dart';

enum ViewMode {
  normal,
  favourite,
}

class DisplayingWord {
  DisplayingWord(
      {required this.wordPair, required this.path, required this.index});

  WordPair wordPair;
  String path; // comprising entire chapter path
  int index;
}

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
  //late Chapter currentChapter;
  late String currentChapterPath;
  late List<DisplayingWord> displayingWords;

  late bool bShowingWords;
  late bool bReadOnly;

  bool bDeleteMode = false;

  ScrollController scrollController = ScrollController();

  TextEditingController textEditingController = TextEditingController();
  FocusNode bottomBarFocusNode = FocusNode();
  FocusNode wordAdderFocusNode = FocusNode();

  late Timer autoSaveTimer;

  late ViewMode viewMode;

  GlobalKey listViewKey = GlobalKey();
  GlobalKey<ChapterSelectionDrawerState> chapterDrawerKey = GlobalKey();

  late List<String> visibleList;

  void addVisibleList(String content) {
    if (!visibleList.contains(content)) {
      visibleList.add(content);
    }
  }

  void removeVisibleList(String content) => visibleList.remove(content);

  /// find the total number of contents
  int getWordsCount() => displayingWords.length * 2;

  /// find the correct Chapter
  int getChapterIndexByPath(String path) {
    for (var element in subjectData.wordlist) {
      if (element.comprisePath() == path) {
        return subjectData.wordlist.indexOf(element);
      }
    }
    return -1;
  }

  //int getChapterIndex(Chapter chapter) => subjectData.wordlist.indexOf(chapter);

  int getCurrentChapterIndex() {
    print("currentChapterPath : $currentChapterPath");
    return subjectData.indexOf(currentChapterPath) ?? -1;
  }

  /// find the index of desired WordPair by general index
  int getWordPairIndex(int index) => index ~/ 2;

  // check whether the index is targeting a question or an answer
  bool isTargetingQuestion(int index) => index % 2 == 0;

  bool isValidIndex(int index) => index < getWordsCount();

  bool isAdditionIndex(int index) => index == getWordsCount() + 1;

  bool bAddingNewWord = false;

  WordPair wordAdditionBuffer = WordPair(
    word1: "",
    word2: "",
    created: DateTime.now(),
    lastEdit: DateTime.now(),
    salt: "",
  );

  late String textBeforeEdit;

  /// returns the text of targeting index
  String getTextOf(int index) {
    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

    WordPair target;
    if (isValidIndex(index)) {
      target = displayingWords[wordPairIndex].wordPair;
    } else if (bAddingNewWord) {
      if (kDebugMode) {
        print("=============================");
        print(wordAdditionBuffer.word1);
        print(wordAdditionBuffer.word2);
      }
      target = wordAdditionBuffer;
    } else {
      return "";
    }

    if (bShowingWords) {
      if (bQuestionTargeting) return target.word1;
      if (!bQuestionTargeting) return target.word2;
    } else {
      if (bQuestionTargeting) return target.example1;
      if (!bQuestionTargeting) return target.example2;
    }

    return "";
  }

  /// get the name of desired chapter
  String getChapterName(int index) =>
      subjectData.wordlist[index].comprisePath();

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
      WordPair target = displayingWords[wordPairIndex].wordPair;

      // check whether words or examples should be changed
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
      displayingWords[wordPairIndex].wordPair = target;
      displayingWords[wordPairIndex].wordPair.lastEdit = DateTime.now();
    } else {
      if (bQuestionTargeting) {
        wordAdditionBuffer.word1 = newText;
      } else {
        wordAdditionBuffer.word2 = newText;
      }
    }
  }

  void addWord(WordPair wordPair) {
    // TODO Should be able to identify current Chapter
    subjectData.wordlist[getCurrentChapterIndex()].wordCount =
        displayingWords.length;

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
      displayingWords.add(DisplayingWord(
          wordPair: wordPair,
          path: currentChapterPath,
          index: displayingWords.length));
    });
  }

  // TODO solve the issue with removing word, user shouldn't delete the last remaining word
  void removeWord(DisplayingWord word) {
    setState(() {
      int targetIndex = displayingWords.indexOf(word);
      displayingWords.removeAt(targetIndex);
      if (!isValidIndex(focusedIndex!) && getWordsCount() != 0) {
        changeFocus(focusedIndex! - 2);
      }
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
      if (bDeleteMode) {
        bDeleteMode = false;
      } else {
        bDeleteMode = true;
      }
    });
  }

  void toggleReadOnly() {
    setState(() {
      bReadOnly = !bReadOnly;
      if (!bReadOnly) {
        bShowingFavouriteOnly = false;
        Future.delayed(
          const Duration(milliseconds: 450),
          () {
            changeFocus(focusedIndex!, force: true);
          },
        );
      }
    });
  }

  /// Change selected chapter
  void changeChapter(String newPath) {
    // Reset to initial state
    bShowingWords = true;
    bDeleteMode = false;
    bottomBarFocusNode.unfocus();

    if (currentChapterPath == newPath) return;

    int oldChapterIndex = getCurrentChapterIndex();
    // Find the index of the desired chapter by its name
    int newChapterIndex = getChapterIndexByPath(newPath);

    // Check if the new chapter is found
    if (newChapterIndex != -1) {
      setState(() {
        // Save latest focused index
        subjectData.wordlist[subjectData.indexOf(currentChapterPath)!]
            .lastIndex = focusedIndex;

        // Save changes of the current chapter into subject data // TODO Apply Changes for Not-Chapter-Only modes
        List<WordPair> list = [];
        for (var element in displayingWords) {
          list.add(element.wordPair);
        }
        subjectData.wordlist[getCurrentChapterIndex()].words = list;
        displayingWords = [];

        // Load the desired chapter from subject data
        focusedIndex = subjectData.wordlist[newChapterIndex].lastIndex;

        for (var word in subjectData.wordlist[newChapterIndex].words) {
          displayingWords.add(
            DisplayingWord(
              wordPair: word,
              path: currentChapterPath,
              index: subjectData.wordlist[newChapterIndex].words.indexOf(word),
            ),
          );
        }

        currentChapterPath = newPath;

        // Save this chapter as latest opened
        subjectData.lastOpenedChapter = currentChapterPath;
        //saveData();

        Future.delayed(const Duration(milliseconds: 50), () {
          if (subjectData.wordlist[newChapterIndex].lastIndex == null) {
            changeFocus(0, requestFocus: true, force: true);
          } else if (!bReadOnly) {
            // Focus on last focused index
            if (subjectData.wordlist[newChapterIndex].lastIndex! <
                (subjectData.wordlist[newChapterIndex].words.length) * 2) {
              changeFocus(subjectData.wordlist[newChapterIndex].lastIndex!,
                  requestFocus: true, force: true);
            } else {
              focusedIndex =
                  (subjectData.wordlist[newChapterIndex].words.length * 2) - 1;
              changeFocus(focusedIndex!, requestFocus: true, force: true);
            }
          } else {
            scrollDelayedToFocus();
          }
        });
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

  bool addChapter(String newName) {
    if (existChapterNameAlready(newName)) {
      return false;
    }

    setState(() {
      List<WordPair> words = [
        WordPair(
          word1: "Type your word",
          word2: "Type your word",
          created: DateTime.now(),
          lastEdit: DateTime.now(),
          salt: generateRandomString(8),
        )
      ];
      Chapter newChapter = Chapter(
        name: newName,
        words: words,
        path: "/",
      );
      subjectData.chapterCount += 1;
      newChapter.wordCount = 1;
      subjectData.wordlist.add(newChapter);
    });
    changeChapter(newName);
    return true;
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

  bool ableToSave() => true;

  /// Save all data to local storage
  void saveData() async {
    if (focusedIndex == null) return null;

    if (ableToSave()) {
      subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].lastIndex =
          focusedIndex;

      // Apply Changes to the actual data
      List<WordPair> list = [];
      for (var element in displayingWords) {
        list.add(element.wordPair);
      }
      subjectData.wordlist[getCurrentChapterIndex()].words = list;

      for (int i = 0; i < SubjectDataModel.subjectList.length; i++) {
        // Find the correct data
        if (SubjectDataModel.subjectList[i].id == subjectData.id) {
          // Then replace the data with the edited one
          // This is the line where saving takes place
          SubjectDataModel.subjectList[i] = subjectData;
        }

        await DataReadWriteManager.write(
          name: DataReadWriteManager.defaultFile,
          data: SubjectDataModel.listToJson(SubjectDataModel.subjectList),
        );

        print("toggle db count...");
        // After that we need to create another backup for fatal case like loosing data
        // Firstly, we toggle the count
        await DoubleBackup.toggleDBCount(); // FUTURE

        print("save double backup...");
        // Then save the backup data
        await DoubleBackup.saveDoubleBackup(SubjectDataModel.listToJson(
            SubjectDataModel.subjectList)); // FUTURE
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
      return null;
    }
    return null;
  }

  void terminateWordAddition() {
    bAddingNewWord = false;
    if (wordAdditionBuffer.word1.isNotEmpty &&
        wordAdditionBuffer.word2.isNotEmpty) {
      wordAdditionBuffer.created = DateTime.now();
      wordAdditionBuffer.lastEdit = DateTime.now();
      wordAdditionBuffer.salt = generateRandomString(8);
      addWord(wordAdditionBuffer);
      //saveData(); Disabled, due to lags
    }

    wordAdditionBuffer = WordPair(
      word1: "",
      word2: "",
      created: DateTime.now(),
      lastEdit: DateTime.now(),
      salt: "",
    );
  }

  void changeFocus(
    int newIndex, {
    bool requestFocus = true,
    bool force = false,
  }) {
    // Make sure that user doesn't make silly issue
    if (newIndex >= getWordsCount() + 2) return;
    if (!isValidIndex(newIndex) && !bShowingWords) return;

    if (bReadOnly) return;

    if (focusedIndex != null && isValidIndex(focusedIndex!)) {
      if (getTextOf(focusedIndex!).isEmpty && bShowingWords) {
        updateWord(textBeforeEdit, focusedIndex!);
      }
    }

    // Word addition begins here
    if (!bAddingNewWord && !isValidIndex(newIndex)) {
      bAddingNewWord = true;
      wordAdditionBuffer = WordPair(
        word1: "",
        word2: "",
        created: DateTime.now(),
        lastEdit: DateTime.now(),
        salt: "",
      );
    }

    if (bAddingNewWord && isValidIndex(newIndex)) {
      terminateWordAddition();
    }

    setState(() {
      focusedIndex = newIndex;
      subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].lastIndex =
          newIndex;

      if (requestFocus) {
        Future.delayed(
          const Duration(milliseconds: 1),
          () {
            bottomBarFocusNode.requestFocus();
            textEditingController.text = getTextOf(newIndex);
          },
        );
      } else {
        textEditingController.text = getTextOf(newIndex);
      }

      if (kDebugMode) {
        print("=================================");
        print("Change focus");
      }

      jumpToIndex(smallIndex: focusedIndex! ~/ 2);
      //scrollDelayedToFocus(delay: const Duration(milliseconds: 1));
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
      textBeforeEdit = getTextOf(newIndex);
    });
  }

  static const scrollCurve = Curves.easeOutQuint;

  void scrollDelayedToFocus(
      {Duration delay = const Duration(milliseconds: 1)}) {
    if (kDebugMode) {
      print("=================================");
      print("Scroll Delayed");
    }
    scrollToIndex(
        smallIndex: focusedIndex! ~/ 2,
        duration: const Duration(milliseconds: 200),
        delay: delay);
  }

  void scrollToIndex({
    required int smallIndex,
    required Duration duration,
    required Duration delay,
  }) {
    if (kDebugMode) {
      print("=================================");
      print("Scroll To Index");
    }
    Future.delayed(delay, () {
      scrollController.animateTo(
        calcOffsetToScroll(smallIndex: smallIndex),
        duration: duration,
        curve: scrollCurve,
      );
    });
  }

  void jumpToIndex({required int smallIndex}) {
    if (kDebugMode) {
      print("=================================");
      print("Jump To Index");
    }
    scrollController.jumpTo(calcOffsetToScroll(smallIndex: smallIndex));
  }

  late KeyboardUtils _keyboardUtils;
  late int _idKeyboardListener;

  double calcOffsetToScroll({required int smallIndex}) {
    final itemCount = (getWordsCount() / 2 + 1).toInt();
    final pos =
        ((smallIndex + 2) * 50) - listViewKey.currentContext!.size!.height;
    final maxPos =
        ((itemCount) * 50) - listViewKey.currentContext!.size!.height;
    if (kDebugMode) {
      print("$itemCount $pos $maxPos");
    }
    if (itemCount > listViewKey.currentContext!.size!.height / 50) {
      if (pos >= 0 && pos <= maxPos + 0.1) {
        return pos;
      } else if (pos > maxPos) {
        return maxPos;
      }
    }
    return 0;
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
    // TODO Should be able to identify the current Chapter
    setState(() {
      String oldName = currentChapterPath.split("/").last;
      String pathOnly = currentChapterPath.substring(
          0, currentChapterPath.length - oldName.length);
      print("$oldName $pathOnly $newName");
      if (getChapterIndexByPath("$pathOnly$newName") == -1) {
        subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].name =
            newName;
        changeChapter(newName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can't make chapters with same name",
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            elevation: 10,
          ),
        );
      }
      currentChapterPath = "$pathOnly$newName";
      saveData();
    });
  }

  bool existChapterNameAlready(String name, {String path = "/"}) {
    for (var element in subjectData.wordlist) {
      if (element.name == name && element.path == path) {
        return true;
      }
    }
    return false;
  }

  void duplicateChapter() {
    throw UnimplementedError("Chapter Duplication hasn't been implemented yet");
    /*setState(() {
      if (getChapterIndexByName("${currentChapter.name} - copy") == -1) {
        final currentChapterIndex = getChapterIndexByName(currentChapter.name);
        var chapter = Chapter.duplicate(currentChapter);
        final newName = "${currentChapter.name} - copy";
        chapter.name = newName;

        subjectData.chapterCount += 1;
        subjectData.wordlist.insert(currentChapterIndex + 1, chapter);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can't duplicate a chapter multiple times",
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            elevation: 10,
          ),
        );
      }
    });*/
  }

  List<String> pathList() {
    List<String> elements = [];
    for (var chap in subjectData.wordlist) {
      String oldName = chap.path.split("/").last;
      String pathOnly =
          chap.path.substring(0, chap.path.length - oldName.length);
      if (!elements.contains(pathOnly)) {
        elements.add(pathOnly);
      }
    }
    return elements;
  }

  // Move Focused Chapter to new Folder
  void addFolder(String folderName) {
    int oldIndex = getChapterIndexByPath(currentChapterPath);

    String oldName = currentChapterPath.split("/").last;
    String pathOnly = currentChapterPath.substring(
        0, currentChapterPath.length - oldName.length);

    String newPath = "$pathOnly$folderName/";

    if (!pathList().contains(newPath)) {
      subjectData.wordlist[oldIndex].path = newPath;
      currentChapterPath = "$pathOnly$folderName/$oldName";
      addVisibleList(newPath);

      resortChapters();
      chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
      changeChapter(currentChapterPath);
    } else {
      openAlert(context,
          title: "Warning",
          content: "You can't create the folder with existing name");
    }
  }

  void moveChapter(String target, String destination) {
    print("moving chapter $target $destination");
    int oldIndex = getChapterIndexByPath(target);

    String oldName = target.split("/").last;
    String pathOnly = target.substring(0, target.length - oldName.length);

    if (pathOnly == destination) return;

    print("chapter [$oldName] moved : from $pathOnly, to $destination");

    bool exist = existChapterNameAlready(oldName, path: destination);

    if (!exist) {
      addVisibleList(destination);
      subjectData.wordlist[oldIndex].path = destination;
      resortChapters();
      chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
      if (currentChapterPath == target) {
        print("moving focused one");
        currentChapterPath = "$destination$oldName";
        changeChapter(currentChapterPath);
      }
    } else {
      openAlert(context,
          title: "Warning",
          content: "There's already a chapter with an existing name");
    }
  }

  void reorderChapter(String target, int newIndex) {
    print("chpater resorted $target to $newIndex");
    int oldIndex = subjectData.indexOf(target)!;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = subjectData.wordlist.removeAt(oldIndex);
    subjectData.wordlist.insert(newIndex, item);
    resortChapters();
    chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
  }

  // target = first index after desired path
  void insertChapters(int start, int size, int target) {
    print("Inserting Chapter");
    print("start:$start, size:$size, target:$target");
    subjectData.printData();
    print("Start Inserting");
    List<Chapter> list = [];
    for (int i = start; i < start + size; i++) {
      list.add(subjectData.wordlist[i]);
    }
    print("I Queue: $list");
    subjectData.printData();
    for (var element in list) {
      subjectData.wordlist.remove(element);
    }
    print("II Edited: ${subjectData.wordlist}");
    subjectData.printData();
    for (int i = 0; i < list.length; i++) {
      if (start < target) {
        print("III Inserting: ${list[i]} to ${i + target - size}");
        subjectData.wordlist.insert(i + target - size, list[i]);
      } else {
        print("Moving to top");
        print("Target ${i + target}, ${list[i]}");
        subjectData.wordlist.insert(i + target, list[i]);
      }
    }
    print("result");
    subjectData.printData();
    print("resort");
    resortChapters();
    chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
  }

  void saveKeyboardMargin() {
    bottomBarFocusNode.requestFocus();
    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        if (bottomBarFocusNode.hasFocus) {
          if (AppConfig.keyboardMargin < _viewInsetsBottom.toInt()) {
            AppConfig.keyboardMargin = _viewInsetsBottom.toInt();
            if (kDebugMode) {
              print(AppConfig.keyboardMargin);
            }
            AppConfig.save();
          }
        }
      },
    );
  }

  bool bShowingFavouriteOnly = false;

  // Change favourite state of the focused index
  void changeFavourite() {
    if (isValidIndex(focusedIndex!)) {
      if (!bReadOnly) {
        setState(() {
          bool? favourite = displayingWords[getWordPairIndex(focusedIndex!)]
              .wordPair
              .favourite;
          if (favourite == null || favourite == false) {
            favourite = true;
          } else {
            favourite = false;
          }
          displayingWords[getWordPairIndex(focusedIndex!)].wordPair.favourite =
              favourite;
          displayingWords[getWordPairIndex(focusedIndex!)].wordPair.lastEdit =
              DateTime.now();
        });
      } /*else {
        setState(() {
          bShowingFavouriteOnly = !bShowingFavouriteOnly;
          print("Toggle show favourite only : $bShowingFavouriteOnly");
        });
      }*/
    } /*else {
      // Show favourite only
      if (bReadOnly) {
        setState(() {
          bShowingFavouriteOnly = !bShowingFavouriteOnly;
          print("Toggle show favourite only : $bShowingFavouriteOnly");
        });
      }}*/
    // TODO Make sowing favourites only mode
  }

  // Returns favourite state of the focused index
  bool isLiked() {
    if (focusedIndex == null) return false;
    if (!isValidIndex(focusedIndex!)) return false;

    bool? favourite =
        displayingWords[getWordPairIndex(focusedIndex!)].wordPair.favourite;
    if (favourite == null || favourite == false) {
      return false;
    } else {
      return true;
    }
  }

  int countFavourite() {
    int count = 0;
    for (int i = 0; i < displayingWords.length; i++) {
      if (displayingWords[i].wordPair.favourite != null) {
        if (displayingWords[i].wordPair.favourite!) {
          count += 1;
        }
      }
    }
    return count;
  }

  List<int> favouriteList() {
    List<int> list = [];

    for (int i = 0; i < displayingWords.length; i++) {
      if (displayingWords[i].wordPair.favourite!) {
        list.add(i);
      }
    }
    if (kDebugMode) {
      print("===========================");
      print("printing favourites");
    }
    for (var element in list) {
      if (kDebugMode) {
        print(element);
      }
    }
    return list;
  }

  int getFavouriteIndex(int index) {
    int num = favouriteList()[index];
    print("Getting favourite index");
    print("index: $index, num: $num");
    return num;
  }

  void showLoadingScreen(BuildContext context) {
    Navigator.of(context).push(LoadingOverlay());
  }

  // up to index
  String limitPath(String original, int index) {
    return original.split("/").sublist(0, index + 1).join("/");
  }

  // Resort Chapter according to its folder
  void resortChapters() {
    // Create a list of the paths
    List<String> paths = [];
    for (var chap in subjectData.wordlist) {
      if (!paths.contains(chap.path)) {
        paths.add(chap.path);
      }
    }

    final original = paths;
    // Sort this path according to the original order
    paths.sort(
      (a, b) {
        // negative: a is located higher, true: b is located higher
        if (a == "/" && b.endsWith("/")) {
          return 1;
        }
        if (b == "/" && a.endsWith("/")) {
          return -1;
        }

        List<String> segmentsA = a.split('/');
        List<String> segmentsB = b.split('/');

        int length = segmentsA.length < segmentsB.length
            ? segmentsA.length
            : segmentsB.length;

        for (int i = 0; i < length; i++) {
          if (segmentsA[i] == segmentsB[i]) {
            //skip
          } else {
            String toCompareA = limitPath(segmentsA.join("/"), i);
            String toCompareB = limitPath(segmentsB.join("/"), i);

            for (var ori in original) {
              if (ori.startsWith(toCompareA)) {
                print(ori);
                return -1;
              } else if (ori.startsWith(toCompareB)) {
                print(ori);
                return 1;
              }
            }
          }
        }
        return -1;
      },
    );

    // Add every Chapter to a new list in sort
    List<Chapter> sorted = [];
    for (var path in paths) {
      for (var chap in subjectData.wordlist) {
        if (chap.path == path) {
          sorted.add(chap);
          // TODO improve re-sorting system
        }
      }
    }

    // Apply changes
    subjectData.wordlist = sorted;
  }

  int whichAppearsFirst(
      List<String> original, String start, String a, String b) {
    for (var str in original) {
      if (str.startsWith(start)) {
        var s = str.substring(0, start.length - 1);
        if (s.startsWith(a)) {
          print("str: $str, start: $start");
          print("s: $s");
          return -1;
        } else if (s.startsWith(b)) {
          print("str: $str, start: $start");
          print("s: $s");
          return 1;
        }
      }
    }
    return -1;
  }

  @override
  void dispose() {
    bottomBarFocusNode.dispose();
    autoSaveTimer.cancel();
    super.dispose();

    if (Platform.isIOS || Platform.isAndroid) {
      _keyboardUtils.unsubscribeListener(subscribingId: _idKeyboardListener);
      if (_keyboardUtils.canCallDispose()) {
        _keyboardUtils.dispose();
      }
    }
  }

  bool _showingKeyboard = false;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    // copy the data which is going to be edited
    subjectData = widget.data;
    resortChapters();

    // initialize some values
    bShowingWords = true;
    bReadOnly = false;
    focusedIndex = 0;

    viewMode = ViewMode.normal;

    visibleList = ["/"];

    if (Platform.isIOS || Platform.isAndroid) {
      _keyboardUtils = KeyboardUtils();
    }

    // Apply last opened chapter and grid
    var startUpChapter = subjectData.wordlist[
        subjectData.indexOf(subjectData.lastOpenedChapter ?? "/") ?? 0];
    focusedIndex = startUpChapter.lastIndex ?? 0;
    currentChapterPath = startUpChapter.comprisePath();

    // Initialise Word List
    displayingWords = [];
    for (var word in startUpChapter.words) {
      displayingWords.add(
        DisplayingWord(
          wordPair: word,
          path: currentChapterPath,
          index: startUpChapter.words.indexOf(word),
        ),
      );
    }

    textBeforeEdit = getTextOf(focusedIndex!);

    // activate auto-save
    autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      saveData();
    });

    if (Platform.isIOS || Platform.isAndroid) {
      _idKeyboardListener = _keyboardUtils.add(
          listener: keyboard_listener.KeyboardListener(
        willHideKeyboard: () {
          _showingKeyboard = false;
          if (kDebugMode) {
            print("========================");
            print("hiding keyboard");
          }
        },
        willShowKeyboard: (double keyboardHeight) {
          _showingKeyboard = true;
          _keyboardHeight = keyboardHeight;
          if (kDebugMode) {
            print("========================");
            print(keyboardHeight);
          }
        },
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (startUpChapter.lastIndex! < (startUpChapter.words.length) * 2) {
        changeFocus(startUpChapter.lastIndex!,
            requestFocus: false, force: true);
      } else {
        focusedIndex = (startUpChapter.words.length * 2) - 1;
        changeFocus(focusedIndex!, requestFocus: false, force: true);
      }
      saveKeyboardMargin();
    });
  }

  late double _screenHeight;
  late double _viewInsetsBottom;

  static const double bottomBarHeight = 60;
  static const double gridViewTopMargin = 105;

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

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
      drawer: _buildChapterDrawer(),
      body: WillPopScope(
        onWillPop: () async {
          widget.refresh();
          saveData();
          Navigator.popUntil(context, ModalRoute.withName('/'));
          return false;
        },
        child: KeyboardAware(
          builder: (context, keyboardConfig) => Column(
            children: [
              _buildBody(),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  void _onPressSummit(String value) {
    if (focusedIndex != null) {
      bottomBarFocusNode.requestFocus();
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
  }

  Widget _buildBody() {
    return Expanded(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: gridViewTopMargin,
              ),
              Expanded(
                child: _buildList(),
              ),
            ],
          ),
          _buildLanguageBar(),
          _buildAppBar(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ReorderableListView.builder(
      key: listViewKey,
      scrollController: scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: bShowingFavouriteOnly
          ? countFavourite() + 1
          : (getWordsCount() / 2 + 1).toInt(),
      dragStartBehavior: DragStartBehavior.start,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (!bShowingFavouriteOnly) {
          final maxIndex = getWordsCount() ~/ 2;
          final currentIndexNormalized = focusedIndex! ~/ 2;

          subjectData.wordlist[subjectData.indexOf(currentChapterPath)!]
              .lastIndex = newIndex;

          if (oldIndex >= maxIndex || newIndex > maxIndex) {
            return;
          }

          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = displayingWords.removeAt(oldIndex);
            displayingWords.insert(newIndex, item);
            // TODO EDIT

            if (oldIndex == currentIndexNormalized) {
              focusedIndex = isTargetingQuestion(focusedIndex!)
                  ? newIndex * 2
                  : newIndex * 2 + 1;
            } else if (currentIndexNormalized < oldIndex) {
              if (currentIndexNormalized >= newIndex) {
                focusedIndex = focusedIndex! + 2;
              }
            } else if (currentIndexNormalized > oldIndex) {
              if (currentIndexNormalized <= newIndex) {
                focusedIndex = focusedIndex! - 2;
              }
            }
          });
        }
      },
      itemBuilder: ((context, index) {
        late bool bValid;
        late String? displayingText1;
        late String? displayingText2;
        late DisplayingWord wordPair;
        late bool bFocused1;
        late bool bFocused2;

        if (!bShowingFavouriteOnly) {
          bValid = index < getWordsCount() ~/ 2;
          displayingText1 = bValid ? getTextOf(2 * index) : "";
          displayingText2 = bValid ? getTextOf(2 * index + 1) : "";

          if (bValid) {
            displayingText1 = getTextOf(2 * index);
            displayingText2 = getTextOf(2 * index + 1);
            wordPair = displayingWords[getWordPairIndex(2 * index)];
          } else if (index < (getWordsCount() + 2) ~/ 2) {
            // end cells
            displayingText1 = getTextOf(2 * index);
            displayingText2 = getTextOf(2 * index + 1);
            wordPair = DisplayingWord(
                wordPair: wordAdditionBuffer, path: "N/A", index: -1);
          } else {
            displayingText1 = "";
            displayingText2 = "";
            wordPair = DisplayingWord(
                wordPair: WordPair.nullWordPair(), path: "N/A", index: -1);
          }

          bFocused1 = 2 * index == focusedIndex;
          bFocused2 = 2 * index + 1 == focusedIndex;
        } else {
          // TODO
          int size = countFavourite();

          bValid = index < size;
          wordPair = bValid
              ? displayingWords[getFavouriteIndex(index)]
              : DisplayingWord(
                  wordPair: WordPair.nullWordPair(), path: "N/A", index: -1);
          if (bShowingWords) {
            displayingText1 = bValid ? wordPair.wordPair.word1 : "";
            displayingText2 = bValid ? wordPair.wordPair.word2 : "";
          } else {
            displayingText1 = bValid ? wordPair.wordPair.example1 : "";
            displayingText2 = bValid ? wordPair.wordPair.example2 : "";
          }

          bFocused1 =
              bValid ? 2 * getFavouriteIndex(index) == focusedIndex : false;
          bFocused2 =
              bValid ? 2 * getFavouriteIndex(index) + 1 == focusedIndex : false;
        }

        return ReorderableDelayedDragStartListener(
          index: index,
          key: Key("$index"),
          child: Row(
            children: [
              WordGridTile(
                text: displayingText1,
                index: 2 * index,
                saveText: updateWord,
                bShowingWords: bShowingWords,
                bDeleteMode: bDeleteMode,
                deleteWord: removeWord,
                changeFocus: changeFocus,
                bFocused: bFocused1,
                wordAdditionBuffer: wordAdditionBuffer,
                displayingWord: wordPair,
                viewMode: viewMode,
                listSize: displayingWords.length,
              ),
              WordGridTile(
                text: displayingText2,
                index: 2 * index + 1,
                saveText: updateWord,
                bShowingWords: bShowingWords,
                bDeleteMode: bDeleteMode,
                deleteWord: removeWord,
                changeFocus: changeFocus,
                bFocused: bFocused2,
                wordAdditionBuffer: wordAdditionBuffer,
                displayingWord: wordPair,
                viewMode: viewMode,
                listSize: displayingWords.length,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLanguageBar() {
    return Transform.translate(
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (bReadOnly) {
      return const SizedBox(
        height: 0,
      );
    }

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
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
        height: bottomBarHeight,
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
                  fontSize:
                      (MediaQuery.of(context).size.height < 600) ? 12 : 16,
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
                onSubmitted: _onPressSummit,
                onTap: () {
                  jumpToIndex(smallIndex: focusedIndex!);
                  if (focusedIndex == null) {
                    bottomBarFocusNode.unfocus();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return EditorScreenAppbar(
      bShowingWords: bShowingWords,
      toggleWords: toggleWords,
      bDeleteMode: bDeleteMode,
      toggleDeleteMode: toggleDeleteMode,
      changeChapterName: changeChapterName,
      wordCount: displayingWords.length,
      bReadOnly: bReadOnly,
      toggleReadOnly: toggleReadOnly,
      chapterName: currentChapterPath.split("/").last,
      changeFavourite: changeFavourite,
      getFavourite: () {
        return isLiked();
      },
      favouriteCount: countFavourite(),
    );
  }

  Widget _buildChapterDrawer() {
    return ChapterSelectionDrawer(
      key: chapterDrawerKey,
      changeChapter: changeChapter,
      getCurrentChapterPath: () {
        return currentChapterPath;
      },
      subjectData: subjectData,
      addChapter: addChapter,
      saveData: saveData,
      changeThumbnail: changeThumbnail,
      changeSubjectName: changeSubjectName,
      reorderChapter: reorderChapter,
      existChapterNameAlready: existChapterNameAlready,
      openDoubleChecker: openDoubleChecker,
      duplicateChapter: duplicateChapter,
      showLoadingScreen: showLoadingScreen,
      addFolder: addFolder,
      moveChapter: moveChapter,
      addVisibleList: addVisibleList,
      removeVisibleList: removeVisibleList,
      visibleList: visibleList,
      insertChapters: insertChapters,
    );
  }

  Future<void> openDoubleChecker(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Attention!"),
          content: const Text("Are you sure you want to save and exit?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                saveData();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  double calcRatio(BuildContext context) =>
      (MediaQuery.of(context).size.width / 2) / 50;
}
