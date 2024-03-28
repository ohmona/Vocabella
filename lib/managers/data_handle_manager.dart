import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataReadWriteManager {
  // LOCAL PATH
  static Future<String> get dirPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;

    if(Platform.isWindows) {
      path = "$path\\Vocabella";
      Directory(path).create();
    }

    return path;
  }

  static const String defaultFile = "subjects.json";

  static Future<String> read({
    String? dir,
    String path = "",
    required String name,
  }) async {
    try {
      final rootPath = await dirPath;
      File file;
      if (dir == null) {
        file = File("$rootPath$path\\$name");
      } else {
        file = File("$dir$path\\$name");
      }
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<String> readPath(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  static Future<File> write({
    required String data,
    required String name,
    String path = "",
    String? dir,
  }) async {
    final rootPath = await dirPath;
    File file;
    if (dir == null) {
      file = File("$rootPath$path\\$name");
    } else {
      file = File("$dir$path\\$name");
    }
    return file.writeAsString(data);
  }

  // IMAGE
  static Future<File?> loadNewImage(ImageSource imageSource) async {
    final XFile? xImage = await ImagePicker().pickImage(source: imageSource);

    if (xImage != null) {
      final File image = File(xImage.path);
      final String path = await dirPath + xImage.name;
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

  static void share({required String dir, required String name}) async {
    XFile file = XFile(
        "$dir/$name");
    Share.shareXFiles([file]);
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
