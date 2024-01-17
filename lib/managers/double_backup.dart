
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:vocabella/managers/data_handle_manager.dart';


class DoubleBackup {
  // DB means double backup

  static int? dbCount;

  static const int dbFirstSpec = 0;
  static const int dbSecondSpec = 1;

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

    if(countData == null) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbConfigFileName", data: dbFirstSpec.toString());
      if (kDebugMode) {
        print("[Double Backup] 2 Initializing double backup succeeded");
      }
    }
    else if(countData != dbFirstSpec && countData != dbSecondSpec) {
      await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbConfigFileName", data: dbFirstSpec.toString());
      if (kDebugMode) {
        print("[Double Backup] 2.1 Initializing double backup succeeded");
      }
    }
    else {
      if (kDebugMode) {
        print("[Double Backup] 3 Double backup has already been initialized");
      }
    }

  }

  // Save current backup-count
  static Future<bool> saveDBCount(int spec) async { // 7. // 16.
    if (kDebugMode) {
      print("[Double Backup] 4 Saving double-backup count...");
    }

    final path = await DataReadWriteManager.getLocalPath();

    if(spec == dbFirstSpec || spec == dbSecondSpec) {
      var result = await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbConfigFileName", data: spec.toString());
      if (kDebugMode) {
        print("[Double Backup] 5 Saving count succeeded : $spec"); // 8. // 17.
      }
      return result.exists();
    }
    else {
      if (kDebugMode) {
        print("[Double Backup] 6 Invalid value has been tried to save");
      }
      return false;
    }
  }

  // Load current backup-count
  static Future<int?> loadDBCount() async { // 3. 11.
    if (kDebugMode) {
      print("[Double Backup] 7 Loading double-backup count...");
    }

    final path = await DataReadWriteManager.getLocalPath();

    try {
      var count = await DataReadWriteManager.readDataByPath("$path/$dbConfigFileName");
      if (kDebugMode) {
        print("[Double Backup] 8 Loading count succeeded : $count");
      }
      return int.tryParse(count); // 4. 12.
    } catch(e) {
      if (kDebugMode) {
        print("[Double Backup] 9 Failed to load backup-count data");
      }
      return null;
    }
  }

  // Save backup data (to alpha or beta) and toggle count
  static Future<File?> saveDoubleBackup(String data) async { // 9. II.
    if (kDebugMode) {
      print("[Double Backup] 10 Saving backup...");
    }

    final path = await DataReadWriteManager.getLocalPath();
    final countData = await loadDBCount();  // 10.
    // 13.

    if(countData != null) {
      if (countData == dbFirstSpec) {
        // Save data
        await saveDBCount(dbFirstSpec);
        if (kDebugMode) {
          print("[Double Backup] 11 Writing backup to alpha succeeded");
        }
        var result = await DataReadWriteManager.writeDataToPath(
            path: "$path/$dbFileFirst", data: data);
        return result;
      }
      else if (countData == dbSecondSpec) { // 14.
        await saveDBCount(dbSecondSpec); // 15.
        if (kDebugMode) {
          print("[Double Backup] 12 Writing backup to beta succeeded");
        }
        var result = await DataReadWriteManager.writeDataToPath(
            path: "$path/$dbFileSecond", data: data);
        return result;
      }
      return null;
    }
    else {
      await saveDBCount(dbFirstSpec);
      var result = await DataReadWriteManager.writeDataToPath(
          path: "$path/$dbFileFirst", data: data);
      if (kDebugMode) {
        print("[Double Backup] 11 Writing backup to alpha succeeded");
      }
      return result;
    }
  }

  static Future<bool> toggleDBCount() async { // I.
    // 1.

    final countData = await loadDBCount(); // 2.

    if (kDebugMode) {
      print("[Double Backup] 20 Toggle db count");
      print("[Double Backup] 21 countdata before toggle : $countData");
    }

    // 5.

    if(countData != null) {
      if (countData == dbFirstSpec) {
        return await saveDBCount(dbSecondSpec); // 6.
      }
      else if (countData == dbSecondSpec) {
        return await saveDBCount(dbFirstSpec);
      }
    }
    else {
      return await saveDBCount(dbFirstSpec);
    }
    return false;
  }

  // Load data backed-up
  static Future<String?> loadDoubleBackup(int spec) async {
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