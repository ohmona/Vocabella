import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
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

  static Future<File?> loadNewImage(ImageSource imageSource) async {
    final XFile? xImage = await ImagePicker().pickImage(source: imageSource);

    if(xImage != null) {
      final File image = File(xImage.path);
      final String path = await _localPath + xImage.name;
      final File newImage = await image.copy(path);

      print("=========================================");
      print("Loading new image from : ${xImage.path}");
      print("Copying new image to : ${newImage.path}");

      return newImage;
    }
    else {
      print("=========================================");
      print("Sry we have to deal with this");
      return null;
    }
  }

  static Future<File?> loadExistingImage(String path) async {
    try {
      final File image = File(path);
      print("=========================================");
      print("Loading existing image from : ${image.path}");
      return image;
    }
    catch(e) {
      print("=========================================");
      print("Sry we have to deal with this 2");
      return null;
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