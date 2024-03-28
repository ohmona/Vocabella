import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/managers/config_file.dart' as cf;
import 'package:vocabella/managers/double_backup.dart';
import 'package:vocabella/managers/event_data_file.dart';
import 'package:vocabella/managers/recent_activity.dart';
import 'package:vocabella/managers/session_saver.dart';
import 'package:vocabella/managers/windows_settings.dart';
import 'package:vocabella/screens/chapter_selection_screen.dart';
import 'package:vocabella/screens/config_screen.dart';
import 'package:vocabella/screens/editor_screen.dart';
import 'package:vocabella/screens/home_screen.dart';

import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/screens/planner_screen.dart';
import 'package:vocabella/screens/quiz_screen.dart';
import 'package:vocabella/screens/result_screen.dart';
import 'package:vocabella/screens/subject_creation_screen.dart';
import 'package:vocabella/screens/word_selection_screen.dart';
import 'package:window_manager/window_manager.dart';

import 'utils/configuration.dart';
import 'utils/constants.dart';
import 'package:flutter/rendering.dart';

const appVersion = "1.9";
const appInfo = 'ver. $appVersion by ohmona';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  DoubleBackup.initDoubleBackup();
  RecentActivity.initRecentActivity();
  SessionSaver.initSessionSaver();
  AppConfig.init();
  cf.ConfigFile.initConfigFile();
  WindowsSettings.init();
  EventDataFile.initFile();

  //debugPaintPointersEnabled = true;
  //debugPaintSizeEnabled  = true;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    DesktopWindow.setMinWindowSize(const Size(500, 700));

    WindowsSettings.loadData();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener{
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowResize() {
    super.onWindowResize();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if(WindowsSettings.loaded) {
        var size = MediaQuery.of(context).size;
        if(WindowsSettings.windowsSizeX != size.width || WindowsSettings.windowsSizeY != size.height) {
          WindowsSettings.setSize(size);
        }
      }
    }
  }

  @override
  void onWindowMoved() async {
    super.onWindowMoved();
    var o = await windowManager.getPosition();
    WindowsSettings.setPosition(o);
  }

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
        ConfigScreen.routeName: (context) => const ConfigScreen(),
        PlannerScreen.routeName: (context) => const PlannerScreen(),
      },
    );
  }
}
