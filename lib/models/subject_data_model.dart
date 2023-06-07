import 'dart:convert';

import 'package:vocabella/classes.dart';

// Word list.json will look like this
/*"words": [
    "chapter": {
      "pairID": {
        "word1",
        "word2",
        "example1",
        "example2",
      },
    },
  ];
  ... but
  this should converted into this
  List<Chapter> [
      Chapter(
        name: "poo",
        words: [
          WordPair(
            word1: "bar",
            word2: "sans",
            example1: "...it's not necessary at all",
          ),
          WordPair(...),
        ],
      ),
      Chapter(...),
    ],
  ]
*/

typedef WordsList = List<Chapter>;

class SubjectDataModel {
  static List<SubjectDataModel> subjectList = [];

  String? title;
  String? thumb;
  List<String>? subjects;
  List<String>? languages;

  WordsList? wordlist;

  SubjectDataModel({
    required this.title,
    this.thumb,
    required this.subjects,
    required this.wordlist,
    required this.languages,
  });

  // create instance by json
  factory SubjectDataModel.fromJson(Map<String, dynamic> json) {
    final chapters = json['wordlist'] as List<dynamic>;
    final parsedChapters = chapters.map((chapter) => Chapter.fromJson(chapter)).toList();

    List<String> tempSubjects = [];
    tempSubjects.add(json['subjects'][0]);
    tempSubjects.add(json['subjects'][1]);

    List<String> tempLanguages = [];
    tempLanguages.add(json['languages'][0]);
    tempLanguages.add(json['languages'][1]);

    return SubjectDataModel(
      wordlist: parsedChapters,
      title: json['title'],
      subjects: tempSubjects,
      languages: tempLanguages,
    );
  }

  static void addAll(List<SubjectDataModel> subjects) {
    print("====================================");
    print("add many subjects");

    subjectList.addAll(subjects);
  }

  static void setAll(List<SubjectDataModel> subjects) {
    subjectList = subjects;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subjects': subjects,
      'languages': languages,
      'wordlist': wordlist?.map((wordlist) => wordlist.toJson()).toList(),
    };
  }

  // Example data for test
  static SubjectDataModel createExampleData() {
    return SubjectDataModel(
      title: "Green Line 5",
      thumb: null,
      subjects: ["English", "German"],
      languages: ["en-US", "de-DE"],
      wordlist: [
        Chapter(
          name: "Across cultures 1",
          words: [
            WordPair(
              word1: "segregation",
              word2: "Segregation; Trennung; Rassentrennung",
              example1: "Apartheid meant racial segregation.",
            ),
            WordPair(
              word1: "apartheid",
              word2: "Apartheid",
              example1: "The South African apartheid system ended in 1994.",
            ),
            WordPair(
              word1: "racism",
              word2: "Rassismus",
              example1: "Apartheid was based on racism.",
            ),
          ],
        ),
        Chapter(
          name: "Unit 1/Check-in",
          words: [
            WordPair(
              word1: "G'day!",
              word2: "Guten Tag.; Hallo.; Hi. (Begrüßung in Australien)",
            ),
            WordPair(
              word1: "coral reef",
              word2: "Korallenriff",
              example1: "The Great Barrier Reef is a huge coral reef.",
            ),
            WordPair(
              word1: "purpose",
              word2: "Ziel; Absicht; Zweck",
              example1:
              "If you have a purpose, you have a reason to do something.",
            ),
          ],
        ),
      ],
    );
  }

  static List<SubjectDataModel> listFromJson(String json) {
    final parsed = jsonDecode(json) as List<dynamic>;
    return parsed.map((item) => SubjectDataModel.fromJson(item)).toList();
  }

  static String listToJson(List<SubjectDataModel> subjects) {
    return jsonEncode(subjects.map((subject) => subject.toJson()).toList());
  }

  // Compresses this data into a JSON string
  String convertToJson() {
    Map<String, dynamic> jsonData = {
      'title': title,
      'thumb': thumb,
      'subjects': jsonEncode(subjects),
      'languages': jsonEncode(languages),
      'wordlist': jsonEncode(convertWordlistToJson(wordlist)),
    };

    return jsonEncode(jsonData);
  }

  // Converts the wordlist into a JSON-encodable structure
  static List<Map<String, dynamic>> convertWordlistToJson(WordsList? wordlist) {
    List<Map<String, dynamic>> jsonWordlist = [];

    if (wordlist != null) {
      for (Chapter chapter in wordlist) {
        List<Map<String, dynamic>> jsonWords = chapter.words.map((wordPair) {
          return {
            'word1': wordPair.word1,
            'word2': wordPair.word2,
            'example1': wordPair.example1,
            'example2': wordPair.example2,
          };
        }).toList();

        Map<String, dynamic> jsonChapter = {
          'name': chapter.name,
          'words': jsonWords,
        };

        jsonWordlist.add(jsonChapter);
      }
    }

    return jsonWordlist;
  }

  // make list from compressed string
  static List<SubjectDataModel> makeListFromJson(String jsonString) {
    List<SubjectDataModel> temp = [];
    for (String partJson in convertJsonToList(jsonString)) {
      temp.add(SubjectDataModel.fromJson(jsonDecode(partJson)));
    }
    return temp;
  }

  static List<String> convertJsonToList(String jsonString) {
    dynamic jsonObject = jsonDecode(jsonString);

    if (jsonObject is List<dynamic>) {
      // JSON string is enclosed in brackets []
      return jsonObject.map((item) => item.toString()).toList();
    } else if (jsonObject is Map<String, dynamic>) {
      // JSON string is enclosed in braces {}
      return jsonObject.values.map((item) => item.toString()).toList();
    }

    return [];
  }


  /*// convert json structure to desired structure
  static List<Chapter> convertJsonToWordlist(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<Chapter> chapters = jsonList.map((jsonChapter) {
      List<dynamic> jsonWords = jsonChapter['words'];
      List<WordPair> words = jsonWords.map((jsonWord) {
        return WordPair(
          word1: jsonWord['word1'],
          word2: jsonWord['word2'],
          example1: jsonWord['example1'],
          example2: jsonWord['example2'],
        );
      }).toList();

      return Chapter(
        name: jsonChapter['name'],
        words: words,
      );
    }).toList();

    return chapters;
  }*/

  // add instance to list
  void addToList() {
    if (!subjectList.contains(this)) {
      print("====================================");
      print("Adding new subject");
      subjectList.add(this);
    }
    else {
      print("====================================");
      print("Subject already exists!");
    }
  }

  // remove instance from list
  void removeFromList() {
    if (subjectList.contains(this)) {
      print("====================================");
      print("Removing new subject");
      subjectList.remove(this);
    }
  }

  printData() {
    print("====================================");
    print("Printing data of:");
    print(title);
    print(languages);
    print(subjects);
    for(Chapter chap in wordlist!) {
      print(chap.name);
      for(WordPair word in chap.words) {
        print(word.word1);
        print(word.word2);
        print(word.example1);
        print(word.example2);
      }
    }
  }

  static printEveryData() {
    for(SubjectDataModel sub in subjectList) {
      sub.printData();
    }
  }
}
