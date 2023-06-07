import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DataReadWriteManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get _localFilePath async {
    final path = await _localPath;
    return '$path/subjects.json';
  }

  static Future<String> readData() async {
    try {
      final file = File(await _localFilePath);
      print("++++++++++++++++++++++++++++++++++++");
      print(await file.readAsString());
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<void> writeData(String data) async {
    final file = File(await _localFilePath);
    await file.writeAsString(data);
  }

  static Future<String> readDataByPath(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}

class DataPickerManager {
  // import single file
  static Future<FilePickerResult?> pickFile() async {
    try {
      return await FilePicker.platform.pickFiles();
    } catch (e) {
      return null;
    }
  }
}