import 'package:flutter/foundation.dart';
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
  });

  SessionDataModel.fromJson(dynamic json) {
    try {
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

      List<WordPair> loq = [];
      for (dynamic word in json['listOfQuestions'] as List<dynamic>) {
        loq.add(
          WordPair.fromJson(
            word,
            name: 'N/A',
          ),
        );
      }
      listOfQuestions = loq;

      List<WordPair> low = [];
      for (dynamic word in json['listOfWrongs'] as List<dynamic>) {
        low.add(
          WordPair.fromJson(
            word,
            name: 'N/A',
          ),
        );
      }
      listOfWrongs = low;
    }
    catch(e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String toJson() {
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
      print(listOfQuestions);
      print(listOfWrongs);
      print(count);
      print(isOddTHCard);
    }
  }
}
