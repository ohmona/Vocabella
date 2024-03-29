import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vocabella/main.dart';
import 'package:vocabella/models/wordpair_model.dart';
import 'package:vocabella/utils/random.dart';

import '../utils/constants.dart';
import 'chapter_model.dart';

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
  //int? lastOpenedChapterIndex = 0;
  String? lastOpenedChapter = "";

  SubjectDataModel({
    required this.title,
    required this.thumb,
    required this.subjects,
    required this.wordlist,
    required this.languages,
    this.version,
    this.id,
    this.lastOpenedChapter,
  });

  static SubjectDataModel fromJson(dynamic decodedJson) {

    // Create dummy instance having nothing
    SubjectDataModel sub = SubjectDataModel(
      languages: ['', ''],
      subjects: ['', ''],
      title: "",
      wordlist: [],
      thumb: "",
    );

    // Copy essential data
    sub.title = decodedJson['title'];
    if (kDebugMode) {
      print("Title loading successful");
    }
    sub.thumb = decodedJson['thumb'];
    if (kDebugMode) {
      print("Thumbnail loading successful");
    }
    sub.subjects[0] = decodedJson['subjects'][0];
    if (kDebugMode) {
      print("First Subject loading successful");
    }
    sub.subjects[1] = decodedJson['subjects'][1];
    if (kDebugMode) {
      print("Second Subject loading successful");
    }
    sub.languages[0] = decodedJson['languages'][0];
    if (kDebugMode) {
      print("First Language loading successful");
    }
    sub.languages[1] = decodedJson['languages'][1];
    if (kDebugMode) {
      print("Second Language loading successful");
    }

    sub.version = decodedJson['version'];
    // Check if json hasn't version data
    if(decodedJson['version'] == null) {
      // if there's no data, assume that the data was created in version 1.0
      sub.version = "1.0";
      if (kDebugMode) {
        print("Version initialising successful");
      }
    }
    else {
      if (kDebugMode) {
        print("Version loading successful");
      }
    }

    sub.id = decodedJson['id'];
    if(decodedJson['id'] == null) {
      // Create Id
      final date = DateTime.now().toString();
      if (kDebugMode) {
        print("data creation date: $date");
      }
      sub.id = makeSubjectId(date: date, name: sub.title);
      if (kDebugMode) {
        print("ID creation successful");
      }
    }
    else {
      if (kDebugMode) {
        print("ID loading successful");
      }
    }


    // Copy word data
    for (int i = 0; i < (decodedJson['wordlist'] as List<dynamic>).length; i++) {
      sub.wordlist.add(Chapter.fromJson(decodedJson['wordlist'][i]));
      if (kDebugMode) {
        print("Chapter loading successful : $i");
      }
    }
    if (kDebugMode) {
      print("Chapters initialising successful");
    }

    // Get the length of current chapters
    sub.chapterCount = sub.wordlist.length;
    if (kDebugMode) {
      print("Chapter Count loading successful");
    }

    // Get the index of last opened Chapter
    sub.lastOpenedChapter = decodedJson['lastOpenedChapter'];
    if(decodedJson['lastOpenedChapter'] == null) {
      sub.lastOpenedChapter = "/";
    }
    else {
      if (kDebugMode) {
        print("Last Opened Chapter loading successful");
      }
    }

    sub.version = appVersion;

    return sub;
  }

  static List<SubjectDataModel> listFromJson(dynamic json) {
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
          sub.id = makeSubjectId(date: date, name: sub.title);
        }


        // Copy word data
        for (int i = 0; i < (inst['wordlist'] as List<dynamic>).length; i++) {
          sub.wordlist.add(Chapter.fromJson(inst['wordlist'][i]));
        }

        // Get the length of current chapters
        sub.chapterCount = sub.wordlist.length;

        // Get the index of last opened Chapter
        sub.lastOpenedChapter = inst['lastOpenedChapter'];
        if(inst['lastOpenedChapter'] == null) {
          sub.lastOpenedChapter = "/";
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
      'lastOpenedChapter': lastOpenedChapter,
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
        print("Chapter : '${chap.comprisePath()}'");
        //print("Chapter id : '${chap.id}'");
        for (WordPair word in chap.words) {
          /*print("First word : '${word.word1}'");
          print("Second word : '${word.word2}'");
          print("Fist example : '${word.example1}'");
          print("Second example : '${word.example2}'");*/
          //print("id : '${word.id}'");
          //print("global id : '${word.globalId}'");
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
        print("Currently copying chapter : ${copyingChapter.comprisePath()}");
      }
      if(pasting.existChapterAlready(copyingChapter)) {
        if (kDebugMode) {
          print("==================================");
          print("The chapter is already included in the list");
        }
        for(int i = 0; i < pasting.wordlist.length; i++) {
          if(pasting.wordlist[i].isSameChapter(as: copyingChapter)) {
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
                  print("Adding new word");
                }
                pasting.wordlist[i].words.add(element);
              }
              else {
                if (kDebugMode) {
                  print("==================================");
                  print("Overriding data");
                }
                var index = pasting.wordlist[i].findAlreadyExistingWord(element);
                if(index != -1) {
                  var original = pasting.wordlist[i].words[index];

                  // check whether current data is older one
                  if (original.lastEdit!.isBefore(element.lastEdit!)) {
                    // Apply lastEdit, data
                    original.lastEdit = element.lastEdit;
                    original.word1 = element.word1;
                    original.word2 = element.word2;
                    original.example1 = element.example1;
                    original.example2 = element.example2;
                    original.favourite = element.favourite;
                  }
                  else if (original.lastLearned != null ||
                      element.lastLearned != null) {

                    if (original.lastLearned != null &&
                        element.lastLearned != null) {
                      if (original.lastLearned!.isBefore(
                          element.lastLearned!)) {
                        original.lastLearned = element.lastLearned;
                        original.errorStack = element.errorStack;
                        original.lastPriorityFactor = element.lastPriorityFactor;
                        original.totalLearned = element.totalLearned;
                      }
                    }
                    else if (element.lastLearned != null) {
                      original.lastLearned = element.lastLearned;
                      original.errorStack = element.errorStack;
                      original.lastPriorityFactor = element.lastPriorityFactor;
                      original.totalLearned = element.totalLearned;
                    }
                  }
                  pasting.wordlist[i].words[index] = original;
                }
              }
            }
          }
        }
      }
      else {
        if (kDebugMode) {
          print("==================================");
          print("The chapter does not exist, so it'll be added");
        }
        //copyingChapter.id = pasting.wordlist.length + 1;
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

  bool existChapterAlready(Chapter chapter) {
    for(var element in wordlist) {
      if(element.created == chapter.created && element.salt == chapter.salt) {
        return true;
      }
    }
    return false;
  }

  static void fixInvalid() {
    if (kDebugMode) {
      print("Checking invalid data");
    }
    for(int i = 0; i < subjectList.length; i++) {
      if (kDebugMode) {
        print("Subject : $i");
      }
      for(int j = 0; j < subjectList[i].wordlist.length; j++) {
        if (kDebugMode) {
          print("Chapter : $j");
        }
        if(subjectList[i].wordlist[j].salt == null) {
          if (kDebugMode) {
            print("invalid chapter found");
          }
          subjectList[i].wordlist[j].salt = generateRandomString(4);
        }
        for(int k = 0; k < subjectList[i].wordlist[j].words.length; k++) {
          if (kDebugMode) {
            print("Word : $k");
          }
          if(subjectList[i].wordlist[j].words[k].salt == null) {
            if (kDebugMode) {
              print("invalid word pair found");
            }
            subjectList[i].wordlist[j].words[k].salt = generateRandomString(4);
          }
        }
      }
    }
  }

  int? indexOf(String fullPath) {
    for(var ele in wordlist) {
      if(fullPath == ele.comprisePath()) {
        return wordlist.indexOf(ele);
      }
    }
    return null;
  }

  int getIndexByPath(String smallPath) {
    for(var ele in wordlist) {
      if(smallPath == ele.path) {
        return wordlist.indexOf(ele);
      }
    }
    return -1;
  }
}
