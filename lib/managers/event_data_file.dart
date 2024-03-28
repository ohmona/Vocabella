


import 'package:flutter/foundation.dart';
import 'package:vocabella/models/event_data_model.dart';
import 'data_handle_manager.dart';

class EventDataFile {
  static String eventsFile = "events.json";

  // Create config storing file
  static Future<void> initFile() async {
    if (kDebugMode) {
      print("[EventDataFile] Initializing Event Data File");
    }
    final data = await readData();

    if(data!.isEmpty) {
      await DataReadWriteManager.write(name: eventsFile, data: makeJson());
      if (kDebugMode) {
        print("[EventDataFile] Initializing Event Data File succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[EventDataFile] Event Data File has already been initialized");
      }
      applyJson(data);
    }
  }

  static Future<String?> readData() async {
    if (kDebugMode) {
      print("[EventDataFile] Reading data");
    }

    try {
      final data = await DataReadWriteManager.read(name: eventsFile);
      if (kDebugMode) {
        print("[EventDataFile] Data reading succeeded");
        print("===================================");
        print(data);
        print("===================================");
      }
      return data;
    }
    catch(e) {
      if (kDebugMode) {
        print("[EventDataFile] An error has been thrown while reading data");
      }
      return "";
    }
  }

  static String makeJson() => EventDataModel.listToJson();

  static void applyData() async => applyJson(await readData());

  static void applyJson(dynamic json) {
    if (kDebugMode) {
      print("========================");
      print("Apply Event Data File data");
      print(json);
    }

    if(json != null && json.isNotEmpty) {
      EventDataModel.eventList = EventDataModel.listFromJson(json);
    }
    else {
      if (kDebugMode) {
        print("[Event Data File] Failed to apply json data");
      }
    }
  }

  static void saveData() async {
    if (kDebugMode) {
      print("[Event Data File] Saving data");
    }

    final path = await DataReadWriteManager.dirPath;

    try {
      await DataReadWriteManager.write(data: makeJson(), dir: path, name: eventsFile);
      if (kDebugMode) {
        print("[Event Data File] Saving data succeeded");
      }
    }
    catch(e) {
      if (kDebugMode) {
        print("[Event Data File] An error has been thrown while saving data");
      }
    }
  }
}