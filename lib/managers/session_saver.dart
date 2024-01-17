import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/session_data_model.dart';
import 'data_handle_manager.dart';

class SessionSaver {
  static bool isSessionBeingSaved = false;

  static SessionDataModel _session = SessionDataModel(existSessionData: false);

  static SessionDataModel get session {
    applySessionData();
    return _session;
  }

  static set session(SessionDataModel value) {
    _session = value;
    if (!isSessionBeingSaved) {
      isSessionBeingSaved = true;
      saveSessionData();
    }
  }

  static String sessionFile = "sessionData.json";

  // Create recentActivity storing file
  static Future<void> initSessionSaver() async {
    if (kDebugMode) {
      print("[Session] Initializing RecentActivity");
    }
    final path = await DataReadWriteManager.getLocalPath();
    final data = await readSessionData();

    if (data!.isEmpty) {
      _session = SessionDataModel(existSessionData: false);
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$sessionFile", data: makeJson());
      if (kDebugMode) {
        print("[Session] Initializing Session succeeded");
      }
    } else {
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
      final data =
          await DataReadWriteManager.readDataByPath("$path/$sessionFile");
      if (kDebugMode) {
        print("[Session] Data reading succeeded");
        //print("===================================");
        //print(data);
        //print("===================================");
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        print("[Session] An error has been thrown while reading data");
        print(e);
      }
      return "";
    }
  }

  static String makeJson() => session.toJson();

  static void applyJson(String? json) {
    if (json != null && json.isEmpty) {
      final object = jsonDecode(json);
      _session = SessionDataModel.fromJson(object);
    } else {
      _session = SessionDataModel(existSessionData: false);
    }
  }

  static void applySessionData() async => applyJson(await readSessionData());

  static void saveSessionData() async {
    if (kDebugMode) {
      print("[Session] Saving data");
    }

    final path = await DataReadWriteManager.getLocalPath();

    _session.printData();

    try {
      await DataReadWriteManager.writeDataToPath(
          data: makeJson(), path: "$path/$sessionFile");
      isSessionBeingSaved = false;
      if (kDebugMode) {
        print("[Session] Saving data succeeded");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[Session] An error has been thrown while saving data");
        print(e);
      }
    }
  }
/*
  // Force removing session data
  static void resetSessionData() {

    _session = SessionDataModel(existSessionData: false);
    if (!isSessionBeingSaved) {
      print("resetting session data immediately");
      saveSessionData();
    } else {
      print("resetting session data immediately");
      late Timer forceSaver;
      forceSaver = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if(!isSessionBeingSaved) {
          saveSessionData();
          forceSaver.cancel();
        }
      });
    }
  }*/
}
