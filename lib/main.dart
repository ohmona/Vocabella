import 'package:flutter/material.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/screens/home_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';

import 'package:vocabella/classes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    late List<WordPair> vocabulary = [];
    for(Chapter chap in SubjectDataModel.createExampleData().wordlist) {
      for(WordPair wordPair in chap.words) {
        vocabulary.add(wordPair);
      }
    }

    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.white,
        cardColor: const Color(0xFF50ECC0),
      ),
      home: QuizScreen(wordPack: vocabulary,),
    );
  }
}

