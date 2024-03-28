
import 'package:flutter/material.dart';
import 'package:vocabella/utils/configuration.dart';

import '../screens/editor_screen.dart';

enum FrameType {
  topLeft,
  topRight,
  middleLeft,
  middleRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  none,
}

class WordGridTile extends StatelessWidget {
  const WordGridTile({
    Key? key,
    required this.index,
    required this.saveText,
    required this.bShowingWords,
    required this.bDeleteMode,
    required this.changeFocus,
    required this.bFocused,
    required this.displayingWord,
    required this.text,
    required this.viewMode,
    required this.listSize,
    required this.toggleSelect,
    required this.focusMode,
    required this.toggleFocusSelectMode,
    required this.selectionList,
  }) : super(key: key);

  final String text;
  final int index;
  final DisplayingWord displayingWord;
  final ViewMode viewMode;
  final SelectionList selectionList;

  final void Function(String newText, int index) saveText;
  final void Function(int newIndex, {bool requestFocus, bool force})
      changeFocus;
  final void Function(int) toggleSelect;
  final void Function() toggleFocusSelectMode;

  final int listSize;
  final bool bShowingWords;
  final bool bDeleteMode;
  final bool bFocused;
  final bool focusMode;

  bool isLeft() => index % 2 == 0;

  Color _getTextColor() {
    final favourite = displayingWord.wordPair.favourite!;
    if (favourite || bShowingWords) {
      return Colors.black;
    }
    return Colors.grey;
  }

  Widget _buildContent() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: _getTextColor(),
            shadows: displayingWord.wordPair.favourite!
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

  FrameType _getFrameType() {
    if (!selectionList.isSelected(index ~/ 2)) {
      return FrameType.none;
    }

    bool isSelectedAbove = selectionList.isSelected(index ~/ 2 - 1);
    bool isSelectedBelow = selectionList.isSelected(index ~/ 2 + 1);

    if (isLeft()) {
      if (isSelectedAbove && isSelectedBelow) return FrameType.middleLeft;
      if (isSelectedAbove) return FrameType.bottomLeft;
      if (isSelectedBelow) return FrameType.topLeft;
      return FrameType.left;
    } else {
      if (isSelectedAbove && isSelectedBelow) return FrameType.middleRight;
      if (isSelectedAbove) return FrameType.bottomRight;
      if (isSelectedBelow) return FrameType.topRight;
      return FrameType.right;
    }
  }

  BoxDecoration _buildBox() {
    const BorderSide defaultSide = BorderSide(color: Colors.black, width: 0.5);
    const BorderSide focusSide = BorderSide(color: Colors.redAccent, width: 3);
    const BorderSide selectSide = BorderSide(color: Colors.purple, width: 3);
    FrameType frameType = _getFrameType();

    BorderSide top = defaultSide;
    BorderSide bottom = defaultSide;
    BorderSide left = defaultSide;
    BorderSide right = defaultSide;

    switch (frameType) {
      case FrameType.none:
        break;
      case FrameType.topLeft:
        left = selectSide;
        top = selectSide;
        break;
      case FrameType.middleLeft:
        left = selectSide;
        break;
      case FrameType.bottomLeft:
        left = selectSide;
        bottom = selectSide;
        break;
      case FrameType.left:
        left = selectSide;
        bottom = selectSide;
        top = selectSide;
        break;
      case FrameType.topRight:
        right = selectSide;
        top = selectSide;
        break;
      case FrameType.middleRight:
        right = selectSide;
        break;
      case FrameType.bottomRight:
        right = selectSide;
        bottom = selectSide;
        break;
      case FrameType.right:
        right = selectSide;
        bottom = selectSide;
        top = selectSide;
        break;
    }

    if (bFocused) {
      top = focusSide;
      bottom = focusSide;
      left = focusSide;
      right = focusSide;
    }

    return BoxDecoration(
      color: Colors.white,
      border: Border(top: top, bottom: bottom, left: left, right: right),
    );
  }

  Widget _buildCell(BuildContext context) {
    final double cellWidth = MediaQuery.of(context).size.width / 2;
    const double cellHeight =
        50.0; // Adjust the aspect ratio based on your requirement

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
              "C:${displayingWord.wordPair.created},E:${displayingWord.wordPair.lastEdit},I:${index},"
              "F:${displayingWord.wordPair.favourite},LL:${displayingWord.wordPair.lastLearned},ER:${displayingWord.wordPair.errorStack},"
              "LPF:${displayingWord.wordPair.lastPriorityFactor},TL:${displayingWord.wordPair.totalLearned},W:${displayingWord.wordPair.word1},K:${displayingWord.wordPair.salt}",
              style: const TextStyle(
                  fontSize: 7,
                  color: Colors.black,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onTap: () => _handleTap(),
        child: _buildCell(context),
      ),
    );
  }

  void _handleTap() {
    if (focusMode) {
      if (listSize * 2 + 2 > index) {
        changeFocus(index, requestFocus: true, force: false);
      }
    } else {
      toggleSelect(index ~/ 2);
    }
  }
}
