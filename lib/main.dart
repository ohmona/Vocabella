import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/screens/chapter_selection_screen.dart';
import 'package:vocabella/screens/editor_screen.dart';
import 'package:vocabella/screens/home_screen.dart';

import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/screens/word_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
        primaryColor: const Color(0xFFA7FFE0),
      ),
      initialRoute: '/',
      routes: {
        //'/': (context) => const HomeScreen(),
        '/': (context) => const EditorScreen(),
        ChapterSelectionScreen.routeName: (context) => ChapterSelectionScreen(),
        WordSelectionScreen.routeName: (context) => WordSelectionScreen(),
        ModeSelectionScreen.routeName: (context) => ModeSelectionScreen(),
        QuizScreenParent.routeName: (context) => const QuizScreenParent(),
        ResultScreen.routeName: (context) => const ResultScreen(),
      },
    );
  }
}
