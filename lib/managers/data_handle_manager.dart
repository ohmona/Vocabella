import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  static Future<String> getLocalAnyFilePath(String name) async {
    final path = await _localPath;
    return '$path/$name.json';
  }

  static Future<String> getLocalPath() {
    return _localPath;
  }

  static Future<String> getLocalFilePath() {
    return _localFilePath;
  }

  static Future<String> readData() async {
    try {
      final file = File(await _localFilePath);
      print('=================================');
      print('Printing reading file');
      print(await file.readAsString());
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<String> readDataFrom({required String name}) async {
    try {
      final file = File(await getLocalAnyFilePath(name));
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<String> readDataByPath(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<void> writeData(String data) async {
    final file = File(await _localFilePath);
    await file.writeAsString(data);
  }

  static Future<void> writeDataTo({required String data, required String name}) async {
    final file = File(await getLocalAnyFilePath(name));
    await file.writeAsString(data);
  }

  static Future<void> writeDataToPath({required String data, required String path}) async {
    final file = File(path);
    await file.writeAsString(data);
  }

  static Future<File?> loadNewImage(ImageSource imageSource) async {
    final XFile? xImage = await ImagePicker().pickImage(source: imageSource);

    if (xImage != null) {
      final File image = File(xImage.path);
      final String path = await _localPath + xImage.name;
      final File newImage = await image.copy(path);

      return newImage;
    } else {
      if (kDebugMode) {
        print("=========================================");
        print("Sry we have to deal with this");
      }
      return null;
    }
  }

  static Future<File?> loadExistingImage(String path) async {
    try {
      final File image = File(path);
      return image;
    } catch (e) {
      if (kDebugMode) {
        print("=========================================");
        print("Sry we have to deal with this 2");
      }
      return null;
    }
  }

  static void exportData({
    required String folderPath,
    required String name,
    required String contents,
  }) {
    final url = "$folderPath/$name.vcb";
    final file = File(url);
    file.writeAsString(contents);
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
