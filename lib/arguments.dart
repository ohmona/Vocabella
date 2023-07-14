import 'models/chapter_model.dart';
import 'models/subject_data_model.dart';
import 'models/wordpair_model.dart';

class ChapterSelectionScreenArguments {
  final SubjectDataModel subject;

  ChapterSelectionScreenArguments(this.subject);
}

class WordSelectionScreenArguments {
  final List<Chapter> chapters;
  final List<String> languages;

  WordSelectionScreenArguments(this.chapters, this.languages);
}

class ModeSelectionScreenArguments {
  final List<WordPair> wordPack;
  final List<String> languages;

  ModeSelectionScreenArguments(this.wordPack, this.languages);
}

class QuizScreenArguments {
  final List<WordPair> wordPack;
  final String language1;
  final String language2;

  QuizScreenArguments(this.wordPack, this.language1, this.language2);
}

class ResultScreenArguments {
  final int total;
  final double inFirstTry;

  ResultScreenArguments(this.total, this.inFirstTry);
}