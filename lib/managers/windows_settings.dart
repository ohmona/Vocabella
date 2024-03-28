import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'data_handle_manager.dart';

class WindowsSettings {
  // Variables
  static double windowsSizeX = 1200;
  static double windowsSizeY = 800;
  static double windowsPosX = 100;
  static double windowsPosY = 100;

  static bool loaded = false;

  // Methods
  static void loadData() async {
    await applyData();
    DesktopWindow.setWindowSize(Size(windowsSizeX, windowsSizeY));
    windowManager.setPosition(Offset(windowsPosX, windowsPosY));
    loaded = true;
  }

  static setSize(Size size) async {
    windowsSizeX = size.width;
    windowsSizeY = size.height;
    if (kDebugMode) {
      print("$windowsSizeX $windowsSizeY");
    }
    await saveData();
  }

  static setPosition(Offset pos) async {
    windowsPosX = pos.dx;
    windowsPosY = pos.dy;
    if (kDebugMode) {
      print("$windowsPosX $windowsPosY");
    }
    await saveData();
  }

  // File data
  static String fileName = "windowsSettings.json";
  static const String actionName = "Windows Settings";

  static String makeJson() {
    final map = {
      // Here comes the data
      "windowsSizeX": windowsSizeX,
      "windowsSizeY": windowsSizeY,
      "windowsPosX": windowsPosX,
      "windowsPosY": windowsPosY,
    };
    return jsonEncode(map);
  }

  static Future<void> applyJson(Future<dynamic> json) async {
    try {
      final object = jsonDecode(await json);

      // Here comes the data
      windowsSizeX = object["windowsSizeX"] ?? 1200;
      windowsSizeY = object["windowsSizeY"] ?? 800;
      windowsPosX = object["windowsPosX"] ?? 100;
      windowsPosY = object["windowsPosY"] ?? 100;

      if (kDebugMode) {
        print("json imported");
      }
      return json;
    }
    catch(e) {
      if (kDebugMode) {
        print("invalid json!");
      }
    }
  }

  static Future<void> init() async {
    if (kDebugMode) {
      print("[$actionName] Initializing $actionName");
    }
    final data = await readData();

    if(data!.isEmpty) {
      await DataReadWriteManager.write(name: fileName, data: makeJson());
      if (kDebugMode) {
        print("[$actionName] Initializing $actionName succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[$actionName] $actionName has already been initialized");
      }
    }
  }

  static Future<String?> readData() async {
    if (kDebugMode) {
      print("[$actionName] Reading data");
    }

    try {
      final data = await DataReadWriteManager.read(name: fileName);
      if (kDebugMode) {
        print("[$actionName] Data reading succeeded");
      }
      return data;
    }
    catch(e) {
      if (kDebugMode) {
        print("[$actionName] An error has been thrown while reading data");
      }
      return "";
    }
  }

  static Future<void> applyData() async => await applyJson(readData());

  static Future<dynamic> saveData() async {
    if (kDebugMode) {
      print("[$actionName] Saving data");
    }

    try {
      if (kDebugMode) {
        print("[$actionName] Saving data succeeded");
      }
      return DataReadWriteManager.write(data: makeJson(), name: fileName);
    }
    catch(e) {
      if (kDebugMode) {
        print("[Recent Activity] An error has been thrown while saving data");
      }
    }
  }
}