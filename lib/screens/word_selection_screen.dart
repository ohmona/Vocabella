import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/screens/mode_selection_screen.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

class WordSelectionScreen extends StatelessWidget {
  WordSelectionScreen({Key? key}) : super(key: key);

  static const routeName = '/words';

  late WordList wordList;

  void onPressContinue() {
    print("==============================");
    print("Continue");
    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizScreen(wordPack: )));*/
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WordSelectionScreenArguments;

    wordList = WordList(chapters: args.chapters);

    print("====================================");
    print("word selection");
    print("====================================");

    return WillPopScope(
      onWillPop: () async {
        wordList.setWords([]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select words"),
        ),
        body: wordList,
        bottomNavigationBar: FloatingActionButton(
          onPressed: () {
            /*Navigator.pushReplacementNamed(
              context,
              QuizScreenParent.routeName,
              arguments: QuizScreenArguments(
                wordList.getWords(),
              ),
            );*/
            Navigator.pushNamed(
              context,
              ModeSelectionScreen.routeName,
              arguments: ModeSelectionScreenArguments(
                wordList.getWords(),
                args.languages,
              ),
            );
          },
        ),
      ),
    );
  }
}

class WordList extends StatefulWidget {
  WordList({Key? key, required this.chapters}) : super(key: key);

  final List<Chapter> chapters;

  late List<WordPair> Function() getWords;
  late void Function(List<WordPair>) setWords;

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  List<WordPair> selectedWords = [];
  Map<WordPair, bool> isChecked = {};

  List<WordPair> getWords() {
    selectedWords = [];
    for (Chapter chapter in widget.chapters) {
      for (WordPair word in chapter.words) {
        if (isChecked[word] == true) {
          if (!selectedWords.contains(word)) {
            selectedWords.add(word);
            print("${word.word1} : ${word.word2} added");
          }
        }
      }
    }
    return selectedWords;
  }

  void setWords(List<WordPair> words) {
    selectedWords = words;
  }

  @override
  void initState() {
    super.initState();

    widget.getWords = getWords;
    widget.setWords = setWords;

    selectedWords = [];
    isChecked = {};

    print("==============================");
    print("Initializing words");

    for (Chapter chapter in widget.chapters) {
      for (WordPair word in chapter.words) {
        isChecked[word] = true;
        print("${word.word1} : ${word.word2}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10),
      children: [
        for (Chapter chapter in widget.chapters)
          for (WordPair word in chapter.words)
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: isChecked[word] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked[word] = value!;
                      });
                      print("${word.word1} : ${word.word2} => $value");
                    },
                  ),
                  Text(word.word1),
                ],
              ),
            ),
      ],
    );
  }
}
