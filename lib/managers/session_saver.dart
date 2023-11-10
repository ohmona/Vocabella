
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/session_data_model.dart';
import 'data_handle_manager.dart';

class SessionSaver {

  static SessionDataModel _session = SessionDataModel(existSessionData: false);
  static SessionDataModel get session {
    applySessionData();
    return _session;
  }
  static set session(SessionDataModel value) {
    _session = value;
    saveSessionData();
  }

  static String sessionFile = "sessionData.json";

  // Create recentActivity storing file
  static Future<void> initSessionSaver() async {
    if (kDebugMode) {
      print("[Session] Initializing RecentActivity");
    }
    final path = await DataReadWriteManager.getLocalPath();
    final data = await readSessionData();

    if(data!.isEmpty) {
      _session = SessionDataModel(existSessionData: false);
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$sessionFile", data: makeJson());
      if (kDebugMode) {
        print("[Session] Initializing Session succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[Session] Session has already been initialized");
      }
    }
  }

  static Future<String?> readSessionData() async {
    if (kDebugMode) {
      print("[Session] Reading data");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      final data = await DataReadWriteManager.readDataByPath("$path/$sessionFile");
      if (kDebugMode) {
        print("[Session] Data reading succeeded");
        print("===================================");
        print(data);
        print("===================================");
      }
      return data;
    }
    catch(e) {
      if (kDebugMode) {
        print("[Session] An error has been thrown while reading data");
      }
      return "";
    }
  }

  static String makeJson() => session.toJson();

  static void applyJson(dynamic json) {
    if(json != null && (json as String).isEmpty) {
      final object = jsonDecode(json);
      _session = SessionDataModel.fromJson(object);
    }
    else {
      _session = SessionDataModel(existSessionData: false);
    }
  }

  static void applySessionData() async => applyJson(await readSessionData());

  static void saveSessionData() async {
    if (kDebugMode) {
      print("[Session] Saving data");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      await DataReadWriteManager.writeDataToPath(data: makeJson(), path: "$path/$sessionFile");
      if (kDebugMode) {
        print("[Session] Saving data succeeded");
      }
    }
    catch(e) {
      if (kDebugMode) {
        print("[Session] An error has been thrown while saving data");
      }
    }
  }
}