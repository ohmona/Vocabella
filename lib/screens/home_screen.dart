import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:vocabella/constants.dart';
import 'package:vocabella/main.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/managers/double_backup.dart';
import 'package:vocabella/managers/recent_activity.dart';
import 'package:vocabella/models/chapter_model.dart';
import 'package:vocabella/models/removed_subject_model.dart';
import 'package:vocabella/models/session_data_model.dart';
import 'package:vocabella/models/wordpair_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocabella/screens/debug_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';
import 'package:vocabella/screens/subject_creation_screen.dart';
import 'package:vocabella/widgets/recycle_bin_grid_tile_widget.dart';

import '../arguments.dart';
import '../managers/session_saver.dart';
import '../models/subject_data_model.dart';
import '../widgets/bottom_button_widget.dart';
import '../widgets/subject_creating_dialog_widget.dart';
import '../widgets/subject_tile_widget.dart';
import 'chapter_selection_screen.dart';
import 'editor_screen.dart';

enum AddOption {
  import,
  createNewSubject,
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return const Body();
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int focusedIndex = 0;

  late Timer autoRefresher;

  /// Load new subject by picking a file
  void loadNewData() async {
    // Clear cache before picking
    await FilePicker.platform.clearTemporaryFiles();

    // Pick a file
    Future<FilePickerResult?> result = DataPickerManager.pickFile();

    result.then((value) async {
      if (value != null) {
        // Get the path of the picked file
        final String path = value.files.single.path!;

        // Read data from the file with got path
        String content = await DataReadWriteManager.readDataByPath(path);
        if (kDebugMode) {
          print("==================================");
          print("Path of picked content");
          log(path);
          print("Raw string");
          log(content);
        }

        // Create a list of subject-objects by read data
        List<SubjectDataModel> newSubjectList =
            SubjectDataModel.listFromJson(content);

        final existingIndex =
            SubjectDataModel.getSubjectIndexByName(newSubjectList[0].title);
        if (newSubjectList.length > 1 || existingIndex == -1) {
          // Add them all to static list
          SubjectDataModel.addAll(newSubjectList);
        } else {
          if (kDebugMode) {
            print("==================================");
            print(
                "Printing pasting data before merging : ${newSubjectList[0].title}");
            newSubjectList[0].printData();
          }
          // Merge data
          SubjectDataModel.merge(newSubjectList[0],
              to: SubjectDataModel.subjectList[existingIndex]);
        }

        // Save updated data to file
        await DataReadWriteManager.writeData(
            SubjectDataModel.listToJson(SubjectDataModel.subjectList));
      }
      setState(() {});
    });
  }

  /// Create a empty subject-data and open editor immediately
  void createNewSubject({
    required String newTitle,
    required String newSubject1,
    required String newSubject2,
    required String newLanguage1,
    required String newLanguage2,
    required String newChapter,
  }) {
    // Create dummy-data of WordPair and Chapter to add
    WordPair dummyWord = WordPair(
      word1: "type your word",
      word2: "type your word",
    );
    Chapter firstChapter = Chapter(
      name: newChapter,
      words: [dummyWord],
      id: 1,
    );
    firstChapter.updateAllId();

    // Create dummy subject-data by just created dummy-data
    SubjectDataModel newSubject = SubjectDataModel(
      title: newTitle,
      subjects: [newSubject1, newSubject2],
      languages: [newLanguage1, newLanguage2],
      wordlist: [firstChapter],
      thumb: "",
      id: makeSubjectId(date: DateTime.now().toString(), name: newTitle),
      version: appVersion,
    );

    setState(() {
      // Add just created, empty subject-data to static list
      SubjectDataModel.subjectList.add(newSubject);

      // Save updated list to local storage
      DataReadWriteManager.writeData(
          SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    });

    RecentActivity.latestOpenedSubject = focusedIndex;
    // Open subject-editor with created subject
    openEditor(newSubject);
  }

  /// Open editor with chosen data
  void openEditor(SubjectDataModel subject) {
    RecentActivity.latestOpenedSubject =
        SubjectDataModel.getSubjectIndexByName(subject.title);
    Navigator.pushNamed(
      context,
      EditorScreenParent.routeName,
      arguments: EditorScreenArguments(
        subject,
        () => setState(() {}),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  /// Unless there's no existing subject to open, open the editor with focusing subject
  void onPressOpenEditor() {
    if (SubjectDataModel.subjectList.isEmpty) {
      sendToastMessage(
        context: context,
        msg: "Hmm... It seems to be you haven't any subject to edit",
        duration: const Duration(seconds: 1),
      );
      return;
    }

    openEditor(SubjectDataModel.subjectList[focusedIndex]);
  }

  /// Unless there's no subject existing, push user to chapter selection of focused subject
  void onPressContinue() {
    if (SubjectDataModel.subjectList.isEmpty) {
      sendToastMessage(
        context: context,
        msg: "Hmm... It seems to be you haven't any subject to practice",
        duration: const Duration(seconds: 1),
      );
      return;
    }

    onContinue(SubjectDataModel.subjectList[focusedIndex]);
  }

  /// Push user to chapter selection of given subject
  void onContinue(SubjectDataModel subject) {
    // Check number of word of focusing subject
    int wordNum = 0;
    for (Chapter chapter in subject.wordlist) {
      for (WordPair word in chapter.words) {
        word.word1;
        wordNum++;
      }
    }
    final bool enoughWord = wordNum >= 3;
    if (!enoughWord) {
      sendToastMessage(
        context: context,
        msg: "Subjects should contain more than 2 words",
        duration: const Duration(milliseconds: 500),
      );
      return;
    }

    // If everything is ok, save index and push user to chapter-selection
    RecentActivity.latestOpenedSubject =
        SubjectDataModel.getSubjectIndexByName(subject.title);
    Navigator.pushNamed(
      context,
      ChapterSelectionScreenParent.routeName,
      arguments: ChapterSelectionScreenArguments(
        subject,
      ),
    );
  }

  /// Unless there's no subject existing, move focusing subject to recycle bin
  void onPressDeleteSubject() async {
    if (SubjectDataModel.subjectList.isEmpty) {
      sendToastMessage(
        context: context,
        msg: "Hmm... It seems to be you haven't any subject to delete",
        duration: const Duration(seconds: 1),
      );
      return;
    }

    RemovedSubjectModel.moveToRecycleBin(focusedIndex);
    await RemovedSubjectModel.saveRecycleBinData();

    await DataReadWriteManager.writeData(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));

    // Since data has been updated, we have to backup it as well
    await DoubleBackup.toggleDBCount();
    await DoubleBackup.saveDoubleBackup(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));

    // If user deleted last subject, due to out of bound issue, reset focused index to 0
    if (focusedIndex > SubjectDataModel.subjectList.length - 1) {
      focusedIndex = 0;
    }
    setState(() {});
  }

  /// Move subject in recycle bin with specific index to static subject list
  void restoreSubject(int index) async {
    RemovedSubjectModel.recycleBin[index].restore();
    await DataReadWriteManager.writeData(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    await RemovedSubjectModel.saveRecycleBinData();

    // Since data has been updated, we have to backup it as well
    await DoubleBackup.toggleDBCount();
    await DoubleBackup.saveDoubleBackup(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    setState(() {});
  }

  /// Delete data from recycle bin to dispose completely from session then save
  void removeSubjectCompletely(int index) {
    setState(() {
      RemovedSubjectModel.recycleBin[index].remove();
      RemovedSubjectModel.saveRecycleBinData();
    });
  }

  /// Restore backup data
  void restoreFromBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Restoring files...",
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        elevation: 10,
      ),
    );

    if (kDebugMode) {
      print("[Double Backup] Trying to restore...");
    }

    // load double backup data
    final firstData =
        await DoubleBackup.loadDoubleBackup(DoubleBackup.dbFirstSpec);
    final secondData =
        await DoubleBackup.loadDoubleBackup(DoubleBackup.dbSecondSpec);
    final lastCount = await DoubleBackup.loadDBCount();

    if (lastCount == DoubleBackup.dbFirstSpec) {
      if (firstData!.isEmpty || firstData == "[]") {
        await DoubleBackup.saveBackupDataToOriginal(secondData!);
      } else {
        await DoubleBackup.saveBackupDataToOriginal(firstData);
      }
    } else if (lastCount == DoubleBackup.dbSecondSpec) {
      if (secondData!.isEmpty || secondData == "[]") {
        await DoubleBackup.saveBackupDataToOriginal(firstData!);
      } else {
        await DoubleBackup.saveBackupDataToOriginal(secondData);
      }
    }

    Future.delayed(
      const Duration(milliseconds: 10),
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Restoration is finishing in 10 seconds...",
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 10),
            elevation: 10,
          ),
        );
      },
    );
    Future.delayed(
      const Duration(seconds: 10),
      () {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Restoration done",
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
              elevation: 10,
            ),
          );
          if (kDebugMode) {
            print("[Double Backup] Restoring done");
          }
        });
      },
    );
  }

  Future<bool> isDataValid() async {
    final data = await DataReadWriteManager.readData();
    if (data.isEmpty || data == "[]") {
      if (kDebugMode) {
        print("[Vocabella] Data is not valid.");
        print("[Vocabella] It's possible that there's actually no data");
        print("[Vocabella] or you're using the app for the first time.");
        print(
            "[Vocabella] If the app crashed once, the data can possibly be destroyed");
        print("[Vocabella] It's necessary to try to restore the data then");
      }
      return false;
    } else {
      return true;
    }
  }

  Future<void> openReminder(BuildContext context) {
    String info = "This app was made by none-professional.\n"
        "So some parts of the app could not work properly.\n"
        "If you found any issue, please contact via email [ohmona.uhu@gmail.com].\n"
        "Once the app doesn't show correct data or anything,\n"
        "try restoring through [menu (left-top)] -> [restore (right-bottom)]\n";
    "And also remind that this popup will appear every startup\n";

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reminder"),
          content: Text(info),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("ok"),
            ),
          ],
        );
      },
    );
  }

  Future<void> openSessionReStarter(
      BuildContext context, SessionDataModel sessionData) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Session found"),
          content: const Text(
              "Unfinished session has been found, would you like to restart?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SessionSaver.session = SessionDataModel(existSessionData: false);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("no"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  QuizScreenParent.routeName,
                  arguments: QuizScreenArguments(
                    [],
                    "",
                    "",
                    sessionData,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Activate auto-refresher
    autoRefresher = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        if (kDebugMode) print("auto-refreshing");
      });
    });

    isDataValid().then((validity) {
      if (!validity) {
        if (kDebugMode) {
          print("[Vocabella] Automatically restoring data");
        }
        restoreFromBackup();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Loading files...",
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            elevation: 10,
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //openReminder(context);

      final startPoint = RecentActivity.latestOpenedSubject;
      focusedIndex = startPoint;

      SessionSaver.readSessionData().then((value) {
        print("=====================");
        print("fetched data");
        sessionData = SessionDataModel.fromJson(jsonDecode(value!));
        sessionDataFound = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    // Deactivate auto-refresher
    autoRefresher.cancel();
  }

  bool startUp = true;

  bool sessionDataFound = false;
  bool sessionStarterShown = false;
  late SessionDataModel sessionData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataReadWriteManager.readData(),
      builder: (context, snapshot) {
        bool bLoaded = snapshot.hasData;
        RemovedSubjectModel.loadRecycleBinData();
        RemovedSubjectModel.autoRemove();

        // In this section comes commands to run after the data has been loaded
        if (bLoaded && startUp) {
          Future.delayed(
            const Duration(milliseconds: 100),
            () {
              // Scroll a bit on start up to refresh focus
              scroller.jumpTo(scroller.offset + 0.1);
              startUp = false;
            },
          );
        }

        return Scaffold(
          appBar: buildAppBar(context, bLoaded),
          body: Container(
            decoration: const BoxDecoration(
              gradient: bgGradient,
            ),
            child: Column(
              children: [
                buildScrollSnapList(
                  context: context,
                  subjects: bLoaded
                      ? SubjectDataModel.listFromJson(snapshot.data)
                      : [],
                  bLoaded: bLoaded,
                ),
                buildBottomButtons(context),
                const SizedBox(height: 39),
                Builder(
                  builder: (context) {
                    if (sessionDataFound && !sessionStarterShown) {
                      sessionStarterShown = true;
                      if (sessionData.existSessionData) {
                        if (kDebugMode) {
                          print("[Session] Valid session data found!");
                        }
                        sessionData.printData();
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () {
                            openSessionReStarter(context, sessionData);
                          },
                        );
                      } else {
                        if (kDebugMode) {
                          print("[Session] No valid session data found!");
                          sessionData.printData();
                        }
                      }
                    }
                    return const SizedBox(height: 1, width: 1);
                  },
                ),
              ],
            ),
          ),
          drawer: buildDrawer(context),
        );
      },
    );
  }

  PreferredSizeWidget? buildAppBar(BuildContext context, bool bLoaded) {
    late String title;
    // Since build method cannot be asynchronous, catch the time before data loaded
    try {
      title = SubjectDataModel.subjectList[focusedIndex].title;
    } catch (e) {
      title = "";
    }

    return AppBar(
      elevation: 0,
      title: Text(title),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              loadNewData();
            });
          },
          icon: const Icon(
            Icons.add_box_outlined,
          ),
        ),
      ],
    );
  }

  Drawer buildDrawer(BuildContext context) {
    bool bBuildRecycleBin = RemovedSubjectModel.recycleBin.isNotEmpty;
    List<Widget> recycleBinWidget = buildRecycleBin();
    List<Widget> emptyRecycleBinWidget = [buildEmptyRecycleBin()];

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Theme.of(context).cardColor,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: GestureDetector(
              onDoubleTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DebugScreen()),
                );
              },
              child: const Text(
                "Vocabella",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          for (Widget widget
              in (bBuildRecycleBin ? recycleBinWidget : emptyRecycleBinWidget))
            widget,
          Container(
            height: 60,
            width: double.infinity,
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Text(
                  appInfo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          restoreFromBackup();
                        });
                      },
                      icon: const Icon(
                        Icons.settings_backup_restore,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        XFile file = XFile(
                            await DataReadWriteManager.getLocalFilePath());
                        Share.shareXFiles([file]);
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyRecycleBin() {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            color: Colors.grey,
            size: 100,
          ),
          Text(
            "Recycle bin is empty!",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildRecycleBin() {
    return [
      Container(
        height: 60,
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(10),
        child: const Text(
          "recycle bin",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Container(
        height: 1,
        width: double.infinity,
        color: Colors.grey,
      ),
      Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: RemovedSubjectModel.recycleBin.length,
          itemBuilder: (context, index) {
            return RecycleBinGridTile(
              data: RemovedSubjectModel.recycleBin[index],
              index: index,
              openDeleteConfirmation: openDeleteConfirmation,
              restoreSubject: restoreSubject,
            );
          },
        ),
      ),
    ];
  }

  var scroller = ScrollController();

  Widget buildScrollSnapList({
    required BuildContext context,
    required List<SubjectDataModel> subjects,
    required bool bLoaded,
  }) {
    return Builder(builder: (context) {
      if (bLoaded) {
        SubjectDataModel.subjectList = subjects;

        return Expanded(
          child: GestureDetector(
            child: ScrollSnapList(
              listController: scroller,
              dynamicItemOpacity: 0.95,
              scrollPhysics: const BouncingScrollPhysics(),
              focusOnItemTap: true,
              selectedItemAnchor: SelectedItemAnchor.MIDDLE,
              initialIndex: 1.0 * RecentActivity.latestOpenedSubject,
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length + 1,
              itemSize: 250,
              dynamicItemSize: true,
              onItemFocus: (index) {
                setState(() {
                  focusedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (index < subjects.length) {
                  return SubjectTile(
                    subject: subjects[index],
                    openEditor: openEditor,
                    openSelection: onContinue,
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    width: 250,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SubjectCreationScreenParent.routeName,
                          arguments: SubjectCreationScreenArguments(
                            createNewSubject,
                          ),
                        );
                      },
                      child: const Opacity(
                        opacity: 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_box_outlined,
                              color: Colors.white,
                              size: 250,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Touch to add new project",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        return Expanded(
          child: Center(
            child: SpinKitRing(
              color: Theme.of(context).cardColor,
            ),
          ),
        );
      }
    });
  }

  Row buildBottomButtons(BuildContext context) {
    if (focusedIndex < SubjectDataModel.subjectList.length) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BottomButton(
            size: 75,
            bBig: false,
            onPressed: onPressDeleteSubject,
            icon: Icons.delete,
          ),
          const SizedBox(width: 30),
          BottomButton(
            size: 100,
            bBig: true,
            onPressed: onPressContinue,
            icon: Icons.arrow_right,
          ),
          const SizedBox(width: 30),
          BottomButton(
            size: 75,
            bBig: false,
            onPressed: onPressOpenEditor,
            icon: Icons.edit,
          ),
        ],
      );
    } else {
      return const Row(
        children: [
          SizedBox(
            height: 100,
          )
        ],
      );
    }
  }

  Future<void> openSubjectCreator(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SubjectCreatingDialog(
          createNewSubject: createNewSubject,
        );
      },
    );
  }

  Future<void> openDeleteConfirmation(BuildContext context, int index) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
              "Are you sure that you want to delete this subject permanently?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                removeSubjectCompletely(index);
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
