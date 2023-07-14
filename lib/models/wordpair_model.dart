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

  WordPair.fromJson(dynamic json) {
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