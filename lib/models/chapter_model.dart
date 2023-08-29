import 'package:vocabella/models/wordpair_model.dart';

class Chapter {
  late String name;
  late List<WordPair> words;

  int? id;
  static int globalCount = 1;
  int? wordCount;

  Chapter({
    required this.name,
    required this.words,
    this.id,
  });

  Chapter.fromJson(dynamic json) {
    name = json["name"];

    id = json['id'];
    if (json['id'] == null) {
      // Set id
      id = globalCount;
      globalCount += 1;
    }

    WordPair.globalCount = 1;
    List<WordPair> temp = [];
    for (dynamic word in json['words'] as List<dynamic>) {
      temp.add(
        WordPair.fromJson(
          word,
          name: name,
        ),
      );
    }
    words = temp;

    // get length of words
    wordCount = words.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'words': words.map((wordPair) => wordPair.toJson()).toList(),
      'id': id,
    };
  }

  void updateAllId() {
    for (int i = 0; i < words.length; i++) {
      words[i].updateId(i);
      words[i].updateGlobalId(name);
    }
  }

  bool existWordAlready(WordPair wordPair) {
    for (var word in words) {
      if (word.isSameWord(as: wordPair)) {
        return true;
      }
    }
    print("printing false");
    return false;
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
