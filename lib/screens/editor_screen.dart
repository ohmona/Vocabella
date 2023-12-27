import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_utils/keyboard_aware/keyboard_aware.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:keyboard_utils/keyboard_listener.dart' as keyboard_listener;
import 'package:vocabella/arguments.dart';
import 'package:vocabella/configuration.dart';
import 'package:vocabella/constants.dart';
import 'package:vocabella/managers/double_backup.dart';
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
  late bool bReadOnly;

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

  int getChapterIndex(Chapter chapter) => subjectData.wordlist.indexOf(chapter);

  int getCurrentChapterIndex() => subjectData.wordlist.indexOf(currentChapter);

  /// find the index of desired WordPair by general index
  int getWordPairIndex(int index) => index ~/ 2;

  // check whether the index is targeting a question or an answer
  bool isTargetingQuestion(int index) => index % 2 == 0;

  bool isValidIndex(int index) => index < getWordsCount();

  bool bAddingNewWord = false;

  WordPair wordAdditionBuffer = WordPair(
    word1: "",
    word2: "",
    created: DateTime.now(),
    lastEdit: DateTime.now(),
  );

  late String textBeforeEdit;

  /// returns the text of targeting index
  String getTextOf(int index) {
    final int wordPairIndex = getWordPairIndex(index);
    final bool bQuestionTargeting = isTargetingQuestion(index);

    WordPair target;
    if (isValidIndex(index)) {
      target = currentChapter.words[wordPairIndex];
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
      currentChapter.words[wordPairIndex] = target;
      currentChapter.words[wordPairIndex].lastEdit = DateTime.now();
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
  void changeChapter(String newName) {
    // Reset to initial state
    bShowingWords = true;
    bDeleteMode = false;
    bottomBarFocusNode.unfocus();

    if (currentChapter.name == newName) return;

    int oldChapterIndex = getCurrentChapterIndex();
    // Find the index of the desired chapter by its name
    int newChapterIndex = getChapterIndexByName(newName);

    // Check if the new chapter is found
    if (newChapterIndex != -1) {
      setState(() {
        // Save latest focused index
        currentChapter.lastIndex = focusedIndex;

        // Save changes of the current chapter into subject data
        subjectData.wordlist[getCurrentChapterIndex()] = currentChapter;

        // Load the desired chapter from subject data
        currentChapter = subjectData.wordlist[newChapterIndex];
        focusedIndex = currentChapter.lastIndex;

        // Save this chapter as latest opened
        subjectData.lastOpenedChapterIndex = newChapterIndex;
        saveData();

        Future.delayed(const Duration(milliseconds: 50), () {
          if (!bReadOnly) {
            // Focus on last focused index
            if (currentChapter.lastIndex! < (currentChapter.words.length) * 2) {
              changeFocus(currentChapter.lastIndex!,
                  requestFocus: true, force: true);
            } else {
              focusedIndex = (currentChapter.words.length * 2) - 1;
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

  void addChapter(String newName) {
    if (existChapterNameAlready(newName)) {
      return;
    }

    setState(() {
      List<WordPair> words = [
        WordPair(
          word1: "Type your word",
          word2: "Type your word",
          created: DateTime.now(),
          lastEdit: DateTime.now(),
        )
      ];
      Chapter newChapter = Chapter(
        name: newName,
        words: words,
        //id: subjectData.chapterCount + 1,
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
  void saveData() async {
    if (focusedIndex == null) return;

    if (ableToSave()) {
      currentChapter.lastIndex = focusedIndex;

      for (int i = 0; i < SubjectDataModel.subjectList.length; i++) {
        // Find the correct data
        if (SubjectDataModel.subjectList[i].id == subjectData.id) {
          // Then replace the data with the edited one
          // This is the line where saving takes place
          SubjectDataModel.subjectList[i] = subjectData;
        }

        // Finally we have to save data to the local no matter it should be
        await DataReadWriteManager.writeData(
            SubjectDataModel.listToJson(SubjectDataModel.subjectList));

        // After that we need to create another backup for fatal case like loosing data
        // Firstly, we toggle the count
        await DoubleBackup.toggleDBCount();

        // Then save the backup data
        await DoubleBackup.saveDoubleBackup(
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
      wordAdditionBuffer.created = DateTime.now();
      wordAdditionBuffer.lastEdit = DateTime.now();
      addWord(wordAdditionBuffer);
      saveData();
    }

    wordAdditionBuffer = WordPair(
      word1: "",
      word2: "",
      created: DateTime.now(),
      lastEdit: DateTime.now(),
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

    if (focusedIndex != null) {
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
      );
    }

    if (bAddingNewWord && isValidIndex(newIndex)) {
      terminateWordAddition();
    }

    setState(() {
      focusedIndex = newIndex;
      currentChapter.lastIndex = newIndex;

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

      scrollDelayedToFocus(delay: const Duration(milliseconds: 1));
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
    scrollToIndex(focusedIndex!,
        duration: const Duration(milliseconds: 200), delay: delay);
  }

  void scrollToIndex(
    int index, {
    required Duration duration,
    required Duration delay,
  }) {
    if (kDebugMode) {
      print("=================================");
      print("Scroll To Index");
    }
    Future.delayed(delay, () {
      scrollController.animateTo(
        calcIndexToScroll(index) * 50,
        duration: duration,
        curve: scrollCurve,
      );
    });
  }

  void jumpToIndex(int index) {
    if (kDebugMode) {
      print("=================================");
      print("Jump To Index");
    }
    scrollController.jumpTo(calcIndexToScroll(index) * 50);
  }

  final KeyboardUtils _keyboardUtils = KeyboardUtils();
  late int _idKeyboardListener;

  int calcIndexToScroll(int index) {
    final targetIndex = (index ~/ 2);
    const cellHeight = 50.0;
    final keyboardMargin = _keyboardHeight;

    final itemsOnScreen = ((_screenHeight -
                bottomBarHeight -
                gridViewTopMargin -
                keyboardMargin) ~/
            cellHeight) -
        1;

    if (kDebugMode) {
      print("=================================");
      print("Calc index to scroll");
      print("Index : $index");
      print("targetIndex : $targetIndex");
      print("cellHeight : $cellHeight");
      print("_showingKeyboard : $_showingKeyboard");
      print("_keyboardHeight : $_keyboardHeight");
      print("keyboardMargin : $keyboardMargin");
      print("_screenHeight : $_screenHeight");
      print("bottomBarHeight : $bottomBarHeight");
      print("gridViewTopMargin : $gridViewTopMargin");
      print("itemsOnScreen : $itemsOnScreen");
      print(
          "targetIndex - (itemsOnScreen - 2) : ${targetIndex - (itemsOnScreen - 2)}");
    }

    // Case 1 : everything is fine! scroll to usual position
    // Case 2 : position is overflowed to negative
    // Case 3 : position is overflowed over valid index

    var desired = targetIndex - (itemsOnScreen - 2);

    if (desired < 0) {
      // Case 2
      return 0;
    } else if (desired > currentChapter.words.length - itemsOnScreen + 1) {
      // Case 3
      return currentChapter.words.length - itemsOnScreen + 1;
    } else {
      // Case 1
      return desired;
    }
  }

  bool inRange(double value, double target, double interval) {
    if (value < target + interval) {
      if (value > target - interval) {
        return true;
      }
    }
    return false;
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
      if (getChapterIndexByName(newName) == -1) {
        currentChapter.name = newName;
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
    });
    saveData();
  }

  void reorderChapter(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = subjectData.wordlist.removeAt(oldIndex);
      subjectData.wordlist.insert(newIndex, item);

      // Save new index as latest opened
      subjectData.lastOpenedChapterIndex = newIndex;
      saveData();
    });
  }

  bool existChapterNameAlready(String name) {
    for (var element in subjectData.wordlist) {
      if (element.name == name) {
        return true;
      }
    }
    return false;
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

  void duplicateChapter() {
    setState(() {
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
    });
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
          bool? favourite =
              currentChapter.words[getWordPairIndex(focusedIndex!)].favourite;
          if (favourite == null || favourite == false) {
            favourite = true;
          } else {
            favourite = false;
          }
          currentChapter.words[getWordPairIndex(focusedIndex!)].favourite =
              favourite;
          currentChapter.words[getWordPairIndex(focusedIndex!)].lastEdit =
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
    if(focusedIndex == null) return false;
    if (!isValidIndex(focusedIndex!)) return false;

    bool? favourite =
        currentChapter.words[getWordPairIndex(focusedIndex!)].favourite;
    if (favourite == null || favourite == false) {
      return false;
    } else {
      return true;
    }
  }

  int countFavourite() {
    int count = 0;
    for (int i = 0; i < currentChapter.words.length; i++) {
      if (currentChapter.words[i].favourite != null) {
        if (currentChapter.words[i].favourite!) {
          count += 1;
        }
      }
    }
    return count;
  }

  List<int> favouriteList() {
    List<int> list = [];

    for (int i = 0; i < currentChapter.words.length; i++) {
      if (currentChapter.words[i].favourite!) {
        list.add(i);
      }
    }
    print("===========================");
    print("printing favourites");
    list.forEach((element) {
      print(element);
    });
    return list;
  }

  int getFavouriteIndex(int index) {
    int num = favouriteList()[index];
    print("Getting favourite index");
    print("index: $index, num: $num");
    return num;
  }

  @override
  void dispose() {
    bottomBarFocusNode.dispose();
    autoSaveTimer.cancel();
    super.dispose();

    _keyboardUtils.unsubscribeListener(subscribingId: _idKeyboardListener);
    if (_keyboardUtils.canCallDispose()) {
      _keyboardUtils.dispose();
    }
  }

  bool _showingKeyboard = false;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    // copy the data which is going to be edited
    subjectData = widget.data;

    // initialize some values
    currentChapter = subjectData.wordlist[0];
    bShowingWords = true;
    bReadOnly = false;
    focusedIndex = 0;

    textBeforeEdit = getTextOf(focusedIndex!);

    // Apply last opened chapter and grid
    var startUpChapter = subjectData.lastOpenedChapterIndex ?? 0;
    currentChapter = subjectData.wordlist[startUpChapter];
    focusedIndex = currentChapter.lastIndex ?? 0;

    // activate auto-save
    autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      saveData();
    });

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (currentChapter.lastIndex! < (currentChapter.words.length) * 2) {
        changeFocus(currentChapter.lastIndex!,
            requestFocus: false, force: true);
      } else {
        focusedIndex = (currentChapter.words.length * 2) - 1;
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
        openDoubleChecker: openDoubleChecker,
        duplicateChapter: duplicateChapter,
      ),
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
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: gridViewTopMargin,
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
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
                                final currentIndexNormalized =
                                    focusedIndex! ~/ 2;

                                currentChapter.lastIndex = newIndex;

                                if (oldIndex >= maxIndex ||
                                    newIndex > maxIndex) {
                                  return;
                                }

                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final item =
                                      currentChapter.words.removeAt(oldIndex);
                                  currentChapter.words.insert(newIndex, item);

                                  if (oldIndex == currentIndexNormalized) {
                                    focusedIndex =
                                        isTargetingQuestion(focusedIndex!)
                                            ? newIndex * 2
                                            : newIndex * 2 + 1;
                                  } else if (currentIndexNormalized <
                                      oldIndex) {
                                    if (currentIndexNormalized >= newIndex) {
                                      focusedIndex = focusedIndex! + 2;
                                    }
                                  } else if (currentIndexNormalized >
                                      oldIndex) {
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
                              late WordPair wordPair;
                              late bool bFocused1;
                              late bool bFocused2;

                              if (!bShowingFavouriteOnly) {
                                bValid = index < getWordsCount() ~/ 2;
                                displayingText1 =
                                    bValid ? getTextOf(2 * index) : "";
                                displayingText2 =
                                    bValid ? getTextOf(2 * index + 1) : "";

                                wordPair = bValid
                                    ? currentChapter
                                        .words[getWordPairIndex(2 * index)]
                                    : WordPair.nullWordPair();

                                bFocused1 = 2 * index == focusedIndex;
                                bFocused2 = 2 * index + 1 == focusedIndex;
                              } else {
                                print("Causing errors : $index");
                                int size = countFavourite();

                                bValid = index < size;
                                wordPair = bValid
                                    ? currentChapter
                                        .words[getFavouriteIndex(index)]
                                    : WordPair.nullWordPair();
                                if (bShowingWords) {
                                  displayingText1 =
                                      bValid ? wordPair.word1 : "";
                                  displayingText2 =
                                      bValid ? wordPair.word2 : "";
                                } else {
                                  displayingText1 =
                                      bValid ? wordPair.example1 : "";
                                  displayingText1 ??= "";
                                  displayingText2 =
                                      bValid ? wordPair.example2 : "";
                                  displayingText2 ??= "";
                                }
                                print(index);
                                print(displayingText1);
                                print(displayingText2);

                                bFocused1 = bValid
                                    ? 2 * getFavouriteIndex(index) ==
                                        focusedIndex
                                    : false;
                                bFocused2 = bValid
                                    ? 2 * getFavouriteIndex(index) + 1 ==
                                        focusedIndex
                                    : false;
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
                                      currentChapter: currentChapter,
                                      addWord: addWord,
                                      bDeleteMode: bDeleteMode,
                                      deleteWord: removeWord,
                                      changeFocus: changeFocus,
                                      bFocused: bFocused1,
                                      wordAdditionBuffer: wordAdditionBuffer,
                                      wordPair: wordPair,
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
                                      bFocused: bFocused2,
                                      wordAdditionBuffer: wordAdditionBuffer,
                                      wordPair: wordPair,
                                    ),
                                  ],
                                ),
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
                      wordCount: currentChapter.words.length,
                      bReadOnly: bReadOnly,
                      toggleReadOnly: toggleReadOnly,
                      chapterName: currentChapter.name,
                      bFavourite: isLiked(),
                      changeFavourite: changeFavourite,
                      getFavourite: () {
                        return isLiked();
                      },
                      favouriteCount: countFavourite(),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
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
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                suffixIcon: Transform.translate(
                                  offset:
                                      (MediaQuery.of(context).size.height < 600)
                                          ? const Offset(0, 3)
                                          : const Offset(0, 0),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.grey.withOpacity(0.5),
                                    onPressed: () {},
                                  ),
                                ),
                                prefixIcon: Transform.translate(
                                  offset:
                                      (MediaQuery.of(context).size.height < 600)
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
                                    (MediaQuery.of(context).size.height < 600)
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
                                            wordAdditionBuffer
                                                .word1.isNotEmpty) {
                                          changeFocus(focusedIndex! + 1);
                                        } else {
                                          changeFocus(focusedIndex!);
                                        }
                                      } else {
                                        if (wordAdditionBuffer.word1.isEmpty ||
                                            wordAdditionBuffer
                                                .word2.isNotEmpty) {
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
                                jumpToIndex(focusedIndex!);
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
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  double calcRatio(BuildContext context) =>
      (MediaQuery.of(context).size.width / 2) / 50;
}
