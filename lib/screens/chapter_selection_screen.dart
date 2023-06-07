import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/screens/word_selection_screen.dart';

import '../classes.dart';

class ChapterSelectionScreen extends StatelessWidget {
  ChapterSelectionScreen({Key? key,})
      : super(key: key);

  static const routeName = '/chapters';

  late ChapterList chapterList;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ChapterSelectionScreenArguments;

    chapterList = ChapterList(subject: args.subject);

    return WillPopScope(
      onWillPop: () async {
        chapterList.setChapters([]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select chapters"),
        ),
        body: chapterList,
        bottomNavigationBar: FloatingActionButton(
          onPressed: () {
            print("==============================");
            print("Continue");
            Navigator.pushNamed(
              context,
              WordSelectionScreen.routeName,
              arguments: WordSelectionScreenArguments(
                chapterList.getChapters(),
                args.subject.languages!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChapterList extends StatefulWidget {
  ChapterList({Key? key, required this.subject}) : super(key: key);

  final SubjectDataModel subject;

  late List<Chapter> Function() getChapters;
  late void Function(List<Chapter>) setChapters;

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {

  List<Chapter> selectedChapters = [];
  Map<String, bool> isChecked = {};

  List<Chapter> getChapters() {
    selectedChapters = [];
    for (Chapter chapter in widget.subject.wordlist!) {
      if (isChecked[chapter.name] == true) {
        if(!selectedChapters.contains(chapter)) {
          selectedChapters.add(chapter);
        }
        print(chapter.name);
      }
    }
    return selectedChapters;
  }

  void setChapters(List<Chapter> newChapters) {
    selectedChapters = newChapters;
  }

  @override
  void initState() {
    super.initState();

    selectedChapters = [];
    isChecked = {};

    widget.getChapters = getChapters;
    widget.setChapters = setChapters;

    print("==============================");
    print("Initializing chapters");

    for (Chapter chapter in widget.subject.wordlist!) {
      isChecked[chapter.name] = true;
      print(chapter.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10),
      children: [
        for (Chapter chapter in widget.subject.wordlist!)
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  value: isChecked[chapter.name],
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked[chapter.name] = value!;
                    });
                    print("${chapter.name} : $value");
                  },
                ),
                Text("Chapter of : ${chapter.words[0].word1}"),
              ],
            ),
          ),
      ],
    );
  }
}
