import 'package:flutter/foundation.dart';
import 'package:vocabella/managers/subject_data_manipulator.dart';
import 'package:vocabella/models/wordpair_model.dart';
import 'dart:convert';

class SessionDataModel {
  late bool existSessionData;

  List<WordPair>? listOfQuestions;
  List<WordPair>? listOfWrongs;
  int? count;
  int? questionsNumber;
  String? language1, language2;
  bool? isOddTHCard;

  int? absoluteProgress;
  int? originalProgress;
  int? wrongAnswers;
  int? absoluteRepetitionProgress;
  int? repetitionProgress;
  bool? hasRepetitionBegun;
  int? inFirstTry;
  int? inRepetitionFirstTry;
  int? stageCount;

  String? id;
  List<OperationStructure>? operations;

  SessionDataModel({
    required this.existSessionData,
    this.listOfQuestions,
    this.listOfWrongs,
    this.count,
    this.questionsNumber,
    this.language1,
    this.language2,
    this.isOddTHCard,
    this.absoluteProgress,
    this.originalProgress,
    this.wrongAnswers,
    this.absoluteRepetitionProgress,
    this.repetitionProgress,
    this.hasRepetitionBegun,
    this.inFirstTry,
    this.inRepetitionFirstTry,
    this.stageCount,
    this.id,
    this.operations,
  });

  SessionDataModel.fromJson(dynamic json) {
    try {
      print("====================================");
      print("Session Data Model from Json");

      existSessionData = json['existSessionData'];
      count = json['count'];
      questionsNumber = json['questionsNumber'];
      language1 = json['language1'];
      language2 = json['language2'];
      isOddTHCard = json['isOddTHCard'];
      absoluteProgress = json['absoluteProgress'];
      originalProgress = json['originalProgress'];
      wrongAnswers = json['wrongAnswers'];
      absoluteRepetitionProgress = json['absoluteRepetitionProgress'];
      repetitionProgress = json['repetitionProgress'];
      hasRepetitionBegun = json['hasRepetitionBegun'];
      inFirstTry = json['inFirstTry'];
      inRepetitionFirstTry = json['inRepetitionFirstTry'];
      stageCount = json['stageCount'];
      id = json['id'];

      List<WordPair> loq = [];
      if(json['listOfQuestions'] != null) {
        for (dynamic word in json['listOfQuestions'] as List<dynamic>) {
          loq.add(
            WordPair.fromJson(
              word,
            ),
          );
        }
      }
      listOfQuestions = loq;

      List<WordPair> low = [];
      if(json['listOfWrongs'] != null) {
        for (dynamic word in json['listOfWrongs'] as List<dynamic>) {
          low.add(
            WordPair.fromJson(
              word,
            ),
          );
        }
      }
      listOfWrongs = low;

      List<OperationStructure> os = [];
      if(json['operations'] != null) {
        for (dynamic op in json['operations'] as List<dynamic>) {
          os.add(OperationStructure.fromJson(op));
        }
        operations = os;
      }
      else {
        operations = [];
      }
    }
    catch(e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String toJson() {
    print("------------------------------");
    print("Session data model toJson");
    Map<String, Object?> map;
    if(existSessionData) {
      map = {
        "existSessionData": true,
        "listOfQuestions": listOfQuestions?.map((chapter) => chapter.toJson())
            .toList(),
        "listOfWrongs": listOfWrongs?.map((chapter) => chapter.toJson())
            .toList(),
        "count": count,
        "questionsNumber": questionsNumber,
        "language1": language1,
        "language2": language2,
        "isOddTHCard": isOddTHCard,
        "absoluteProgress": absoluteProgress,
        "originalProgress": originalProgress,
        "wrongAnswers": wrongAnswers,
        "absoluteRepetitionProgress": absoluteRepetitionProgress,
        "repetitionProgress": repetitionProgress,
        "hasRepetitionBegun": hasRepetitionBegun,
        "inFirstTry": inFirstTry,
        "inRepetitionFirstTry": inRepetitionFirstTry,
        "stageCount": stageCount,
        "id": id,
        "operations": operations?.map((op) => op.toJson())
            .toList(),
      };
    }
    else {
      map = {
        "existSessionData": false,
      };
    }
    return jsonEncode(map);
  }

  void printData() {
    if (kDebugMode) {
      print("Printing session data");
      print(existSessionData);
      //print(listOfQuestions);
      //print(listOfWrongs);
      //print(count);
      //print(isOddTHCard);
      //print(id);
      /*for(var op in operations) {
        print("ERRROR??");
        print(op.toJson());
      }*/
    }
  }
}
