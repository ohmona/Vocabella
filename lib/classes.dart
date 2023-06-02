
/*
* This class has a list of Wordpair classes
* and every chapter has own unique name
 */
class Chapter {
  final String name;
  final List<WordPair> words;

  Chapter({
    required this.name,
    required this.words,
  });
}

/*
* This class has the data of words and corresponding
* examples and every wordpair class has an id
 */
class WordPair {
  final String word1, word2; // question, answer
  final int id;
  final String? example1, example2;

  WordPair({
    required this.word1,
    required this.word2,
    required this.id,
    this.example1,
    this.example2,
  });
}