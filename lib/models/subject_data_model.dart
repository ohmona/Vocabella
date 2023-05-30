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
            id: 1,
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
  final String title, id;
  final String? thumb;
  final List<String> subjects;

  final WordsList wordlist;

  SubjectDataModel({
    required this.title,
    required this.id,
    this.thumb,
    required this.subjects,
    required this.wordlist,
  });

  //TODO: make this lol I give up
  /*SubjectDataModel.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        id = json["id"],
        thumb = json["thumb"],
        subjects = json["subjects"],
        words = json['words'] {
    print("object");
  }*/

  // Example data for test
  static SubjectDataModel createExampleData() {
    return SubjectDataModel(
      title: "Green Line 5",
      id: "05",
      thumb: null,
      subjects: ["English", "German"],
      wordlist: [
        Chapter(
          name: "Across cultures 1",
          words: [
            WordPair(
              id: 1,
              word1: "segregation",
              word2: "Segregation; Trennung; Rassentrennung",
              example1: "Apartheid meant racial segregation.",
            ),
            WordPair(
              id: 2,
              word1: "apartheid",
              word2: "Apartheid",
              example1: "The South African apartheid system ended in 1994.",
            ),
            WordPair(
              id: 3,
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
              id: 1,
              word1: "G'day!",
              word2: "Guten Tag.; Hallo.; Hi. (Begrüßung in Australien)",
            ),
            WordPair(
              id: 2,
              word1: "coral reef",
              word2: "Korallenriff",
              example1: "The Great Barrier Reef is a huge coral reef.",
            ),
            WordPair(
              id: 3,
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

  // turn entire data into list which has words in same order as wordlist
  List<List<String>> toList() {
    List<List<String>> list = [];
    for (var chapter in wordlist) {
      for (var word in chapter.words) {
        list.add([
          word.word1,
          word.word2,
          word.example1 ?? "",
          word.example2 ?? "",
        ]);
      }
    }
    return list;
  }
}
