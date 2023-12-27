/*
* This class has the data of words and corresponding
* examples and every wordpair class has an id
 */
import 'package:flutter/foundation.dart';
import 'package:vocabella/configuration.dart';

class WordPair {
  // Word data
  late String word1, word2; // question, answer
  late String? example1, example2;

  // Priority stuffs
  late bool? favourite;
  late int? errorStack;
  late double? lastPriorityFactor;
  late int? totalLearned;

  // Important time data
  late DateTime? created;
  late DateTime? lastEdit;
  late DateTime? lastLearned;

  WordPair({
    required this.word1,
    required this.word2,
    this.example1,
    this.example2,
    required this.created,
    required this.lastEdit,
    this.favourite = false,
    this.lastLearned,
    this.errorStack,
    this.lastPriorityFactor,
    this.totalLearned,
  });

  WordPair.fromJson(dynamic json) {
    word1 = json['word1'];
    word2 = json['word2'];
    example1 = json['example1'];
    example2 = json['example2'];

    // Creation time
    if (json['created'] != null) {
      created = DateTime.tryParse(json['created']);
    } else {
      created = DateTime.now();
    }

    // Previously edited time
    if (json['lastEdit'] != null) {
      lastEdit = DateTime.tryParse(json['lastEdit']);
    } else {
      lastEdit = DateTime.now();
    }

    // Favourite property
    if (json['favourite'] != null) {
      favourite = json['favourite'];
    } else {
      favourite = false;
    }

    // Last learned time
    if (json['lastLearned'] != null) {
      lastLearned = DateTime.tryParse(json['lastLearned']);
    } else {
      lastLearned = DateTime(1, 1, 1, 0, 0);
    }

    // Factor how much user gave the wrong answer
    if (json['errorStack'] != null) {
      errorStack = json['errorStack'];
    } else {
      errorStack = null;
    }

    // Factor in which order the word was placed
    if (json['lastPriorityFactor'] != null) {
      lastPriorityFactor = json['lastPriorityFactor'];
    } else {
      lastPriorityFactor = null;
    }

    // Factor in which order the word was placed
    if (json['totalLearned'] != null) {
      totalLearned = json['totalLearned'];
    } else {
      totalLearned = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'word1': word1,
      'word2': word2,
      'example1': example1 ?? "",
      'example2': example2 ?? "",
      'created': created.toString(),
      'lastEdit': lastEdit.toString(),
      'favourite': favourite,
      'lastLearned': lastLearned.toString(),
      'errorStack': errorStack,
      'lastPriorityFactor': lastPriorityFactor,
      'totalLearned': totalLearned,
    };
  }

  void printWord() {
    if (kDebugMode) {
      print("first word : $word1");
      print("second word : $word2");
      print("first example : $example1");
      print("second example : $example2");
      print("created : $created");
      print("lastEdit : $lastEdit");
      print("favourite : $favourite");
      print("lastLearned : $lastLearned");
      print("errorStack : $errorStack");
      print("lastPriorityFactor : $lastPriorityFactor");
      print("totalLearned : $totalLearned");
    }
  }

  bool isSameWord({required WordPair as}) {
    var comparing = as;

    // 1. All words are same
    if (word1 == comparing.word1 && word2 == comparing.word2) {
      if(!AppConfig.checkCreationDateWhileMerging) {
        if (AppConfig.checkExamplesWhileMerging) {
          if (example1 == comparing.example1 &&
              example2 == comparing.example2) {
            return true;
          }
        }
        else {
          return true;
        }
      }
      else {
        if(created == as.created) {
          return true;
        }
      }
    }

    // 2. Only one or more is/are same
    if(word1 == comparing.word1 || word2 == comparing.word2) {
      if(created == as.created) {
        return true;
      }
    }
    else if(example1 == comparing.example1 ||
        example2 == comparing.example2) {
      if(AppConfig.checkExamplesWhileMerging) {
        if(created == as.created) {
          return true;
        }
      }
    }

    return false;
  }

  static WordPair nullWordPair() {
    return WordPair(
      word1: "",
      word2: "",
      created: DateTime(1, 1, 1, 0, 0),
      lastEdit: DateTime(1, 1, 1, 0, 0),
      example1: "",
      example2: "",
      errorStack: -1,
      favourite: false,
      lastLearned: DateTime(1, 1, 1, 0, 0),
      lastPriorityFactor: -1,
      totalLearned: -1,
    );
  }

  void resetLearningData() {
    errorStack = null;
    lastLearned = DateTime(1, 1, 1, 0, 0);
    lastPriorityFactor = null;
    totalLearned = null;

  }
}
