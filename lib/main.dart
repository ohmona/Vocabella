
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/screens/chapter_selection_screen.dart';
import 'package:vocabella/screens/editor_screen.dart';
import 'package:vocabella/screens/home_screen.dart';

import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/screens/word_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (MediaQuery.of(context).size.width > 500) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    return MaterialApp(
      theme: ThemeData(
        cardColor: const Color(0xFF50ECC0),
        primaryColor: const Color(0xFFA7FFE0),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
        ),
        focusColor: const Color(0xFF50ECC0),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFA7FFE0),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF50ECC0),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF50ECC0),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Color(0xFF50ECC0),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        EditorScreenParent.routeName: (context) => const EditorScreenParent(),
        ChapterSelectionScreen.routeName: (context) => ChapterSelectionScreen(),
        WordSelectionScreen.routeName: (context) => WordSelectionScreen(),
        ModeSelectionScreen.routeName: (context) => ModeSelectionScreen(),
        QuizScreenParent.routeName: (context) => const QuizScreenParent(),
        ResultScreen.routeName: (context) => const ResultScreen(),
      },
    );
  }
}
