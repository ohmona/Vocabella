import 'dart:convert';

import 'package:vocabella/constants.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/models/subject_data_model.dart';

import 'chapter_model.dart';

class RemovedSubjectModel extends SubjectDataModel {
  DateTime? removeDate;

  RemovedSubjectModel({
    required super.title,
    required super.subjects,
    required super.wordlist,
    required super.languages,
    required this.removeDate,
    required super.thumb,
  });

  static List<RemovedSubjectModel> recycleBin = [];

  /// Copy data from subjectList at SubjectDataModel class to recycleBin list
  static void moveToRecycleBin(int index) {
    SubjectDataModel temp = SubjectDataModel.subjectList[index];
    RemovedSubjectModel trash = RemovedSubjectModel(
      title: temp.title,
      subjects: temp.subjects,
      wordlist: temp.wordlist,
      languages: temp.languages,
      thumb: temp.thumb,
      removeDate: DateTime.now(),
    );

    recycleBin.add(trash);
    SubjectDataModel.subjectList[index].removeFromList();
  }

  /// Opposite function as moveToRecycleBin, but restores current object only
  void restore() {
    SubjectDataModel.subjectList.add(this);
    recycleBin.remove(this);
  }

  /// remove this object from the static list
  void remove() => recycleBin.remove(this);

  static void autoRemove() {
    List<RemovedSubjectModel> toDelete = [];
    for (RemovedSubjectModel data in recycleBin) {
      if (data.checkExpiration) {
        toDelete.add(data);
      }
    }
    for (var element in toDelete) {
      element.remove();
    }
    if (recycleBin.isNotEmpty) {
      saveRecycleBinData();
    }
  }

  /// check whether any of data is expired so that it can be deleted
  bool get checkExpiration {
    if (DateTime.now().isAfter(removeDate!.add(expirationDuration))) {
      return true;
    }
    return false;
  }

  /// Save data of recycle bin data to local
  static void saveRecycleBinData() async {
    const String name = "recycleBin";
    final String content = listToJson(recycleBin);
    DataReadWriteManager.writeDataTo(data: content, name: name);
  }

  /// Load data from local and save it to dart list
  static void loadRecycleBinData() async {
    const String name = "recycleBin";
    final String content = await DataReadWriteManager.readDataFrom(name: name);

    if (content.isNotEmpty) {
      recycleBin = listFromJson(content);
    }
  }

  /// Same as listFromJson of SubjectDataModel class
  static List<RemovedSubjectModel> listFromJson(dynamic json) {
    List<RemovedSubjectModel> data = [];
    final jsonList = jsonDecode(json) as List<dynamic>;

    for (dynamic inst in jsonList) {
      RemovedSubjectModel temp = RemovedSubjectModel(
        languages: ['', ''],
        subjects: ['', ''],
        title: "",
        wordlist: [],
        thumb: "",
        removeDate: DateTime.now(),
      );

      temp.title = inst['title'];
      temp.thumb = inst['thumb'];
      temp.subjects![0] = inst['subjects'][0];
      temp.subjects![1] = inst['subjects'][1];
      temp.languages![0] = inst['languages'][0];
      temp.languages![1] = inst['languages'][1];
      for (int i = 0; i < (inst['wordlist'] as List<dynamic>).length; i++) {
        temp.wordlist!.add(Chapter.fromJson(inst['wordlist'][i]));
      }
      temp.removeDate = DateTime.parse(inst['removeDate']);

      data.add(temp);
    }
    return data;
  }

  /// Convert current list into encoded json by converting individual instances
  static String listToJson(List<RemovedSubjectModel> data) {
    return jsonEncode(data.map((trash) => trash.toJson()).toList());
  }

  /// Convert current instance into encoded json
  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumb': thumb,
      'subjects': subjects,
      'languages': languages,
      'wordlist': wordlist?.map((chapter) => chapter.toJson()).toList(),
      'removeDate': removeDate.toString(),
    };
  }
}
