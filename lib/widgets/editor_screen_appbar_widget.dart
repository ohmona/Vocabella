import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/chapter_model.dart';

class EditorScreenAppbar extends StatefulWidget {
  const EditorScreenAppbar({
    Key? key,
    required this.currentChapter,
    required this.bShowingWords,
    required this.toggleWords,
    required this.bDeleteMode,
    required this.toggleDeleteMode,
    required this.changeChapterName,
    required this.wordCount,
    required this.bReadOnly,
    required this.toggleReadOnly,
  }) : super(key: key);

  final Chapter currentChapter;
  final bool bShowingWords;
  final bool bDeleteMode;
  final bool bReadOnly;
  final int wordCount;
  final void Function() toggleWords;
  final void Function() toggleDeleteMode;
  final void Function() toggleReadOnly;
  final void Function(String) changeChapterName;

  @override
  State<EditorScreenAppbar> createState() => _EditorScreenAppbarState();
}

class _EditorScreenAppbarState extends State<EditorScreenAppbar> {
  TextEditingController controller = TextEditingController();

  Future<void> openChapterNameEditor(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the new title of the chapter"),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.changeChapterName(controller.text);

                  controller.text = "";
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    openChapterNameEditor(context);
                  },
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    "${widget.currentChapter.name} (${widget.wordCount})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Icon(
                widget.bReadOnly ? Icons.menu_book_rounded : Icons.edit_note,
                color: Colors.white,
              ),
              tooltip: widget.bReadOnly ? "Continue editing" : "Read only",
              onPressed: () {
                widget.toggleReadOnly();
              },
            ),
            IconButton(
              icon: Icon(
                widget.bDeleteMode ? Icons.delete : Icons.add_circle,
                color: Colors.white,
              ),
              tooltip: widget.bDeleteMode ? "Continue editing" : "Remove words",
              onPressed: () {
                if (widget.bShowingWords) {
                  widget.toggleDeleteMode();
                }
              },
            ),
            IconButton(
              icon: Icon(
                widget.bShowingWords ? Icons.edit : Icons.book,
                color: Colors.white,
              ),
              tooltip: widget.bShowingWords
                  ? "Edit examples"
                  : "Edit questions & answers",
              onPressed: widget.toggleWords,
            ),
          ],
        ),
      ),
    );
  }
}
