import 'package:flutter/foundation.dart';
import 'package:vocabella/models/subject_data_model.dart';

import '../models/wordpair_model.dart';

enum Operation {
  LASTLEARNED,
  ERRORSTACK,
  FAVOURITE,
  LASTPRIORITYFACTOR,
  TOTALLEARNED
}

String opToString(Operation op) {
  switch (op) {
    case Operation.LASTLEARNED:
      return "LASTLEARNED";
    case Operation.ERRORSTACK:
      return "ERRORSTACK";
    case Operation.FAVOURITE:
      return "FAVOURITE";
    case Operation.LASTPRIORITYFACTOR:
      return "LASTPRIORITYFACTOR";
    case Operation.TOTALLEARNED:
      return "TOTALLEARNED";
  }
}

Operation opFromString(String str) {
  if (str == "LASTLEARNED") return Operation.LASTLEARNED;
  if (str == "ERRORSTACK") return Operation.ERRORSTACK;
  if (str == "FAVOURITE") return Operation.FAVOURITE;
  if (str == "LASTPRIORITYFACTOR") return Operation.LASTPRIORITYFACTOR;
  if (str == "TOTALLEARNED") return Operation.TOTALLEARNED;
  return Operation.FAVOURITE;
}

const double invalidDoubleData = -1.0;
const int invalidIntData = -1;
const bool defaultBoolData = false;
final DateTime invalidDateTime = DateTime(1, 1, 1, 0, 1);

class OperationStructure {
  OperationStructure.forTime({
    required this.word,
    required this.operation,
    this.doubleData = invalidDoubleData,
    this.intData = invalidIntData,
    this.boolData = defaultBoolData,
    required this.timeData,
  });

  OperationStructure({
    required this.word,
    required this.operation,
    this.doubleData = invalidDoubleData,
    this.intData = invalidIntData,
    this.boolData = defaultBoolData,
  });

  late WordPairIdentifier word;
  late Operation operation;
  double doubleData = invalidDoubleData;
  int intData = invalidIntData;
  bool boolData = defaultBoolData;
  DateTime timeData = invalidDateTime;

  OperationStructure.fromJson(dynamic json) {
    operation = opFromString(json['operation']);

    word = WordPairIdentifier.fromJson(json['word']);

    if (operation == Operation.LASTLEARNED) {
      timeData = DateTime.tryParse(json['timeData']) ?? invalidDateTime;
    } else if (operation == Operation.LASTPRIORITYFACTOR) {
      doubleData = json['doubleData'] ?? invalidDoubleData;
    } else if (operation == Operation.TOTALLEARNED ||
        operation == Operation.ERRORSTACK) {
      intData = json['intData'] ?? invalidIntData;
    } else {
      boolData = json['boolData'] ?? defaultBoolData;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "word": word.toJson(),
      "operation": opToString(operation),
      "doubleData": doubleData,
      "intData": intData,
      "boolData": boolData,
      "timeData": timeData.toString(),
    };
  }

  dynamic getData() {
    if (doubleData != invalidDoubleData) return doubleData;
    if (intData != invalidIntData) return intData;
    if (timeData != invalidDateTime) return timeData;
    return boolData;
  }
}

class WordPairIdentifier {
  WordPairIdentifier({
    required this.w1,
    required this.w2,
    required this.e1,
    required this.e2,
    required this.created,
    required this.salt,
  });

  late String w1;
  late String w2;
  late String e1;
  late String e2;
  late DateTime created;
  late String? salt;

  WordPairIdentifier.fromJson(dynamic json) {
    w1 = json['w1'];
    w2 = json['w2'];
    e1 = json['e1'];
    e2 = json['e2'];
    created = DateTime.tryParse(json['created'])!;
    salt = json['salt'];
  }

  Map<String, dynamic> toJson() {
    var map = {
      "w1": w1,
      "w2": w2,
      "e1": e1,
      "e2": e2,
      "created": created.toString(),
      "salt": salt,
    };
    return map;
  }

  static WordPairIdentifier fromWordPair(WordPair wordPair) {
    return WordPairIdentifier(
      w1: wordPair.word1,
      w2: wordPair.word2,
      e1: wordPair.example1,
      e2: wordPair.example2,
      created: wordPair.created!,
      salt: wordPair.salt,
    );
  }

  static bool isTheWordPair({
    required WordPair wordPair,
    required WordPairIdentifier data,
  }) {
    return wordPair.word1 == data.w1 &&
        wordPair.word2 == data.w2 &&
        wordPair.example1 == data.e1 &&
        wordPair.example2 == data.e2 &&
        wordPair.created == data.created &&
        (wordPair.salt ?? "null") == (data.salt ?? "null");
  }
}

/// How to
/// 1. accessSubject
/// 2. run operations
/// 3. disposeAccess

class SubjectManipulator {
  static String _currentId = "";

  static void accessSubject({required String id}) {
    _currentId = id;
  }

  static void disposeAccess() {
    _currentId = "";
  }

  static bool operate({required OperationStructure str}) {
    var word = str.word;
    var operation = str.operation;
    dynamic data = str.getData();

    late int target = -1;
    for (int i = 0; i < SubjectDataModel.subjectList.length; i++) {
      if (SubjectDataModel.subjectList[i].id == _currentId) {
        target = i;
      }
    }

    if (target != -1) {
      var subjectCopy = SubjectDataModel.subjectList[target];
      for (int i = 0; i < subjectCopy.wordlist.length; i++) {
        for (int j = 0; j < subjectCopy.wordlist[i].words.length; j++) {
          if (WordPairIdentifier.isTheWordPair(
            wordPair: subjectCopy.wordlist[i].words[j],
            data: word,
          )) {
            switch (operation) {
              case Operation.LASTLEARNED:
                if (data is DateTime) {
                  subjectCopy.wordlist[i].words[j].lastLearned = data;
                }
                break;
              case Operation.ERRORSTACK:
                if (data is int) {
                  subjectCopy.wordlist[i].words[j].errorStack = data;
                }
                break;
              case Operation.FAVOURITE:
                if (data is bool) {
                  subjectCopy.wordlist[i].words[j].favourite = data;
                }
                break;
              case Operation.LASTPRIORITYFACTOR:
                if (data is double) {
                  subjectCopy.wordlist[i].words[j].lastPriorityFactor = data;
                }
                break;
              case Operation.TOTALLEARNED:
                if (data is int) {
                  subjectCopy.wordlist[i].words[j].totalLearned = data;
                }
                break;
            }
            if (kDebugMode) {
              print("================================");
              print("Applying data : $data");
              print("Operation type : $operation");
              print("Word : ${subjectCopy.wordlist[i].words[j].word1}");
            }
            SubjectDataModel.subjectList[target] = subjectCopy;
            return true;
          }
        }
      }
    }
    return false;
  }
}
