
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'data_handle_manager.dart';

class RecentActivity {
  static int _latestOpenedSubject = 0;
  static int get latestOpenedSubject {
    applyRAData();
    return _latestOpenedSubject;
  }
  static set latestOpenedSubject(int value) {
    _latestOpenedSubject = value;
    saveRAData();
  }

  static String recentActivityFile = "recentActivity.json";

  // Create recentActivity storing file
  static Future<void> initRecentActivity() async {
    if (kDebugMode) {
      print("[Recent Activity] Initializing RecentActivity");
    }
    final path = await DataReadWriteManager.getLocalPath();
    final data = await readRAData();

    if(data!.isEmpty) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$recentActivityFile", data: makeJson());
      if (kDebugMode) {
        print("[Recent Activity] Initializing Recent Activity succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[Recent Activity] Recent Activity has already been initialized");
      }
    }
  }

  static Future<String?> readRAData() async {
    if (kDebugMode) {
      print("[Recent Activity] Reading data");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      final data = await DataReadWriteManager.readDataByPath("$path/$recentActivityFile");
      if (kDebugMode) {
        print("[Recent Activity] Data reading succeeded");
      }
      return data;
    }
    catch(e) {
      if (kDebugMode) {
        print("[Recent Activity] An error has been thrown while reading data");
      }
      return "";
    }
  }

  static String makeJson() {
    final map = {
      // Here comes the data
      "latestOpenedSubject": _latestOpenedSubject,
    };
    return jsonEncode(map);
  }

  static void applyJson(dynamic json) {
    final object = jsonDecode(json);

    // Here comes the data
    _latestOpenedSubject = object["latestOpenedSubject"];
  }

  static void applyRAData() async => applyJson(await readRAData());

  static void saveRAData() async {
    if (kDebugMode) {
      print("[Recent Activity] Saving data");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      await DataReadWriteManager.writeDataToPath(data: makeJson(), path: "$path/$recentActivityFile");
      if (kDebugMode) {
        print("[Recent Activity] Saving data succeeded");
      }
    }
    catch(e) {
      if (kDebugMode) {
        print("[Recent Activity] An error has been thrown while saving data");
      }
    }
  }
}