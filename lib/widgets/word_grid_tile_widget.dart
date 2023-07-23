import 'package:flutter/material.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

/// TODO open data once the session has started
/// TODO save data into local storage
/// TODO make chapter rename-able

class WordGridTile extends StatefulWidget {
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
  }) : super(key: key);

  final String text;
  final int index;

  final void Function(String newText, int index) saveText;
  final void Function(WordPair wordPair) addWord;
  final void Function(WordPair wordPair) deleteWord;

  final Chapter currentChapter;
  final bool bShowingWords;
  final bool bDeleteMode;

  @override
  State<WordGridTile> createState() => _WordGridTileState();
}

class _WordGridTileState extends State<WordGridTile> {
  late String text;

  TextEditingController controller = TextEditingController();
  TextEditingController secondController = TextEditingController();

  Future<void> openTextEditor(BuildContext context) {
    String originalText = text;
    controller.text = text;
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type new text"),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) {
              text = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                text = originalText;
                Navigator.of(context).pop();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                if (text.isNotEmpty) {
                  // apply new text
                  setState(() {
                    widget.saveText(text, widget.index);
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> openWordAdder(BuildContext context) {
    String text1 = "";
    String text2 = "";

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type new words"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (value) {
                    text1 = value;
                  },
                ),
                TextField(
                  onChanged: (value) {
                    text2 = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                // apply new text
                setState(() {
                  if (text1.isNotEmpty && text2.isNotEmpty) {
                    WordPair wordPair = WordPair(word1: text1, word2: text2);
                    widget.addWord(wordPair);
                    Navigator.of(context).pop();
                  }
                });
              },
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  void updateText() {
    final int wordPairIndex = widget.index ~/
        2; // Update this line to calculate the wordPairIndex correctly

    if (wordPairIndex > widget.currentChapter.words.length - 1) {
      text = "";
      return;
    }

    // Get the WordPair from the currentChapter based on the wordPairIndex
    WordPair wordPair = widget.currentChapter.words[wordPairIndex];

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
    // Define the desired font weight
    const FontWeight fontWeight =
        FontWeight.normal; // Replace with your desired font weight

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
            color: widget.bShowingWords ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCell() {
    // Determine the width and height of the cell
    final cellWidth = MediaQuery.of(context).size.width / 2;
    final cellHeight = cellWidth /
        (widget.bShowingWords
            ? 3
            : 2); // Adjust the aspect ratio based on your requirement

    // Use a ConstrainedBox to limit the cell size
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cellWidth, maxHeight: cellHeight),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onTap: () {
          if (!widget.bDeleteMode) {
            if (widget.currentChapter.words.length * 2 > widget.index) {
              openTextEditor(context);
            } else if (widget.bShowingWords) {
              openWordAdder(context);
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
}
