
/*
* This class has a list of Wordpair classes
* and every chapter has own unique name
 */
import 'dart:convert';

class Chapter {
  late final String name;
  late final List<WordPair> words;

  Chapter({
    required this.name,
    required this.words,
  });

  Chapter.fromJson(Map<String, dynamic> json) {

    final _words = json['words'] as List<dynamic>;
    final parsedWords = _words.map((word) => WordPair.fromJson(word)).toList();

    name = json['name'].toString();
    words = parsedWords;
  }

  Map<String, dynamic> toJson() {
    return {
      'words': words,
      'name': words.map((wordPair) => wordPair.toJson()).toList(),
    };
  }
}

/*
* This class has the data of words and corresponding
* examples and every wordpair class has an id
 */
class WordPair {
  late String word1, word2; // question, answer
  late String? example1, example2;

  WordPair({
    required this.word1,
    required this.word2,
    this.example1,
    this.example2,
  });

  WordPair.fromJson(Map<String, dynamic> json) {
    word1 = json['word1'];
    word2 = json['word2'];
    example1 = json['example1'];
    example2 = json['example2'];
  }

  Map<String, dynamic> toJson() {
    return {
      'word1': word1,
      'word2': word2,
      'example1': example1 ?? "",
      'example2': example2 ?? "",
    };
  }
}