import 'package:flutter/material.dart';
import 'package:vocabella/screens/editor_screen.dart';
import 'package:vocabella/utils/configuration.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

/*class WordGridTile extends StatefulWidget {
  const WordGridTile({
    Key? key,
    required this.text,
    required this.index,
    required this.saveText,
    required this.currentChapter,
    required this.bShowingWords,
    required this.addWord,
    required this.bDeleteMode,
    required this.deleteWord,
    required this.changeFocus,
    required this.bFocused,
    required this.wordAdditionBuffer,
    required this.wordPair,
  }) : super(key: key);

  final String text;
  final int index;
  final WordPair wordPair;

  final void Function(String newText, int index) saveText;
  final void Function(WordPair wordPair) addWord;
  final void Function(WordPair wordPair) deleteWord;
  final void Function(
    int newIndex, {
    bool requestFocus,
    bool force,
  }) changeFocus;

  final Chapter currentChapter;
  final WordPair wordAdditionBuffer;
  final bool bShowingWords;
  final bool bDeleteMode;
  final bool bFocused;

  @override
  State<WordGridTile> createState() => _WordGridTileState();
}

class _WordGridTileState extends State<WordGridTile> {
  late String text;

  void updateText() {
    final int wordPairIndex = widget.index ~/
        2; // Update this line to calculate the wordPairIndex correctly

    if (wordPairIndex > widget.currentChapter.words.length) {
      text = "";
      return;
    }

    WordPair wordPair;
    if (wordPairIndex <= widget.currentChapter.words.length - 1) {
      // Get the WordPair from the currentChapter based on the wordPairIndex
      wordPair = widget.currentChapter.words[wordPairIndex];
    } else {
      wordPair = widget.wordAdditionBuffer;
    }

    // Determine which text to display based on bShowingWords flag
    if (widget.bShowingWords) {
      text = (widget.index) % 2 == 0 ? wordPair.word1 : wordPair.word2;
    } else {
      text = (widget.index) % 2 == 0
          ? wordPair.example1 ?? ""
          : wordPair.example2 ?? "";
    }
  }

  @override
  void initState() {
    super.initState();

    // initialize the text
    text = widget.text;
  }

  @override
  void didUpdateWidget(covariant WordGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Call updateText whenever the widget is updated
    updateText();
  }

  Widget _buildContent() {
    final favourite = widget.wordPair.favourite!;

    // Define the desired font weight
    const FontWeight fontWeight =
        FontWeight.normal; // Replace with your desired font weight

    Color textCol;
    if (favourite) {
      textCol = Colors.black;
    } else if (widget.bShowingWords) {
      textCol = Colors.black;
    } else {
      textCol = Colors.grey;
    }

    // Use a FittedBox to scale the text to fit within the available space
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: fontWeight,
            color: textCol,
            shadows: favourite
                ? [
                    const Shadow(
                      color: Colors.yellowAccent,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBox() {
    final favourite = widget.wordPair.favourite!;
    final focused = widget.bFocused;

    Color borderColor;
    double borderSize;
    if (focused) {
      borderColor = Colors.redAccent;
      borderSize = 3;
    } else if (favourite) {
      borderColor = Colors.black;
      borderSize = 0.5;
    } else {
      borderColor = Colors.black;
      borderSize = 0.5;
    }

    return BoxDecoration(
      color: favourite ? Colors.white : Colors.white,
      border: Border.all(
        color: borderColor,
        width: borderSize,
        style: BorderStyle.solid,
      ),
    );
  }

  Widget _buildCell() {
    // Determine the width and height of the cell
    final cellWidth = MediaQuery.of(context).size.width / 2;
    const cellHeight =
        50.0; // Adjust the aspect ratio based on your requirement

    // Use a ConstrainedBox to limit the cell size
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cellWidth, maxHeight: cellHeight),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(5),
            decoration: _buildBox(),
            child: _buildContent(),
          ),
          if (AppConfig.bDebugMode)
            Text(
              "C:${widget.wordPair.created},E:${widget.wordPair.lastEdit},I:${widget.index},"
              "F:${widget.wordPair.favourite},LL:${widget.wordPair.lastLearned},ER:${widget.wordPair.errorStack},"
              "LPF:${widget.wordPair.lastPriorityFactor},TL:${widget.wordPair.totalLearned},W:${widget.wordPair.word1},K:${widget.wordPair.salt}",
              style:
                  const TextStyle(fontSize: 7, color: Colors.black, shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 10,
                ),
              ]),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          print("=================================");
          print("on tap");
          if (!widget.bDeleteMode) {
            print("=================================");
            print("not delete mode");
            if (widget.currentChapter.words.length * 2 + 2 > widget.index) {
              print("=================================");
              print("Focus requested");
              print("index : ${widget.index}");
              widget.changeFocus(widget.index,
                  requestFocus: true, force: false);
            } else if (widget.bShowingWords) {
              print("=================================");
              print("Focus request failed");
              //widget.openWordAdder(context);
            }
          } else {
            if (widget.currentChapter.words.length * 2 > widget.index) {
              WordPair word = widget.currentChapter.words[widget.index ~/ 2];
              widget.deleteWord(word);
            }
          }
        },
        child: _buildCell(),
      ),
    );
  }
}*/

class WordGridTile extends StatelessWidget {
  const WordGridTile({
    Key? key,
    required this.index,
    required this.saveText,
    required this.currentChapter,
    required this.bShowingWords,
    required this.addWord,
    required this.bDeleteMode,
    required this.deleteWord,
    required this.changeFocus,
    required this.bFocused,
    required this.wordAdditionBuffer,
    required this.wordPair,
    required this.text,
    required this.viewMode,
  }) : super(key: key);

  final String text;
  final int index;
  final WordPair wordPair;
  final ViewMode viewMode;

  final void Function(String newText, int index) saveText;
  final void Function(WordPair wordPair) addWord;
  final void Function(WordPair wordPair) deleteWord;
  final void Function(
    int newIndex, {
    bool requestFocus,
    bool force,
  }) changeFocus;

  final Chapter currentChapter;
  final WordPair wordAdditionBuffer;
  final bool bShowingWords;
  final bool bDeleteMode;
  final bool bFocused;

  Widget _buildContent() {
    final favourite = wordPair.favourite!;

    // Define the desired font weight
    const FontWeight fontWeight =
        FontWeight.normal; // Replace with your desired font weight

    Color textCol;
    if (favourite) {
      textCol = Colors.black;
    } else if (bShowingWords) {
      textCol = Colors.black;
    } else {
      textCol = Colors.grey;
    }

    // Use a FittedBox to scale the text to fit within the available space
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: fontWeight,
            color: textCol,
            shadows: favourite
                ? [
                    const Shadow(
                      color: Colors.yellowAccent,
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBox() {
    final favourite = wordPair.favourite!;
    final focused = bFocused;

    Color borderColor;
    double borderSize;
    if (focused) {
      borderColor = Colors.redAccent;
      borderSize = 3;
    } else if (favourite) {
      borderColor = Colors.black;
      borderSize = 0.5;
    } else {
      borderColor = Colors.black;
      borderSize = 0.5;
    }

    return BoxDecoration(
      color: favourite ? Colors.white : Colors.white,
      border: Border.all(
        color: borderColor,
        width: borderSize,
        style: BorderStyle.solid,
      ),
    );
  }

  Widget _buildCell(BuildContext context) {
    // Determine the width and height of the cell
    final cellWidth = MediaQuery.of(context).size.width / 2;
    const cellHeight =
        50.0; // Adjust the aspect ratio based on your requirement

    // Use a ConstrainedBox to limit the cell size
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cellWidth, maxHeight: cellHeight),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(5),
            decoration: _buildBox(),
            child: _buildContent(),
          ),
          if (AppConfig.bDebugMode)
            Text(
              "C:${wordPair.created},E:${wordPair.lastEdit},I:${index},"
              "F:${wordPair.favourite},LL:${wordPair.lastLearned},ER:${wordPair.errorStack},"
              "LPF:${wordPair.lastPriorityFactor},TL:${wordPair.totalLearned},W:${wordPair.word1},K:${wordPair.salt}",
              style:
                  const TextStyle(fontSize: 7, color: Colors.black, shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 10,
                ),
              ]),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          print("=================================");
          print("on tap");
          if (!bDeleteMode) {
            print("=================================");
            print("not delete mode");
            if (currentChapter.words.length * 2 + 2 > index) {
              print("=================================");
              print("Focus requested");
              print("index : ${index}");
              changeFocus(index, requestFocus: true, force: false);
            } else if (bShowingWords) {
              print("=================================");
              print("Focus request failed");
              //widget.openWordAdder(context);
            }
          } else {
            if (currentChapter.words.length * 2 > index) {
              WordPair word = currentChapter.words[index ~/ 2];
              deleteWord(word);
            }
          }
        },
        child: _buildCell(context),
      ),
    );
  }
}
