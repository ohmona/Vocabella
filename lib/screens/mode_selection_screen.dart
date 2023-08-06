import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/screens/quiz_screen.dart';

import '../models/wordpair_model.dart';

class ModeSelectionScreen extends StatefulWidget {
  ModeSelectionScreen({super.key});

  static const routeName = '/mode';

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {

  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();

  late String language1;
  late String language2;

  late ModeSelectionScreenArguments args;

  List<WordPair> switchLanguage(List<WordPair> from) {
    List<WordPair> to = [];
    for (WordPair word in from) {
      String w1 = word.word1;
      String w2 = word.word2;
      String? e1 = word.example1;
      String? e2 = word.example2;

      WordPair newPair = WordPair(
        word1: w2,
        word2: w1,
        example1: e2,
        example2: e1,
      );
      to.add(newPair);
    }
    return to;
  }

  void switchLang() {
    list = switchLanguage(list);

    Timer(const Duration(milliseconds: 10), () {
      String buffer = language1;
      language1 = language2;
      language2 = buffer;
      setState(() {});
    });
  }

  void onLang1Change(String newValue) {
    language1 = newValue;
  }

  void onLang2Change(String newValue) {
    language2 = newValue;
  }

  List<WordPair> list = [];

  @override
  void initState() {
    super.initState();
  }

  bool dataAlreadyReceived = false;

  @override
  Widget build(BuildContext context) {

    args = ModalRoute.of(context)!.settings.arguments
    as ModeSelectionScreenArguments;

    if(!dataAlreadyReceived) {
      language1 = args.languages[0];
      language2 = args.languages[1];

      list = args.wordPack;
      dataAlreadyReceived = true;
    }

    controller1.text = language1;
    controller2.text = language2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose mode'),
      ),
      body: Center(
        child: Column(
          children: [
            LanguageChanger(onPressed: switchLang),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  QuizScreenParent.routeName,
                  arguments: QuizScreenArguments(list, language1, language2),
                );
              },
              icon: const Icon(Icons.navigate_next),
            ),
            const Text("language 1 : "),
            TextField(
              controller: controller1,
              onChanged: onLang1Change,
            ),
            const Text("language 2 : "),
            TextField(
              controller: controller2,
              onChanged: onLang2Change,
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageChanger extends StatefulWidget {
  const LanguageChanger({Key? key, required this.onPressed}) : super(key: key);

  final void Function() onPressed;

  @override
  State<LanguageChanger> createState() => _LanguageChangerState();
}

class _LanguageChangerState extends State<LanguageChanger> {
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        widget.onPressed();
        changed = !changed;
        setState(() {});
      },
      icon: Icon(changed ? Icons.arrow_back : Icons.language),
    );
  }
}
