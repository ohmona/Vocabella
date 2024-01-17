
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vocabella/managers/config_file.dart';

// Theme...
// - Appbar

// Animation...

// Backup state...

// Login...

/*
*
* How to add configuration property
* 1. Declare and initialise the property
* 2. Add the property to map
* 3. Add the property to import method
*
 */

class AppConfig {
  // Config data
  static String language = "en";
  static bool checkExamplesWhileMerging = true;
  static bool bDebugMode = false;
  static int keyboardMargin = 0;
  static int quizTimeInterval = 100;
  static bool bUseSmartWordOrder = true;
  static bool checkCreationDateWhileMerging = true;
  static bool stopTTSBeforeContinuing = true;

  // Set default value
  static void init() {
    language = "en";
    checkExamplesWhileMerging = true;
    bDebugMode = false;
    keyboardMargin = 0;
    quizTimeInterval = 100;
    bUseSmartWordOrder = true;
    checkCreationDateWhileMerging = true;
    stopTTSBeforeContinuing = true;
  }

  // Mapping config data
  static String json() {
    final map = {
      "language": AppConfig.language,
      "checkExamplesWhileMerging": AppConfig.checkExamplesWhileMerging,
      "bDebugMode": AppConfig.bDebugMode,
      "keyboardMargin": AppConfig.keyboardMargin,
      "quizTimeInterval": AppConfig.quizTimeInterval,
      "bUseSmartWordOrder": AppConfig.bUseSmartWordOrder,
      "checkCreationDateWhileMerging": AppConfig.checkCreationDateWhileMerging,
      "stopTTSBeforeContinuing": AppConfig.stopTTSBeforeContinuing,
    };
    return jsonEncode(map);
  }

  // Loading config data
  static void import(dynamic json) {
    language = json['language'];
    checkExamplesWhileMerging = json['checkExamplesWhileMerging'];
    bDebugMode = json['bDebugMode'];
    keyboardMargin = json['keyboardMargin'];
    quizTimeInterval = json['quizTimeInterval'];
    stopTTSBeforeContinuing = json['stopTTSBeforeContinuing'];
    if(json['bUseSmartWordOrder'] == null) {
      bUseSmartWordOrder = true;
    }
    else {
      bUseSmartWordOrder = json['bUseSmartWordOrder'];
    }

    if(json['checkCreationDateWhileMerging'] == null) {
      checkCreationDateWhileMerging = true;
    }
    else {
      checkCreationDateWhileMerging = json['checkCreationDateWhileMerging'];
    }
  }

  static void configPrint() {
    if (kDebugMode) {
      print("===========================");
      print("Config information");
      print(language);
      print(checkExamplesWhileMerging);
      print(bDebugMode);
      print(keyboardMargin);
      print(quizTimeInterval);
      print(bUseSmartWordOrder);
      print(checkCreationDateWhileMerging);
      print(stopTTSBeforeContinuing);
      print("===========================");
    }
  }

  static void save() => ConfigFile.saveConfigData();
  static void load() => ConfigFile.applyConfigData();
}