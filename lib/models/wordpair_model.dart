/*
* This class has the data of words and corresponding
* examples and every wordpair class has an id
 */
import 'package:vocabella/constants.dart';

class WordPair {
  late String word1, word2; // question, answer
  late String? example1, example2;
  static int globalCount = 1;
  int? id;
  String? globalId;

  WordPair({
    required this.word1,
    required this.word2,
    this.example1,
    this.example2,
  });

  WordPair.fromJson(
    dynamic json, {
    required String name,
  }) {
    word1 = json['word1'];
    word2 = json['word2'];
    example1 = json['example1'];
    example2 = json['example2'];

    id = json['id'];
    if (json['id'] == null) {
      id = globalCount;
    }

    globalId = json['globalId'];
    if (json['globalId'] == null) {
      globalId = makeWordPairId(id: globalCount, name: name);
    }
    globalCount += 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'word1': word1,
      'word2': word2,
      'example1': example1 ?? "",
      'example2': example2 ?? "",
      'id': id,
      'globalId': globalId,
    };
  }

  void updateId(int newId) {
    id = newId;
  }

  void updateGlobalId(String newChapterName) {
    globalId = makeWordPairId(id: id!, name: newChapterName);
  }

  void printWord() {
    print("first word : $word1");
    print("second word : $word2");
    print("first example : $example1");
    print("second example : $example2");
    print("id : $id");
    print("global id : $globalId");
  }

  bool isSameWord({required WordPair as}) {

    if (word1 == as.word1 && word2 == as.word2) {
      // TODO currently examples aren't checked
      return true;
    }
    return false;
  }
}
