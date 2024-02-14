import 'package:flutter/foundation.dart';
import 'package:vocabella/models/wordpair_model.dart';

class Chapter {
  late String name;
  late String path; // "/folder1/subfolder/"
  late List<WordPair> words;

  int? wordCount;
  int? lastIndex;

  Chapter({
    required this.name,
    required this.words,
    required this.path,
    //this.id,
    this.lastIndex,
  });

  Chapter.fromJson(dynamic json) {
    if (kDebugMode) {
      print("--------------------------------------------");
      print("Initialising Chapter from json");
    }
    name = json["name"];
    if (kDebugMode) {
      print("Name loading successful");
    }

    List<WordPair> temp = [];
    for (dynamic word in json['words'] as List<dynamic>) {
      temp.add(
        WordPair.fromJson(
          word,
        ),
      );
    }
    words = temp;
    if (kDebugMode) {
      print("Word List loading successful");
    }

    // get length of words
    wordCount = words.length;
    if (kDebugMode) {
      print("Word Count loading successful");
    }

    // Get last focused index
    lastIndex = json['lastIndex'];
    if(json['lastIndex'] == null) {
      lastIndex = 0;
      if (kDebugMode) {
        print("Initialising Last Index successful");
      }
    }
    else {
      if (kDebugMode) {
        print("Last Index loading successful");
      }
    }

    if(json['path'] == null) {
      path = "/";
      if (kDebugMode) {
        print("Initialising Path successful");
      }
    }
    else {
      path = json['path'];
      if (kDebugMode) {
        print("Path loading successful");
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'words': words.map((wordPair) => wordPair.toJson()).toList(),
      //'id': id,
      'lastIndex': lastIndex,
      'path': path,
    };
  }

  /*static Chapter duplicate(Chapter object) {
    var newChapter = Chapter(name: object.name, words: object.words, );
    return newChapter;
  }*/

  bool existWordAlready(WordPair wordPair) {
    for (var word in words) {
      if (word.isSameWord(as: wordPair)) {
        return true;
      }
    }
    if (kDebugMode) {
      print("printing false");
    }
    return false;
  }

  int findAlreadyExistingWord(WordPair wordPair) {
    if(existWordAlready(wordPair)) {
      for(int i = 0; i < words.length; i++) {
        if(words[i].isSameWord(as: wordPair)) {
          return i;
        }
      }
    }
    return -1;
  }

  String comprisePath() {
    return "$path$name";
  }
}

class EditedChapter extends Chapter {
  EditedChapter({required super.name, required super.words, required super.path});

  static EditedChapter copyFrom(Chapter chapter) {
    return EditedChapter(name: chapter.name, words: chapter.words, path: chapter.path);
  }

  Chapter toChapter() {
    return Chapter(name: name, words: words, path: path);
  }

  List<int> excludedIndex = [];

  @override
  Map<String, dynamic> toJson() => throw Error();
}
