import 'package:flutter/material.dart';

import '../models/chapter_model.dart';
import '../models/wordpair_model.dart';

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
    required this.changeFocus,
    required this.bFocused,
    required this.wordAdditionBuffer,
  }) : super(key: key);

  final String text;
  final int index;

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

  TextEditingController controller = TextEditingController();
  TextEditingController secondController = TextEditingController();
  FocusNode focusNode = FocusNode();

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
    const cellHeight =
        50.0; // Adjust the aspect ratio based on your requirement

    // Use a ConstrainedBox to limit the cell size
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cellWidth, maxHeight: cellHeight),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: widget.bFocused ? Colors.redAccent : Colors.black,
            width: widget.bFocused ? 3 : 0.5,
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
            if (widget.currentChapter.words.length * 2 + 2 > widget.index) {
              widget.changeFocus(widget.index, requestFocus: true, force: false);
            } else if (widget.bShowingWords) {
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
}
