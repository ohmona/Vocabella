import 'package:flutter/material.dart';

import '../models/chapter_model.dart';

class EditorScreenAppbar extends StatefulWidget {
  const EditorScreenAppbar({
    Key? key,
    required this.currentChapter,
    required this.bShowingWords,
    required this.toggleWords,
    required this.bDeleteMode,
    required this.toggleDeleteMode,
  }) : super(key: key);

  final Chapter currentChapter;
  final bool bShowingWords;
  final bool bDeleteMode;
  final void Function() toggleWords;
  final void Function() toggleDeleteMode;

  @override
  State<EditorScreenAppbar> createState() => _EditorScreenAppbarState();
}

class _EditorScreenAppbarState extends State<EditorScreenAppbar> {

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
                  onPressed: () {},
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    widget.currentChapter.name,
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
                widget.bDeleteMode ? Icons.add_circle : Icons.delete,
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
