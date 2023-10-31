import 'models/chapter_model.dart';
import 'models/session_data_model.dart';
import 'models/subject_data_model.dart';
import 'models/wordpair_model.dart';

class ChapterSelectionScreenArguments {
  final SubjectDataModel subject;

  ChapterSelectionScreenArguments(this.subject);
}

class WordSelectionScreenArguments {
  final EditedChapter chapter;
  final int originalIndex;
  final bool selected;
  final void Function(int, List<int>) applyEdit;

  WordSelectionScreenArguments(
      this.chapter, this.selected, this.applyEdit, this.originalIndex);
}

class ModeSelectionScreenArguments {
  final SubjectDataModel data;
  final List<WordPair> wordPack;
  final List<String> languages;

  ModeSelectionScreenArguments(this.wordPack, this.languages, this.data);
}

class QuizScreenArguments {
  final List<WordPair> wordPack;
  final String language1;
  final String language2;
  final SessionDataModel sessionData;

  QuizScreenArguments(
      this.wordPack, this.language1, this.language2, this.sessionData);
}

class ResultScreenArguments {
  final int total;
  final double inFirstTry;

  ResultScreenArguments(this.total, this.inFirstTry);
}

class EditorScreenArguments {
  final SubjectDataModel data;
  final void Function() refresh;

  EditorScreenArguments(this.data, this.refresh);
}

class SubjectCreationScreenArguments {
  final void Function({
    required String newTitle,
    required String newSubject1,
    required String newSubject2,
    required String newLanguage1,
    required String newLanguage2,
    required String newChapter,
  }) createNewSubject;

  SubjectCreationScreenArguments(this.createNewSubject);
}
