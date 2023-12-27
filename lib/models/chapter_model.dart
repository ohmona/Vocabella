import 'package:flutter/foundation.dart';
import 'package:vocabella/models/wordpair_model.dart';

class Chapter {
  late String name;
  late List<WordPair> words;

  int? wordCount;
  int? lastIndex;

  Chapter({
    required this.name,
    required this.words,
    //this.id,
    this.lastIndex,
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
    if(json['lastIndex'] == null) {
      lastIndex = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'words': words.map((wordPair) => wordPair.toJson()).toList(),
      //'id': id,
      'lastIndex': lastIndex,
    };
  }

  static Chapter duplicate(Chapter object) {
    var newChapter = Chapter(name: object.name, words: object.words);
    return newChapter;
  }

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

}

class EditedChapter extends Chapter {
  EditedChapter({required super.name, required super.words});

  static EditedChapter copyFrom(Chapter chapter) {
    return EditedChapter(name: chapter.name, words: chapter.words);
  }

  Chapter toChapter() {
    return Chapter(name: name, words: words);
  }

  List<int> excludedIndex = [];

  @override
  Map<String, dynamic> toJson() => throw Error();
}
