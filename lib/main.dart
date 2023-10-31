import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/managers/double_backup.dart';
import 'package:vocabella/managers/recent_activity.dart';
import 'package:vocabella/managers/session_saver.dart';
import 'package:vocabella/screens/chapter_selection_screen.dart';
import 'package:vocabella/screens/editor_screen.dart';
import 'package:vocabella/screens/home_screen.dart';

import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/screens/subject_creation_screen.dart';
import 'package:vocabella/screens/word_selection_screen.dart';

import 'constants.dart';

const appVersion = "1.4";
const appInfo = 'ver. $appVersion by ohmona';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  DoubleBackup.initDoubleBackup();
  RecentActivity.initRecentActivity();
  SessionSaver.initSessionSaver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (MediaQuery.of(context).size.width > smallDeviceWidthLimit) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    return MaterialApp(
      theme: ThemeData(
        cardColor: mintColor,
        primaryColor: const Color(0xFFA7FFE0),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
        ),
        focusColor: mintColor,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFA7FFE0),
        ),
        appBarTheme: const AppBarTheme(
          color: mintColor,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: mintColor,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: mintColor,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        EditorScreenParent.routeName: (context) => const EditorScreenParent(),
        ChapterSelectionScreenParent.routeName: (context) =>
            const ChapterSelectionScreenParent(),
        WordSelectionScreenParent.routeName: (context) =>
            const WordSelectionScreenParent(),
        ModeSelectionScreenParent.routeName: (context) =>
            const ModeSelectionScreenParent(),
        QuizScreenParent.routeName: (context) => const QuizScreenParent(),
        ResultScreen.routeName: (context) => const ResultScreen(),
        SubjectCreationScreenParent.routeName: (context) => const SubjectCreationScreenParent(),
      },
    );
  }
}
