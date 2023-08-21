

import 'package:vocabella/models/wordpair_model.dart';

class Chapter {
  late final String name;
  late final List<WordPair> words;

  Chapter({
    required this.name,
    required this.words,
  });

  Chapter.fromJson(dynamic json) {
    name = json["name"];

    List<WordPair> temp = [];
    for(dynamic word in json['words'] as List<dynamic>) {
      temp.add(WordPair.fromJson(word));
    }
    words = temp;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'words': words.map((wordPair) => wordPair.toJson()).toList(),
    };
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