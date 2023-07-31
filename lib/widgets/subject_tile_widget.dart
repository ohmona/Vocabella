import 'package:flutter/material.dart';
import 'package:vocabella/managers/data_handle_manager.dart';

import '../arguments.dart';
import '../models/chapter_model.dart';
import '../models/subject_data_model.dart';
import '../models/wordpair_model.dart';
import '../screens/chapter_selection_screen.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile(
      {Key? key,
      required this.subject,
      required this.refreshData,
      required this.openEditor})
      : super(key: key);

  final SubjectDataModel subject;
  final void Function() refreshData;
  final void Function(SubjectDataModel) openEditor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int wordNum = 0;
        for (Chapter chapter in subject.wordlist!) {
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
              subject,
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
      },
      onLongPress: () {
        openEditor(subject);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(100),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              const SizedBox(height: 50),
              FutureBuilder(
                future: DataReadWriteManager.loadExistingImage(subject.thumb ?? ""),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image(
                      image: FileImage(snapshot.data!),
                      height: 1920,
                      width: 1357,
                      fit: BoxFit.cover,
                    );
                  }
                  return const Icon(Icons.image);
                },
              ),
              const SizedBox(height: 50),
              Text(
                subject.title!,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    subject.subjects![0],
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  const Text(
                    " // ",
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    subject.subjects![1],
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
