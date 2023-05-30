import 'package:flutter/material.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/screens/home_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';

void main() {
  print(SubjectDataModel.createExampleData().toList());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.white,
        cardColor: const Color(0xFF50ECC0),
      ),
      home: const QuizScreen(),
    );
  }
}

