import 'dart:convert';

import 'package:vocabella/models/wordpair_model.dart';

import 'chapter_model.dart';

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

class SubjectDataModel {
  static List<SubjectDataModel> subjectList = [];

  String? title;
  String? thumb;
  List<String>? subjects;
  List<String>? languages;

  List<Chapter>? wordlist;

  SubjectDataModel({
    required this.title,
    this.thumb,
    required this.subjects,
    required this.wordlist,
    required this.languages,
  });

  /// Create list of data from not decoded json data
  /// Since json data has only type of a list, fromJson constructor isn't necessary
  /// So use this function instead
  static List<SubjectDataModel> listFromJson(dynamic json) {
    // Declare list to return
    List<SubjectDataModel> subjects = [];

    // Decode received json data to dart List
    final jsonList = jsonDecode(json) as List<dynamic>;

    // Create individual instances from decoded json
    for (dynamic inst in jsonList) {
      // Since the data is currently dynamic, it's necessary to copy the data one by one

      // Create dummy instance having nothing
      SubjectDataModel sub = SubjectDataModel(
        languages: ['', ''],
        subjects: ['', ''],
        title: "",
        wordlist: [],
      );

      // Now we copy the data
      sub.title = inst['title'];
      sub.subjects![0] = inst['subjects'][0];
      sub.subjects![1] = inst['subjects'][1];
      sub.languages![0] = inst['languages'][0];
      sub.languages![1] = inst['languages'][1];
      for (int i = 0; i < (inst['wordlist'] as List<dynamic>).length; i++) {
        sub.wordlist!.add(Chapter.fromJson(inst['wordlist'][i]));
      }

      // Finally add created instance to the list to return
      subjects.add(sub);
    }
    return subjects;
  }

  /// Convert current list into encoded json by converting individual instances
  static String listToJson(List<SubjectDataModel> subjects) {
    return jsonEncode(subjects.map((subject) => subject.toJson()).toList());
  }

  /// Convert current instance into encoded json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subjects': subjects,
      'languages': languages,
      'wordlist': wordlist?.map((chapter) => chapter.toJson()).toList(),
    };
  }

  /// Add current instance into list
  void addToList() {
    if (!subjectList.contains(this)) {
      print("====================================");
      print("Adding new subject");
      subjectList.add(this);
    } else {
      print("====================================");
      print("Subject already exists!");
    }
  }

  /// Remove current instance from list
  void removeFromList() {
    if (subjectList.contains(this)) {
      print("====================================");
      print("Removing new subject");
      subjectList.remove(this);
    }
  }

  // Debug
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
            WordPair(
              word1: "word",
              word2: "Wort",
              example1:
              "If you don't learn words, you won't ever get better.",
            ),
          ],
        ),
      ],
    );
  }

  printData() {
    print("====================================");
    print("Printing data of:");
    print(title);
    print(languages);
    print(subjects);
    for (Chapter chap in wordlist!) {
      print(chap.name);
      for (WordPair word in chap.words) {
        print(word.word1);
        print(word.word2);
        print(word.example1);
        print(word.example2);
      }
    }
  }

  static printEveryData() {
    for (SubjectDataModel sub in subjectList) {
      sub.printData();
    }
  }

  static void addAll(List<SubjectDataModel> subjects) {
    print("====================================");
    print("add many subjects");

    subjectList.addAll(subjects);
  }

  static void setAll(List<SubjectDataModel> subjects) {
    subjectList = subjects;
  }
}
