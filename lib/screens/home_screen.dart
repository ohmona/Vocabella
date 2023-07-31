import 'package:flutter/material.dart';
import 'package:vocabella/constants.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/models/chapter_model.dart';
import 'package:vocabella/models/wordpair_model.dart';

import '../arguments.dart';
import '../models/subject_data_model.dart';
import '../widgets/subject_tile_widget.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocabella"),
      ),
      body: const Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  void loadNewData() {
    DataPickerManager.pickFile().then((result) {
      if (result != null) {
        DataReadWriteManager.readDataByPath(result.files.single.path!)
            .then((value) {
          SubjectDataModel.addAll(SubjectDataModel.listFromJson(value));

          refreshData();

          DataReadWriteManager.writeData(
              SubjectDataModel.listToJson(SubjectDataModel.subjectList));
        });
      }
    });
  }

  void refreshData() {
    DataReadWriteManager.readData().then((value) {
      try {
        if (value.isNotEmpty) {
          SubjectDataModel.subjectList = SubjectDataModel.listFromJson(value);
          print(value);
        }
      } catch (e) {
        if (e is FormatException) {
          print('You can only import files with extension ".json"');
        }
      }
      setState(() {});
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

    SubjectDataModel.subjectList.add(newSubject);
    refreshData();
    DataReadWriteManager.writeData(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));

    openEditor(newSubject);
  }

  /// Open editor with choosen data
  void openEditor(SubjectDataModel subject) {
    Navigator.pushNamed(
      context,
      EditorScreenParent.routeName,
      arguments: EditorScreenArguments(
        subject,
      ),
    ).then((value) {
      refreshData();
    });
  }

  @override
  void initState() {
    super.initState();
    // Load data
    DataReadWriteManager.readData().then((value) {
      if (value.isNotEmpty) {
        refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              for(SubjectDataModel subject in SubjectDataModel.subjectList)
                SubjectTile(
                  subject: subject,
                  refreshData: refreshData,
                  openEditor: openEditor,
                )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: loadNewData,
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: () {
                openSubjectCreator(context);
              },
              child: const Icon(Icons.add_box_outlined),
            ),
            ElevatedButton(
              onPressed: refreshData,
              child: const Icon(Icons.refresh),
            ),
            ElevatedButton(
              onPressed: reset,
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ],
    );
  }
}

class SubjectCreatingDialog extends StatefulWidget {
  const SubjectCreatingDialog({Key? key, required this.createNewSubject})
      : super(key: key);

  final void Function({
    required String newTitle,
    required String newSubject1,
    required String newSubject2,
    required String newLanguage1,
    required String newLanguage2,
    required String newChapter,
  }) createNewSubject;

  @override
  State<SubjectCreatingDialog> createState() => _SubjectCreatingDialogState();
}

class _SubjectCreatingDialogState extends State<SubjectCreatingDialog> {
  late String newTitle;
  late String newSubject1;
  late String newSubject2;
  late String newLanguage1;
  late String newLanguage2;
  late String newChapter;

  @override
  void initState() {
    super.initState();

    newTitle = "";
    newSubject1 = "";
    newSubject2 = "";
    newLanguage1 = "";
    newLanguage2 = "";
    newChapter = "";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create new subject"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "title",
              ),
              onChanged: (value) {
                newTitle = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "first subject",
              ),
              onChanged: (value) {
                newSubject1 = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "second subject",
              ),
              onChanged: (value) {
                newSubject2 = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "language : [$newLanguage1]",
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.language),
                  initialValue: newLanguage1,
                  itemBuilder: (context) {
                    return [
                      for (String str in languageList)
                        PopupMenuItem(
                          value: str,
                          child: Text(str),
                        )
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      newLanguage1 = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "language : [$newLanguage2]",
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.language),
                  initialValue: newLanguage2,
                  itemBuilder: (context) {
                    return [
                      for (String str in languageList)
                        PopupMenuItem(
                          value: str,
                          child: Text(str),
                        )
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      newLanguage2 = value;
                    });
                  },
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "first chapter name",
              ),
              onChanged: (value) {
                newChapter = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (newTitle.isNotEmpty &&
                newSubject1.isNotEmpty &&
                newSubject2.isNotEmpty &&
                newLanguage1.isNotEmpty &&
                newLanguage2.isNotEmpty &&
                newChapter.isNotEmpty) {
              widget.createNewSubject(
                newChapter: newChapter,
                newLanguage1: newLanguage1,
                newLanguage2: newLanguage2,
                newSubject1: newSubject1,
                newSubject2: newSubject2,
                newTitle: newTitle,
              );
            }
          },
          child: const Text("next"),
        ),
      ],
    );
  }
}
