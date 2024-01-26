

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vocabella/utils/configuration.dart';
import 'data_handle_manager.dart';

class ConfigFile {
  static String configFile = "config.json";

  // Create config storing file
  static Future<void> initConfigFile() async {
    if (kDebugMode) {
      print("[Config] Initializing Config");
    }
    final data = await readConfigData();

    if(data!.isEmpty) {
      await DataReadWriteManager.write(name: configFile, data: makeJson());
      if (kDebugMode) {
        print("[Config] Initializing Config succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[Config] Config has already been initialized");
      }
      applyJson(data);
    }
  }

  static Future<String?> readConfigData() async {
    if (kDebugMode) {
      print("[Config] Reading data");
    }

    try {
      final data = await DataReadWriteManager.read(name: configFile);
      if (kDebugMode) {
        print("[Config] Data reading succeeded");
        print("===================================");
        print(data);
        print("===================================");
      }
      return data;
    }
    catch(e) {
      if (kDebugMode) {
        print("[Config] An error has been thrown while reading data");
      }
      return "";
    }
  }

  static String makeJson() => AppConfig.json();

  static void applyConfigData() async => applyJson(await readConfigData());

  static void applyJson(dynamic json) {
    if (kDebugMode) {
      print("========================");
      print("Apply config data");
      print(json);
    }

    if(json != null && json.isNotEmpty) {
      final object = jsonDecode(json);
      AppConfig.import(object);
    }
    else {
      if (kDebugMode) {
        print("[Config] Failed to apply json data");
      }
    }
  }

  static void saveConfigData() async {
    if (kDebugMode) {
      print("[Config] Saving data");
    }

    final path = await DataReadWriteManager.dirPath;

    try {
      await DataReadWriteManager.write(data: makeJson(), dir: path, name: configFile);
      if (kDebugMode) {
        print("[Config] Saving data succeeded");
      }
    }
    catch(e) {
      if (kDebugMode) {
        print("[Config] An error has been thrown while saving data");
      }
    }
  }
}