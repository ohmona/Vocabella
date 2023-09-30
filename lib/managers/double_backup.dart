
import 'package:flutter/foundation.dart';
import 'package:vocabella/managers/data_handle_manager.dart';


class DoubleBackup {
  // DB means double backup

  static const String dbFirstSpec = "alpha";
  static const String dbSecondSpec = "beta";

  static const String dbFileFirst = "DoubleBackupAlpha.json";
  static const String dbFileSecond = "DoubleBackupBeta.json";

  static const String dbConfigFileName = "DoubleBackupConfig.txt";

  // Create backup-count storing file
  static Future<void> initDoubleBackup() async {
    if (kDebugMode) {
      print("[Double Backup] 1 Initializing double backup");
    }
    final path = await DataReadWriteManager.getLocalPath();
    final countData = await loadDBCount();

    if(countData!.isEmpty || (countData != dbFirstSpec && countData != dbSecondSpec)) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbConfigFileName", data: dbFirstSpec);
      if (kDebugMode) {
        print("[Double Backup] 2 Initializing double backup succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[Double Backup] 3 Double backup has already been initialized");
      }
    }

  }

  // Save current backup-count
  static Future<void> saveDBCount(String spec) async {
    if (kDebugMode) {
      print("[Double Backup] 4 Saving double-backup count...");
    }

    final path = await DataReadWriteManager.getLocalPath();

    if(spec == dbFirstSpec || spec == dbSecondSpec) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbConfigFileName", data: spec);
      if (kDebugMode) {
        print("[Double Backup] 5 Saving count succeeded : $spec");
      }
    }
    else {
      if (kDebugMode) {
        print("[Double Backup] 6 Invalid value has been tried to save");
      }
    }
  }

  // Load current backup-count
  static Future<String?> loadDBCount() async {
    if (kDebugMode) {
      print("[Double Backup] 7 Loading double-backup count...");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      var count = await DataReadWriteManager.readDataByPath("$path/$dbConfigFileName");
      if (kDebugMode) {
        print("[Double Backup] 8 Loading count succeeded : $count");
      }
      return count;
    } catch(e) {
      if (kDebugMode) {
        print("[Double Backup] 9 Failed to load backup-count data");
      }
      return "";
    }
  }

  // Save backup data (to alpha or beta) and toggle count
  static Future<void> saveDoubleBackup(String data) async {
    if (kDebugMode) {
      print("[Double Backup] 10 Saving backup...");
    }

    final path = await DataReadWriteManager.getLocalPath();
    final countData = await loadDBCount();

    if(countData! == dbFirstSpec) {
      // Save data
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbFileFirst", data: data);
      if (kDebugMode) {
        print("[Double Backup] 11 Writing backup to alpha succeeded");
      }
      await saveDBCount(dbFirstSpec);
    }
    else if(countData == dbSecondSpec) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbFileSecond", data: data);
      if (kDebugMode) {
        print("[Double Backup] 12 Writing backup to beta succeeded");
      }
      await saveDBCount(dbSecondSpec);
    }
  }

  static Future<void> toggleDBCount() async {
    if (kDebugMode) {
      print("[Double Backup] 20 Toggle db count");
    }

    final countData = await loadDBCount();

    if(countData! == dbFirstSpec) {
      await saveDBCount(dbSecondSpec);
    }
    else if(countData == dbSecondSpec) {
      await saveDBCount(dbFirstSpec);
    }
  }

  // Load data backed-up
  static Future<String?> loadDoubleBackup(String spec) async {
    if (kDebugMode) {
      print("[Double Backup] 13 Loading backup data...");
    }

    try {
      // get current count
      final path = await DataReadWriteManager.getLocalPath();

      // read data
      if (spec == dbFirstSpec) {
        final data = await DataReadWriteManager.readDataByPath(
            "$path/$dbFileFirst");
        if (kDebugMode) {
          print("[Double Backup] 14 Loading backup data from first file succeeded");
        }
        return data;
      }
      else if (spec == dbSecondSpec) {
        final data = await DataReadWriteManager.readDataByPath(
            "$path/$dbFileSecond");
        if (kDebugMode) {
          print("[Double Backup] 15 Loading backup data from second file succeeded");
        }
        return data;
      }
      else {
        if (kDebugMode) {
          print("[Double Backup] 16 Failed to load backup");
        }
        return null;
      }
    }
    catch(e) {
      if (kDebugMode) {
        print("[Double Backup] 17 Failed to load backup");
      }
      return null;
    }
  }

  // Save data to original storage
  static Future<void> saveBackupDataToOriginal(String backupData) async {
    if (kDebugMode) {
      print("[Double Backup] 18 Saving...");
    }
    await DataReadWriteManager.writeData(backupData);
    if (kDebugMode) {
      print("[Double Backup] 19 Saving succeeded");
    }
  }

}