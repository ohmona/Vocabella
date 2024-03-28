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

class SelectionList {
  late List<bool> _selectionList;
  late int count;

  SelectionList(int size) {
    reset(size);
  }

  void reset(int size) {
    _selectionList = [];
    count = 0;
    for (int i = 0; i < size; i++) {
      _selectionList.add(false);
    }
  }

  bool isSelected(int index) {
    try {
      return _selectionList[index];
    } catch (e) {
      return false;
    }
  }

  void select(int index) {
    if (_selectionList.length > index) {
      _selectionList[index] = true;
      count += 1;
    }
  }

  void deselect(int index) {
    if (_selectionList.length > index) {
      _selectionList[index] = false;
      count -= 1;
    }
  }

  void increase() {
    _selectionList.add(false);
  }

  void decrease(int index) {
    _selectionList.removeAt(index);
  }

  List<int> allSelected() {
    List<int> list = [];
    for (int i = 0; i < _selectionList.length; i++) {
      if (isSelected(i)) {
        list.add(i);
      }
    }
    return list;
  }
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
  ////////////////////////////////////////
  // VARIABLE

  // STATIC FIELD
  static const scrollCurve = Curves.easeOutQuint;
  static const double bottomBarHeight = 40;
  static const double gridViewTopMargin = 105;

  // BOOL
  bool bShowingWords = true;
  bool bReadOnly = false;
  bool bDeleteMode = false;
  bool bAddingNewWord = false;
  bool bShowingFavouriteOnly = false;
  bool bCrossMode = false;
  bool bPasted = true;
  bool bFocusing = true; // focus mode vs select mode

  // NUMBER
  int? focusedIndex;
  late int _idKeyboardListener;
  late double _viewInsetsBottom;

  // TEXT
  late String currentChapterPath;
  late String textBeforeEdit;
  late List<String> visibleList;

  // CORE DATA
  late SubjectDataModel subjectData;

  late WordPair wordAdditionBuffer;
  late List<DisplayingWord> displayingWords;
  late List<DisplayingWord> clipBoard;
  late List<DisplayingWord> temporaryBin;

  // CONTROLLER
  ScrollController scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  FocusNode bottomBarFocusNode = FocusNode();
  FocusNode wordAdderFocusNode = FocusNode();
  late SelectionList selectionList;

  // KEY
  GlobalKey listViewKey = GlobalKey();
  GlobalKey<ChapterSelectionDrawerState> chapterDrawerKey = GlobalKey();

  // TIMER
  late Timer autoSaveTimer;

  // VIEW MODE
  late ViewMode viewMode;

  // KEYBOARD
  late KeyboardUtils _keyboardUtils;

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
    clipBoard = [];
    temporaryBin = [];
    wordAdditionBuffer = WordPair(
      word1: "",
      word2: "",
      created: DateTime.now(),
      lastEdit: DateTime.now(),
      salt: "",
    );

    // Apply last opened chapter and grid
    Chapter startUpChapter;
    startUpChapter = subjectData.wordlist[
        subjectData.indexOf(subjectData.lastOpenedChapter ?? "/") ?? 0];
    focusedIndex = startUpChapter.lastIndex ?? 0;
    currentChapterPath = startUpChapter.comprisePath();

    // Initialize Word List
    refreshDisplay(startUpChapter);
    selectionList = SelectionList(displayingWords.length);
    textBeforeEdit = getText(focusedIndex!);

    // Keyboard settings
    if (Platform.isIOS || Platform.isAndroid) {
      _keyboardUtils = KeyboardUtils();
      _idKeyboardListener = _keyboardUtils.add(
          listener: keyboard_listener.KeyboardListener(
        willHideKeyboard: () {
          if (kDebugMode) {
            print("========================");
            print("hiding keyboard");
          }
        },
        willShowKeyboard: (double keyboardHeight) {
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

    // activate auto-save
    if (!AppConfig.bDebugMode) {
      autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
        saveData();
      });
    }
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // GETTER & SETTER

  bool isTargetingQuestion(int index) => index % 2 == 0;

  bool isValidIndex(int index) => index < getContentCount();

  bool isAdditionIndex(int index) => index == getContentCount() + 1;

  bool isClipboardNotEmpty() => clipBoard.isNotEmpty;

  bool isSelectionNotEmpty() => selectionList.count != 0;

  bool isBinNotEmpty() => temporaryBin.isNotEmpty;

  int getContentCount() => displayingWords.length * 2;

  int getChapterIndexByPath(String path) {
    for (var element in subjectData.wordlist) {
      if (element.comprisePath() == path) {
        return subjectData.wordlist.indexOf(element);
      }
    }
    return -1;
  }

  int getCurrentChapterIndex() => subjectData.indexOf(currentChapterPath) ?? -1;

  int getWordPairIndex(int gridIndex) => gridIndex ~/ 2;

  double calcRatio(BuildContext context) =>
      (MediaQuery.of(context).size.width / 2) / 50;

  String getChapterName(int index) =>
      subjectData.wordlist[index].comprisePath();

  ////////////////////////////////////////

  ////////////////////////////////////////
  // TOGGLE MODE

  void toggleWords() {
    setState(() {
      bDeleteMode = false;
      bShowingWords = !bShowingWords;
      setText(getText(focusedIndex!), focusedIndex!);
    });
    textEditingController.text = getText(focusedIndex!);
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

  void toggleFocusSelectMode() => setState(() {
    bFocusing = !bFocusing;
  });

  ////////////////////////////////////////

  ////////////////////////////////////////
  // WORD

  /// returns the text of targeting index
  String getText(int index) {
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

  /// updates the text of targeting index
  void setText(String newText, int index) {
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

    // Get current list size
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
      selectionList.increase();
    });
  }

  void terminateWordAddition() {
    bAddingNewWord = false;
    if (wordAdditionBuffer.word1.isNotEmpty &&
        wordAdditionBuffer.word2.isNotEmpty) {
      wordAdditionBuffer.created = DateTime.now();
      wordAdditionBuffer.lastEdit = DateTime.now();
      wordAdditionBuffer.salt = generateRandomString(8);
      addWord(wordAdditionBuffer);
    }

    wordAdditionBuffer = WordPair(
      word1: "",
      word2: "",
      created: DateTime.now(),
      lastEdit: DateTime.now(),
      salt: "",
    );
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // CHAPTER

  void addVisibleList(String path) {
    if (!visibleList.contains(path)) {
      visibleList.add(path);
    }
  }

  void removeVisibleList(String path) => visibleList.remove(path);

  /// Change selected chapter
  void changeChapter(String newPath) {
    // Reset to initial state
    bShowingWords = true;
    bDeleteMode = false;
    bottomBarFocusNode.unfocus();

    bFocusing = true;
    operationOffset = 50;

    if (currentChapterPath == newPath) return;

    temporaryBin = [];

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

        // Load the desired chapter from subject data
        focusedIndex = subjectData.wordlist[newChapterIndex].lastIndex;

        refreshDisplay(subjectData.wordlist[newChapterIndex]);

        resetSelect();

        currentChapterPath = newPath;

        // Save this chapter as latest opened
        subjectData.lastOpenedChapter = currentChapterPath;

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
        salt: generateRandomString(8),
        created: DateTime.now(),
      );
      subjectData.chapterCount += 1;
      newChapter.wordCount = 1;
      subjectData.wordlist.add(newChapter);
    });
    changeChapter(newName);
    return true;
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
    if (kDebugMode) {
      print("moving chapter $target $destination");
    }
    int oldIndex = getChapterIndexByPath(target);

    String oldName = target.split("/").last;
    String pathOnly = target.substring(0, target.length - oldName.length);

    if (pathOnly == destination) return;

    if (kDebugMode) {
      print("chapter [$oldName] moved : from $pathOnly, to $destination");
    }

    bool exist = existChapterNameAlready(oldName, path: destination);

    if (!exist) {
      addVisibleList(destination);
      subjectData.wordlist[oldIndex].path = destination;
      resortChapters();
      chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
      if (currentChapterPath == target) {
        if (kDebugMode) {
          print("moving focused one");
        }
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
    if (kDebugMode) {
      print("Inserting Chapter");
      print("start:$start, size:$size, target:$target");
    }

    subjectData.printData();
    if (kDebugMode) {
      print("Start Inserting");
    }
    List<Chapter> list = [];
    for (int i = start; i < start + size; i++) {
      list.add(subjectData.wordlist[i]);
    }
    if (kDebugMode) {
      print("I Queue: $list");
    }
    subjectData.printData();
    for (var element in list) {
      subjectData.wordlist.remove(element);
    }
    if (kDebugMode) {
      print("II Edited: ${subjectData.wordlist}");
    }
    subjectData.printData();
    for (int i = 0; i < list.length; i++) {
      if (start < target) {
        if (kDebugMode) {
          print("III Inserting: ${list[i]} to ${i + target - size}");
        }
        subjectData.wordlist.insert(i + target - size, list[i]);
      } else {
        if (kDebugMode) {
          print("Moving to top");
          print("Target ${i + target}, ${list[i]}");
        }
        subjectData.wordlist.insert(i + target, list[i]);
      }
    }
    subjectData.printData();
    resortChapters();
    chapterDrawerKey.currentState!.updateLists(subjectData.wordlist);
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
          return -1;
        } else if (s.startsWith(b)) {
          return 1;
        }
      }
    }
    return -1;
  }

  void refreshDisplay(Chapter chapter) {
    displayingWords = [];
    for (var word in chapter.words) {
      displayingWords.add(
        DisplayingWord(
          wordPair: word,
          path: currentChapterPath,
          index: chapter.words.indexOf(word),
        ),
      );
    }
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // META DATA

  void changeSubjectAndLanguage({
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

  ////////////////////////////////////////

  ////////////////////////////////////////
  // STORAGE

  void saveData() async {
    if (focusedIndex == null) return null;

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

      // After that we need to create another backup for fatal case like loosing data
      // Firstly, we toggle the count
      await DoubleBackup.toggleDBCount(); // FUTURE

      // Then save the backup data
      await DoubleBackup.saveDoubleBackup(
          SubjectDataModel.listToJson(SubjectDataModel.subjectList)); // FUTURE
    }
    return null;
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // FOCUS

  void changeFocus(
    int newIndex, {
    bool requestFocus = true,
    bool force = false,
  }) {
    // Make sure that user doesn't make silly issue
    if (newIndex >= getContentCount() + 2) return;
    if (!isValidIndex(newIndex) && !bShowingWords) return;

    if (bReadOnly) return;

    if (focusedIndex != null && isValidIndex(focusedIndex!)) {
      if (getText(focusedIndex!).isEmpty && bShowingWords) {
        setText(textBeforeEdit, focusedIndex!);
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
        bottomBarFocusNode.requestFocus();
        textEditingController.text = getText(newIndex);
      } else {
        textEditingController.text = getText(newIndex);
      }

      if (kDebugMode) {
        print("=================================");
        print("Change focus");
      }

      if (Platform.isAndroid || Platform.isIOS) {
        jumpToIndex(smallIndex: focusedIndex! ~/ 2);
      }
      //scrollDelayedToFocus(delay: const Duration(milliseconds: 1));
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: textEditingController.text.length,
        ),
      );
      textBeforeEdit = getText(newIndex);
    });
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // SCROLL

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

  double calcOffsetToScroll({required int smallIndex}) {
    final itemCount = (getContentCount() / 2 + 1).toInt();
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

  ////////////////////////////////////////

  ////////////////////////////////////////
  // KEYBOARD

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

  ////////////////////////////////////////

  ////////////////////////////////////////
  // MODIFICATION

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

  bool isFocusedLiked() {
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

  int favouriteCount() {
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
    return num;
  }

  ////////////////////////////////////////

  ////////////////////////////////////////
  // GRAPHIC

  void showLoadingScreen(BuildContext context) =>
      Navigator.of(context).push(LoadingOverlay());

  ////////////////////////////////////////

  ////////////////////////////////////////
  // OPERATION

  void selectWord(int wordPairIndex) => setState(() {
        selectionList.select(wordPairIndex);
      });

  void deselectWord(int wordPairIndex) => setState(() {
        selectionList.deselect(wordPairIndex);
      });

  void resetSelect({bool refresh = true}) {
    selectionList.reset(displayingWords.length);
    if (refresh) {
      setState(() {});
    }
  }

  void toggleSelect(int wordPairIndex) {
    if (!selectionList.isSelected(wordPairIndex)) {
      selectWord(wordPairIndex);
    } else {
      deselectWord(wordPairIndex);
    }
  }

  void operateCopy() {
    final list = selectionList.allSelected();
    clipBoard = [];
    for (var index in list) {
      clipBoard.add(displayingWords[index]);
    }
  }

  void operateCross() {
    if (selectionList.count == displayingWords.length) {
      openAlert(context,
          title: "Warning", content: "You can't cut the entire Word List");
      return;
    }

    final list = selectionList.allSelected();
    clipBoard = [];
    for (var index in list) {
      clipBoard.add(displayingWords[index]);
    }
    for (var element in clipBoard) {
      displayingWords.remove(element);
    }
    selectionList.reset(displayingWords.length);
    List<WordPair> words = [];
    for (var element in displayingWords) {
      words.add(element.wordPair);
    }
    subjectData.wordlist[getCurrentChapterIndex()].words = words;
    refreshDisplay(subjectData.wordlist[getCurrentChapterIndex()]);
    bPasted = false;
    if (displayingWords.length * 2 > focusedIndex!) {
      changeFocus(focusedIndex!);
    } else {
      changeFocus(displayingWords.length * 2 - 1);
    }
  }

  void operatePaste() {
    for (int i = 0; i < clipBoard.length; i++) {
      var element = clipBoard[i];
      final index = getCurrentChapterIndex();
      var wordPair = element.wordPair;
      wordPair.salt = generateRandomString(5);
      wordPair.created = DateTime.now();
      print("${(focusedIndex! ~/ 2) + 1 + i} ${element.wordPair.word1}");
      subjectData.wordlist[index].words
          .insert((focusedIndex! ~/ 2) + 1 + i, element.wordPair);
    }
    refreshDisplay(subjectData.wordlist[getCurrentChapterIndex()]);
    selectionList.reset(displayingWords.length);
    bPasted = true;
  }

  void undoCrossing() {
    if (!bPasted) {
      List<List<DisplayingWord>> group = [];
      List<String> pathList = [];

      for (var element in clipBoard) {
        if (!pathList.contains(element.path)) {
          pathList.add(element.path);
          group.add([element]);
        } else {
          var i = pathList.indexOf(element.path);
          group[i].add(element);
        }
      }

      for (var element in group) {
        var path = pathList.elementAt(group.indexOf(element));
        var index = subjectData.indexOf(path);

        for (int i = 0; i < element.length; i++) {
          var target = element[i].index;
          subjectData.wordlist[index!].words
              .insert(target, element[i].wordPair);
        }
      }
      clipBoard = [];
    }
  }

  void operateDelete() {
    if (selectionList.count == displayingWords.length) {
      openConfirm(
        context,
        title: "Warning",
        content: "Are you sure you want to delete the chapter?",
        onConfirm: () {
          final index = getCurrentChapterIndex();
          if (index != 0) {
            changeChapter(subjectData.wordlist.first.comprisePath());
            subjectData.wordlist.removeAt(index);
          } else {
            if (subjectData.wordlist.length != 1) {
              changeChapter(subjectData.wordlist[1].comprisePath());
              subjectData.wordlist.removeAt(index);
            } else {
              openAlert(context,
                  title: "Warning",
                  content: "You can't delete the last remaining chapter");
            }
          }
        },
      );
      return;
    }

    openConfirm(
      context,
      title: "Warning",
      content: "Are you sure you want to delete the words?",
      onConfirm: () {
        final list = selectionList.allSelected();
        temporaryBin = [];
        for (var index in list) {
          temporaryBin.add(displayingWords[index]);
        }
        for (var element in temporaryBin) {
          displayingWords.remove(element);
        }
        selectionList.reset(displayingWords.length);
        List<WordPair> words = [];
        for (var element in displayingWords) {
          words.add(element.wordPair);
        }
        subjectData.wordlist[getCurrentChapterIndex()].words = words;
        refreshDisplay(subjectData.wordlist[getCurrentChapterIndex()]);
        if (displayingWords.length * 2 > focusedIndex!) {
          changeFocus(focusedIndex!);
        } else {
          changeFocus(displayingWords.length * 2 - 1);
        }
      },
    );
  }

  void operateUndoDeleting() {
    List<List<DisplayingWord>> group = [];
    List<String> pathList = [];

    for (var element in temporaryBin) {
      if (!pathList.contains(element.path)) {
        pathList.add(element.path);
        group.add([element]);
      } else {
        var i = pathList.indexOf(element.path);
        group[i].add(element);
      }
    }

    for (var element in group) {
      var path = pathList.elementAt(group.indexOf(element));
      var index = subjectData.indexOf(path);

      for (int i = 0; i < element.length; i++) {
        var target = element[i].index;
        subjectData.wordlist[index!].words.insert(target, element[i].wordPair);
        refreshDisplay(subjectData.wordlist[getCurrentChapterIndex()]);
      }
    }
    temporaryBin = [];
    selectionList.reset(displayingWords.length);
  }

  ////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
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
          setText(value, focusedIndex!);
          textEditingController.text = "";
          changeFocus(focusedIndex! + 1);
        });
      } else {
        setState(() {
          setText(value, focusedIndex!);
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

  bool operationBarOpened = false;
  double operationOffset = 50;

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
          if (AppConfig.bDebugMode)
            Text(
              "N:${subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].name}, P:${subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].path}, C:${subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].created}, S:${subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].salt}, L:${subjectData.wordlist[subjectData.indexOf(currentChapterPath)!].lastIndex}",
              style:
                  const TextStyle(fontSize: 7, color: Colors.black, shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 10,
                ),
              ]),
            ),
          Transform.translate(
            offset: (Platform.isAndroid || Platform.isIOS)
                ? Offset(
                    MediaQuery.of(context).size.width - operationOffset - 5,
                    MediaQuery.of(context).size.height -
                        130 -
                        MediaQuery.of(context).viewInsets.bottom)
                : Offset(MediaQuery.of(context).size.width - operationOffset,
                    MediaQuery.of(context).size.height - 90),
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (operationBarOpened == false) {
                        operationOffset =
                            (Platform.isAndroid || Platform.isIOS) ? 280 : 250;
                        bFocusing = false;
                        operationBarOpened = true;
                      } else {
                        operationOffset = 50;
                        bFocusing = true;
                        operationBarOpened = false;
                      }
                    });
                  },
                  backgroundColor:
                      (operationOffset != 250) ? Colors.grey : mintColor,
                  mini: true,
                  child: (operationOffset != 250)
                      ? const Icon(Icons.arrow_left)
                      : const Icon(Icons.arrow_right),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (isSelectionNotEmpty()) {
                      setState(() {
                        operateCopy();
                      });
                    }
                  },
                  backgroundColor:
                      isSelectionNotEmpty() ? mintColor : Colors.grey,
                  mini: true,
                  child: const Icon(Icons.copy),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (isSelectionNotEmpty()) {
                      setState(() {
                        operateCross();
                      });
                    }
                  },
                  backgroundColor:
                      isSelectionNotEmpty() ? mintColor : Colors.grey,
                  mini: true,
                  child: const Icon(Icons.cut),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (isClipboardNotEmpty()) {
                      setState(() {
                        operatePaste(); // TODO change to insert
                      });
                    }
                  },
                  backgroundColor:
                      isClipboardNotEmpty() ? mintColor : Colors.grey,
                  mini: true,
                  child: const Icon(Icons.paste),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (isSelectionNotEmpty()) {
                      setState(() {
                        operateDelete(); // TODO change to insert
                      });
                    }
                  },
                  backgroundColor:
                      isSelectionNotEmpty() ? mintColor : Colors.grey,
                  mini: true,
                  child: const Icon(Icons.delete),
                ),
                /*const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (isBinNotEmpty()) {
                      setState(() {
                        operateUndoDeleting();
                      });
                    }
                  },
                  backgroundColor: isBinNotEmpty() ? mintColor : Colors.grey,
                  mini: true,
                  child: const Icon(Icons.undo),
                ),*/
              ],
            ),
          ),
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
          ? favouriteCount() + 1
          : (getContentCount() / 2 + 1).toInt(),
      dragStartBehavior: DragStartBehavior.start,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (!bShowingFavouriteOnly) {
          final maxIndex = getContentCount() ~/ 2;
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

        bValid = index < getContentCount() ~/ 2;
        displayingText1 = bValid ? getText(2 * index) : "";
        displayingText2 = bValid ? getText(2 * index + 1) : "";

        if (bValid) {
          displayingText1 = getText(2 * index);
          displayingText2 = getText(2 * index + 1);
          wordPair = displayingWords[getWordPairIndex(2 * index)];
        } else if (index < (getContentCount() + 2) ~/ 2) {
          // end cells
          displayingText1 = getText(2 * index);
          displayingText2 = getText(2 * index + 1);
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

        return ReorderableDelayedDragStartListener(
          index: index,
          key: Key("$index"),
          child: Row(
            children: [
              WordGridTile(
                text: displayingText1,
                index: 2 * index,
                saveText: setText,
                bShowingWords: bShowingWords,
                bDeleteMode: bDeleteMode,
                changeFocus: changeFocus,
                bFocused: bFocused1,
                displayingWord: wordPair,
                viewMode: viewMode,
                listSize: displayingWords.length,
                toggleSelect: toggleSelect,
                focusMode: bFocusing,
                toggleFocusSelectMode: toggleFocusSelectMode,
                selectionList: selectionList,
              ),
              WordGridTile(
                text: displayingText2,
                index: 2 * index + 1,
                saveText: setText,
                bShowingWords: bShowingWords,
                bDeleteMode: bDeleteMode,
                changeFocus: changeFocus,
                bFocused: bFocused2,
                displayingWord: wordPair,
                viewMode: viewMode,
                listSize: displayingWords.length,
                toggleSelect: toggleSelect,
                focusMode: bFocusing,
                toggleFocusSelectMode: toggleFocusSelectMode,
                selectionList: selectionList,
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
            changeSubject: changeSubjectAndLanguage,
          ),
          Container(
            width: 2,
            height: 50,
            color: Colors.grey,
          ),
          LanguageBar(
            subjectData: subjectData,
            index: 1,
            changeSubject: changeSubjectAndLanguage,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
              horizontal: BorderSide(color: Colors.black87, width: 3)),
        ),
        height: bottomBarHeight,
        child: TextField(
          focusNode: bottomBarFocusNode,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.all((Platform.isAndroid || Platform.isIOS) ? 0 : 16),
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.black87,
              onPressed: () {
                _onPressSummit(textEditingController.text);
              },
            ),
            prefixIcon: IconButton(
              icon: Icon(
                bFocusing ? Icons.keyboard_alt_outlined : Icons.edit,
                color: Colors.black87,
              ),
              onPressed: toggleFocusSelectMode,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          controller: textEditingController,
          cursorColor: Colors.black87,
          textAlign: TextAlign.center,
          onChanged: (value) {
            if (focusedIndex != null) {
              setState(() {
                setText(value, focusedIndex!);
              });
            }
          },
          onSubmitted: _onPressSummit,
          onTap: () {
            jumpToIndex(smallIndex: focusedIndex! ~/ 2);
            if (focusedIndex == null) {
              bottomBarFocusNode.unfocus();
            }
          },
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
        return isFocusedLiked();
      },
      favouriteCount: favouriteCount(),
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
      undoCrossing: undoCrossing,
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
}
