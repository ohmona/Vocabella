import 'dart:convert';

import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/models/wordpair_model.dart';

class EventDataModel {
  static List<EventDataModel> eventList = [];

  SubjectDataModel? subjectData;
  List<WordPair>? wordPack;
  String? title;
  bool? bPractised;
  late DateTime date;
  late int size;
  late bool bUpcoming;
  late bool bValid;

  // constructor
  EventDataModel({
    this.subjectData,
    this.wordPack,
    this.title,
    required this.date,
  }) {
    size = wordPack!.length;
    bUpcoming = true;
    bValid = true;
    bPractised = false;
  }

  static List<EventDataModel> listFromJson(dynamic json) {
    List<EventDataModel> list = [];
    final data = jsonDecode(json) as List<dynamic>;

    for(dynamic inst in data) {
      SubjectDataModel s = SubjectDataModel.fromJson(inst['subjectData']);
      String t = inst['title'];
      bool p = inst['bPractised'];
      DateTime d = DateTime.tryParse(inst['date']) ?? DateTime(0);
      int si = inst['size'];
      bool u = inst['bUpcoming'];
      bool v = inst['bValid'];

      List<WordPair> w = [];
      for(int i = 0; i < (inst['wordPack'] as List<dynamic>).length; i++) {
        w.add(WordPair.fromJson(inst['wordPack'][i]));
      }

      EventDataModel e = EventDataModel(date: d, wordPack: w, title: t, subjectData: s);
      e.bPractised = p;
      e.size = si;
      e.bUpcoming = u;
      e.bValid = v;
      if(d.isAfter(DateTime.now().subtract(const Duration(days: 365)))) {
        list.add(e);
      }
    }
    return list;
  }

  static String listToJson() {
    return jsonEncode(eventList.map((event) => event.toJson()).toList());
  }

  Map<String, dynamic> toJson() {
    return {
      "subjectData": subjectData!.toJson(),
      "wordPack": wordPack!.map((word) => word.toJson()).toList(),
      "title": title,
      "bPractised": bPractised,
      "date": date.toString(),
      "size": size,
      "bUpcoming": bUpcoming,
      "bValid": bValid,
    };
  }

  /*static void generateExample() {
    if(eventList.isEmpty) {
      var list = [
        SubjectDataModel.subjectList[0].wordlist[0].words[0],
        SubjectDataModel.subjectList[0].wordlist[0].words[1],
        SubjectDataModel.subjectList[0].wordlist[0].words[2],
        SubjectDataModel.subjectList[0].wordlist[0].words[3],
        SubjectDataModel.subjectList[0].wordlist[0].words[4],
      ];
      DateTime n = DateTime.now().toUtc();
      eventList.add(EventDataModel(subjectData: SubjectDataModel.subjectList[0],
          wordPack: list,
          title: "TestEvent",
          date: n,
      ));

      print("======================================");
      print(eventList);
    }
  }*/

  static EventDataModel nullData() {
    EventDataModel e = EventDataModel(date: DateTime.now());
    e.bValid = true;
    return e;
  }
}
