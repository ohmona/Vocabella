import 'package:flutter/material.dart';

import '../utils/constants.dart';

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