import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vocabella/main.dart';
import 'package:vocabella/models/wordpair_model.dart';

import '../constants.dart';
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

  String title;
  String? thumb;
  List<String> subjects;
  List<String> languages;

  List<Chapter> wordlist;

  // Added after 1.1
  String? version;
  String? id;
  int chapterCount = -1;

  // Added after 1.3.7
  int? lastOpenedChapterIndex = 0;

  SubjectDataModel({
    required this.title,
    required this.thumb,
    required this.subjects,
    required this.wordlist,
    required this.languages,
    this.version,
    this.id,
    this.lastOpenedChapterIndex,
  });

  /// Create list of data from not decoded json data
  /// Since json data has only type of a list, fromJson constructor isn't necessary
  /// So use this function instead
  static List<SubjectDataModel> listFromJson(dynamic json) {
    print("========================================");
    print("make list");
    try {
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
          thumb: "",
        );

        // Copy essential data
        sub.title = inst['title'];
        sub.thumb = inst['thumb'];
        sub.subjects[0] = inst['subjects'][0];
        sub.subjects[1] = inst['subjects'][1];
        sub.languages[0] = inst['languages'][0];
        sub.languages[1] = inst['languages'][1];

        sub.version = inst['version'];
        // Check if json hasn't version data
        if(inst['version'] == null) {
          // if there's no data, assume that the data was created in version 1.0
          sub.version = "1.0";
        }

        sub.id = inst['id'];
        if(inst['id'] == null) {
          // Create Id
          final date = DateTime.now().toString();
          if (kDebugMode) {
            print("data creation date: $date");
          }
          sub.id = makeSubjectId(date: date, name: sub.title);
        }

        Chapter.globalCount = 1;
        // Copy word data
        for (int i = 0; i < (inst['wordlist'] as List<dynamic>).length; i++) {
          sub.wordlist.add(Chapter.fromJson(inst['wordlist'][i]));
        }

        // Get the length of current chapters
        sub.chapterCount = sub.wordlist.length;

        // Get the index of last opened Chapter
        sub.lastOpenedChapterIndex = inst['lastOpenedChapterIndex'];
        if(inst['lastOpenedChapterIndex'] == null) {
          sub.lastOpenedChapterIndex = 0;
        }

        // Update version
        sub.version = appVersion;

        // Finally add created instance to the list to return
        subjects.add(sub);
      }
      return subjects;
    } catch (e) {
      if (kDebugMode) {
        print("An error was threw while creating new subject instance");
        print(e);
      }
      return [];
    }
  }

  /// Convert current list into encoded json by converting individual instances
  static String listToJson(List<SubjectDataModel> subjects) {
    return jsonEncode(subjects.map((subject) => subject.toJson()).toList());
  }

  /// Convert current instance into encoded json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumb': thumb,
      'subjects': subjects,
      'languages': languages,
      'wordlist': wordlist.map((chapter) => chapter.toJson()).toList(),
      'version': version,
      'id': id,
      'lastOpenedChapterIndex': lastOpenedChapterIndex,
    };
  }

  /// Add current instance into list
  void addToList() {
    if (!subjectList.contains(this)) {
      if (kDebugMode) {
        print("====================================");
        print("Adding new subject");
      }
      subjectList.add(this);
    } else {
      if (kDebugMode) {
        print("====================================");
        print("Subject already exists!");
      }
    }
  }

  /// Remove current instance from list
  void removeFromList() {
    if (subjectList.contains(this)) {
      if (kDebugMode) {
        print("====================================");
        print("Removing new subject");
      }
      subjectList.remove(this);
    }
  }

  int getWordCount() {
    int count = 0;
    for (Chapter chapter in wordlist) {
      count += chapter.words.length;
    }
    return count;
  }

  // Debug
  // Example data for test
  @Deprecated("Don't use this anymore")
  static SubjectDataModel createExampleData() {
    return SubjectDataModel(
      title: "Green Line 5",
      thumb: "",
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
              example1: "If you don't learn words, you won't ever get better.",
            ),
          ],
        ),
      ],
    );
  }

  printData() {
    if (kDebugMode) {
      print("====================================");
      print("Printing data of:");
      print("title : $title");
      print("thumb : $thumb");
      print("lang : $languages");
      print("subs : $subjects");
      print("version : $version");
      print("id : $id");
      for (Chapter chap in wordlist) {
        print("Chapter name : '${chap.name}'");
        print("Chapter id : '${chap.id}'");
        for (WordPair word in chap.words) {
          print("First word : '${word.word1}'");
          print("Second word : '${word.word2}'");
          print("Fist example : '${word.example1}'");
          print("Second example : '${word.example2}'");
          print("id : '${word.id}'");
          print("global id : '${word.globalId}'");
        }
      }
    }
  }

  static printEveryData() {
    for (SubjectDataModel sub in subjectList) {
      sub.printData();
    }
  }

  static void addAll(List<SubjectDataModel> subjects) {
    if (kDebugMode) {
      print("====================================");
      print("add many subjects");
    }

    subjectList.addAll(subjects);
  }

  static void setAll(List<SubjectDataModel> subjects) {
    subjectList = subjects;
  }

  /// Copy merging data to target data
  /// Where Chapter is copied if there's no Chapter with same name
  /// and if there's Chapter with same name, the words will be stacked to data
  /// After all, the data will be replaced to original data
  ///
  /// subject : data to be copied to target data
  /// to : target data which should have already been added to subjectList
  static void merge(SubjectDataModel subject, {required SubjectDataModel to}) {
    if(!subjectList.contains(to)) {
      return;
    }

    var pasting = to;
    if (kDebugMode) {
      print("==================================");
      print("Printing pasting data : ${pasting.title}");
      pasting.printData();
    }

    for(Chapter copyingChapter in subject.wordlist) {
      if (kDebugMode) {
        print("==================================");
        print("Currently copying chapter : ${copyingChapter.name}");
      }
      if(pasting.existChapterNameAlready(copyingChapter.name)) {
        if (kDebugMode) {
          print("==================================");
          print("The chapter is already included in the list");
        }
        for(int i = 0; i < pasting.wordlist.length; i++) {
          if(pasting.wordlist[i].name == copyingChapter.name) {
            if (kDebugMode) {
              print("==================================");
              print("The chapter from pasting data found : $i");
              print("The length : ${copyingChapter.words.length}");
            }
            // Copy every words
            for (var element in copyingChapter.words) {
              if (kDebugMode) {
                print("==================================");
                print("Now looking for the word : ${element.word1} / ${element.word2} / ${element.example1} / ${element.example2}");
              }

              // If they aren't same, add it to list
              if(!pasting.wordlist[i].existWordAlready(element)) {
                if (kDebugMode) {
                  print("adding non existing word!!!!!!!");
                }
                pasting.wordlist[i].words.add(element);
              }
              else {
                if (kDebugMode) {
                  print("==================================");
                  print("The word already exist!");
                }
              }
            }
            pasting.wordlist[i].updateAllId();
          }
        }
      }
      else {
        if (kDebugMode) {
          print("==================================");
          print("The chapter does not exist, so it'll be added");
        }
        copyingChapter.id = pasting.wordlist.length + 1;
        pasting.wordlist.add(copyingChapter);
        pasting.chapterCount = pasting.wordlist.length;
      }
    }

    for(int i = 0; i < subjectList.length; i++) {
      if(subjectList[i].title == to.title) {
        subjectList[i] = pasting;
        if (kDebugMode) {
          print("data successfully merged");
        }
      }
    }
  }

  static int getSubjectIndexByName(String name) {
    for(int i = 0; i < subjectList.length; i++) {
      if(subjectList[i].title == name) {
        return i;
      }
    }
    return -1;
  }

  bool existChapterNameAlready(String name) {
    for (var element in wordlist) {
      if(element.name == name) {
        return true;
      }
    }
    return false;
  }
}
