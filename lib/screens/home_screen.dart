import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/models/chapter_model.dart';
import 'package:vocabella/models/wordpair_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../arguments.dart';
import '../models/subject_data_model.dart';
import '../widgets/subject_creating_dialog_widget.dart';
import '../widgets/subject_tile_widget.dart';
import 'chapter_selection_screen.dart';
import 'editor_screen.dart';

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

  void loadNewData() {
    DataPickerManager.pickFile().then((result) {
      if (result != null) {
        DataReadWriteManager.readDataByPath(result.files.single.path!)
            .then((value) {
          setState(() {
            SubjectDataModel.addAll(SubjectDataModel.listFromJson(value));

            DataReadWriteManager.writeData(
                SubjectDataModel.listToJson(SubjectDataModel.subjectList));
          });
        });
      }
    });
  }

  void reset() {
    // Clear the subjectList before adding new data
    SubjectDataModel.subjectList.clear();
    setState(() {});
    DataReadWriteManager.writeData("");
  }

  late SubjectDataModel creatingSubject;

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

  void createNewSubject({
    required String newTitle,
    required String newSubject1,
    required String newSubject2,
    required String newLanguage1,
    required String newLanguage2,
    required String newChapter,
  }) {
    WordPair dummyWord =
        WordPair(word1: "type your word", word2: "type your word");
    Chapter firstChapter = Chapter(name: newChapter, words: [dummyWord]);
    SubjectDataModel newSubject = SubjectDataModel(
      title: newTitle,
      subjects: [newSubject1, newSubject2],
      languages: [newLanguage1, newLanguage2],
      wordlist: [firstChapter],
      thumb: "",
    );

    setState(() {
      SubjectDataModel.subjectList.add(newSubject);
      DataReadWriteManager.writeData(
          SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    });

    openEditor(newSubject);
  }

  /// Open editor with chosen data
  void openEditor(SubjectDataModel subject) {
    Navigator.pushNamed(
      context,
      EditorScreenParent.routeName,
      arguments: EditorScreenArguments(
        subject,
      ),
    ).then((value) {
      setState(() {});
    });
  }

  void continueWithSubject() {
    int wordNum = 0;
    for (Chapter chapter
        in SubjectDataModel.subjectList[focusedIndex].wordlist!) {
      for (WordPair word in chapter.words) {
        word.word1;
        wordNum++;
      }
    }
    if (wordNum >= 3) {
      Navigator.pushNamed(
        context,
        ChapterSelectionScreen.routeName,
        arguments: ChapterSelectionScreenArguments(
          SubjectDataModel.subjectList[focusedIndex],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Subjects should contain more than 2 words",
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          elevation: 10,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataReadWriteManager.readData(),
      builder: (context, snapshot) {
        bool bLoaded = snapshot.hasData;

        return Scaffold(
          appBar: buildAppBar(context, bLoaded),
          body: Column(
            children: [
              const SizedBox(height: 40),
              buildScrollSnapList(
                context: context,
                subjects:
                    bLoaded ? SubjectDataModel.listFromJson(snapshot.data) : [],
                bLoaded: bLoaded,
              ),
              buildBottomButtons(context),
              const SizedBox(height: 40),
            ],
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  alignment: Alignment.bottomLeft,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: const Text(
                    "Vocabella",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return;
                    },
                  ),
                ),
                Container(
                  height: 60,
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Row buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BottomButton(
          size: 75,
          bBig: false,
          onPressed: () {
            // TODO delete focused subject
          },
          icon: Icons.delete,
        ),
        const SizedBox(
          width: 30,
        ),
        BottomButton(
          size: 100,
          bBig: true,
          onPressed: continueWithSubject,
          icon: Icons.arrow_right,
        ),
        const SizedBox(
          width: 30,
        ),
        BottomButton(
          size: 75,
          bBig: false,
          onPressed: () {
            openEditor(SubjectDataModel.subjectList[focusedIndex]);
          },
          icon: Icons.edit,
        ),
      ],
    );
  }

  Widget buildScrollSnapList({
    required BuildContext context,
    required List<SubjectDataModel> subjects,
    required bool bLoaded,
  }) {
    return Builder(builder: (context) {
      if (bLoaded) {
        SubjectDataModel.subjectList = subjects;

        return Expanded(
          child: ScrollSnapList(
            scrollPhysics: const BouncingScrollPhysics(),
            initialIndex: 0,
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length,
            itemSize: MediaQuery.of(context).size.width - 150,
            dynamicItemSize: true,
            onItemFocus: (index) {
              setState(() {
                focusedIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return SubjectTile(
                subject: subjects[index],
                openEditor: openEditor,
              );
            },
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

  PreferredSizeWidget? buildAppBar(BuildContext context, bool bLoaded) {
    late String title;
    try {
      title = SubjectDataModel.subjectList[focusedIndex].title!;
    }
    catch(e) {
      title = "";
    }

    return AppBar(
      title: Text(title),
      actions: <Widget>[
        PopupMenuButton(
          icon: const Icon(Icons.add),
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: AddOption.createNewSubject,
                child: Text("create new project"),
              ),
              const PopupMenuItem(
                value: AddOption.import,
                child: Text("import existing data"),
              ),
            ];
          },
          onSelected: (value) {
            setState(() {
              if (value == AddOption.createNewSubject) {
                openSubjectCreator(context);
              } else if (value == AddOption.import) {
                loadNewData();
              }
            });
          },
        ),
      ],
    );
  }
}

enum AddOption {
  import,
  createNewSubject,
}

class BottomButton extends StatelessWidget {
  const BottomButton(
      {Key? key,
      required this.size,
      required this.bBig,
      required this.onPressed,
      required this.icon})
      : super(key: key);

  final double size;
  final bool bBig;
  final void Function() onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(90)),
          ),
          backgroundColor: Theme.of(context).cardColor,
          shadowColor: Theme.of(context).cardColor,
          elevation: 10,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: bBig ? 75 : 25,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: bBig ? 10 : 5,
            ),
          ],
        ),
      ),
    );
  }
}
