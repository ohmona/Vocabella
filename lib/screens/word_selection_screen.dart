import 'package:flutter/material.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/widgets/word_modifier_widget.dart';

import '../utils/constants.dart';
import '../models/chapter_model.dart';

class WordSelectionScreenParent extends StatelessWidget {
  const WordSelectionScreenParent({Key? key}) : super(key: key);

  static const routeName = '/words';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WordSelectionScreenArguments;

    return WordSelectionScreen(
      chapter: args.chapter,
      selected: args.selected,
      applyEdit: args.applyEdit,
      originalIndex: args.originalIndex,
    );
  }
}

class WordSelectionScreen extends StatefulWidget {
  const WordSelectionScreen(
      {Key? key,
      required this.chapter,
      required this.selected,
      required this.applyEdit,
      required this.originalIndex})
      : super(key: key);

  final EditedChapter chapter;
  final bool selected;
  final int originalIndex;
  final void Function(int, List<int>) applyEdit;

  @override
  State<WordSelectionScreen> createState() => _WordSelectionScreenState();
}

class _WordSelectionScreenState extends State<WordSelectionScreen> {
  late List<int> excludedIndex;

  void excludeAll() {
    excludedIndex = [];
    for (int i = 0; i < widget.chapter.words.length; i++) {
      excludedIndex.add(i);
    }
  }

  void onExit() {
    widget.applyEdit(widget.originalIndex, excludedIndex);
  }

  void onTileTap(int index) {
    setState(() {
      if (excludedIndex.contains(index)) {
        excludedIndex.remove(index);
      } else {
        excludedIndex.add(index);
      }
    });
  }

  void openSelector(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1), () {
      showDialog<void>(
        context: context,
        builder: (context) {
          return WordModifier(
            applyEdit: (newList) {
              setState(() {
                excludedIndex = newList;
              });
            },
            excludedIndex: excludedIndex,
            size: widget.chapter.words.length,
            list: widget.chapter.words,
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();

    widget.selected
        ? excludedIndex = widget.chapter.excludedIndex
        : excludeAll();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onExit();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select words"),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                openSelector(context);
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                onExit();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [
                firstBgColor.withOpacity(0.5),
                secondBgColor.withOpacity(0.5),
              ],
            ),
          ),
          child: ListView.separated(
            itemCount: widget.chapter.words.length,
            itemBuilder: (context, index) {
              bool bSelected = !excludedIndex.contains(index);

              return GestureDetector(
                onTap: () {
                  onTileTap(index);
                },
                child: Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bSelected
                        ? Color.lerp(
                            firstBgColor,
                            secondBgColor,
                            index / widget.chapter.words.length,
                          )
                        : Color.lerp(
                            firstBgColor.withOpacity(0.3),
                            secondBgColor.withOpacity(0.3),
                            index / widget.chapter.words.length,
                          ),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints.tight(const Size(double.infinity, 100)),
                    child: Text(
                      widget.chapter.words[index].word1,
                      style: bSelected
                          ? const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )
                          : TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 2,
                color: Colors.white.withOpacity(0.5),
              );
            },
          ),
        ),
      ),
    );
  }
}
