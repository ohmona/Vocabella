import 'package:flutter/foundation.dart';
import 'package:vocabella/models/wordpair_model.dart';

class Chapter {
  late String name;
  late String path; // "/folder1/subfolder/"
  late List<WordPair> words;

  int? wordCount;
  int? lastIndex;

  DateTime? created;
  String? salt;

  Chapter({
    required this.name,
    required this.words,
    required this.path,
    //this.id,
    this.lastIndex,
    required this.created,
    required this.salt,
  });

  Chapter.fromJson(dynamic json) {
    name = json["name"];

    List<WordPair> temp = [];
    for (dynamic word in json['words'] as List<dynamic>) {
      temp.add(
        WordPair.fromJson(
          word,
        ),
      );
    }
    words = temp;

    // get length of words
    wordCount = words.length;

    // Get last focused index
    lastIndex = json['lastIndex'];
    if (json['lastIndex'] == null) {
      lastIndex = 0;
    }

    if (json['path'] == null) {
      path = "/";
    } else {
      path = json['path'];
    }

    // Creation time
    if (json['created'] != null) {
      created = DateTime.tryParse(json['created']);
    } else {
      created = DateTime.now();
    }

    salt = json['salt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastIndex': lastIndex,
      'path': path,
      'salt': salt,
      'created': created.toString(),
      'words': words.map((wordPair) => wordPair.toJson()).toList(),
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

  bool isSameChapter({required Chapter as}) {
    if(as.salt == salt && as.created == created) {
      return true;
    }
    return false;
  }

  int findAlreadyExistingWord(WordPair wordPair) {
    if (existWordAlready(wordPair)) {
      for (int i = 0; i < words.length; i++) {
        if (words[i].isSameWord(as: wordPair)) {
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
  EditedChapter(
      {required super.name,
      required super.words,
      required super.path,
      required super.salt,
      required super.created});

  static EditedChapter copyFrom(Chapter chapter) {
    return EditedChapter(
      name: chapter.name,
      words: chapter.words,
      path: chapter.path,
      salt: chapter.salt,
      created: chapter.created,
    );
  }

  Chapter toChapter() {
    return Chapter(
      name: name,
      words: words,
      path: path,
      created: created,
      salt: salt,
    );
  }

  List<int> excludedIndex = [];

  @override
  Map<String, dynamic> toJson() => throw Error();
}
